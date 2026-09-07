/// Integration test for session timeout handling
/// Tests that devices reconnect properly after idle timeout periods
@Tags(['integration'])
library;

import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';
import 'test_helpers.dart';

void main() {
  group('Session Timeout Tests', () {
    test(
      'v3.5 device handles session timeouts correctly',
      () async {
        // Load device configuration
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

        print('Testing with device: ${v35Device['name']}');
        print('IP: ${v35Device['ip']}');

        // Create device instance
        final device = Device(
          deviceId: v35Device['device_id'],
          address: v35Device['ip'],
          localKey: v35Device['local_key'],
          version: v35Device['version'],
        );

        try {
          // Test 1: Initial connection and status
          print('\nTest 1: Initial connection and status query');
          final status1 = await device.status();
          expect(
            status1['success'],
            isTrue,
            reason: 'Initial status query should succeed',
          );
          print('✓ Status query successful');
          print('  DPS: ${status1['dps']}');

          // Test 2: Wait 1 minute idle, then try again
          print('\nTest 2: Idle for 1 minute, then query status');
          print('Waiting 1 minute (60 seconds) with idle connection...');
          await Future.delayed(const Duration(seconds: 60));

          print('1 minute elapsed. Attempting status query...');
          final status2 = await device.status();
          expect(
            status2['success'],
            isTrue,
            reason: 'Status query should succeed after 1 minute idle',
          );
          print('✓ Status query successful after 1 minute idle');
          print('  DPS: ${status2['dps']}');

          // Test 3: Turn device on
          print('\nTest 3: Turn device ON');
          final turnOnResult = await device.turnOn();
          expect(
            turnOnResult['success'],
            isTrue,
            reason: 'Turn ON should succeed',
          );
          print('✓ Turn ON successful');

          // Test 4: Wait 2 minutes idle, then try again
          print('\nTest 4: Idle for 2 minutes, then query status');
          print('Waiting 2 minutes (120 seconds) with idle connection...');
          await Future.delayed(const Duration(seconds: 120));

          print('2 minutes elapsed. Attempting status query...');
          final status3 = await device.status();
          expect(
            status3['success'],
            isTrue,
            reason: 'Status query should succeed after 2 minutes idle',
          );
          print('✓ Status query successful after 2 minutes idle');
          print('  DPS: ${status3['dps']}');

          // Test 5: Turn device off
          print('\nTest 5: Turn device OFF');
          final turnOffResult = await device.turnOff();
          expect(
            turnOffResult['success'],
            isTrue,
            reason: 'Turn OFF should succeed',
          );
          print('✓ Turn OFF successful');

          print('\n✅ All session timeout tests passed');
        } finally {
          device.close();
          print('Device connection closed');
        }
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
