import 'package:flutter_test/flutter_test.dart';
import 'package:shome/application/models/presence_settings.dart';
import 'package:shome/data/services/presence_detector.dart';
import 'package:shome/domain/services/presence_cloud_reader.dart';
import 'dart:async';

class _FakePresenceCloudReader implements PresenceCloudReader {
  final Map<String, PresenceCloudReadResult> results = {};
  final List<String> requestedPhoneIds = [];

  @override
  Future<PresenceCloudReadResult> readPresence({
    required String phoneId,
  }) async {
    requestedPhoneIds.add(phoneId);

    return results[phoneId] ??
        const PresenceCloudReadResult.notFound();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PresenceDetector', () {
    late DateTime now;
    late _FakePresenceCloudReader cloud;
    late Map<String, PresenceHeartbeatData?> heartbeats;
    late PresenceDetector detector;

    PresenceSettings settingsFor({
      double homeLat = 55.0,
      double homeLng = 37.0,
      int homeRadius = 100,
      List<PresencePhone>? phones,
    }) {
      return PresenceSettings(
        enabled: true,
        phones: phones ??
            [
              PresencePhone(
                phoneId: 'phone-1',
                phoneName: 'Phone 1',
              ),
            ],
        homeLat: homeLat,
        homeLng: homeLng,
        homeRadius: homeRadius,
      );
    }

    Map<String, dynamic> cloudRecord({
      required String phoneId,
      required double lat,
      required double lng,
      double accuracy = 10,
      int? timestampMs,
      String status = 'away',
    }) {
      return {
        'phoneId': phoneId,
        'status': status,
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'battery': 70,
        'ts': timestampMs ?? now.millisecondsSinceEpoch,
      };
    }

    Future<void> startWith(
        PresenceSettings settings,
        ) async {
      detector = PresenceDetector(
        heartbeatLookup: (phoneId) => heartbeats[phoneId],
        cloudReader: cloud,
        clock: () => now,
        checkInterval: null,
        heartbeatMaxAge: const Duration(seconds: 90),
        cloudMaxAge: const Duration(minutes: 10),
        gpsOutsideMargin: 30,
      );

      await detector.start(settings);
    }

    setUp(() {
      now = DateTime.utc(2026, 11, 20, 12);
      cloud = _FakePresenceCloudReader();
      heartbeats = {};
    });

    tearDown(() {
      detector.stop();
    });

    test('свежий heartbeat определяет home и не читает облако', () async {
      heartbeats['phone-1'] = PresenceHeartbeatData(
        timestamp: now,
        battery: 82,
      );

      await startWith(settingsFor());

      final phone = detector.phones['phone-1']!;

      expect(phone.status, PhonePresenceStatus.home);
      expect(phone.source, PresenceSource.heartbeat);
      expect(phone.viaWifi, isTrue);
      expect(phone.battery, 82);
      expect(cloud.requestedPhoneIds, isEmpty);
      expect(
        detector.cloudAvailability,
        PresenceCloudAvailability.notChecked,
      );
    });

    test('устаревший heartbeat не подтверждает home', () async {
      heartbeats['phone-1'] = PresenceHeartbeatData(
        timestamp: now.subtract(const Duration(seconds: 91)),
      );

      await startWith(settingsFor());

      final phone = detector.phones['phone-1']!;

      expect(phone.status, PhonePresenceStatus.unknown);
      expect(phone.source, PresenceSource.cloud);
      expect(cloud.requestedPhoneIds, ['phone-1']);
    });

    test('свежий GPS внутри радиуса определяет home', () async {
      cloud.results['phone-1'] = PresenceCloudReadResult.found(
        cloudRecord(
          phoneId: 'phone-1',
          lat: 55.0,
          lng: 37.0,
          accuracy: 10,
        ),
      );

      await startWith(settingsFor());

      final phone = detector.phones['phone-1']!;

      expect(phone.status, PhonePresenceStatus.home);
      expect(phone.source, PresenceSource.cloud);
      expect(phone.viaWifi, isFalse);
      expect(phone.distanceFromHome, closeTo(0, 0.1));
      expect(detector.cloudAvailability, PresenceCloudAvailability.available);
    });

    test('свежий GPS уверенно снаружи радиуса и запаса определяет away',
            () async {
          // Сдвиг широты примерно на 220 метров: после вычета accuracy
          // расстояние всё ещё больше радиуса 100 м плюс запас 30 м.
          cloud.results['phone-1'] = PresenceCloudReadResult.found(
            cloudRecord(
              phoneId: 'phone-1',
              lat: 55.002,
              lng: 37.0,
              accuracy: 10,
            ),
          );

          await startWith(settingsFor());

          final phone = detector.phones['phone-1']!;

          expect(phone.status, PhonePresenceStatus.away);
          expect(phone.source, PresenceSource.cloud);
          expect(phone.distanceFromHome, greaterThan(200));
        });

    test('GPS в зоне погрешности или запаса у границы даёт unknown',
            () async {
          // Примерно 111 м от центра: это дальше радиуса 100 м,
          // но не дальше радиуса плюс 30 м с учётом accuracy.
          cloud.results['phone-1'] = PresenceCloudReadResult.found(
            cloudRecord(
              phoneId: 'phone-1',
              lat: 55.001,
              lng: 37.0,
              accuracy: 10,
            ),
          );

          await startWith(settingsFor());

          final phone = detector.phones['phone-1']!;

          expect(phone.status, PhonePresenceStatus.unknown);
          expect(phone.source, PresenceSource.cloud);
        });

    test('отсутствующая запись даёт unknown, но облако доступно', () async {
      cloud.results['phone-1'] =
      const PresenceCloudReadResult.notFound();

      await startWith(settingsFor());

      expect(
        detector.phones['phone-1']!.status,
        PhonePresenceStatus.unknown,
      );
      expect(
        detector.cloudAvailability,
        PresenceCloudAvailability.available,
      );
      expect(detector.isNobodyHome, isFalse);
    });

    test('ошибка облака даёт unknown и отмечает облако недоступным',
            () async {
          cloud.results['phone-1'] =
          const PresenceCloudReadResult.unavailable(
            details: 'test network error',
          );

          await startWith(settingsFor());

          expect(
            detector.phones['phone-1']!.status,
            PhonePresenceStatus.unknown,
          );
          expect(
            detector.cloudAvailability,
            PresenceCloudAvailability.unavailable,
          );
          expect(detector.isNobodyHome, isFalse);
        });

    test('некорректная запись даёт unknown, но облако доступно', () async {
      cloud.results['phone-1'] =
      const PresenceCloudReadResult.invalidData(
        details: 'invalid JSON',
      );

      await startWith(settingsFor());

      expect(
        detector.phones['phone-1']!.status,
        PhonePresenceStatus.unknown,
      );
      expect(
        detector.cloudAvailability,
        PresenceCloudAvailability.available,
      );
    });

    test('устаревшая GPS-запись даёт unknown', () async {
      cloud.results['phone-1'] = PresenceCloudReadResult.found(
        cloudRecord(
          phoneId: 'phone-1',
          lat: 55.0,
          lng: 37.0,
          timestampMs:
          now.subtract(const Duration(minutes: 11)).millisecondsSinceEpoch,
        ),
      );

      await startWith(settingsFor());

      expect(
        detector.phones['phone-1']!.status,
        PhonePresenceStatus.unknown,
      );
      expect(
        detector.cloudAvailability,
        PresenceCloudAvailability.available,
      );
    });

    test('GPS-запись без accuracy не подтверждает home или away', () async {
      cloud.results['phone-1'] = PresenceCloudReadResult.found({
        'phoneId': 'phone-1',
        'status': 'home',
        'lat': 55.0,
        'lng': 37.0,
        'ts': now.millisecondsSinceEpoch,
      });

      await startWith(settingsFor());

      expect(
        detector.phones['phone-1']!.status,
        PhonePresenceStatus.unknown,
      );
    });

    test('статус Companion не заменяет GPS-геозону', () async {
      cloud.results['phone-1'] = PresenceCloudReadResult.found(
        cloudRecord(
          phoneId: 'phone-1',
          lat: 55.002,
          lng: 37.0,
          accuracy: 10,
          status: 'home',
        ),
      );

      await startWith(settingsFor());

      expect(
        detector.phones['phone-1']!.status,
        PhonePresenceStatus.away,
      );
    });

    test('несовпадающий phoneId в записи даёт unknown', () async {
      cloud.results['phone-1'] = PresenceCloudReadResult.found(
        cloudRecord(
          phoneId: 'different-phone',
          lat: 55.0,
          lng: 37.0,
        ),
      );

      await startWith(settingsFor());

      expect(
        detector.phones['phone-1']!.status,
        PhonePresenceStatus.unknown,
      );
    });

    test('isNobodyHome false, если хотя бы один телефон unknown', () async {
      cloud.results['phone-1'] = PresenceCloudReadResult.found(
        cloudRecord(
          phoneId: 'phone-1',
          lat: 55.002,
          lng: 37.0,
          accuracy: 10,
        ),
      );
      cloud.results['phone-2'] =
      const PresenceCloudReadResult.notFound();

      await startWith(
        settingsFor(
          phones: [
            PresencePhone(
              phoneId: 'phone-1',
              phoneName: 'Phone 1',
            ),
            PresencePhone(
              phoneId: 'phone-2',
              phoneName: 'Phone 2',
            ),
          ],
        ),
      );

      expect(
        detector.phones['phone-1']!.status,
        PhonePresenceStatus.away,
      );
      expect(
        detector.phones['phone-2']!.status,
        PhonePresenceStatus.unknown,
      );
      expect(detector.isNobodyHome, isFalse);
    });

    test('distance: одинаковые координаты дают ноль', () {
      final distance = detector.distance(55.0, 37.0, 55.0, 37.0);

      expect(distance, closeTo(0, 0.01));
    });

    test('distance: один градус широты примерно 111 км', () {
      final distance = detector.distance(55.0, 37.0, 56.0, 37.0);

      expect(distance, closeTo(111195, 1000));
    });

    test('пустой список телефонов не означает, что никого нет дома',
            () async {
          await startWith(
            settingsFor(phones: const []),
          );

          expect(detector.phones, isEmpty);
          expect(detector.isAnyoneHome, isFalse);
          expect(detector.isNobodyHome, isFalse);
        });

    test('checkNow не запускает второй параллельный цикл', () async {
      final completer = Completer<PresenceCloudReadResult>();
      var readCount = 0;

      final blockingReader = _BlockingPresenceCloudReader(
        onRead: () {
          readCount++;
          return completer.future;
        },
      );

      detector = PresenceDetector(
        heartbeatLookup: (_) => null,
        cloudReader: blockingReader,
        clock: () => now,
        checkInterval: null,
      );

      final startFuture = detector.start(settingsFor());

      // start() уже ждёт первый облачный вызов.
      await Future<void>.delayed(Duration.zero);

      final secondCheck = detector.checkNow();
      await Future<void>.delayed(Duration.zero);

      expect(readCount, 1);

      completer.complete(
        const PresenceCloudReadResult.notFound(),
      );

      await startFuture;
      await secondCheck;

      expect(readCount, 1);
    });

    test('stop до start не падает и повторный stop безопасен', () {
      detector = PresenceDetector(checkInterval: null);

      detector
        ..stop()
        ..stop();

      expect(detector.isRunning, isFalse);
    });
  });
}

class _BlockingPresenceCloudReader implements PresenceCloudReader {
  _BlockingPresenceCloudReader({
    required this.onRead,
  });

  final Future<PresenceCloudReadResult> Function() onRead;

  @override
  Future<PresenceCloudReadResult> readPresence({
    required String phoneId,
  }) {
    return onRead();
  }
}