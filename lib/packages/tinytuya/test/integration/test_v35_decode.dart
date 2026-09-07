/// Diagnostic test for v3.5 device response decoding
import 'package:tinytuya/tinytuya.dart';

void main() async {
  print('Testing v3.5 Device Response Decoding');
  print('=' * 60);
  print('');

  // TODO: Replace with your actual v3.5 device credentials
  final device = Device(
    deviceId: 'YOUR_DEVICE_ID_HERE',
    address: '192.168.1.102',
    localKey: 'YOUR_LOCAL_KEY_HERE',
    version: 3.5,
  );

  try {
    print('Test 1: Get Status');
    print('-' * 60);
    final status = await device.status();
    print('Status result: $status');
    print('');

    if (status.containsKey('Error')) {
      print('⚠️  ERROR in status response: ${status['Error']}');
    }
    if (status.containsKey('dps')) {
      print('✓ DPS data: ${status['dps']}');
    }
    print('');

    print('Test 2: Turn ON');
    print('-' * 60);
    final onResult = await device.turnOn();
    print('Turn ON result: $onResult');
    print('');

    if (onResult.containsKey('Error')) {
      print('⚠️  ERROR in turn ON response: ${onResult['Error']}');
    }
    if (onResult.containsKey('dps')) {
      print('✓ DPS data: ${onResult['dps']}');
    }
    print('');

    await Future.delayed(Duration(seconds: 1));

    print('Test 3: Turn OFF');
    print('-' * 60);
    final offResult = await device.turnOff();
    print('Turn OFF result: $offResult');
    print('');

    if (offResult.containsKey('Error')) {
      print('⚠️  ERROR in turn OFF response: ${offResult['Error']}');
    }
    if (offResult.containsKey('dps')) {
      print('✓ DPS data: ${offResult['dps']}');
    }
    print('');

    print('Test 4: Get Final Status');
    print('-' * 60);
    final finalStatus = await device.status();
    print('Final status result: $finalStatus');
    print('');

    if (finalStatus.containsKey('Error')) {
      print('⚠️  ERROR in final status response: ${finalStatus['Error']}');
    }
    if (finalStatus.containsKey('dps')) {
      print('✓ DPS data: ${finalStatus['dps']}');
    }
  } catch (e, stack) {
    print('✗ Exception: $e');
    print('Stack trace: $stack');
  } finally {
    device.close();
    print('');
    print('Device closed');
  }
}
