import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'heartbeat_server.dart';
import 'mailru_cloud_service.dart';
import 'event_logger.dart';
import '../../application/models/presence_settings.dart';
import '../local/secure_storage/encrypted_keys.dart';

/// Статус присутствия для одного телефона.
enum PhonePresenceStatus {
  home, // дома
  away, // ушёл
  unknown, // неизвестно
}

/// Источник определения статуса.
enum PresenceSource {
  heartbeat, // HTTP heartbeat (Wi-Fi, точно дома)
  cloud, // Mail.ru Cloud
  unknown, // нет данных
}

class PhonePresence {
  final String phoneId;
  final String phoneName;
  PhonePresenceStatus status;
  PresenceSource source;
  double? lat;
  double? lng;
  int? battery;
  DateTime? lastSeen;
  bool viaWifi;
  double? distanceFromHome;

  PhonePresence({
    required this.phoneId,
    required this.phoneName,
    this.status = PhonePresenceStatus.unknown,
    this.source = PresenceSource.unknown,
    this.lat,
    this.lng,
    this.battery,
    this.lastSeen,
    this.viaWifi = false,
    this.distanceFromHome,
  });
}

class PresenceDetector {
  Timer? _timer;
  final Map<String, PhonePresence> _phones = {};
  PresenceSettings? _settings;
  bool _running = false;

  bool get isRunning => _running;

  Map<String, PhonePresence> get phones => _phones;

  void Function(
      String phoneId,
      PhonePresenceStatus oldStatus,
      PhonePresenceStatus newStatus,
      )? onStatusChanged;

  bool get isAnyoneHome {
    return _phones.values.any(
          (phone) => phone.status == PhonePresenceStatus.home,
    );
  }

  bool get isNobodyHome {
    return _phones.isNotEmpty &&
        _phones.values.every(
              (phone) => phone.status == PhonePresenceStatus.away,
        );
  }

  Future<void> start(PresenceSettings settings) async {
    if (_running) {
      debugPrint('⚠️ PresenceDetector уже запущен');
      return;
    }

    _settings = settings;
    _phones.clear();

    for (final phone in settings.phones.where((phone) => phone.enabled)) {
      _phones[phone.phoneId] = PhonePresence(
        phoneId: phone.phoneId,
        phoneName: phone.phoneName,
      );
    }

    _running = true;
    await _checkAll();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => _checkAll(),
    );

