import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'heartbeat_server.dart';
import 'mailru_cloud_service.dart';
import '../../application/models/presence_settings.dart';
import '../local/secure_storage/encrypted_keys.dart';

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

  /// Callback при изменении статуса телефона.
  void Function(
      String phoneId,
      PhonePresenceStatus oldStatus,
      PhonePresenceStatus newStatus,
      )? onStatusChanged;

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

  /// Проверяет все телефоны
  Future<void> _checkAll() async {
    if (_settings == null) return;

    final entries = List<MapEntry<String, PhonePresence>>.from(_phones.entries);

    for (final entry in entries) {
      if (!_running) return;
      final phone = entry.value;
      final oldStatus = phone.status;
      final settings = _settings!.phones.firstWhere(
            (p) => p.phoneId == phone.phoneId,
        orElse: () => PresencePhone(
          phoneId: phone.phoneId,
          phoneName: phone.phoneName,
        ),
      );

      if (!_phones.containsKey(phone.phoneId)) continue;

      await _checkPhone(phone, settings);

      // Уведомляем об изменении
      if (phone.status != oldStatus) {
        onStatusChanged?.call(phone.phoneId, oldStatus, phone.status);
      }
    }

    _logStatus();
  }

  Future<void> _checkPhone(PhonePresence phone, PresencePhone settings) async {
    // ─── 1. Проверяем локальный heartbeat ───
    if (HeartbeatServer.isAlive(phone.phoneId, maxAgeSec: 90)) {
      final hb = HeartbeatServer.getHeartbeat(phone.phoneId);
      phone.status = PhonePresenceStatus.home;
      phone.viaWifi = true;
      phone.battery = hb?.battery;
      phone.lastSeen = DateTime.now();
      debugPrint('🏠 ${phone.phoneName}: дома (HTTP heartbeat)');
      return;
    }

    // ─── 2. Нет локального heartbeat > 90 сек — читаем облако ───
    final heartbeat = await _checkCloud(phone.phoneId);

    if (heartbeat == null) {
      phone.status = PhonePresenceStatus.unknown;
      phone.viaWifi = false;
      debugPrint('❓ ${phone.phoneName}: unknown (нет данных)');
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final ts = (heartbeat['ts'] as num?)?.toInt() ?? 0;
    final age = now - ts;
    final status = heartbeat['status'] as String? ?? 'unknown';

    // ─── 3. Данные старше 10 мин — unknown ───
    if (age > 10 * 60 * 1000) {
      phone.status = PhonePresenceStatus.unknown;
      phone.viaWifi = false;
      debugPrint('❓ ${phone.phoneName}: unknown (данные старше 10 мин)');
      return;
    }

    // ─── 4. Читаем статус от Companion ───
    switch (status) {
      case 'home':
        phone.status = PhonePresenceStatus.home;
        phone.viaWifi = false;
        debugPrint('🏠 ${phone.phoneName}: дома (heartbeat home)');
        break;

      case 'away':
        final lat = (heartbeat['lat'] as num?)?.toDouble();
        final lng = (heartbeat['lng'] as num?)?.toDouble();
        phone.status = PhonePresenceStatus.away;
        phone.viaWifi = false;
        phone.lat = lat;
        phone.lng = lng;
        debugPrint('🚶 ${phone.phoneName}: ушёл (heartbeat away)');
        break;

      default:
        phone.status = PhonePresenceStatus.unknown;
        phone.viaWifi = false;
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