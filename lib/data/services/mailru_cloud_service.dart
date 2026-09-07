/// Сервис для работы с облаком Mail.ru через WebDAV.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webdav_client/webdav_client.dart';
import 'dart:convert';

class MailruCloudService {
  static const String _webdavUrl = 'https://webdav.cloud.mail.ru';
  static const String _backupFolder = 'SHome/backups';

  final String login;
  final String password;

  MailruCloudService({required this.login, required this.password});

  Client _createClient() {
    return newClient(
      _webdavUrl,
      user: login,
      password: password,
      debug: false,
    );
  }

  // ─── ПОДКЛЮЧЕНИЕ ───────────────────────────────────────

  /// Проверяет соединение с облаком.
  Future<bool> testConnection() async {
    try {
      final client = _createClient();
      await client.ping();
      return true;
    } catch (e) {
      debugPrint('❌ Ошибка подключения к облаку: $e');
      return false;
    }
  }

  // ─── БЕКАПЫ ────────────────────────────────────────────

  /// Загружает JSON бекапа в облако.
  Future<bool> uploadBackup(String jsonConfig) async {
    try {
      final client = _createClient();
      await _createFolderIfNeeded(client, '/$_backupFolder');

      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
          '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'backup_$dateStr.json';
      final filePath = '/$_backupFolder/$fileName';

      final data = Uint8List.fromList(utf8.encode(jsonConfig));
      await client.write(filePath, data);
      debugPrint('✅ Бекап загружен в облако: $fileName');

      await _rotateBackups(client, 5);

      return true;
    } catch (e) {
      debugPrint('❌ Ошибка загрузки бекапа: $e');
      return false;
    }
  }

  /// Скачивает JSON бекапа по имени файла.
  Future<String?> downloadBackup(String fileName) async {
    try {
      final client = _createClient();
      final filePath = '/$_backupFolder/$fileName';
      final bytes = await client.read(filePath);
      final content = utf8.decode(bytes);
      debugPrint('✅ Бекап скачан из облака: $fileName');
      return content;
    } catch (e) {
      debugPrint('❌ Ошибка скачивания бекапа: $e');
      return null;
    }
  }

  /// Возвращает список имён файлов бекапов в облаке.
  Future<List<String>> listBackups() async {
    try {
      final client = _createClient();
      await _createFolderIfNeeded(client, '/$_backupFolder');

      final files = await client.readDir('/$_backupFolder');
      final backups = files
          .where((f) => f.name != null && f.name!.endsWith('.json'))
          .map((f) => f.name!)
          .toList();

      backups.sort((a, b) => b.compareTo(a));
      return backups;
    } catch (e) {
      debugPrint('❌ Ошибка получения списка бекапов: $e');
      return [];
    }
  }

  // ─── ВСПОМОГАТЕЛЬНЫЕ ───────────────────────────────────

  Future<void> _createFolderIfNeeded(Client client, String path) async {
    try {
      await client.mkdirAll(path);
    } catch (e) {
      debugPrint('ℹ️ Папка $path: $e');
    }
  }

  Future<void> _rotateBackups(Client client, int keepCount) async {
    try {
      final files = await client.readDir('/$_backupFolder');
      final backups = files
          .where((f) => f.name != null && f.name!.endsWith('.json'))
          .map((f) => f.name!)
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (backups.length <= keepCount) return;

      for (final oldBackup in backups.skip(keepCount)) {
        try {
          await client.remove('/$_backupFolder/$oldBackup');
          debugPrint('🗑️ Удалён старый бекап: $oldBackup');
        } catch (e) {
          debugPrint('⚠️ Не удалось удалить $oldBackup: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Ошибка ротации бекапов: $e');
    }
  }

  // ─── АВТОСИНХРОНИЗАЦИЯ ─────────────────────────────────

  static Future<void> autoSync(String jsonConfig) async {
    try {
      const storage = FlutterSecureStorage();
      final login = await storage.read(key: 'mailru_login');
      final password = await storage.read(key: 'mailru_password');
      final autoSync = await storage.read(key: 'mailru_autosync');

      if (login == null || password == null || autoSync != 'true') return;

      final service = MailruCloudService(login: login, password: password);
      final success = await service.uploadBackup(jsonConfig);

      if (success) {
        final now = DateTime.now();
        final dateStr = '${now.day}.${now.month}.${now.year} ${now.hour}:${now.minute}';
        await storage.write(key: 'mailru_last_sync', value: dateStr);
      }
    } catch (e) {
      debugPrint('❌ Ошибка автосинхронизации: $e');
    }
  }
}