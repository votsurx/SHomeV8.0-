/// Сервис для работы с облаком Mail.ru через WebDAV.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:webdav_client/webdav_client.dart';
import '../../domain/services/presence_cloud_reader.dart';

typedef PresenceDirectoryListing = Future<List<String>> Function(
    String path,
    );

typedef PresenceFileReader = Future<List<int>> Function(
    String path,
    );

class MailruCloudService implements PresenceCloudReader {
  static const String _webdavUrl = 'https://webdav.cloud.mail.ru';
  static const String _backupFolder = 'SHome/backups';
  static const String _presenceFolder = 'SHome/presence';

  static const Duration _presenceRequestTimeout = Duration(seconds: 15);

  final String login;
  final String password;

  /// Необязательные замены WebDAV-чтения для детерминированных тестов.
  ///
  /// В production оставляются null, и используются реальные WebDAV-запросы.
  final PresenceDirectoryListing? presenceDirectoryListing;
  final PresenceFileReader? presenceFileReader;

  MailruCloudService({
    required this.login,
    required this.password,
    this.presenceDirectoryListing,
    this.presenceFileReader,
  }) {
    if ((presenceDirectoryListing == null) !=
        (presenceFileReader == null)) {
      throw ArgumentError(
        'Для тестового чтения присутствия нужно передать обе функции: '
            'presenceDirectoryListing и presenceFileReader.',
      );
    }
  }

  Client _createClient() {
    return newClient(
      _webdavUrl,
      user: login,
      password: password,
      debug: false,
    );
  }

  // ─── ПОДКЛЮЧЕНИЕ ───────────────────────────────────────

  Future<bool> testConnection() async {
    try {
      final client = _createClient();
      await client.ping();
      return true;
    } catch (error) {
      debugPrint('Ошибка подключения к облаку: $error');
      return false;
    }
  }

  // ─── БЕКАПЫ ────────────────────────────────────────────

  Future<bool> uploadBackup(String jsonConfig) async {
    try {
      final client = _createClient();
      await _createFolderIfNeeded(client, '/$_backupFolder');

      final now = DateTime.now();
      final dateStr =
          '${now.year}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}';

      final fileName = 'backup_$dateStr.json';
      final filePath = '/$_backupFolder/$fileName';

      final data = Uint8List.fromList(utf8.encode(jsonConfig));
      await client.write(filePath, data);

      debugPrint('Бекап загружен в облако: $fileName');

      await _rotateBackups(client, 5);
      return true;
    } catch (error) {
      debugPrint('Ошибка загрузки бекапа: $error');
      return false;
    }
  }

  Future<String?> downloadBackup(String fileName) async {
    try {
      final client = _createClient();
      final filePath = '/$_backupFolder/$fileName';
      final bytes = await client.read(filePath);
      final content = utf8.decode(bytes);

      debugPrint('Бекап скачан из облака: $fileName');
      return content;
    } catch (error) {
      debugPrint('Ошибка скачивания бекапа: $error');
      return null;
    }
  }

  Future<List<String>> listBackups() async {
    try {
      final client = _createClient();
      await _createFolderIfNeeded(client, '/$_backupFolder');

      final files = await client.readDir('/$_backupFolder');
      final backups = files
          .where((file) => file.name != null && file.name!.endsWith('.json'))
          .map((file) => file.name!)
          .toList();

      backups.sort((a, b) => b.compareTo(a));
      return backups;
    } catch (error) {
      debugPrint('Ошибка получения списка бекапов: $error');
      return [];
    }
  }

  // ─── PRESENCE ──────────────────────────────────────────

