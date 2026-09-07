import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shome/data/services/adaptive_poller.dart';
import 'package:shome/data/protocols/tuya_protocol.dart';
import 'package:shome/domain/models/device.dart';
import 'package:talker/talker.dart';

class MockTuyaProtocol implements TuyaProtocol {
  final Map<String, Map<String, dynamic>> _deviceStates = {};
  int getStatusCallCount = 0;
  bool throwError = false;

  void setDeviceState(String deviceId, bool isOn) {
    _deviceStates[deviceId] = {'dps': {'1': isOn}};
  }

  @override
  Future<bool> setDp(Device device, int dpId, dynamic value) async {
    // Заглушка для тестов — всегда успешно
    return true;
  }

  void setMultiChannelState(String deviceId, List<bool> states) {
    final dps = <String, bool>{};
    for (var i = 0; i < states.length; i++) {
      dps['${i + 1}'] = states[i];
    }
    _deviceStates[deviceId] = {'dps': dps};
  }

  @override
  Future<Map<String, dynamic>?> getStatus(Device device) async {
    getStatusCallCount++;
    if (throwError) throw Exception('Network error');
    return _deviceStates[device.id];
  }

  @override Future<bool> turnOn(Device device) async => true;
  @override Future<bool> turnOff(Device device) async => true;
  @override Future<bool> ping(Device device) async => true;
  @override Future<bool> setSwitchChannel(Device device, int channel, bool state) async => true;
  @override Future<bool> setCurtainPosition(Device device, int position) async => true;
  @override Future<bool> setHvac(Device device, {required bool power, required double targetTemp, required String mode, required int fanSpeed}) async => true;
  @override Future<bool> setBrightness(Device device, int brightness) async => true;
  @override Future<Map<String, dynamic>?> getDeviceDps(Device device) async => _deviceStates[device.id];
}

Device createDevice({
  required String id,
  required DeviceType type,
  Map<String, dynamic>? properties,
}) {
  return Device(
    id: id, name: 'Test', type: type, roomId: 'living',
    isOnline: true, state: DeviceState.online,
    deviceId: 'bf_$id', localKey: 'key_$id', address: '192.168.1.1',
    version: 3.3, properties: properties ?? {'isOn': false},
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('AdaptivePoller', () {
    late MockTuyaProtocol mockTuya;
    late Talker talker;

    setUp(() async {
      // Уникальная БД для каждого теста
      databaseFactory = databaseFactoryFfi;
      final dbPath = '${DateTime.now().millisecondsSinceEpoch}_test.db';
      // sqfliteFfiDatabaseFactory.setDatabasesPath(dbPath);

      mockTuya = MockTuyaProtocol();
      talker = Talker();
    });

    test('pollOnce вызывает getStatus', () async {
      final device = createDevice(id: 'dev_1', type: DeviceType.outlet, properties: {'isOn': false});
      mockTuya.setDeviceState(device.id, true);

      final poller = AdaptivePoller(
        mockTuya, talker,
            (deviceId, isOn) {}, (deviceId, isOnline) {}, (deviceId, states) {},
        normalInterval: const Duration(minutes: 10),
      );

      poller.updateDevices([device]);
      poller.start();
      await poller.pollOnce(device.id);
      poller.stop();

      expect(mockTuya.getStatusCallCount, greaterThan(0));
    });

    test('pollOnce вызывает onStateChanged при изменении', () async {
      final device = createDevice(id: 'dev_1', type: DeviceType.outlet, properties: {'isOn': false});
      mockTuya.setDeviceState(device.id, true);

      final stateChanges = <String>[];
      final poller = AdaptivePoller(
        mockTuya, talker,
            (deviceId, isOn) => stateChanges.add('$deviceId:$isOn'),
            (deviceId, isOnline) {}, (deviceId, states) {},
        normalInterval: const Duration(minutes: 10),
      );

      poller.updateDevices([device]);
      poller.start();
      await poller.pollOnce(device.id);
      poller.stop();

      expect(stateChanges, contains('dev_1:true'));
    });

    test('pollOnce вызывает onStatesChanged для многоканальных', () async {
      final device = createDevice(
        id: 'switch_1', type: DeviceType.switch2,
        properties: {'channels': 2, 'states': [false, false]},
      );
      mockTuya.setMultiChannelState(device.id, [true, false]);

      final statesChanges = <Map<String, dynamic>>[];
      final poller = AdaptivePoller(
        mockTuya, talker,
            (deviceId, isOn) {}, (deviceId, isOnline) {},
            (deviceId, states) => statesChanges.add({'id': deviceId, 'states': states}),
        normalInterval: const Duration(minutes: 10),
      );

      poller.updateDevices([device]);
      poller.start();
      await poller.pollOnce(device.id);
      poller.stop();

      expect(statesChanges.length, 1);
      expect(statesChanges.first['states'], [true, false]);
    });

    test('pollOnce НЕ вызывает колбэк без изменений', () async {
      final device = createDevice(id: 'dev_1', type: DeviceType.outlet, properties: {'isOn': false});
      mockTuya.setDeviceState(device.id, false);

      final stateChanges = <String>[];
      final poller = AdaptivePoller(
        mockTuya, talker,
            (deviceId, isOn) => stateChanges.add('$deviceId:$isOn'),
            (deviceId, isOnline) {}, (deviceId, states) {},
        normalInterval: const Duration(minutes: 10),
      );

      poller.updateDevices([device]);
      poller.start();
      await poller.pollOnce(device.id);
      poller.stop();

      expect(stateChanges, isEmpty);
    });

    test('pollOnce вызывает onOnlineChanged', () async {
      final device = createDevice(id: 'dev_1', type: DeviceType.outlet);
      mockTuya.setDeviceState(device.id, false);

      final onlineChanges = <String>[];
      final poller = AdaptivePoller(
        mockTuya, talker,
            (deviceId, isOn) {}, (deviceId, isOnline) => onlineChanges.add('$deviceId:$isOnline'),
            (deviceId, states) {},
        normalInterval: const Duration(minutes: 10),
      );

      poller.updateDevices([device]);
      poller.start();
      await poller.pollOnce(device.id);
      poller.stop();

      expect(onlineChanges, contains('dev_1:true'));
    });

    test('stop() останавливает периодический опрос', () async {
      final device = createDevice(id: 'dev_1', type: DeviceType.outlet);
      mockTuya.setDeviceState(device.id, false);

      final poller = AdaptivePoller(
        mockTuya, talker,
            (deviceId, isOn) {}, (deviceId, isOnline) {}, (deviceId, states) {},
        normalInterval: const Duration(milliseconds: 100),
      );

      poller.updateDevices([device]);
      poller.start();
      await Future.delayed(const Duration(milliseconds: 500));
      poller.stop();

      final countAfterStop = mockTuya.getStatusCallCount;
      await Future.delayed(const Duration(milliseconds: 300));
      expect(mockTuya.getStatusCallCount, countAfterStop);
    });
  });
}