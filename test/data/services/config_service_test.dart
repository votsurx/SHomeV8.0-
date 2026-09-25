import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shome/data/services/config_service.dart';
import 'package:shome/data/local/database.dart';
import 'package:shome/data/local/entities/device_entity.dart';
import 'package:shome/data/local/entities/room_entity.dart';

void main() {
  // 1. Биндинг — обязателен для SharedPreferences и MethodChannel
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigService', () {
    setUpAll(() {
      // 2. sqflite FFI для тестов без эмулятора
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // 3. Мокаем FlutterSecureStorage — иначе MissingPluginException
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
            (MethodCall call) async {
          switch (call.method) {
            case 'read':
            case 'readAll':
              return null;
            case 'write':
            case 'delete':
            case 'deleteAll':
              return null;
            case 'containsKey':
              return false;
            default:
              return null;
          }
        },
      );
    });

    setUp(() async {
      // 4. Мокаем SharedPreferences — пустые значения
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      final db = await AppDatabase.database;
      await db.delete('devices');
      await db.delete('rooms');
      await db.delete('scenes');
      await db.delete('timers');
    });

    test('buildConfigJson возвращает валидный JSON', () async {
      await AppDatabase.insertRoom(
        RoomEntity(id: 'test_room', name: 'Тестовая', icon: '🧪', sortOrder: 0),
      );

      await AppDatabase.insertDevice(
        DeviceEntity(
          id: 'test_device',
          name: 'Тестовое устройство',
          type: 'switch1',
          roomId: 'test_room',
          isOnline: 1,
          state: 'online',
          address: '192.168.1.100',
          localKey: 'key123',
          properties: jsonEncode({'isOn': false}),
        ),
      );

      final json = await ConfigService.buildConfigJson();

      expect(json, isNotEmpty);
      expect(json, contains('test_room'));
      expect(json, contains('test_device'));
      expect(json, contains('"version"'));
    });

    test('restoreFromJson восстанавливает комнаты', () async {
      final testJson = '''
{
  "version": "2.11",
  "rooms": [
    {"id": "living", "name": "Гостиная", "icon": "🛋️", "sortOrder": 0}
  ],
  "devices": [],
  "scenes": [],
  "timers": []
}
''';

      await ConfigService.restoreFromJson(testJson);

      final rooms = await AppDatabase.getAllRooms();
      expect(rooms.length, 1);
      expect(rooms.first.id, 'living');
      expect(rooms.first.name, 'Гостиная');
    });

    test('restoreFromJson восстанавливает устройства', () async {
      final testJson = '''
{
  "version": "2.11",
  "rooms": [],
  "devices": [
    {
      "id": "dev1",
      "name": "Лампа",
      "type": "switch1",
      "roomId": "",
      "isOnline": 1,
      "state": "online",
      "address": "192.168.1.1",
      "localKey": "key1",
      "properties": "{\\"isOn\\": true}"
    }
  ],
  "scenes": [],
  "timers": []
}
''';

      await ConfigService.restoreFromJson(testJson);

      final devices = await AppDatabase.getAllDevices();
      expect(devices.length, 1);
      expect(devices.first.name, 'Лампа');
    });

    test('restoreFromJson восстанавливает сцены и таймеры', () async {
      final testJson = '''
{
  "version": "2.11",
  "rooms": [],
  "devices": [],
  "scenes": [
    {
      "id": "scene1",
      "name": "Вечер",
      "icon": "🌙",
      "actions": "[]",
      "triggerType": null,
      "triggerTime": null,
      "triggerRepeat": null
    }
  ],
  "timers": [
    {
      "id": "timer1",
      "deviceId": "dev1",
      "deviceName": "Лампа",
      "command": "on",
      "executeAt": "2026-06-08T20:00:00.000",
      "executed": false
    }
  ]
}
''';

      await ConfigService.restoreFromJson(testJson);

      final scenes = await AppDatabase.getAllScenes();
      expect(scenes.length, 1);
      expect(scenes.first.name, 'Вечер');

      final timers = await AppDatabase.getActiveTimers();
      expect(timers.length, 1);
      expect(timers.first.command, 'on');
    });

    test('exportConfig + restoreFromJson — roundtrip', () async {
      await AppDatabase.insertRoom(
        RoomEntity(id: 'r1', name: 'Комната', icon: '🏠', sortOrder: 0),
      );

      await AppDatabase.insertDevice(
        DeviceEntity(
          id: 'd1',
          name: 'Девайс',
          type: 'sensor',
          roomId: 'r1',
          isOnline: 1,
          state: 'online',
          address: '10.0.0.1',
          localKey: 'k1',
          properties: jsonEncode({'isOn': false}),
        ),
      );

      final exported = await ConfigService.buildConfigJson();

      final db = await AppDatabase.database;
      await db.delete('devices');
      await db.delete('rooms');

      await ConfigService.restoreFromJson(exported);

      final rooms = await AppDatabase.getAllRooms();
      final devices = await AppDatabase.getAllDevices();

      expect(rooms.length, 1);
      expect(rooms.first.name, 'Комната');
      expect(devices.length, 1);
      expect(devices.first.name, 'Девайс');
    });
  });
}