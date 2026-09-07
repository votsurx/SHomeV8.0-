/// Test script for real Tuya devices
///
/// This example connects to your actual devices and tests basic functionality.
/// Configuration is loaded from devices.json

import 'dart:convert';
import 'dart:io';
import 'package:tinytuya/tinytuya.dart';

/// Device configuration
class DeviceConfig {
  final String name;
  final String deviceId;
  final String localKey;
  final String ip;
  final double version;
  final String type;

  DeviceConfig({
    required this.name,
    required this.deviceId,
    required this.localKey,
    required this.ip,
    required this.version,
    required this.type,
  });

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    return DeviceConfig(
      name: json['name'] as String,
      deviceId: json['device_id'] as String,
      localKey: json['local_key'] as String,
      ip: json['ip'] as String,
      version: (json['version'] as num).toDouble(),
      type: json['type'] as String,
    );
  }
}

/// Load device configuration from JSON file
List<DeviceConfig> loadDevices() {
  final file = File('example/devices.json');
  if (!file.existsSync()) {
    print('ERROR: devices.json not found!');
    print('Please create example/devices.json with your device configuration.');
    exit(1);
  }

  final content = file.readAsStringSync();
  final json = jsonDecode(content) as Map<String, dynamic>;
  final devicesList = json['devices'] as List;

  return devicesList
      .map((d) => DeviceConfig.fromJson(d as Map<String, dynamic>))
      .toList();
}

/// Test basic device connectivity
Future<void> testDevice(DeviceConfig config) async {
  print('\n${'=' * 70}');
  print('Testing: ${config.name}');
  print('${'=' * 70}');
  print('Device ID: ${config.deviceId}');
  print('IP: ${config.ip}');
  print('Version: ${config.version}');
  print('Type: ${config.type}');
  print('');

  final device = Device(
    deviceId: config.deviceId,
    address: config.ip,
    localKey: config.localKey,
    version: config.version,
  );

  try {
    // Test 1: Get device status
    print('Test 1: Getting device status...');
    final status = await device.status();
    print('✓ Status retrieved successfully!');
    print('  Raw response: $status');

    if (status.containsKey('dps')) {
      final dps = status['dps'] as Map<String, dynamic>;
      print('  DPS values:');
      dps.forEach((key, value) {
        print('    DPS $key: $value (${value.runtimeType})');
      });
    }
    print('');

    // Test 2: Turn on (if supported)
    print('Test 2: Attempting to turn device ON...');
    try {
      await device.turnOn(switchNum: '1', nowait: false);
      print('✓ Turn ON command sent successfully!');
      await Future.delayed(Duration(seconds: 1));

      // Check status after turning on
      final afterOn = await device.status();
      if (afterOn.containsKey('dps')) {
        final dps = afterOn['dps'] as Map<String, dynamic>;
        print('  Status after ON: DPS 1 = ${dps['1']}');
      }
    } catch (e) {
      print('⚠ Turn ON failed (device may not support this): $e');
    }
    print('');

    // Test 3: Turn off (if supported)
    print('Test 3: Attempting to turn device OFF...');
    try {
      await device.turnOff(switchNum: '1', nowait: false);
      print('✓ Turn OFF command sent successfully!');
      await Future.delayed(Duration(seconds: 1));

      // Check status after turning off
      final afterOff = await device.status();
      if (afterOff.containsKey('dps')) {
        final dps = afterOff['dps'] as Map<String, dynamic>;
        print('  Status after OFF: DPS 1 = ${dps['1']}');
      }
    } catch (e) {
      print('⚠ Turn OFF failed (device may not support this): $e');
    }
    print('');

    // Test 4: Test specific device type features
    if (config.type == 'bulb') {
      await testBulb(config);
    } else if (config.type == 'outlet') {
      await testOutlet(config);
    }

    print('✓ All tests completed for ${config.name}');
  } catch (e, stackTrace) {
    print('✗ ERROR testing device: $e');
    print('Stack trace: $stackTrace');
  } finally {
    device.close();
    print('Device connection closed.\n');
  }
}

