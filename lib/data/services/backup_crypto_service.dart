import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../local/secure_storage/encrypted_keys.dart';

class BackupCryptoException implements Exception {
  const BackupCryptoException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupCryptoService {
  BackupCryptoService({
    EncryptedKeys? keys,
    AesGcm? cipher,
  })  : _keys = keys ?? EncryptedKeys(),
        _cipher = cipher ?? AesGcm.with256bits();

  static const String formatPrefix = 'SHBK1:';
  static const int keyLength = 32;
  static const int nonceLength = 12;

  final EncryptedKeys _keys;
  final AesGcm _cipher;

  Future<bool> hasKey() async {
    final key = await _keys.getBackupEncryptionKey();
    return key != null && key.isNotEmpty;
  }

  Future<void> generateKey() async {
    final bytes = Uint8List.fromList(
      List<int>.generate(
        keyLength,
            (_) => Random.secure().nextInt(256),
      ),
    );

    final encoded = base64UrlEncode(bytes).replaceAll('=', '');
    await _keys.saveBackupEncryptionKey(encoded);
  }

  Future<String?> getKey() {
    return _keys.getBackupEncryptionKey();
  }

  Future<void> deleteKey() {
    return _keys.deleteBackupEncryptionKey();
  }

  Future<SecretKey> _readSecretKey() async {
    final encoded = await _keys.getBackupEncryptionKey();

    if (encoded == null || encoded.isEmpty) {
      throw const BackupCryptoException(
        'Ключ резервного копирования не создан',
      );
    }

    try {
      final normalized = base64Url.normalize(encoded);
      final bytes = base64Url.decode(normalized);

      if (bytes.length != keyLength) {
        throw const BackupCryptoException(
          'Некорректная длина ключа резервного копирования',
        );
      }

      return SecretKey(bytes);
    } catch (error) {
      if (error is BackupCryptoException) rethrow;

      throw const BackupCryptoException(
        'Ключ резервного копирования повреждён',
      );
    }
  }

  Future<String> encrypt(String plaintext) async {
    final secretKey = await _readSecretKey();

    final nonce = Uint8List.fromList(
      List<int>.generate(
        nonceLength,
            (_) => Random.secure().nextInt(256),
      ),
    );

    final box = await _cipher.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    final payload = <String, dynamic>{
      'version': 1,
      'algorithm': 'AES-256-GCM',
      'nonce': base64UrlEncode(box.nonce).replaceAll('=', ''),
      'mac': base64UrlEncode(box.mac.bytes).replaceAll('=', ''),
      'ciphertext': base64UrlEncode(box.cipherText).replaceAll('=', ''),
    };

    return '$formatPrefix${base64UrlEncode(utf8.encode(jsonEncode(payload))).replaceAll('=', '')}';
  }

  Future<String> decrypt(String container) async {
    if (!container.startsWith(formatPrefix)) {
      throw const BackupCryptoException(
        'Формат резервной копии не поддерживается',
      );
    }

    final encodedPayload = container.substring(formatPrefix.length);

    try {
      final payloadBytes = base64Url.decode(
        base64Url.normalize(encodedPayload),
      );

      final payload = jsonDecode(
        utf8.decode(payloadBytes),
      );

      if (payload is! Map<String, dynamic>) {
        throw const BackupCryptoException(
          'Некорректный контейнер резервной копии',
        );
      }

      if (payload['version'] != 1 ||
          payload['algorithm'] != 'AES-256-GCM') {
        throw const BackupCryptoException(
          'Неподдерживаемая версия резервной копии',
        );
      }

      final nonce = base64Url.decode(
        base64Url.normalize(payload['nonce'] as String),
      );

      final mac = base64Url.decode(
        base64Url.normalize(payload['mac'] as String),
      );

      final ciphertext = base64Url.decode(
        base64Url.normalize(payload['ciphertext'] as String),
      );

      if (nonce.length != nonceLength) {
        throw const BackupCryptoException(
          'Некорректный nonce резервной копии',
        );
      }

      final secretKey = await _readSecretKey();

      final plaintext = await _cipher.decrypt(
        SecretBox(
          ciphertext,
          nonce: nonce,
          mac: Mac(mac),
        ),
        secretKey: secretKey,
      );

      return utf8.decode(plaintext);
    } on SecretBoxAuthenticationError {
      throw const BackupCryptoException(
        'Неверный ключ или резервная копия повреждена',
      );
    } on BackupCryptoException {
      rethrow;
    } catch (_) {
      throw const BackupCryptoException(
        'Не удалось расшифровать резервную копию',
      );
    }
  }
}