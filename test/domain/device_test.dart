import 'package:flutter_test/flutter_test.dart';
import 'package:shome/domain/models/device.dart';

void main() {
  group('Device model', () {
    test('Создание устройства outlet', () {
      final device = Device(
        id: 'test_1',
        name: 'Test Outlet',
        type: DeviceType.outlet,
        roomId: 'living',
        isOnline: false,
        state: DeviceState.offline,
        deviceId: 'bf123',
        localKey: 'key123',
        address: '192.168.1.1',
        version: 3.3,
        dpsIndex: 1,
        properties: {'isOn': false},
      );

      expect(device.id, 'test_1');
      expect(device.type, DeviceType.outlet);
      expect(device.properties['isOn'], false);
    });

    test('JSON сериализация / десериализация', () {
      final device = Device(
        id: 'test_1',
        name: 'Test',
        type: DeviceType.outlet,
        roomId: 'living',
        isOnline: true,
        state: DeviceState.online,
        properties: {'isOn': true},
      );

      final json = device.toJson();
      final restored = Device.fromJson(json);

      expect(restored.id, device.id);
      expect(restored.name, device.name);
      expect(restored.properties['isOn'], true);
    });

    test('copyWith изменяет свойства', () {
      final device = Device(
        id: 'test_1',
        name: 'Test',
        type: DeviceType.outlet,
        roomId: 'living',
        isOnline: false,
        state: DeviceState.offline,
        properties: {'isOn': false},
      );

      final updated = device.copyWith(
        name: 'Renamed',
        properties: {'isOn': true},
      );

      expect(updated.name, 'Renamed');
      expect(updated.properties['isOn'], true);
    });

    test('Многоканальное устройство', () {
      final device = Device(
        id: 'switch_1',
        name: 'Switch',
        type: DeviceType.switch2,
        roomId: 'living',
        isOnline: true,
        state: DeviceState.online,
        properties: {
          'channels': 2,
          'states': [true, false],
        },
      );

      final states = device.properties['states'] as List<bool>;
      expect(states.length, 2);
      expect(states[0], true);
      expect(states[1], false);
    });
  });
}