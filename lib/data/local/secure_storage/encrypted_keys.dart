/// Синглтон для безопасного хранения ключей.
/// Использует flutter_secure_storage (EncryptedSharedPreferences на Android,
/// Keychain на iOS) для шифрованного хранения.
library;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptedKeys {
  static final EncryptedKeys _instance = EncryptedKeys._();
  factory EncryptedKeys() => _instance;
  EncryptedKeys._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,  // ← AES-256 через Keystore
    ),
  );

  /// Префикс для ключей устройств. Используется в БД как `sec:<uuid>`.
  static const deviceKeyPrefix = 'device_key_';

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // ─── Удобные обёртки для ключей устройств ───

  /// Сохраняет localKey устройства по UUID.
  Future<void> saveDeviceKey(String uuid, String localKey) =>
      save('$deviceKeyPrefix$uuid', localKey);

  /// Читает localKey устройства по UUID.
  Future<String?> getDeviceKey(String uuid) =>
      get('$deviceKeyPrefix$uuid');

  /// Удаляет localKey устройства.
  Future<void> deleteDeviceKey(String uuid) =>
      delete('$deviceKeyPrefix$uuid');
}