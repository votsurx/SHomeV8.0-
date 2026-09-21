import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'mailru_cloud_service.dart';
import '../../application/models/presence_settings.dart';

/// Статус присутствия для одного телефона
enum PhonePresenceStatus {
  home,     // дома (Wi-Fi или GPS)
  away,     // ушёл
  unknown,  // неизвестно
}

class PhonePresence {
  final String phoneId;
  final String phoneName;
  PhonePresenceStatus status;
  double? lat;
  double? lng;
  int? battery;
  DateTime? lastSeen;
  bool viaWifi;

  PhonePresence({
    required this.phoneId,
    required this.phoneName,
    this.status = PhonePresenceStatus.unknown,
    this.lat,
    this.lng,
    this.battery,
    this.lastSeen,
    this.viaWifi = false,
  });
}

/// Определяет присутствие телефонов дома
class PresenceDetector {
  Timer? _timer;
  final Map<String, PhonePresence> _phones = {};
  PresenceSettings? _settings;
  bool _running = false;

  bool get isRunning => _running;
  Map<String, PhonePresence> get phones => _phones;

  /// Общий статус дома
  bool get isAnyoneHome {
    return _phones.values.any((p) => p.status == PhonePresenceStatus.home);
  }

  bool get isNobodyHome {
    return _phones.isNotEmpty &&
        _phones.values.every((p) => p.status == PhonePresenceStatus.away);
  }

  /// Запускает отслеживание
  Future<void> start(PresenceSettings settings) async {
    if (_running) return;

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

  /// Проверяет все телефоны
  Future<void> _checkAll() async {
    if (_settings == null) return;

    for (final entry in _phones.entries) {
      final phone = entry.value;
      final settings = _settings!.phones.firstWhere(
            (p) => p.phoneId == phone.phoneId,
        orElse: () => PresencePhone(
          phoneId: phone.phoneId,
          phoneName: phone.phoneName,
        ),
      );

      await _checkPhone(phone, settings);
    }

    _logStatus();
  }

  Future<void> _checkPhone(PhonePresence phone, PresencePhone settings) async {
    // 1. Пробуем Wi-Fi ping
    if (settings.ip.isNotEmpty) {
      final wifiOk = await _ping(settings.ip);
      if (wifiOk) {
        phone.status = PhonePresenceStatus.home;
        phone.viaWifi = true;
        phone.lastSeen = DateTime.now();
        debugPrint('🏠 ${phone.phoneName}: дома (Wi-Fi)');
        return;
      }
    }

    // 2. Пробуем Mail.ru Cloud
    final cloudData = await _checkCloud(phone.phoneId);
    if (cloudData != null) {
      final lat = (cloudData['lat'] as num?)?.toDouble();
      final lng = (cloudData['lng'] as num?)?.toDouble();
      final ts = cloudData['ts'] as int?;
      final battery = cloudData['battery'] as int?;

      phone.lat = lat;
      phone.lng = lng;
      phone.battery = battery;

      // Проверяем, свежие ли данные
      if (ts != null) {
        final age = DateTime.now().millisecondsSinceEpoch - ts;
        final ageMin = age ~/ 60000;

        if (ageMin > _settings!.awayTimeoutMin) {
          phone.status = PhonePresenceStatus.away;
          phone.viaWifi = false;
          debugPrint('🚶 ${phone.phoneName}: ушёл (данные устарели: $ageMin мин)');
          return;
        }
      }

      // Проверяем координаты
      if (lat != null &&
          lng != null &&
          _settings!.homeLat != 0 &&
          _settings!.homeLng != 0) {
        final distance = _distance(
          lat,
          lng,
          _settings!.homeLat,
          _settings!.homeLng,
        );

        if (distance <= _settings!.homeRadius) {
          phone.status = PhonePresenceStatus.home;
          phone.viaWifi = false;
          phone.lastSeen = DateTime.now();
          debugPrint('🏠 ${phone.phoneName}: дома (GPS, ${distance.round()} м)');
          return;
        } else {
          phone.status = PhonePresenceStatus.away;
          phone.viaWifi = false;
          debugPrint('🚶 ${phone.phoneName}: ушёл (GPS, ${distance.round()} м)');
          return;
        }
      } else {
        // Нет координат — считаем, что дома (если данные свежие)
        phone.status = PhonePresenceStatus.home;
        phone.viaWifi = false;
        phone.lastSeen = DateTime.now();
        debugPrint('🏠 ${phone.phoneName}: дома (по свежим данным)');
        return;
      }
    }

    // 3. Нет данных — неизвестно
    phone.status = PhonePresenceStatus.unknown;
    phone.viaWifi = false;
    debugPrint('❓ ${phone.phoneName}: неизвестно');
  }

  Future<Map<String, dynamic>?> _checkCloud(String phoneId) async {
    try {
      const storage = FlutterSecureStorage();
      final login = await storage.read(key: 'mailru_login');
      final password = await storage.read(key: 'mailru_password');

      if (login == null || password == null) return null;
      if (_settings == null) return null;

      final service = MailruCloudService(login: login, password: password);
      final content = await service.downloadPresence(
        pairId: _settings!.pairId,
        phoneId: phoneId,
      );

      if (content == null) return null;
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Ошибка чтения облака: $e');
      return null;
    }
  }

  Future<bool> _ping(String ip) async {
    try {
      final result = await Process.run(
        'ping',
        ['-c', '1', '-W', '2', ip],
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  double _distance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0; // метры
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
    final unknownCount =
        _phones.values.where((p) => p.status == PhonePresenceStatus.unknown).length;

    debugPrint(
        '📊 Статус: дома=$homeCount, ушёл=$awayCount, неизвестно=$unknownCount');
    debugPrint('🏠 Дома кто-то есть: $isAnyoneHome');
    debugPrint('🚫 Дома никого: $isNobodyHome');
  }

  void stop() {
    _timer?.cancel();
    _running = false;
    debugPrint('👁 PresenceDetector остановлен');
  }
}