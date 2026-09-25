/// Синглтон для безопасного хранения ключей.
/// Использует flutter_secure_storage для шифрованного хранения
/// локальных ключей Tuya, VK-токенов и других чувствительных данных.
/// На Android данные хранятся в EncryptedSharedPreferences (AES-256),
/// на iOS — в Keychain.
library;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptedKeys {
  static final EncryptedKeys _instance = EncryptedKeys._();
  factory EncryptedKeys() => _instance;
  EncryptedKeys._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Префикс для ключей устройств Tuya.
  static const deviceKeyPrefix = 'device_key_';

  /// Ключ для VK-токена.
  static const _vkTokenKey = 'vk_token';

  /// Ключ для VK user_id.
  static const _vkUserIdKey = 'vk_user_id';

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // ─── Обёртки для ключей устройств ───

  Future<void> saveDeviceKey(String uuid, String localKey) =>
      save('$deviceKeyPrefix$uuid', localKey);

  Future<String?> getDeviceKey(String uuid) =>
      get('$deviceKeyPrefix$uuid');

  Future<void> deleteDeviceKey(String uuid) =>
      delete('$deviceKeyPrefix$uuid');

  // ─── Обёртки для VK ───

  Future<void> saveVkToken(String token) => save(_vkTokenKey, token);

  Future<String?> getVkToken() => get(_vkTokenKey);

  Future<void> deleteVkToken() => delete(_vkTokenKey);

  Future<void> saveVkUserId(String userId) => save(_vkUserIdKey, userId);

  Future<String?> getVkUserId() => get(_vkUserIdKey);

  Future<void> deleteVkUserId() => delete(_vkUserIdKey);
}