/// Test bulb-specific features
Future<void> testBulb(DeviceConfig config) async {
  print('Test 4: Testing bulb-specific features...');

  final bulb = BulbDevice(
    deviceId: config.deviceId,
    address: config.ip,
    localKey: config.localKey,
    version: config.version,
  );

  try {
    // Get status and detect bulb type
    final status = await bulb.status();
    bulb.detectBulb(response: status);

    if (bulb.bulbConfigured) {
      print('  ✓ Bulb type detected: ${bulb.bulbType}');
      print('  DPS configuration:');
      bulb.dpset.forEach((key, value) {
        print('    $key: $value');
      });
    } else {
      print('  ⚠ Could not detect bulb type automatically');
    }

    // Test color change (red)
    print('  Setting color to RED...');
    await bulb.setColour(255, 0, 0);
    await Future.delayed(Duration(seconds: 2));

    // Test color change (green)
    print('  Setting color to GREEN...');
    await bulb.setColour(0, 255, 0);
    await Future.delayed(Duration(seconds: 2));

    // Test color change (blue)
    print('  Setting color to BLUE...');
    await bulb.setColour(0, 0, 255);
    await Future.delayed(Duration(seconds: 2));

    // Test white mode
    print('  Setting to WHITE mode...');
    await bulb.setMode('white');
    await bulb.setBrightnessPercentage(50);
    await Future.delayed(Duration(seconds: 2));

    print('  ✓ Bulb tests completed!');
  } catch (e) {
    print('  ⚠ Bulb test error: $e');
  } finally {
    bulb.close();
  }
}

/// Test outlet-specific features
Future<void> testOutlet(DeviceConfig config) async {
  print('Test 4: Testing outlet-specific features...');

  final outlet = OutletDevice(
    deviceId: config.deviceId,
    address: config.ip,
    localKey: config.localKey,
    version: config.version,
  );

  try {
    // Test dimmer at different levels
    for (final level in [25, 50, 75, 100]) {
      print('  Setting dimmer to $level%...');
      await outlet.setDimmer(percentage: level);
      await Future.delayed(Duration(seconds: 1));

      final status = await outlet.status();
      if (status.containsKey('dps')) {
        print('  Current DPS: ${status['dps']}');
      }
    }

    print('  ✓ Outlet tests completed!');
  } catch (e) {
    print('  ⚠ Outlet test error: $e');
  } finally {
    outlet.close();
  }
}

/// Scan network and verify configured devices are present
Future<Map<String, DiscoveredDevice>> scanAndVerify(
  List<DeviceConfig> devices,
) async {
  print('${'=' * 70}');
  print('Step 1: Scanning local network for Tuya devices...');
  print('${'=' * 70}');
  print('Scan duration: 10 seconds');
  print('Listening on ports: 6666, 6667, 7000');
  print('');

  final discovered = await deviceScan(scanTime: 10, verbose: true);

  print('\n✓ Scan complete! Found ${discovered.length} device(s):\n');

  final deviceMap = <String, DiscoveredDevice>{};

  for (final device in discovered) {
    print('  Device: ${device.ip}');
    print('    Gateway ID: ${device.gwId}');
    print('    Version: ${device.version}');
    print('    Product Key: ${device.productKey}');

    if (device.gwId != null) {
      deviceMap[device.gwId!] = device;
    }
    print('');
  }

  // Verify all configured devices were found
  print('Verifying configured devices are on network:');
  for (final config in devices) {
    final found = deviceMap.containsKey(config.deviceId);
    final status = found ? '✓' : '✗';
    print('  $status ${config.name} (${config.deviceId})');

    if (found) {
      final discovered = deviceMap[config.deviceId]!;
      print('    Found at: ${discovered.ip}');
      print('    Version: ${discovered.version}');

      // Check if IP matches
      if (discovered.ip != config.ip) {
        print('    ⚠ WARNING: IP mismatch!');
        print('      Expected: ${config.ip}');
        print('      Found: ${discovered.ip}');
      }
    } else {
      print('    ⚠ Device NOT found on network!');
      print('      Expected at: ${config.ip}');
    }
    print('');
  }

  return deviceMap;
}

void main() async {
  print(
    '╔════════════════════════════════════════════════════════════════════╗',
  );
  print(
    '║            TinyTuya Dart - Real Device Test Suite                 ║',
  );
  print(
    '╚════════════════════════════════════════════════════════════════════╝',
  );
  print('');

  // Load device configuration
  print('Loading device configuration from devices.json...');
  final devices = loadDevices();
  print('✓ Loaded ${devices.length} device(s)\n');

  // Scan network and verify devices
  await scanAndVerify(devices);

  // Ask user if they want to continue with tests
  print('\n${'=' * 70}');
  print('Continue with device control tests? (y/n)');
  print('${'=' * 70}');
  stdout.write('> ');
  final response = stdin.readLineSync();

  if (response?.toLowerCase() != 'y') {
    print('Tests cancelled by user.');
    return;
  }

  // Test each device
  print('\n\n');
  for (final config in devices) {
    await testDevice(config);
    await Future.delayed(Duration(seconds: 1));
  }

  print(
    '╔════════════════════════════════════════════════════════════════════╗',
  );
  print(
    '║                    All Tests Completed!                           ║',
  );
  print(
    '╚════════════════════════════════════════════════════════════════════╝',
  );
}
