/// Payload generation tests
/// Compares Dart Device.generatePayload with Python XenonDevice.generate_payload

import 'package:test/test.dart';
import 'package:tinytuya/src/core/device.dart';
import 'package:tinytuya/src/core/command_types.dart';
import 'dart:convert';
import 'comparison_tests/test_runner.dart';

void main() {
  group('Payload Generation Tests', () {
    test('Generate STATUS payload - compare with Python', () async {
      final testInput = {
        'dev_id': 'test_device_001',
        'local_key': 'test_key_1234567',
        'version': '3.3',
        'command': status,
      };

      // Run Python version
      final pythonOutputStr = await runPythonTest(
        'test/comparison_tests/python_scripts/test_payload_generation.py',
        testInput,
      );
      final pythonOutput = jsonDecode(pythonOutputStr) as Map<String, dynamic>;

      expect(
        pythonOutput['success'],
        isTrue,
        reason: 'Python test should succeed',
      );

      // Run Dart version
      final device = Device(
        deviceId: testInput['dev_id']! as String,
        address: '192.168.1.100',
        localKey: testInput['local_key']! as String,
        version: double.parse(testInput['version']! as String),
      );

      final payload = device.generatePayload(command: status);

      // Parse Dart payload
      final dartPayloadData =
          jsonDecode(utf8.decode(payload.payload)) as Map<String, dynamic>;

      print('Python command: ${pythonOutput['command']}');
      print('Dart   command: ${payload.cmd}');
      print('Python payload: ${pythonOutput['payload_data']}');
      print('Dart   payload: $dartPayloadData');

      // Compare command
      expect(
        payload.cmd,
        equals(pythonOutput['command']),
        reason: 'Command should match',
      );

      // Compare payload structure (excluding timestamp 't' which will differ)
      expect(
        dartPayloadData['devId'],
        equals(pythonOutput['payload_data']['devId']),
        reason: 'devId should match',
      );
      expect(
        dartPayloadData['gwId'],
        equals(pythonOutput['payload_data']['gwId']),
        reason: 'gwId should match',
      );
      expect(
        dartPayloadData.containsKey('t'),
        equals(pythonOutput['payload_data'].containsKey('t')),
        reason: 'Both should have or not have timestamp',
      );
    });

    test('Generate CONTROL payload with data - compare with Python', () async {
      final testInput = {
        'dev_id': 'test_device_002',
        'local_key': 'another_test_key',
        'version': '3.3',
        'command': control,
        'data': {'1': true, '2': false},
      };

      // Run Python version
      final pythonOutputStr = await runPythonTest(
        'test/comparison_tests/python_scripts/test_payload_generation.py',
        testInput,
      );
      final pythonOutput = jsonDecode(pythonOutputStr) as Map<String, dynamic>;

      expect(
        pythonOutput['success'],
        isTrue,
        reason: 'Python test should succeed',
      );

      // Run Dart version
      final device = Device(
        deviceId: testInput['dev_id']! as String,
        address: '192.168.1.100',
        localKey: testInput['local_key']! as String,
        version: double.parse(testInput['version']! as String),
      );

      final payload = device.generatePayload(
        command: control,
        data: testInput['data'] as Map<String, dynamic>,
      );

      // Parse Dart payload
      final dartPayloadData =
          jsonDecode(utf8.decode(payload.payload)) as Map<String, dynamic>;

      print('Python command: ${pythonOutput['command']}');
      print('Dart   command: ${payload.cmd}');
      print('Python payload: ${pythonOutput['payload_data']}');
      print('Dart   payload: $dartPayloadData');

      // Compare command
      expect(
        payload.cmd,
        equals(pythonOutput['command']),
        reason: 'Command should match',
      );

      // Compare dps data
      expect(
        dartPayloadData['dps'],
        equals(pythonOutput['payload_data']['dps']),
        reason: 'DPS data should match',
      );
    });

    test('Generate payload for v3.4 device - compare with Python', () async {
      final testInput = {
        'dev_id': 'test_device_v34',
        'local_key': 'v34_test_key_16b',
        'version': '3.4',
        'command': control,
        'data': {'1': 100},
      };

      // Run Python version
      final pythonOutputStr = await runPythonTest(
        'test/comparison_tests/python_scripts/test_payload_generation.py',
        testInput,
      );
      final pythonOutput = jsonDecode(pythonOutputStr) as Map<String, dynamic>;

      expect(
        pythonOutput['success'],
        isTrue,
        reason: 'Python test should succeed',
      );

      // Run Dart version
      final device = Device(
        deviceId: testInput['dev_id']! as String,
        address: '192.168.1.100',
        localKey: testInput['local_key']! as String,
        version: double.parse(testInput['version']! as String),
      );

      final payload = device.generatePayload(
        command: control,
        data: testInput['data'] as Map<String, dynamic>,
      );

      // Parse Dart payload
      final dartPayloadData =
          jsonDecode(utf8.decode(payload.payload)) as Map<String, dynamic>;

      print('Python command: ${pythonOutput['command']}');
      print('Dart   command: ${payload.cmd}');
      print('Python payload: ${pythonOutput['payload_data']}');
      print('Dart   payload: $dartPayloadData');

      // v3.4+ uses CONTROL_NEW (0x0d) instead of CONTROL (0x07)
      expect(
        payload.cmd,
        equals(pythonOutput['command']),
        reason: 'Command should be overridden to CONTROL_NEW',
      );

      // v3.4+ has different payload structure
      expect(
        dartPayloadData.containsKey('protocol'),
        isTrue,
        reason: 'v3.4 should have protocol field',
      );
      expect(
        dartPayloadData.containsKey('data'),
        isTrue,
        reason: 'v3.4 should have data field',
      );
    });
  });
}
