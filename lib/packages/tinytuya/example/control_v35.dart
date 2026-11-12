/// Control v3.5 device - turn on/off
import 'package:tinytuya/tinytuya.dart';

void main() async {
  print('Testing Device v3.5 Control');
  print('============================\n');

  final device = Device(
    deviceId: 'YOUR_DEVICE_ID_HERE',
    address: '192.168.1.102',
    localKey: 'YOUR_LOCAL_KEY_HERE',
    version: 3.5,
  );

  try {
    // Get current status
    print('Getting current status...');
    var result = await device.status();
    print('Current DPS 1 (switch): ${result['dps']?["1"]}\n');

    // Turn ON
    print('Turning device ON...');
    result = await device.turnOn();
    if (result['success'] == true) {
      print('✓ Successfully turned ON');
    } else {
      print('✗ Failed to turn ON: $result');
    }

    await Future.delayed(Duration(seconds: 2));

    // Get status after ON
    result = await device.status();
    print('DPS 1 after ON: ${result['dps']?["1"]}\n');

    // Turn OFF
    print('Turning device OFF...');
    result = await device.turnOff();
    if (result['success'] == true) {
      print('✓ Successfully turned OFF');
    } else {
      print('✗ Failed to turn OFF: $result');
    }

    await Future.delayed(Duration(seconds: 2));

    // Get final status
    result = await device.status();
    print('DPS 1 after OFF: ${result['dps']?["1"]}');
  } catch (e) {
    print('Error: $e');
  } finally {
    device.close();
  }
}
