/// ECB mode comparison test - Dart vs Python
///
/// This test verifies that our pure-Dart AES-ECB implementation
/// produces identical results to Python's PyCrypto/PyCryptodome

import 'package:test/test.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:tinytuya/src/core/aes_ecb.dart';
import 'package:tinytuya/src/core/crypto_helper.dart';

/// Run Python test and get output
Future<Map<String, dynamic>> runPythonEcbTest(
  Map<String, dynamic> input,
) async {
  // Write input to temp file
  final inputFile = File('test_ecb_input.json');
  await inputFile.writeAsString(jsonEncode(input));

  try {
    final result = await Process.run('python3', [
      'test/comparison_tests/python_scripts/test_ecb_crypto.py',
      'test_ecb_input.json',
    ]);

    if (result.exitCode != 0) {
      throw Exception('Python test failed: ${result.stderr}');
    }

    return jsonDecode(result.stdout.toString());
  } finally {
    if (await inputFile.exists()) {
      await inputFile.delete();
    }
  }
}

void main() {
  group('ECB Python Comparison Tests', () {
    test('ECB encryption matches Python', () async {
      final testInput = {
        'test_type': 'encrypt',
        'key': 'test_key_1234567890abcdef',
        'plaintext': 'Hello, World!',
      };

      // Run Python version
      final pythonResult = await runPythonEcbTest(testInput);

      // Run Dart version
      final key = Uint8List.fromList(utf8.encode(testInput['key']!));
      final paddedKey = Uint8List(16);
      paddedKey.setRange(0, key.length > 16 ? 16 : key.length, key);

      final plaintext = Uint8List.fromList(
        utf8.encode(testInput['plaintext']!),
      );
      final padded = AESCipher.pad(plaintext, 16);

      final cipher = AesEcb(paddedKey);
      final encrypted = cipher.encrypt(padded);

      // Compare
      final pythonCiphertext = pythonResult['ciphertext_hex'];
      final dartCiphertext = encrypted
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('');

      print('Python ciphertext: $pythonCiphertext');
      print('Dart   ciphertext: $dartCiphertext');

      expect(
        dartCiphertext,
        equals(pythonCiphertext),
        reason: 'Dart ECB encryption should match Python',
      );
    });

    test('ECB decryption matches Python', () async {
      // First encrypt with Python to get a ciphertext
      final encryptInput = {
        'test_type': 'encrypt',
        'key': 'my_secret_key_16',
        'plaintext': 'Test message!',
      };

      final encryptResult = await runPythonEcbTest(encryptInput);
      final ciphertextHex = encryptResult['ciphertext_hex'];

      // Now decrypt with both Python and Dart
      final decryptInput = {
        'test_type': 'decrypt',
        'key': 'my_secret_key_16',
        'ciphertext_hex': ciphertextHex,
      };

      final pythonResult = await runPythonEcbTest(decryptInput);

      // Dart decryption
      final key = Uint8List.fromList(utf8.encode(decryptInput['key']!));
      final paddedKey = Uint8List(16);
      paddedKey.setRange(0, key.length > 16 ? 16 : key.length, key);

      final ciphertext = Uint8List.fromList(
        List<int>.generate(
          ciphertextHex.length ~/ 2,
          (i) =>
              int.parse(ciphertextHex.substring(i * 2, i * 2 + 2), radix: 16),
        ),
      );

      final cipher = AesEcb(paddedKey);
      final decrypted = cipher.decrypt(ciphertext);
      final unpadded = AESCipher.unpad(decrypted);
      final plaintext = utf8.decode(unpadded);

      print('Python plaintext: ${pythonResult['plaintext']}');
      print('Dart   plaintext: $plaintext');

      expect(
        plaintext,
        equals(pythonResult['plaintext']),
        reason: 'Dart ECB decryption should match Python',
      );
    });

    test('ECB roundtrip matches Python', () async {
      final testInput = {
        'test_type': 'roundtrip',
        'key': 'roundtrip_key_16b',
        'plaintext': 'Roundtrip test message!',
      };

      final pythonResult = await runPythonEcbTest(testInput);

      // Dart roundtrip
      final key = Uint8List.fromList(utf8.encode(testInput['key']!));
      final paddedKey = Uint8List(16);
      paddedKey.setRange(0, key.length > 16 ? 16 : key.length, key);

      final plaintext = Uint8List.fromList(
        utf8.encode(testInput['plaintext']!),
      );
      final padded = AESCipher.pad(plaintext, 16);

      final cipher = AesEcb(paddedKey);
      final encrypted = cipher.encrypt(padded);
      final decrypted = cipher.decrypt(encrypted);
      final unpadded = AESCipher.unpad(decrypted);
      final result = utf8.decode(unpadded);

      print('Python match: ${pythonResult['match']}');
      print('Dart   result: $result');
      print('Original: ${testInput['plaintext']}');

      expect(
        pythonResult['match'],
        isTrue,
        reason: 'Python roundtrip should succeed',
      );
      expect(
        result,
        equals(testInput['plaintext']),
        reason: 'Dart roundtrip should succeed',
      );
      expect(
        result,
        equals(pythonResult['decrypted_plaintext']),
        reason: 'Dart and Python results should match',
      );
    });

    test('Multiple test vectors match Python', () async {
      final testVectors = [
        {'key': 'key1_1234567890ab', 'plaintext': 'Short'},
        {'key': 'key2_abcdefghijkl', 'plaintext': 'Medium length text here'},
        {
          'key': 'key3_zyxwvutsrqpo',
          'plaintext':
              'A longer message that spans multiple blocks of encryption data',
        },
      ];

      for (var i = 0; i < testVectors.length; i++) {
        final vector = testVectors[i];
        print('\nTesting vector ${i + 1}: "${vector['plaintext']}"');

        final testInput = {'test_type': 'roundtrip', ...vector};

        final pythonResult = await runPythonEcbTest(testInput);

        // Dart version
        final key = Uint8List.fromList(utf8.encode(vector['key']!));
        final paddedKey = Uint8List(16);
        paddedKey.setRange(0, key.length > 16 ? 16 : key.length, key);

        final plaintext = Uint8List.fromList(utf8.encode(vector['plaintext']!));
        final padded = AESCipher.pad(plaintext, 16);

        final cipher = AesEcb(paddedKey);
        final encrypted = cipher.encrypt(padded);

        final pythonCiphertext = pythonResult['ciphertext_hex'];
        final dartCiphertext = encrypted
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join('');

        expect(
          dartCiphertext,
          equals(pythonCiphertext),
          reason: 'Vector ${i + 1} ciphertext should match',
        );
        expect(
          pythonResult['match'],
          isTrue,
          reason: 'Vector ${i + 1} Python roundtrip should succeed',
        );
      }
    });
  });
}
