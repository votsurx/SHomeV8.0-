/// Integration test for socket open/close behavior
/// Verifies socket state for persist modes
@Tags(['integration'])
library;

import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';
import 'test_helpers.dart';

void main() {
  group('Socket Behavior Tests', () {
    test('socket closes after operations with persist=false', () async {
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

      print('Verifying socket closes with persist=false');

      final device = Device(
        deviceId: v35Device['device_id'],
        address: v35Device['ip'],
        localKey: v35Device['local_key'],
        version: v35Device['version'],
        persist: false,
      );

      try {
        expect(
          device.isSocketActive,
          isFalse,
          reason: 'Socket should be closed initially',
        );

        await device.status();
        expect(
          device.isSocketActive,
          isFalse,
          reason: 'Socket should close after operation with persist=false',
        );

        await Future.delayed(const Duration(seconds: 2));
        expect(device.isSocketActive, isFalse);

        await device.turnOn();
        expect(
          device.isSocketActive,
          isFalse,
          reason: 'Socket should close after each operation',
        );

        print('✅ Socket correctly closes after each operation');
      } finally {
        device.close();
      }
    });

    test('socket stays open between operations with persist=true', () async {
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

      print('Verifying socket stays open with persist=true');

      final device = Device(
        deviceId: v35Device['device_id'],
        address: v35Device['ip'],
        localKey: v35Device['local_key'],
        version: v35Device['version'],
        persist: true,
      );

      try {
        expect(
          device.isSocketActive,
          isFalse,
          reason: 'Socket should be closed initially',
        );

        await device.status();
        expect(
          device.isSocketActive,
          isTrue,
          reason: 'Socket should stay open after operation with persist=true',
        );

        await Future.delayed(const Duration(seconds: 2));
        expect(
          device.isSocketActive,
          isTrue,
          reason: 'Socket should still be open after delay',
        );

        await device.turnOn();
        expect(
          device.isSocketActive,
          isTrue,
          reason: 'Socket should stay open between operations',
        );

        print('✅ Socket correctly stays open between operations');
      } finally {
        device.close();
      }
    });

    test(
      'socket reconnects after timeout with persist=true',
      () async {
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

        print('Testing idle timeout reconnection');

        final device = Device(
          deviceId: v35Device['device_id'],
          address: v35Device['ip'],
          localKey: v35Device['local_key'],
          version: v35Device['version'],
          persist: true,
        );

        try {
          await device.status();
          expect(device.isSocketActive, isTrue);

          print('Waiting 90 seconds for timeout...');
          await Future.delayed(const Duration(seconds: 90));

          print('Attempting operation after timeout...');
          final result = await device.status();
          expect(
            result['success'],
            isTrue,
            reason: 'Should reconnect automatically after timeout',
          );

          print('✅ Automatic reconnection worked correctly');
        } finally {
          device.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