    debugPrint('👁 PresenceDetector запущен (${_phones.length} телефонов)');
  }

  Future<void> _checkAll() async {
    if (_settings == null) return;

    final entries = List<MapEntry<String, PhonePresence>>.from(
      _phones.entries,
    );

    for (final entry in entries) {
      if (!_running) return;

      final phone = entry.value;
      if (!_phones.containsKey(phone.phoneId)) continue;

      final oldStatus = phone.status;
      final oldSource = phone.source;

      await _checkPhone(phone);

      final statusChanged = phone.status != oldStatus;
      final sourceChanged = phone.source != oldSource;

      if (statusChanged) {
        onStatusChanged?.call(
          phone.phoneId,
          oldStatus,
          phone.status,
        );
      }

      // Записываем изменение статуса, а также смену источника известного
      // статуса: например, «дома (облако) → дома (локальный heartbeat)».
      // Повторные проверки без изменений в журнал не попадают.
      final shouldLog =
          statusChanged ||
              (sourceChanged && phone.status != PhonePresenceStatus.unknown);

      if (shouldLog) {
        final oldDescription = _describePresence(oldStatus, oldSource);
        final newDescription = _describePresence(phone.status, phone.source);
        final transition = '$oldDescription → $newDescription';

        try {
          await EventLogger.log(
            event: 'Присутствие: ${phone.phoneName}: $transition',
            deviceId: phone.phoneId,
            deviceName: phone.phoneName,
            value: transition,
          );
        } catch (error, stackTrace) {
          debugPrint(
            '❌ Не удалось записать изменение присутствия '
                'для ${phone.phoneName}: $error\n$stackTrace',
          );
        }
      }
    }

    _logStatus();
  }

  Future<void> _checkPhone(PhonePresence phone) async {
    // 1. Локальный heartbeat — Companion в Wi-Fi сети.
    if (HeartbeatServer.isAlive(phone.phoneId, maxAgeSec: 90)) {
      final heartbeat = HeartbeatServer.getHeartbeat(phone.phoneId);

      phone.status = PhonePresenceStatus.home;
      phone.source = PresenceSource.heartbeat;
      phone.viaWifi = true;
      phone.battery = heartbeat?.battery;
      phone.lastSeen = DateTime.now();
      phone.distanceFromHome = 0;
      phone.lat = null;
      phone.lng = null;

      debugPrint('🏠 ${phone.phoneName}: дома (HTTP heartbeat)');
      return;
    }

    // 2. Нет heartbeat — читаем облако.
    final heartbeat = await _checkCloud(phone.phoneId);

    if (heartbeat == null) {
      phone.status = PhonePresenceStatus.unknown;
      phone.source = PresenceSource.unknown;
      phone.viaWifi = false;
      phone.distanceFromHome = null;

      debugPrint('❓ ${phone.phoneName}: unknown (нет данных)');
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final timestamp = (heartbeat['ts'] as num?)?.toInt() ?? 0;
    final age = now - timestamp;

// Читаем статус безопасно: убираем пробелы и переводим в нижний регистр.
    final rawStatus = heartbeat['status'];
    final cloudStatus = rawStatus
        ?.toString()
        .trim()
        .toLowerCase() ??
        'unknown';

    final battery = (heartbeat['battery'] as num?)?.toInt();

    phone.battery = battery;

    debugPrint(
      '[PRESENCE CLOUD] '
          'rawStatus=${jsonEncode(rawStatus)}, '
          'normalized="$cloudStatus", '
          'lat=${heartbeat['lat']}, '
          'lng=${heartbeat['lng']}, '
          'age=${age}ms',
    );

    // 3. Данные старше 10 минут — статус неизвестен.
    if (age > 10 * 60 * 1000) {
      phone.status = PhonePresenceStatus.unknown;
      phone.source = PresenceSource.cloud;
      phone.viaWifi = false;
      phone.distanceFromHome = null;

      debugPrint('❓ ${phone.phoneName}: unknown (данные старше 10 мин)');
      return;
    }

    // 4. Читаем статус от Companion.
    switch (cloudStatus) {
      case 'home':
        final lat = (heartbeat['lat'] as num?)?.toDouble();
        final lng = (heartbeat['lng'] as num?)?.toDouble();

        phone.status = PhonePresenceStatus.home;
        phone.source = PresenceSource.cloud;
        phone.viaWifi = false;
        phone.lat = lat;
        phone.lng = lng;

        if (lat != null &&
            lng != null &&
            _settings!.homeLat != 0 &&
            _settings!.homeLng != 0) {
          phone.distanceFromHome = distance(
            lat,
            lng,
            _settings!.homeLat,
            _settings!.homeLng,
          );

          debugPrint(
            '🏠 ${phone.phoneName}: дома (cloud, GPS '
                '${phone.distanceFromHome!.round()} м)',
          );
        } else {
          phone.distanceFromHome = null;
          debugPrint(
            '🏠 ${phone.phoneName}: дома, GPS координаты недоступны',
          );
        }
        break;

      case 'away':
        final lat = (heartbeat['lat'] as num?)?.toDouble();
        final lng = (heartbeat['lng'] as num?)?.toDouble();

        phone.lat = lat;
        phone.lng = lng;
        phone.source = PresenceSource.cloud;
        phone.viaWifi = false;

        if (lat != null &&
            lng != null &&
            _settings!.homeLat != 0 &&
            _settings!.homeLng != 0) {
          final distanceFromHome = distance(
            lat,
            lng,
            _settings!.homeLat,
            _settings!.homeLng,
          );

          phone.distanceFromHome = distanceFromHome;

          if (distanceFromHome <= _settings!.homeRadius) {
            phone.status = PhonePresenceStatus.home;
            debugPrint(
              '🏠 ${phone.phoneName}: рядом с домом '
                  '(GPS, ${distanceFromHome.round()} м)',
            );
          } else {
            phone.status = PhonePresenceStatus.away;
            debugPrint(
              '🚶 ${phone.phoneName}: ушёл '
                  '(GPS, ${distanceFromHome.round()} м)',
            );
          }
        } else {
          phone.status = PhonePresenceStatus.away;
          phone.distanceFromHome = null;
          debugPrint('🚶 ${phone.phoneName}: ушёл (без GPS)');
        }
        break;

      default:
        phone.status = PhonePresenceStatus.unknown;
        phone.source = PresenceSource.cloud;
        phone.viaWifi = false;
        phone.distanceFromHome = null;

        debugPrint(
          '❓ ${phone.phoneName}: неизвестный cloud status '
              '(raw=${jsonEncode(rawStatus)}, normalized="$cloudStatus")',
        );
    }
  }

  Future<Map<String, dynamic>?> _checkCloud(String phoneId) async {
    try {
      final keys = EncryptedKeys();
      final login = await keys.getCloudLogin();
      final password = await keys.getCloudPassword();

      if (login == null || password == null) return null;

      final service = MailruCloudService(
        login: login,
        password: password,
      );

      final content = await service.downloadPresence(phoneId: phoneId);

      if (content == null) return null;

      return jsonDecode(content) as Map<String, dynamic>;
    } catch (error) {
      debugPrint('❌ Ошибка чтения облака: $error');
      return null;
    }
  }

  String _describePresence(
      PhonePresenceStatus status,
      PresenceSource source,
      ) {
    final statusText = switch (status) {
      PhonePresenceStatus.home => 'дома',
      PhonePresenceStatus.away => 'ушёл',
      PhonePresenceStatus.unknown => 'неизвестно',
    };

    final sourceText = switch (source) {
      PresenceSource.heartbeat => 'локальный heartbeat',
      PresenceSource.cloud => 'облако',
      PresenceSource.unknown => 'источник неизвестен',
    };

    return '$statusText ($sourceText)';
  }

  double distance(
      double lat1,
      double lng1,
      double lat2,
      double lng2,
      ) {
    const earthRadius = 6371000.0;

    final deltaLat = _toRadians(lat2 - lat1);
    final deltaLng = _toRadians(lng2 - lng1);

    final a = 0.5 -
        0.5 * math.cos(deltaLat) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            (0.5 - 0.5 * math.cos(deltaLng));

    return earthRadius * 2 * math.asin(math.sqrt(a));
  }

  double _toRadians(double degrees) => degrees * math.pi / 180.0;

  void _logStatus() {
    final homeCount = _phones.values
        .where((phone) => phone.status == PhonePresenceStatus.home)
        .length;

    final awayCount = _phones.values
        .where((phone) => phone.status == PhonePresenceStatus.away)
        .length;

    final unknownCount = _phones.values
        .where((phone) => phone.status == PhonePresenceStatus.unknown)
        .length;

    debugPrint(
      '📊 Статус: дома=$homeCount, ушёл=$awayCount, '
          'неизвестно=$unknownCount',
    );
  }

  void stop() {
    _timer?.cancel();
    _running = false;
    debugPrint('👁 PresenceDetector остановлен');
  }
}