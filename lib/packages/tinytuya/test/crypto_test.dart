/// Basic crypto tests for AESCipher
import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  group('AESCipher Tests', () {
    test('Create cipher from string', () {
      final cipher = AESCipher.fromString('test_key_123456');
      expect(cipher.key.length, equals(16));
    });

    test('PKCS7 padding', () {
      final data = Uint8List.fromList([1, 2, 3, 4, 5]);
      final padded = AESCipher.pad(data, 16);

      expect(padded.length % 16, equals(0));
      expect(padded.length, equals(16));

      // Last byte should be the padding length
      expect(padded[padded.length - 1], equals(11)); // 16 - 5 = 11
    });

    test('PKCS7 unpadding', () {
      final data = Uint8List.fromList([1, 2, 3, 4, 5]);
      final padded = AESCipher.pad(data, 16);
      final unpadded = AESCipher.unpad(padded);

      expect(unpadded, equals(data));
    });

    test('ECB encrypt/decrypt roundtrip', () async {
      final cipher = AESCipher.fromString('test_key_1234567890abcdef');
      final plaintext = Uint8List.fromList(utf8.encode('Hello, World!'));

      // Encrypt
      final encrypted = await cipher.encrypt(
        raw: plaintext,
        useBase64: false,
        usePad: true,
        useIv: false,
      );

      expect(encrypted, isA<Uint8List>());

      // Decrypt
      final decrypted = await cipher.decrypt(
        enc: encrypted,
        useBase64: false,
        decodeText: true,
        useIv: false,
      );

      expect(decrypted, equals('Hello, World!'));
    });

    test('ECB encrypt with base64', () async {
      final cipher = AESCipher.fromString('test_key_1234567890abcdef');
      final plaintext = Uint8List.fromList(utf8.encode('Test'));

      final encrypted = await cipher.encrypt(
        raw: plaintext,
        useBase64: true,
        usePad: true,
        useIv: false,
      );

      expect(encrypted, isA<String>());

      final decrypted = await cipher.decrypt(
        enc: encrypted,
        useBase64: true,
        decodeText: true,
        useIv: false,
      );

      expect(decrypted, equals('Test'));
    });

    test('GCM encrypt/decrypt roundtrip', () async {
      final cipher = AESCipher.fromString('test_key_1234567890abcdef');
      final plaintext = Uint8List.fromList(utf8.encode('GCM Test Message'));

      // Encrypt with GCM mode
      final encrypted = await cipher.encrypt(
        raw: plaintext,
        useBase64: false,
        useIv: true,
      );

      expect(encrypted, isA<Uint8List>());

      // Encrypted data should contain: IV (12) + ciphertext + tag (16)
      expect(encrypted.length, greaterThan(28));

      // Decrypt with GCM mode
      final decrypted = await cipher.decrypt(
        enc: encrypted,
        useBase64: false,
        decodeText: true,
        useIv: true,
      );

      expect(decrypted, equals('GCM Test Message'));
    });

    test('GCM with header (AAD)', () async {
      final cipher = AESCipher.fromString('test_key_1234567890abcdef');
      final plaintext = Uint8List.fromList(
        utf8.encode('Authenticated Message'),
      );
      final header = Uint8List.fromList(utf8.encode('header_data'));

      // Encrypt with header
      final encrypted = await cipher.encrypt(
        raw: plaintext,
        useBase64: false,
        useIv: true,
        header: header,
      );

      // Decrypt with same header
      final decrypted = await cipher.decrypt(
        enc: encrypted,
        useBase64: false,
        decodeText: true,
        useIv: true,
        header: header,
      );

      expect(decrypted, equals('Authenticated Message'));
    });

    test('Different keys produce different results', () async {
      final cipher1 = AESCipher.fromString('key1_1234567890abc');
      final cipher2 = AESCipher.fromString('key2_1234567890abc');
      final plaintext = Uint8List.fromList(utf8.encode('Same message'));

      final encrypted1 = await cipher1.encrypt(
        raw: plaintext,
        useBase64: true,
        useIv: false,
      );

      final encrypted2 = await cipher2.encrypt(
        raw: plaintext,
        useBase64: true,
        useIv: false,
      );

      expect(encrypted1, isNot(equals(encrypted2)));
    });
  });
}
