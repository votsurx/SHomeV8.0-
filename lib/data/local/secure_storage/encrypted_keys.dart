/// Синглтон для безопасного хранения ключей.
/// Использует flutter_secure_storage (EncryptedSharedPreferences на Android,
/// Keychain на iOS). ЕДИНАЯ точка входа для всех секретов приложения.
library;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptedKeys {
  static final EncryptedKeys _instance = EncryptedKeys._();
  factory EncryptedKeys() => _instance;
  EncryptedKeys._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ─── Префиксы ───
  static const deviceKeyPrefix = 'device_key_';
  static const _vkTokenKey = 'vk_token';
  static const _vkUserIdKey = 'vk_user_id';
  static const _cloudLoginKey = 'mailru_login';
  static const _cloudPasswordKey = 'mailru_password';
  static const _cloudAutoSyncKey = 'mailru_autosync';
  static const _cloudLastSyncKey = 'mailru_last_sync';

  // ─── Базовые ───
  Future<void> save(String key, String value) => _storage.write(key: key, value: value);
  Future<String?> get(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);

  // ─── Ключи устройств Tuya ───
  Future<void> saveDeviceKey(String uuid, String localKey) => save('$deviceKeyPrefix$uuid', localKey);
  Future<String?> getDeviceKey(String uuid) => get('$deviceKeyPrefix$uuid');
  Future<void> deleteDeviceKey(String uuid) => delete('$deviceKeyPrefix$uuid');

  // ─── VK ───
  Future<void> saveVkToken(String token) => save(_vkTokenKey, token);
  Future<String?> getVkToken() => get(_vkTokenKey);
  Future<void> deleteVkToken() => delete(_vkTokenKey);

  Future<void> saveVkUserId(String userId) => save(_vkUserIdKey, userId);
  Future<String?> getVkUserId() => get(_vkUserIdKey);
  Future<void> deleteVkUserId() => delete(_vkUserIdKey);

  // ─── Cloud Mail.ru ───
  Future<void> saveCloudLogin(String login) => save(_cloudLoginKey, login);
  Future<String?> getCloudLogin() => get(_cloudLoginKey);
  Future<void> deleteCloudLogin() => delete(_cloudLoginKey);

  Future<void> saveCloudPassword(String password) => save(_cloudPasswordKey, password);
  Future<String?> getCloudPassword() => get(_cloudPasswordKey);
  Future<void> deleteCloudPassword() => delete(_cloudPasswordKey);

  Future<void> saveCloudAutoSync(bool enabled) => save(_cloudAutoSyncKey, enabled.toString());
  Future<bool?> getCloudAutoSync() async {
    final v = await get(_cloudAutoSyncKey);
    if (v == null) return null;
    return v == 'true';
  }
  Future<void> deleteCloudAutoSync() => delete(_cloudAutoSyncKey);

  Future<void> saveCloudLastSync(String value) => save(_cloudLastSyncKey, value);
  Future<String?> getCloudLastSync() => get(_cloudLastSyncKey);
  Future<void> deleteCloudLastSync() => delete(_cloudLastSyncKey);
}