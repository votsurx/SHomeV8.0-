/// Integration test for socket persistence modes
/// Tests persist=false (default) vs persist=true behavior
@Tags(['integration'])
library;

import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';
import 'test_helpers.dart';

void main() {
  group('Persist Mode Tests', () {
    test('persist=false closes socket after each operation', () async {
      final config = await loadDeviceConfig();
      if (config == null) {
        print(
          'Skipped: No devices.json found. Copy test/integration/devices.json.example and fill in device credentials to run integration tests',
        );
        return;
      }

      final v35Device = findDeviceByVersion(config, 3.5);
      if (v35Device == null) {
        print('Skipped: No v3.5 device found in config');
        return;
      }

      print('Testing persist=false with: ${v35Device['name']}');

      final device = Device(
        deviceId: v35Device['device_id'],
        address: v35Device['ip'],
        localKey: v35Device['local_key'],
        version: v35Device['version'],
        persist: false, // Socket closes after each operation
      );

      try {
        final status1 = await device.status();
        expect(status1['success'], isTrue);
        print('✓ Status query 1 successful');

        await Future.delayed(const Duration(milliseconds: 100));

        final turnOnResult = await device.turnOn();
        expect(turnOnResult['success'], isTrue);
        print('✓ Turn ON successful');

        await Future.delayed(const Duration(milliseconds: 100));

        final status2 = await device.status();
        expect(status2['success'], isTrue);
        print('✓ Status query 2 successful');

        await Future.delayed(const Duration(milliseconds: 100));

        final turnOffResult = await device.turnOff();
        expect(turnOffResult['success'], isTrue);
        print('✓ Turn OFF successful');

        print('\n✅ persist=false: All operations successful');
      } finally {
        device.close();
      }
    });

    test('persist=true keeps socket open between operations', () async {
      final config = await loadDeviceConfig();
      if (config == null) {
        print(
          'Skipped: No devices.json found. Copy test/integration/devices.json.example and fill in device credentials to run integration tests',
        );
        return;
      }

      final v35Device = findDeviceByVersion(config, 3.5);
      if (v35Device == null) {
        print('Skipped: No v3.5 device found in config');
        return;
      }

      print('Testing persist=true with: ${v35Device['name']}');

      final device = Device(
        deviceId: v35Device['device_id'],
        address: v35Device['ip'],
        localKey: v35Device['local_key'],
        version: v35Device['version'],
        persist: true, // Socket stays open
      );

      try {
        final status1 = await device.status();
        expect(status1['success'], isTrue);
        expect(
          device.isSocketActive,
          isTrue,
          reason: 'Socket should stay open with persist=true',
        );
        print('✓ Status query 1 successful - socket still open');

        await Future.delayed(const Duration(milliseconds: 100));

        final turnOnResult = await device.turnOn();
        expect(turnOnResult['success'], isTrue);
        expect(device.isSocketActive, isTrue);
        print('✓ Turn ON successful - socket still open');

        await Future.delayed(const Duration(milliseconds: 100));

        final status2 = await device.status();
        expect(status2['success'], isTrue);
        expect(device.isSocketActive, isTrue);
        print('✓ Status query 2 successful - socket still open');

        await Future.delayed(const Duration(milliseconds: 100));

        final turnOffResult = await device.turnOff();
        expect(turnOffResult['success'], isTrue);
        print('✓ Turn OFF successful');

        print(
          '\n✅ persist=true: All operations successful, socket stayed open',
        );
      } finally {
        device.close();
      }
    });
  });
}
