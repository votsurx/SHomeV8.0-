import 'dart:convert';
import 'dart:typed_data';

class BackupKeyQrException implements Exception {
  const BackupKeyQrException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupKeyQrService {
  static const String prefix = 'shome-backup-key:v1:';
  static const int keyLength = 32;

  const BackupKeyQrService();

  /// Создаёт содержимое QR-кода из Base64URL-ключа.
  String encode(String key) {
    final bytes = _decodeKey(key);

    final normalizedKey = base64UrlEncode(bytes).replaceAll('=', '');

    return '$prefix$normalizedKey';
  }

  /// Извлекает и проверяет ключ из содержимого QR-кода.
  String decode(String value) {
    final raw = value.trim();

    if (!raw.startsWith(prefix)) {
      throw const BackupKeyQrException(
        'QR-код не является ключом SHome',
      );
    }

    final encodedKey = raw.substring(prefix.length).trim();

    if (encodedKey.isEmpty) {
      throw const BackupKeyQrException(
        'QR-код не содержит ключ резервного копирования',
      );
    }

    final bytes = _decodeKey(encodedKey);

    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  Uint8List _decodeKey(String value) {
    try {
      final bytes = base64Url.decode(base64Url.normalize(value));

      if (bytes.length != keyLength) {
        throw const BackupKeyQrException(
          'Некорректная длина ключа резервного копирования',
        );
      }

      return Uint8List.fromList(bytes);
    } catch (error) {
      if (error is BackupKeyQrException) {
        rethrow;
      }

      throw const BackupKeyQrException(
        'Некорректный ключ резервного копирования',
      );
    }
  }
}