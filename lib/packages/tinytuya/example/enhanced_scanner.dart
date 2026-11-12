/// Enhanced scanner example with detailed device information
///
/// This example scans for Tuya devices on your local network and displays
/// comprehensive information about each device found.

import 'package:tinytuya/tinytuya.dart';

void main() async {
  print(
    '╔════════════════════════════════════════════════════════════════════╗',
  );
  print(
    '║              TinyTuya Dart - Network Scanner                       ║',
  );
  print(
    '╚════════════════════════════════════════════════════════════════════╝',
  );
  print('');
  print('Scanning for Tuya devices on local network...');
  print('Scan duration: 15 seconds');
  print('Listening on UDP ports: 6666, 6667, 7000');
  print('Supported protocols: v3.1, v3.3, v3.4, v3.5 (GCM)');
  print('');
  print('Please wait...\n');

  // Perform scan with verbose output
  final devices = await deviceScan(scanTime: 15, verbose: true);

  print('\n${'=' * 70}');
  print('Scan Results');
  print('${'=' * 70}\n');

  if (devices.isEmpty) {
    print('⚠ No devices found!');
    print('');
    print('Troubleshooting tips:');
    print('  1. Ensure devices are powered on and connected to WiFi');
    print('  2. Check that your computer is on the same network');
    print('  3. Verify firewall is not blocking UDP ports 6666, 6667, 7000');
    print('  4. Some devices may not respond to broadcasts');
    return;
  }

  print('✓ Found ${devices.length} device(s):\n');

  // Group devices by protocol version
  final byVersion = <String, List<DiscoveredDevice>>{};
  for (final device in devices) {
    final version = device.version ?? 'unknown';
    byVersion.putIfAbsent(version, () => []).add(device);
  }

  // Display devices grouped by version
  for (final version in byVersion.keys.toList()..sort()) {
    final versionDevices = byVersion[version]!;
    print(
      'Protocol v$version (${versionDevices.length} device${versionDevices.length != 1 ? 's' : ''})',
    );
    print('${'─' * 70}');

    for (var i = 0; i < versionDevices.length; i++) {
      final device = versionDevices[i];

      print('  Device ${i + 1}:');
      print('    IP Address:    ${device.ip}');
      print('    Gateway ID:    ${device.gwId ?? 'N/A'}');
      print('    Product Key:   ${device.productKey ?? 'N/A'}');
      print('    Version:       ${device.version ?? 'N/A'}');

      // Display raw data if available
      if (device.rawData.isNotEmpty) {
        print('    Raw Data:');
        device.rawData.forEach((key, value) {
          if (key != 'ip' && key != 'gwId' && key != 'version') {
            print('      $key: $value');
          }
        });
      }

      if (i < versionDevices.length - 1) {
        print('');
      }
    }
    print('');
  }

  // Summary and recommendations
  print('${'=' * 70}');
  print('Summary & Recommendations');
  print('${'=' * 70}\n');

  for (final device in devices) {
    if (device.gwId == null) {
      print('⚠ Device at ${device.ip} has no Gateway ID');
      continue;
    }

    print('Device: ${device.gwId}');
    print('  IP: ${device.ip}');
    print('  To control this device, you need:');
    print('    1. Device ID: ${device.gwId}');
    print('    2. Local Key: (obtain from Tuya Cloud API or tinytuya wizard)');
    print('    3. IP Address: ${device.ip}');
    print('    4. Version: ${device.version}');
    print('');
    print('  Example code:');
    print('  ```dart');
    print('  final device = Device(');
    print('    devId: \'${device.gwId}\',');
    print('    address: \'${device.ip}\',');
    print('    localKey: \'YOUR_LOCAL_KEY_HERE\',');
    print('    version: ${device.version},');
    print('  );');
    print('  final status = await device.status();');
    print('  ```');
    print('');
  }

  print('For more information on getting local keys, see:');
  print(
    'https://github.com/jasonacox/tinytuya#setup-wizard---getting-local-keys',
  );
}
