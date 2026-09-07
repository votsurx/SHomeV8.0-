/// Test v3.5 device using .then() syntax (Promise-style)
/// This matches the user's actual usage pattern
import 'package:tinytuya/tinytuya.dart';

void main() async {
  print('Testing v3.5 Device with .then() syntax');
  print('=' * 60);
  print('');

  // TODO: Replace with your actual v3.5 device credentials
  final device = Device(
    deviceId: 'YOUR_DEVICE_ID_HERE',
    address: '192.168.1.102',
    localKey: 'YOUR_LOCAL_KEY_HERE',
    version: 3.5,
  );

  // Test turn ON with .then() syntax
  print('Turning device ON...');
  device
      .turnOn()
      .then((data) {
        print('Device turned on: $data');

        if (data.containsKey('Error')) {
          print('⚠️  ERROR: ${data['Error']}');
        } else {
          print('✓ No errors!');
        }
        print('');

        // Wait a bit, then turn OFF
        Future.delayed(Duration(seconds: 1)).then((_) {
          print('Turning device OFF...');
          device.turnOff().then((data) {
            print('Device turned off: $data');

            if (data.containsKey('Error')) {
              print('⚠️  ERROR: ${data['Error']}');
            } else {
              print('✓ No errors!');
            }
            print('');

            // Get final status
            device.status().then((status) {
              print('Final status: $status');
              if (status.containsKey('dps')) {
                print('✓ DPS: ${status['dps']}');
              }

              device.close();
              print('');
              print('Test complete!');
            });
          });
        });
      })
      .catchError((error) {
        print('✗ Exception: $error');
        device.close();
      });

  // Keep the program alive
  await Future.delayed(Duration(seconds: 5));
}
