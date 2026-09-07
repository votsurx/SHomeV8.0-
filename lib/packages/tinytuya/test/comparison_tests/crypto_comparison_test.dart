/// Crypto function comparison tests
///
/// Tests AES encryption/decryption against Python reference implementation

import 'package:test/test.dart';
import 'package:tinytuya/src/core/crypto_helper.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'test_runner.dart';

void main() {
  group('Crypto Comparison Tests', () {
    test('AES-ECB encryption - compare with Python', () async {
      final testInput = {
        'test_type': 'encrypt',
        'key': 'test_key_123456',
        'plaintext': 'Hello World',
      };

      // Run Python version (uses base64-encoded ECB by default)
      final pythonOutputStr = await runPythonTest(
        'test/comparison_tests/python_scripts/test_crypto.py',
        testInput,
      );
      final pythonOutput = jsonDecode(pythonOutputStr) as Map<String, dynamic>;

      // Run Dart version
      final cipher = AESCipher.fromString(testInput['key']!);
      final plaintext = Uint8List.fromList(
        utf8.encode(testInput['plaintext']!),
      );

      // Python's AESCipher.encrypt() uses base64=True, pad=True, iv=False by default
      final encrypted = await cipher.encrypt(
        raw: plaintext,
        useBase64: true,
        usePad: true,
        useIv: false,
      );

      print('Python encrypted (base64): ${pythonOutput['encrypted']}');
      print('Dart   encrypted (base64): $encrypted');

      expect(
        encrypted,
        equals(pythonOutput['encrypted']),
        reason: 'Dart and Python ECB encryption should match',
      );
    });

    test('AES-ECB roundtrip - compare with Python', () async {
      // First encrypt with Python
      final encryptInput = {
        'test_type': 'encrypt',
        'key': 'my_secret_key_16',
        'plaintext': 'Test roundtrip!',
      };

      final pythonEncryptOutputStr = await runPythonTest(
        'test/comparison_tests/python_scripts/test_crypto.py',
        encryptInput,
      );
      final pythonEncryptOutput =
          jsonDecode(pythonEncryptOutputStr) as Map<String, dynamic>;

      // Now decrypt with Dart
      final cipher = AESCipher.fromString(encryptInput['key']!);
      final decrypted = await cipher.decrypt(
        enc: pythonEncryptOutput['encrypted'],
        useBase64: true,
        decodeText: true,
        useIv: false,
      );

      print('Original plaintext: ${encryptInput['plaintext']}');
      print('Dart   decrypted:   $decrypted');

      expect(
        decrypted,
        equals(encryptInput['plaintext']),
        reason: 'Dart should decrypt Python-encrypted data correctly',
      );
    });
  });
}
