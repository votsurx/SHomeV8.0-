import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../application/models/presence_settings.dart';
import '../../domain/services/presence_cloud_reader.dart';
import '../local/secure_storage/encrypted_keys.dart';
import 'event_logger.dart';
import 'heartbeat_server.dart';
import 'mailru_cloud_service.dart';

/// Фактический статус присутствия одного телефона.
enum PhonePresenceStatus {
  home,
  away,
  unknown,
}

/// Источник последнего определённого статуса.
enum PresenceSource {
  heartbeat,
  cloud,
  unknown,
}

/// Доступность облака в последнем полном цикле проверки.
enum PresenceCloudAvailability {
  /// Облачные данные не запрашивались, например телефон найден по heartbeat.
  notChecked,

  /// Облачные запросы завершились без ошибки соединения.
  available,

  /// Хотя бы один облачный запрос завершился ошибкой соединения или авторизации.
  unavailable,
}

/// Данные свежего heartbeat, необходимые детектору.
class PresenceHeartbeatData {
  const PresenceHeartbeatData({
    required this.timestamp,
    this.battery,
  });

  final DateTime timestamp;
  final int? battery;
}

/// Неизменяемое представление телефона для результата полного цикла.
class PresencePhoneSnapshot {
  const PresencePhoneSnapshot({
    required this.phoneId,
    required this.phoneName,
    required this.status,
    required this.source,
    required this.viaWifi,
    this.lat,
    this.lng,
    this.battery,
    this.lastSeen,
    this.distanceFromHome,
  });

  final String phoneId;
  final String phoneName;
  final PhonePresenceStatus status;
  final PresenceSource source;
  final bool viaWifi;
  final double? lat;
  final double? lng;
  final int? battery;
  final DateTime? lastSeen;
  final double? distanceFromHome;
}

/// Снимок результатов проверки всех включённых телефонов.
class PresenceCycleResult {
  PresenceCycleResult({
    required Map<String, PresencePhoneSnapshot> phones,
    required this.cloudAvailability,
    required this.checkedAt,
  }) : phones = Map.unmodifiable(phones);

  final Map<String, PresencePhoneSnapshot> phones;
  final PresenceCloudAvailability cloudAvailability;
  final DateTime checkedAt;

  bool get cloudAvailable =>
      cloudAvailability == PresenceCloudAvailability.available;

  bool get hasHome => phones.values.any(
        (phone) => phone.status == PhonePresenceStatus.home,
  );

  bool get allAway =>
      phones.isNotEmpty &&
          phones.values.every(
                (phone) => phone.status == PhonePresenceStatus.away,
          );

  bool get hasUnknown => phones.values.any(
        (phone) => phone.status == PhonePresenceStatus.unknown,
  );

  List<PresencePhoneSnapshot> get unknownPhones => phones.values
      .where((phone) => phone.status == PhonePresenceStatus.unknown)
      .toList(growable: false);
}

/// Зависимости для тестирования и подмены источников.
///
/// В production heartbeat читается из [HeartbeatServer], облако — через
/// [MailruCloudService]. В тестах можно передать свои реализации.
typedef PresenceHeartbeatLookup = PresenceHeartbeatData? Function(
    String phoneId,
    );

typedef PresenceClock = DateTime Function();

class PhonePresence {
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

  PresencePhoneSnapshot toSnapshot() {
    return PresencePhoneSnapshot(
      phoneId: phoneId,
      phoneName: phoneName,
      status: status,
      source: source,
      viaWifi: viaWifi,
      lat: lat,
      lng: lng,
      battery: battery,
      lastSeen: lastSeen,
      distanceFromHome: distanceFromHome,
    );
  }
}

class PresenceDetector {
  PresenceDetector({
    PresenceHeartbeatLookup? heartbeatLookup,
    PresenceCloudReader? cloudReader,
    PresenceClock? clock,
    Duration? checkInterval = const Duration(seconds: 30),
    this.heartbeatMaxAge = const Duration(seconds: 90),
    this.cloudMaxAge = const Duration(minutes: 10),
    this.gpsOutsideMargin = 30,
  })  : _heartbeatLookup = heartbeatLookup ?? _readHeartbeat,
        _cloudReader = cloudReader,
        _clock = clock ?? DateTime.now,
        _checkInterval = checkInterval;

  /// Дополнительный запас за радиусом участка, в метрах.
  ///
  /// Телефон считается уверенно снаружи, только если расстояние с учётом
  /// погрешности GPS больше радиуса участка плюс этот запас.
  final double gpsOutsideMargin;

  final Duration heartbeatMaxAge;
  final Duration cloudMaxAge;

