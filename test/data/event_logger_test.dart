import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shome/data/services/event_logger.dart';
import 'package:shome/data/local/database.dart';

void main() {
  // Инициализируем sqflite для тестов
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('EventLogger', () {
    setUp(() async {
      await AppDatabase.clearEvents();
    });

    test('Логирование turnOn', () async {
      await EventLogger.log(
        event: 'turnOn',
        deviceId: 'dev_1',
        deviceName: 'Test Device',
      );

      final events = await AppDatabase.getRecentEvents(limit: 10);
      expect(events.length, 1);
      expect(events.first.event, 'turnOn');
      expect(events.first.deviceName, 'Test Device');
    });

    test('Логирование scene', () async {
      await EventLogger.log(
        event: 'scene',
        deviceId: 'dev_1',
        deviceName: 'Test Device',
        sceneName: 'Test Scene',
      );

      final events = await AppDatabase.getRecentEvents(limit: 10);
      expect(events.length, 1);
      expect(events.first.event, 'scene');
      expect(events.first.sceneName, 'Test Scene');
    });

    test('Логирование deviceAdded', () async {
      await EventLogger.log(
        event: 'deviceAdded',
        deviceId: 'dev_2',
        deviceName: 'New Device',
      );

      final events = await AppDatabase.getRecentEvents(limit: 10);
      expect(events.length, 1);
      expect(events.first.event, 'deviceAdded');
    });

    test('Ограничение количества записей', () async {
      for (var i = 0; i < 5; i++) {
        await EventLogger.log(
          event: 'turnOn',
          deviceId: 'dev_$i',
          deviceName: 'Device $i',
        );
      }

      final events = await AppDatabase.getRecentEvents(limit: 3);
      expect(events.length, 3);
    });

    test('Очистка событий', () async {
      await EventLogger.log(event: 'turnOn', deviceId: 'dev_1', deviceName: 'Test');
      await AppDatabase.clearEvents();

      final events = await AppDatabase.getRecentEvents(limit: 10);
      expect(events.length, 0);
    });
  });
}