/// Синглтон для безопасного хранения ключей.
/// Использует flutter_secure_storage для шифрованного хранения
/// локальных ключей Tuya, токенов и других чувствительных данных.
/// На Android данные хранятся в EncryptedSharedPreferences,
/// на iOS — в Keychain.
library;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptedKeys {
  /// Синглтон — единственный экземпляр на всё приложение
  static final EncryptedKeys _instance = EncryptedKeys._();
  factory EncryptedKeys() => _instance;
  EncryptedKeys._();

  /// Экземпляр FlutterSecureStorage для шифрованного хранения
  final _storage = const FlutterSecureStorage();

  /// Сохраняет значение по ключу в защищённое хранилище.
  /// Используется для localKey устройств Tuya.
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Читает значение по ключу из защищённого хранилища.
  /// Возвращает null, если ключ не найден.
  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  /// Удаляет значение по ключу из защищённого хранилища.
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}