/// Device helper methods tests
///
/// Tests turnOn, turnOff, setTimer, updateDps against Python reference implementation

import 'package:test/test.dart';
import 'package:tinytuya/src/core/device.dart';
import 'package:tinytuya/src/core/command_types.dart';
import 'dart:convert';
import 'comparison_tests/test_runner.dart';

void main() {
  group('Device Helper Methods Tests', () {
    test('turnOn() - compare with Python', () async {
      final testInput = {
        'test_type': 'turn_on',
        'dev_id': 'test_device_001',
        'local_key': 'test_key_1234567',
        'version': 3.3,
        'switch': 1,
      };

      // Run Python version
      final pythonOutputStr = await runPythonTest(
        'test/comparison_tests/python_scripts/test_device_helpers.py',
        testInput,
      );
      final pythonOutput = jsonDecode(pythonOutputStr) as Map<String, dynamic>;

      // Run Dart version
      final device = Device(
        deviceId: testInput['dev_id']! as String,
        address: '192.168.1.100',
        localKey: testInput['local_key']! as String,
        version: testInput['version']! as double,
      );

      final payload = device.generatePayload(
        command: control,
        data: {'1': true},
      );
      final dartPayloadData =
          jsonDecode(utf8.decode(payload.payload)) as Map<String, dynamic>;

      print('Python command: ${pythonOutput['command']}');
      print('Dart   command: ${payload.cmd}');
      print('Python payload: ${pythonOutput['payload_data']}');
      print('Dart   payload: $dartPayloadData');

      expect(payload.cmd, equals(pythonOutput['command']));
      expect(
        dartPayloadData['devId'],
        equals(pythonOutput['payload_data']['devId']),
      );
      expect(
        dartPayloadData['uid'],
        equals(pythonOutput['payload_data']['uid']),
      );
      expect(
        dartPayloadData['dps'],
        equals(pythonOutput['payload_data']['dps']),
      );
    });

    test('turnOff() - compare with Python', () async {
      final testInput = {
        'test_type': 'turn_off',
        'dev_id': 'test_device_002',
        'local_key': 'test_key_9876543',
        'version': 3.3,
        'switch': 2,
      };

      // Run Python version
      final pythonOutputStr = await runPythonTest(
        'test/comparison_tests/python_scripts/test_device_helpers.py',
        testInput,
      );
      final pythonOutput = jsonDecode(pythonOutputStr) as Map<String, dynamic>;

      // Run Dart version
      final device = Device(
        deviceId: testInput['dev_id']! as String,
        address: '192.168.1.100',
        localKey: testInput['local_key']! as String,
        version: testInput['version']! as double,
      );

      final payload = device.generatePayload(
        command: control,
        data: {'2': false},
      );
      final dartPayloadData =
          jsonDecode(utf8.decode(payload.payload)) as Map<String, dynamic>;

      print('Python command: ${pythonOutput['command']}');
      print('Dart   command: ${payload.cmd}');
      print('Python payload: ${pythonOutput['payload_data']}');
      print('Dart   payload: $dartPayloadData');

      expect(payload.cmd, equals(pythonOutput['command']));
      expect(
        dartPayloadData['dps'],
        equals(pythonOutput['payload_data']['dps']),
      );
    });

    test('setTimer() - compare with Python', () async {
      final testInput = {
        'test_type': 'set_timer',
        'dev_id': 'test_device_003',
        'local_key': 'test_key_timer01',
        'version': 3.3,
        'num_secs': 3600,
        'dps_id': 7,
      };

      // Run Python version
      final pythonOutputStr = await runPythonTest(
        'test/comparison_tests/python_scripts/test_device_helpers.py',
        testInput,
      );
      final pythonOutput = jsonDecode(pythonOutputStr) as Map<String, dynamic>;

      // Run Dart version
      final device = Device(
        deviceId: testInput['dev_id']! as String,
        address: '192.168.1.100',
        localKey: testInput['local_key']! as String,
        version: testInput['version']! as double,
      );

      final payload = device.generatePayload(
        command: control,
        data: {'7': 3600},
      );
      final dartPayloadData =
          jsonDecode(utf8.decode(payload.payload)) as Map<String, dynamic>;

      print('Python command: ${pythonOutput['command']}');
      print('Dart   command: ${payload.cmd}');
      print('Python payload: ${pythonOutput['payload_data']}');
      print('Dart   payload: $dartPayloadData');

      expect(payload.cmd, equals(pythonOutput['command']));
      expect(
        dartPayloadData['dps']['7'],
        equals(pythonOutput['payload_data']['dps']['7']),
      );
    });

    test('updateDps() - compare with Python', () async {
      final testInput = {
        'test_type': 'updatedps',
        'dev_id': 'test_device_004',
        'local_key': 'test_key_update1',
        'version': 3.3,
        'index': [1, 2, 3],
      };

      // Run Python version
      final pythonOutputStr = await runPythonTest(
        'test/comparison_tests/python_scripts/test_device_helpers.py',
        testInput,
      );
      final pythonOutput = jsonDecode(pythonOutputStr) as Map<String, dynamic>;

      // Run Dart version
      final device = Device(
        deviceId: testInput['dev_id']! as String,
        address: '192.168.1.100',
        localKey: testInput['local_key']! as String,
        version: testInput['version']! as double,
      );

      final payload = device.generatePayload(
        command: updatedps,
        data: [1, 2, 3],
      );
      final dartPayloadData =
          jsonDecode(utf8.decode(payload.payload)) as Map<String, dynamic>;

      print('Python command: ${pythonOutput['command']}');
      print('Dart   command: ${payload.cmd}');
      print('Python payload: ${pythonOutput['payload_data']}');
      print('Dart   payload: $dartPayloadData');

      expect(payload.cmd, equals(pythonOutput['command']));
      expect(
        dartPayloadData['dpId'],
        equals(pythonOutput['payload_data']['dpId']),
      );
    });
  });
}
