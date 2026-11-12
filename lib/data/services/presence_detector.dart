import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'heartbeat_server.dart';
import 'mailru_cloud_service.dart';
import '../../application/models/presence_settings.dart';
import '../local/secure_storage/encrypted_keys.dart';

/// Статус присутствия для одного телефона.
enum PhonePresenceStatus {
  home,     // дома
  away,     // ушёл
  unknown,  // неизвестно
}

/// Источник определения статуса.
enum PresenceSource {
  heartbeat,   // HTTP heartbeat (Wi-Fi, точно дома)
  cloud,       // Mail.ru Cloud (может быть дома/рядом/ушёл)
  unknown,     // нет данных
}

class PhonePresence {
  final String phoneId;
  final String phoneName;
  PhonePresenceStatus status;
  PresenceSource source;        // ← источник данных
  double? lat;
  double? lng;
  int? battery;
  DateTime? lastSeen;
  bool viaWifi;
  double? distanceFromHome;     // ← расстояние до дома в метрах

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
    return _phones.values.any((p) => p.status == PhonePresenceStatus.home);
  }

  bool get isNobodyHome {
    return _phones.isNotEmpty &&
        _phones.values.every((p) => p.status == PhonePresenceStatus.away);
  }

  Future<void> start(PresenceSettings settings) async {
    if (_running) {
      debugPrint('⚠️ PresenceDetector уже запущен');
      return;
    }

    _settings = settings;
    _phones.clear();

    for (final phone in settings.phones.where((p) => p.enabled)) {
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

    final entries = List<MapEntry<String, PhonePresence>>.from(_phones.entries);

    for (final entry in entries) {
      if (!_running) return;
      final phone = entry.value;
      final oldStatus = phone.status;

      if (!_phones.containsKey(phone.phoneId)) continue;

      await _checkPhone(phone);

      if (phone.status != oldStatus) {
        onStatusChanged?.call(phone.phoneId, oldStatus, phone.status);
      }
    }

    _logStatus();
  }

  Future<void> _checkPhone(PhonePresence phone) async {
    // ═══ 1. Локальный heartbeat — Companion в Wi-Fi сети ═══
    if (HeartbeatServer.isAlive(phone.phoneId, maxAgeSec: 90)) {
      final hb = HeartbeatServer.getHeartbeat(phone.phoneId);
      phone.status = PhonePresenceStatus.home;
      phone.source = PresenceSource.heartbeat;
      phone.viaWifi = true;
      phone.battery = hb?.battery;
      phone.lastSeen = DateTime.now();
      phone.distanceFromHome = 0;
      phone.lat = null;
      phone.lng = null;
      debugPrint('🏠 ${phone.phoneName}: дома (HTTP heartbeat)');
      return;
    }

    // ═══ 2. Нет heartbeat — читаем облако ═══
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
    final ts = (heartbeat['ts'] as num?)?.toInt() ?? 0;
    final age = now - ts;
    final status = heartbeat['status'] as String? ?? 'unknown';
    final battery = (heartbeat['battery'] as num?)?.toInt();
    phone.battery = battery;

    // ═══ 3. Данные старше 10 мин → unknown ═══
    if (age > 10 * 60 * 1000) {
      phone.status = PhonePresenceStatus.unknown;
      phone.source = PresenceSource.cloud;
      phone.viaWifi = false;
      phone.distanceFromHome = null;
      debugPrint('❓ ${phone.phoneName}: unknown (данные старше 10 мин)');
      return;
    }

    // ═══ 4. Читаем статус от Companion ═══
    switch (status) {
      case 'home':
      // Companion говорит "дома", но без Wi-Fi (возможно, GPS)
        phone.status = PhonePresenceStatus.home;
        phone.source = PresenceSource.cloud;
        phone.viaWifi = false;
        phone.distanceFromHome = 0;
        debugPrint('🏠 ${phone.phoneName}: дома (cloud)');
        break;

      case 'away':
        final lat = (heartbeat['lat'] as num?)?.toDouble();
        final lng = (heartbeat['lng'] as num?)?.toDouble();
        phone.lat = lat;
        phone.lng = lng;
        phone.source = PresenceSource.cloud;
        phone.viaWifi = false;

        // Проверяем GPS в радиусе
        if (lat != null &&
            lng != null &&
            _settings!.homeLat != 0 &&
            _settings!.homeLng != 0) {
          final dist = distance(
            lat, lng, _settings!.homeLat, _settings!.homeLng,
          );
          phone.distanceFromHome = dist;

          if (dist <= _settings!.homeRadius) {
            // Companion сказал "away", но GPS в радиусе
            // Это "рядом с домом" — на границе зоны
            phone.status = PhonePresenceStatus.home;
            debugPrint(
              '🏠 ${phone.phoneName}: рядом с домом '
                  '(GPS, ${dist.round()} м)',
            );
          } else {
            phone.status = PhonePresenceStatus.away;
            debugPrint(
              '🚶 ${phone.phoneName}: ушёл '
                  '(GPS, ${dist.round()} м)',
            );
          }
        } else {
          // Нет координат → доверяем Companion
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
        debugPrint('❓ ${phone.phoneName}: unknown (status=$status)');
    }
  }

  Future<Map<String, dynamic>?> _checkCloud(String phoneId) async {
    try {
      final keys = EncryptedKeys();
      final login = await keys.getCloudLogin();
      final password = await keys.getCloudPassword();

      if (login == null || password == null) return null;

      final service = MailruCloudService(login: login, password: password);
      final content = await service.downloadPresence(phoneId: phoneId);

      if (content == null) return null;
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Ошибка чтения облака: $e');
      return null;
    }
  }

  double distance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = (0.5 -
        0.5 * math.cos(dLat) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            (0.5 - 0.5 * math.cos(dLng)));
    return earthRadius * 2 * math.asin(math.sqrt(a));
  }

  double _toRadians(double deg) => deg * math.pi / 180.0;

  void _logStatus() {
    final homeCount =
        _phones.values.where((p) => p.status == PhonePresenceStatus.home).length;
    final awayCount =
        _phones.values.where((p) => p.status == PhonePresenceStatus.away).length;
    final unknownCount = _phones.values
        .where((p) => p.status == PhonePresenceStatus.unknown)
        .length;

    debugPrint(
        '📊 Статус: дома=$homeCount, ушёл=$awayCount, неизвестно=$unknownCount');
  }

  void stop() {
    _timer?.cancel();
    _running = false;
    debugPrint('👁 PresenceDetector остановлен');
  }
}