  final PresenceHeartbeatLookup _heartbeatLookup;
  final PresenceCloudReader? _cloudReader;
  final PresenceClock _clock;
  final Duration? _checkInterval;

  Timer? _timer;
  final Map<String, PhonePresence> _phones = {};

  PresenceSettings? _settings;
  bool _running = false;
  bool _checkInProgress = false;

  PresenceCloudAvailability _cloudAvailability =
      PresenceCloudAvailability.notChecked;

  bool get isRunning => _running;

  Map<String, PhonePresence> get phones => _phones;

  PresenceCloudAvailability get cloudAvailability => _cloudAvailability;

  /// Совместимо с прежними потребителями.
  bool get isAnyoneHome => _phones.values.any(
        (phone) => phone.status == PhonePresenceStatus.home,
  );

  /// Истинно, только когда телефоны есть и каждый точно away.
  ///
  /// Телефон со статусом unknown блокирует это условие.
  bool get isNobodyHome =>
      _phones.isNotEmpty &&
          _phones.values.every(
                (phone) => phone.status == PhonePresenceStatus.away,
          );

  /// Вызывается только при изменении фактического статуса телефона.
  void Function(
      String phoneId,
      PhonePresenceStatus oldStatus,
      PhonePresenceStatus newStatus,
      )? onStatusChanged;

  /// Вызывается после каждого полного цикла, даже если статусы не изменились.
  ///
  /// Это нужно AutomationEngine для проверки доступности облака и таймеров.
  void Function(PresenceCycleResult result)? onCheckCompleted;

  Future<void> start(PresenceSettings settings) async {
    if (_running) {
      debugPrint('PresenceDetector уже запущен');
      return;
    }

    _settings = settings;
    _phones
      ..clear()
      ..addEntries(
        settings.phones
            .where((phone) => phone.enabled)
            .map(
              (phone) => MapEntry(
            phone.phoneId,
            PhonePresence(
              phoneId: phone.phoneId,
              phoneName: phone.phoneName,
            ),
          ),
        ),
      );

    _running = true;
    await checkNow();

    final interval = _checkInterval;
    if (_running && interval != null) {
      _timer = Timer.periodic(interval, (_) {
        unawaited(checkNow());
      });
    }

    debugPrint('PresenceDetector запущен (${_phones.length} телефонов)');
  }

  /// Выполняет одну проверку всех включённых телефонов.
  ///
  /// Параллельные вызовы пропускаются, пока предыдущий цикл не завершился.
  Future<void> checkNow() async {
    if (!_running || _settings == null || _checkInProgress) return;

    _checkInProgress = true;
    var cloudWasChecked = false;
    var cloudUnavailable = false;

    try {
      final entries = List<MapEntry<String, PhonePresence>>.of(
        _phones.entries,
      );

      for (final entry in entries) {
        if (!_running) return;

        final phone = entry.value;
        if (!_phones.containsKey(phone.phoneId)) continue;

        final oldStatus = phone.status;
        final oldSource = phone.source;

        final cloudResult = await _checkPhone(phone);

        if (cloudResult != null) {
          cloudWasChecked = true;
          if (cloudResult.status == PresenceCloudReadStatus.unavailable) {
            cloudUnavailable = true;
          }
        }

        if (phone.status != oldStatus) {
          onStatusChanged?.call(
            phone.phoneId,
            oldStatus,
            phone.status,
          );
        }

        final sourceChanged = phone.source != oldSource;
        final statusChanged = phone.status != oldStatus;

        // Записываем изменение статуса, а также смену источника известного
        // статуса. Повторные проверки без изменений не записываем.
        final shouldLog = statusChanged ||
            (sourceChanged && phone.status != PhonePresenceStatus.unknown);

        if (shouldLog) {
          await _logTransition(
            phone: phone,
            oldStatus: oldStatus,
            oldSource: oldSource,
          );
        }
      }

      if (cloudUnavailable) {
        _cloudAvailability = PresenceCloudAvailability.unavailable;
      } else if (cloudWasChecked) {
        _cloudAvailability = PresenceCloudAvailability.available;
      } else {
        _cloudAvailability = PresenceCloudAvailability.notChecked;
      }

      _logStatus();

      onCheckCompleted?.call(
        PresenceCycleResult(
          phones: {
            for (final entry in _phones.entries)
              entry.key: entry.value.toSnapshot(),
          },
          cloudAvailability: _cloudAvailability,
          checkedAt: _clock(),
        ),
      );
    } finally {
      _checkInProgress = false;
    }
  }