  /// Читает и классифицирует облачную запись присутствия.
  ///
  /// `notFound` возвращается только когда удалось прочитать список файлов
  /// каталога, но файла `{phoneId}.json` в нём нет.
  ///
  /// Ошибка списка или чтения файла считается `unavailable`: по ней нельзя
  /// достоверно утверждать, что запись отсутствует.
  @override
  Future<PresenceCloudReadResult> readPresence({
    required String phoneId,
  }) async {
    final directoryPath = '/$_presenceFolder';
    final fileName = '$phoneId.json';
    final filePath = '$directoryPath/$fileName';

    try {
      final List<String> fileNames;

      if (presenceDirectoryListing != null) {
        fileNames = await presenceDirectoryListing!(directoryPath).timeout(
          _presenceRequestTimeout,
        );
      } else {
        final client = _createClient();
        final files = await client.readDir(directoryPath).timeout(
          _presenceRequestTimeout,
        );

        fileNames = files
            .where((file) => file.name != null)
            .map((file) => file.name!)
            .toList();
      }

      if (!fileNames.contains(fileName)) {
        return const PresenceCloudReadResult.notFound();
      }

      final List<int> bytes;

      if (presenceFileReader != null) {
        bytes = await presenceFileReader!(filePath).timeout(
          _presenceRequestTimeout,
        );
      } else {
        final client = _createClient();
        bytes = await client.read(filePath).timeout(
          _presenceRequestTimeout,
        );
      }

      final content = utf8.decode(bytes);
      final decoded = jsonDecode(content);

      if (decoded is! Map) {
        return const PresenceCloudReadResult.invalidData(
          details: 'Presence JSON is not an object.',
        );
      }

      final data = Map<String, dynamic>.from(decoded);

      debugPrint('Presence прочитан из облака: $filePath');
      return PresenceCloudReadResult.found(data);
    } on FormatException catch (error) {
      debugPrint('Некорректные данные presence для $phoneId: $error');

      return PresenceCloudReadResult.invalidData(
        details: error.message,
      );
    } catch (error) {
      debugPrint('Облачное чтение presence недоступно для $phoneId: $error');

      return PresenceCloudReadResult.unavailable(
        details: error.toString(),
      );
    }
  }

  /// Старый API оставлен для существующих вызовов.
  ///
  /// Новая логика определения присутствия должна использовать [readPresence],
  /// чтобы отличать ошибку облака от отсутствующей записи.
  Future<String?> downloadPresence({
    required String phoneId,
  }) async {
    try {
      final client = _createClient();
      final filePath = '/$_presenceFolder/$phoneId.json';
      final bytes = await client.read(filePath);
      final content = utf8.decode(bytes);

      debugPrint('Presence скачан: $filePath');
      return content;
    } catch (error) {
      debugPrint('Ошибка скачивания presence: $error');
      return null;
    }
  }

  /// Возвращает список ID телефонов, для которых есть JSON-файлы.
  Future<List<String>> listPresencePhones() async {
    try {
      final client = _createClient();
      await _createFolderIfNeeded(client, '/$_presenceFolder');

      final files = await client.readDir('/$_presenceFolder');
      return files
          .where((file) => file.name != null && file.name!.endsWith('.json'))
          .map((file) => file.name!.replaceAll('.json', ''))
          .toList();
    } catch (error) {
      debugPrint('Ошибка получения списка телефонов presence: $error');
      return [];
    }
  }

  /// Удаляет облачную запись присутствия.
  Future<bool> deletePresence({
    required String phoneId,
  }) async {
    try {
      final client = _createClient();
      final filePath = '/$_presenceFolder/$phoneId.json';
      await client.remove(filePath);

      debugPrint('Presence удалён: $filePath');
      return true;
    } catch (error) {
      debugPrint('Ошибка удаления presence: $error');
      return false;
    }
  }

  // ─── ВСПОМОГАТЕЛЬНЫЕ ───────────────────────────────────

  Future<void> _createFolderIfNeeded(Client client, String path) async {
    try {
      await client.mkdirAll(path);
    } catch (error) {
      // mkdirAll может завершиться ошибкой, если каталог уже существует.
      debugPrint('Каталог $path: $error');
    }
  }

  Future<void> _rotateBackups(Client client, int keepCount) async {
    try {
      final files = await client.readDir('/$_backupFolder');
      final backups = files
          .where((file) => file.name != null && file.name!.endsWith('.json'))
          .map((file) => file.name!)
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (backups.length <= keepCount) return;

      for (final oldBackup in backups.skip(keepCount)) {
        try {
          await client.remove('/$_backupFolder/$oldBackup');
          debugPrint('Удалён старый бекап: $oldBackup');
        } catch (error) {
          debugPrint('Не удалось удалить $oldBackup: $error');
        }
      }
    } catch (error) {
      debugPrint('Ошибка ротации бекапов: $error');
    }
  }
}