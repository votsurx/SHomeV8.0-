import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';

/// Helper to run Python test script
Future<Map<String, dynamic>> runPythonSignatureTest() async {
  final result = await Process.run('python3', [
    'test/comparison_tests/python_scripts/test_cloud_signature.py',
  ]);

  if (result.exitCode != 0) {
    throw Exception('Python test failed: ${result.stderr}');
  }

  return jsonDecode(result.stdout.toString().trim()) as Map<String, dynamic>;
}

void main() {
  group('Cloud API Signature Generation', () {
    late Map<String, dynamic> pythonResults;
    const apiKey = 'test_key_12345';
    const apiSecret = 'test_secret_abcde';
    const timestamp = 1234567890000;

    setUpAll(() async {
      pythonResults = await runPythonSignatureTest();
    });

    test(
      'GET request without token (initial token request) - compare with Python',
      () {
        final cloud = Cloud(
          apiKey: apiKey,
          apiSecret: apiSecret,
          apiRegion: 'us',
          token: null,
          newSignAlgorithm: true,
        );

        final signature = cloud.generateSignature(
          timestamp: timestamp,
          action: 'GET',
          body: '',
          headers: {},
          urlPath: 'https://openapi.tuyaus.com/v1.0/token',
        );

        expect(signature, equals(pythonResults['get_token_no_token']));
      },
    );

    test('GET request with token - compare with Python', () {
      final cloud = Cloud(
        apiKey: apiKey,
        apiSecret: apiSecret,
        apiRegion: 'us',
        token: 'access_token_xyz',
        newSignAlgorithm: true,
      );

      final signature = cloud.generateSignature(
        timestamp: timestamp,
        action: 'GET',
        body: '',
        headers: {},
        urlPath:
            'https://openapi.tuyaus.com/v1.0/iot-01/associated-users/devices',
      );

      expect(signature, equals(pythonResults['get_with_token']));
    });

    test('POST request with body - compare with Python', () {
      final cloud = Cloud(
        apiKey: apiKey,
        apiSecret: apiSecret,
        apiRegion: 'us',
        token: 'access_token_xyz',
        newSignAlgorithm: true,
      );

      final body = '{"commands":[{"code":"switch_1","value":true}]}';
      final headers = {
        'Content-Type': 'application/json',
        'Signature-Headers': 'Content-Type',
      };

      final signature = cloud.generateSignature(
        timestamp: timestamp,
        action: 'POST',
        body: body,
        headers: headers,
        urlPath:
            'https://openapi.tuyaus.com/v1.0/iot-03/devices/test_device_id/commands',
      );

      expect(signature, equals(pythonResults['post_with_body']));
    });

    test('GET request with query parameters - compare with Python', () {
      final cloud = Cloud(
        apiKey: apiKey,
        apiSecret: apiSecret,
        apiRegion: 'us',
        token: 'access_token_xyz',
        newSignAlgorithm: true,
      );

      final signature = cloud.generateSignature(
        timestamp: timestamp,
        action: 'GET',
        body: '',
        headers: {},
        urlPath:
            'https://openapi.tuyaus.com/v1.0/iot-01/associated-users/devices?size=100',
      );

      expect(signature, equals(pythonResults['get_with_query']));
    });

    test('PUT request - compare with Python', () {
      final cloud = Cloud(
        apiKey: apiKey,
        apiSecret: apiSecret,
        apiRegion: 'us',
        token: 'access_token_xyz',
        newSignAlgorithm: true,
      );

      final body = '{"name":"Updated Name"}';
      final headers = {
        'Content-Type': 'application/json',
        'Signature-Headers': 'Content-Type',
      };

      final signature = cloud.generateSignature(
        timestamp: timestamp,
        action: 'PUT',
        body: body,
        headers: headers,
        urlPath: 'https://openapi.tuyaus.com/v1.0/devices/test_device_id',
      );

      expect(signature, equals(pythonResults['put_request']));
    });
  });
}