  /// Возвращает результат облачного чтения, если облако запрашивалось.
  ///
  /// `null` означает, что свежий heartbeat уже подтвердил присутствие.
  Future<PresenceCloudReadResult?> _checkPhone(
      PhonePresence phone,
      ) async {
    final heartbeat = _tryReadHeartbeat(phone.phoneId);

    if (heartbeat != null) {
      phone
        ..status = PhonePresenceStatus.home
        ..source = PresenceSource.heartbeat
        ..viaWifi = true
        ..battery = heartbeat.battery
        ..lastSeen = heartbeat.timestamp
        ..distanceFromHome = 0
        ..lat = null
        ..lng = null;

      debugPrint('${phone.phoneName}: дома по heartbeat');
      return null;
    }

    final result = await _readCloud(phone.phoneId);

    switch (result.status) {
      case PresenceCloudReadStatus.unavailable:
        _setUnknown(
          phone,
          source: PresenceSource.unknown,
          clearLocation: false,
        );
        debugPrint('${phone.phoneName}: unknown — облако недоступно');
        return result;

      case PresenceCloudReadStatus.notFound:
        _setUnknown(
          phone,
          source: PresenceSource.cloud,
          clearLocation: true,
        );
        debugPrint('${phone.phoneName}: unknown — облачной записи нет');
        return result;

      case PresenceCloudReadStatus.invalidData:
        _setUnknown(
          phone,
          source: PresenceSource.cloud,
          clearLocation: true,
        );
        debugPrint(
          '${phone.phoneName}: unknown — некорректная облачная запись '
              '(${result.details ?? "без подробностей"})',
        );
        return result;

      case PresenceCloudReadStatus.found:
        final data = result.data;
        if (data == null) {
          _setUnknown(
            phone,
            source: PresenceSource.cloud,
            clearLocation: true,
          );
          return const PresenceCloudReadResult.invalidData(
            details: 'Found result has no data.',
          );
        }

        _applyCloudRecord(phone, data);
        return result;
    }
  }

  PresenceHeartbeatData? _tryReadHeartbeat(String phoneId) {
    try {
      final heartbeat = _heartbeatLookup(phoneId);
      if (heartbeat == null) return null;

      final age = _clock().difference(heartbeat.timestamp);

      // Не принимаем heartbeat из будущего или старше заданного срока.
      if (age.isNegative || age > heartbeatMaxAge) {
        return null;
      }

      return heartbeat;
    } catch (error) {
      // Ошибка локального heartbeat не означает автоматический away:
      // пробуем облачный источник.
      debugPrint('Ошибка чтения heartbeat для $phoneId: $error');
      return null;
    }
  }

  static PresenceHeartbeatData? _readHeartbeat(String phoneId) {
    if (!HeartbeatServer.isAlive(
      phoneId,
      maxAgeSec: 90,
    )) {
      return null;
    }

    final heartbeat = HeartbeatServer.getHeartbeat(phoneId);
    if (heartbeat == null) return null;

    return PresenceHeartbeatData(
      timestamp: heartbeat.ts,
      battery: heartbeat.battery,
    );
  }

  Future<PresenceCloudReadResult> _readCloud(String phoneId) async {
    final injectedReader = _cloudReader;
    if (injectedReader != null) {
      try {
        return await injectedReader.readPresence(phoneId: phoneId);
      } catch (error) {
        debugPrint('Ошибка облачного читателя для $phoneId: $error');
        return PresenceCloudReadResult.unavailable(
          details: error.toString(),
        );
      }
    }

    try {
      final keys = EncryptedKeys();
      final login = await keys.getCloudLogin();
      final password = await keys.getCloudPassword();

      if (login == null ||
          login.trim().isEmpty ||
          password == null ||
          password.isEmpty) {
        return const PresenceCloudReadResult.unavailable(
          details: 'Cloud credentials are not configured.',
        );
      }

      final service = MailruCloudService(
        login: login,
        password: password,
      );

      return await service.readPresence(phoneId: phoneId);
    } catch (error) {
      debugPrint('Ошибка чтения облака для $phoneId: $error');
      return PresenceCloudReadResult.unavailable(
        details: error.toString(),
      );
    }
  }

