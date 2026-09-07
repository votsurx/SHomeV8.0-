/// Tests for pure Dart AES-128 ECB implementation
import 'package:test/test.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../lib/src/core/aes_ecb.dart';

void main() {
  group('AES-128 ECB Tests', () {
    test('Encrypt/decrypt single block', () {
      final key = Uint8List.fromList(
        utf8.encode('0123456789abcdef'),
      ); // 16 bytes
      final cipher = AesEcb(key);

      final plaintext = Uint8List.fromList(
        utf8.encode('Hello, World!123'),
      ); // 16 bytes
      final encrypted = cipher.encryptBlock(plaintext);

      expect(encrypted.length, equals(16));
      expect(encrypted, isNot(equals(plaintext)));

      final decrypted = cipher.decryptBlock(encrypted);
      expect(decrypted, equals(plaintext));
    });

    test('Encrypt/decrypt multiple blocks', () {
      final key = Uint8List.fromList(
        utf8.encode('my_secret_key_16'),
      ); // 16 bytes
      final cipher = AesEcb(key);

      // 32 bytes = 2 blocks
      final plaintext = Uint8List.fromList(
        utf8.encode('This is a test message!!12345678'),
      ); // 32 bytes

      final encrypted = cipher.encrypt(plaintext);
      expect(encrypted.length, equals(32));
      expect(encrypted, isNot(equals(plaintext)));

      final decrypted = cipher.decrypt(encrypted);
      expect(decrypted, equals(plaintext));
    });

    test('Different keys produce different ciphertext', () {
      final key1 = Uint8List.fromList(utf8.encode('key1_1234567890a'));
      final key2 = Uint8List.fromList(utf8.encode('key2_1234567890a'));

      final cipher1 = AesEcb(key1);
      final cipher2 = AesEcb(key2);

      final plaintext = Uint8List.fromList(utf8.encode('Same plaintext!!'));

      final encrypted1 = cipher1.encryptBlock(plaintext);
      final encrypted2 = cipher2.encryptBlock(plaintext);

      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('ECB mode consistency - same plaintext produces same ciphertext', () {
      final key = Uint8List.fromList(utf8.encode('consistent_key16'));
      final cipher = AesEcb(key);

      final block = Uint8List.fromList(utf8.encode('Repeated block!!'));

      // Encrypt same block multiple times
      final encrypted1 = cipher.encryptBlock(block);
      final encrypted2 = cipher.encryptBlock(block);
      final encrypted3 = cipher.encryptBlock(block);

      // ECB mode means same input = same output
      expect(encrypted1, equals(encrypted2));
      expect(encrypted2, equals(encrypted3));
    });

    test('Known test vector - NIST', () {
      // NIST test vector for AES-128
      // Key: 2b7e151628aed2a6abf7158809cf4f3c
      // Plaintext: 6bc1bee22e409f96e93d7e117393172a
      // Ciphertext: 3ad77bb40d7a3660a89ecaf32466ef97

      final key = Uint8List.fromList([
        0x2b,
        0x7e,
        0x15,
        0x16,
        0x28,
        0xae,
        0xd2,
        0xa6,
        0xab,
        0xf7,
        0x15,
        0x88,
        0x09,
        0xcf,
        0x4f,
        0x3c,
      ]);

      final plaintext = Uint8List.fromList([
        0x6b,
        0xc1,
        0xbe,
        0xe2,
        0x2e,
        0x40,
        0x9f,
        0x96,
        0xe9,
        0x3d,
        0x7e,
        0x11,
        0x73,
        0x93,
        0x17,
        0x2a,
      ]);

      final expectedCiphertext = Uint8List.fromList([
        0x3a,
        0xd7,
        0x7b,
        0xb4,
        0x0d,
        0x7a,
        0x36,
        0x60,
        0xa8,
        0x9e,
        0xca,
        0xf3,
        0x24,
        0x66,
        0xef,
        0x97,
      ]);

      final cipher = AesEcb(key);
      final encrypted = cipher.encryptBlock(plaintext);

      expect(encrypted, equals(expectedCiphertext));

      // Also test decryption
      final decrypted = cipher.decryptBlock(encrypted);
      expect(decrypted, equals(plaintext));
    });

    test('Invalid key length throws error', () {
      final shortKey = Uint8List(8); // Only 8 bytes

      expect(() => AesEcb(shortKey), throwsA(isA<ArgumentError>()));
    });

    test('Invalid block length throws error', () {
      final key = Uint8List(16);
      final cipher = AesEcb(key);
      final shortBlock = Uint8List(8); // Only 8 bytes

      expect(
        () => cipher.encryptBlock(shortBlock),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Multi-block encryption with non-aligned length throws error', () {
      final key = Uint8List(16);
      final cipher = AesEcb(key);
      final data = Uint8List(17); // Not multiple of 16

      expect(() => cipher.encrypt(data), throwsA(isA<ArgumentError>()));
    });
  });
}
