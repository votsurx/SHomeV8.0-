/// Example demonstrating Tuya Cloud API usage
///
/// This example shows how to:
/// - Connect to Tuya Cloud
/// - Get list of devices
/// - Get device status
/// - Send commands to devices
///
/// Before running this example:
/// 1. Sign up for Tuya IoT Platform: https://iot.tuya.com/
/// 2. Create a Cloud Project and get your API Key and Secret
/// 3. Link your Tuya devices to the project
/// 4. Set environment variables or update the constants below

import 'package:tinytuya/tinytuya.dart';

// Replace these with your actual credentials
const apiKey = 'YOUR_API_KEY';
const apiSecret = 'YOUR_API_SECRET';
const apiRegion = 'us'; // us, eu, cn, in, sg, etc.

void main() async {
  print('=== Tuya Cloud API Example ===\n');

  // Create Cloud API client
  final cloud = Cloud(
    apiKey: apiKey,
    apiSecret: apiSecret,
    apiRegion: apiRegion,
  );

  // Initialize and get OAuth token
  print('Authenticating with Tuya Cloud...');
  final success = await cloud.init();
  if (!success) {
    print('Failed to authenticate: ${cloud.error}');
    return;
  }
  print('Successfully authenticated!\n');

  // Get list of all devices
  print('Fetching device list...');
  final devices = await cloud.getDevices();
  print('Found ${devices.length} devices:\n');

  for (final device in devices) {
    print('Device: ${device['name'] ?? 'Unknown'}');
    print('  ID: ${device['id']}');
    print('  Product ID: ${device['product_id'] ?? 'N/A'}');
    print('  Local Key: ${device['local_key'] ?? 'N/A'}');
    print('  Online: ${device['online'] ?? 'N/A'}');
    print('  IP: ${device['ip'] ?? 'N/A'}');
    print('');
  }

  // Example: Get status of first device
  if (devices.isNotEmpty) {
    final deviceId = devices[0]['id'] as String;
    print('Getting status for device: $deviceId');

    final status = await cloud.getStatus(deviceId);
    if (status != null && status['success'] == true) {
      print('Status: ${status['result']}');
    } else {
      print('Failed to get status: ${cloud.error}');
    }
    print('');

    // Example: Get device specifications
    print('Getting specifications for device: $deviceId');
    final specs = await cloud.getDps(deviceId);
    if (specs != null && specs['success'] == true) {
      print('Specifications:');
      final result = specs['result'] as Map<String, dynamic>?;
      if (result != null && result.containsKey('functions')) {
        final functions = result['functions'] as List;
        for (final func in functions) {
          print('  - ${func['code']}: ${func['type']} (${func['values']})');
        }
      }
    } else {
      print('Failed to get specifications: ${cloud.error}');
    }
    print('');

    // Example: Send command to device (turn on)
    print('Sending command to device: $deviceId');
    final command = {
      'commands': [
        {'code': 'switch_1', 'value': true},
      ],
    };

    final result = await cloud.sendCommand(deviceId, command);
    if (result != null && result['success'] == true) {
      print('Command sent successfully!');
    } else {
      print('Failed to send command: ${cloud.error}');
    }
  }

  print('\n=== Example Complete ===');
}