  void _applyCloudRecord(
      PhonePresence phone,
      Map<String, dynamic> data,
      ) {
    final now = _clock();

    final recordPhoneId = data['phoneId']?.toString();
    if (recordPhoneId != null &&
        recordPhoneId.isNotEmpty &&
        recordPhoneId != phone.phoneId) {
      _setUnknown(
        phone,
        source: PresenceSource.cloud,
        clearLocation: true,
      );
      debugPrint('${phone.phoneName}: unknown — phoneId не совпадает');
      return;
    }

    final timestampValue = data['ts'];
    if (timestampValue is! num || !timestampValue.isFinite) {
      _setUnknown(
        phone,
        source: PresenceSource.cloud,
        clearLocation: true,
      );
      debugPrint('${phone.phoneName}: unknown — нет корректного ts');
      return;
    }

    final timestampMs = timestampValue.toInt();
    if (timestampMs <= 0) {
      _setUnknown(
        phone,
        source: PresenceSource.cloud,
        clearLocation: true,
      );
      debugPrint('${phone.phoneName}: unknown — некорректный ts');
      return;
    }

    final recordTime = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final age = now.difference(recordTime);

    if (age.isNegative || age > cloudMaxAge) {
      _setUnknown(
        phone,
        source: PresenceSource.cloud,
        clearLocation: true,
      );
      debugPrint('${phone.phoneName}: unknown — облачные данные устарели');
      return;
    }

    final latitudeValue = data['lat'];
    final longitudeValue = data['lng'];
    final accuracyValue = data['accuracy'];

    if (latitudeValue is! num ||
        longitudeValue is! num ||
        accuracyValue is! num ||
        !latitudeValue.isFinite ||
        !longitudeValue.isFinite ||
        !accuracyValue.isFinite) {
      _setUnknown(
        phone,
        source: PresenceSource.cloud,
        clearLocation: true,
      );
      debugPrint('${phone.phoneName}: unknown — нет корректного GPS');
      return;
    }

    final latitude = latitudeValue.toDouble();
    final longitude = longitudeValue.toDouble();
    final accuracy = accuracyValue.toDouble();

    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180 ||
        accuracy < 0) {
      _setUnknown(
        phone,
        source: PresenceSource.cloud,
        clearLocation: true,
      );
      debugPrint('${phone.phoneName}: unknown — GPS вне допустимого диапазона');
      return;
    }

    phone
      ..source = PresenceSource.cloud
      ..viaWifi = false
      ..lat = latitude
      ..lng = longitude
      ..battery = (data['battery'] as num?)?.toInt()
      ..lastSeen = recordTime;

    final settings = _settings;
    if (settings == null ||
        (settings.homeLat == 0 && settings.homeLng == 0)) {
      phone
        ..status = PhonePresenceStatus.unknown
        ..distanceFromHome = null;

      debugPrint('${phone.phoneName}: unknown — домашняя зона не настроена');
      return;
    }

    final distanceFromHome = distance(
      latitude,
      longitude,
      settings.homeLat,
      settings.homeLng,
    );

    phone.distanceFromHome = distanceFromHome;

    // Внутри участка телефон считается дома, даже если Wi-Fi уже пропал.
    if (distanceFromHome + accuracy <= settings.homeRadius) {
      phone.status = PhonePresenceStatus.home;
      debugPrint(
        '${phone.phoneName}: дома по GPS '
            '(${distanceFromHome.round()} м, точность ±${accuracy.round()} м)',
      );
      return;
    }

    // Для away учитываем точность GPS и дополнительный запас за границей
    // участка. Это снижает ложные переключения около края геозоны.
    if (distanceFromHome - accuracy >
        settings.homeRadius + gpsOutsideMargin) {
      phone.status = PhonePresenceStatus.away;
      debugPrint(
        '${phone.phoneName}: ушёл по GPS '
            '(${distanceFromHome.round()} м, точность ±${accuracy.round()} м)',
      );
      return;
    }

    // GPS-погрешность пересекает границу участка либо телефон находится
    // в дополнительном запасе: данных недостаточно для home/away.
    phone.status = PhonePresenceStatus.unknown;
    debugPrint(
      '${phone.phoneName}: unknown — GPS около границы участка '
          '(${distanceFromHome.round()} м, точность ±${accuracy.round()} м)',
    );
  }

  void _setUnknown(
      PhonePresence phone, {
        required PresenceSource source,
        required bool clearLocation,
      }) {
    phone
      ..status = PhonePresenceStatus.unknown
      ..source = source
      ..viaWifi = false;

    if (clearLocation) {
      phone
        ..lat = null
        ..lng = null
        ..distanceFromHome = null
        ..lastSeen = null;
    }
  }

  Future<void> _logTransition({
    required PhonePresence phone,
    required PhonePresenceStatus oldStatus,
    required PresenceSource oldSource,
  }) async {
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
        'Не удалось записать изменение присутствия '
            'для ${phone.phoneName}: $error\n$stackTrace',
      );
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
      'Статус присутствия: дома=$homeCount, '
          'ушли=$awayCount, неизвестно=$unknownCount, '
          'облако=$_cloudAvailability',
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    debugPrint('PresenceDetector остановлен');
  }
}