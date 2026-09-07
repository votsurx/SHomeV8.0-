/// Helper functions for integration tests
library;

import 'dart:convert';
import 'dart:io';

/// Load device configuration from devices.json
/// Returns null if file doesn't exist (allows tests to skip gracefully)
Future<Map<String, dynamic>?> loadDeviceConfig() async {
  final configFile = File('test/integration/devices.json');
  if (!configFile.existsSync()) {
    return null; // File not found - test will skip
  }
  try {
    return jsonDecode(await configFile.readAsString());
  } catch (e) {
    return null; // Invalid JSON - test will skip
  }
}

/// Find a device by version from the config
Map<String, dynamic>? findDeviceByVersion(
  Map<String, dynamic> config,
  double version,
) {
  final devices = config['devices'] as List;
  return devices.firstWhere((d) => d['version'] == version, orElse: () => null);
}
