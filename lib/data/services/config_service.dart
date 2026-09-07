/// Сервис экспорта/импорта/автобекапа конфигурации.
/// Экспорт: собирает все данные из БД в JSON, шарит через Share.
/// Импорт: читает JSON через FilePicker.
/// Автобекап: сохраняет копию локально.
/// Все бекапы шифруются (XOR + Base64).
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../local/database.dart';
import '../local/entities/device_entity.dart';
import '../local/entities/room_entity.dart';
import '../local/entities/scene_entity.dart';
import '../../domain/models/device_timer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _backupFileName = 'auto_backup.json';
  static const String _backupDirName = 'backups';
  static const String _encryptKey = 'SHomeBackup2026!';

  // ═══════════════════════════════════════════════════════
  // ШИФРОВАНИЕ
  // ═══════════════════════════════════════════════════════

  /// Шифрует строку (XOR + Base64).
  static String encrypt(String text) {
    final key = utf8.encode(_encryptKey);
    final data = utf8.encode(text);
    final result = <int>[];
    for (var i = 0; i < data.length; i++) {
      result.add(data[i] ^ key[i % key.length]);
    }
    return base64Encode(result);
  }

  /// Дешифрует строку (Base64 + XOR).
  static String decrypt(String encrypted) {
    final key = utf8.encode(_encryptKey);
    final data = base64Decode(encrypted);
    final result = <int>[];
    for (var i = 0; i < data.length; i++) {
      result.add(data[i] ^ key[i % key.length]);
    }
    return utf8.decode(result);
  }

  // ═══════════════════════════════════════════════════════
  // ЭКСПОРТ
  // ═══════════════════════════════════════════════════════

  /// Экспорт: собирает JSON, шифрует, сохраняет локально и шарит.
  static Future<void> exportConfig() async {
    final json = await buildConfigJson();
    final encrypted = encrypt(json);

    await _saveLocalBackup(encrypted);

    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/shome_backup_$dateStr.json');
    await file.writeAsString(encrypted);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Резервная копия SHome (зашифрована)',
    );
  }

  // ═══════════════════════════════════════════════════════
  // ИМПОРТ
  // ═══════════════════════════════════════════════════════

  /// Импорт через FilePicker. Поддерживает зашифрованные и обычные бекапы.
  static Future<void> importConfig() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final encrypted = await file.readAsString();

    String json;
    try {
      json = decrypt(encrypted);
    } catch (_) {
      json = encrypted; // старый формат без шифрования
    }

    await restoreFromJson(json);
    await _saveLocalBackup(encrypted);
  }

  /// Быстрый импорт из локального бекапа.
  static Future<void> quickImport() async {
    final encrypted = await _loadLocalBackup();
    if (encrypted == null) {
      throw Exception('Локальный бекап не найден.');
    }

    String json;
    try {
      json = decrypt(encrypted);
    } catch (_) {
      json = encrypted;
    }

    await restoreFromJson(json);
  }

  // ═══════════════════════════════════════════════════════
  // ЛОКАЛЬНЫЙ АВТОБЕКАП
  // ═══════════════════════════════════════════════════════

  static Future<Directory> get _backupDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/$_backupDirName');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  static Future<void> _saveLocalBackup(String encrypted) async {
    try {
      final dir = await _backupDir;
      final file = File('${dir.path}/$_backupFileName');
      await file.writeAsString(encrypted);
      debugPrint('✅ Локальный бекап сохранён');
    } catch (e) {
      debugPrint('❌ Ошибка сохранения локального бекапа: $e');
    }
  }

  static Future<String?> _loadLocalBackup() async {
    try {
      final dir = await _backupDir;
      final file = File('${dir.path}/$_backupFileName');
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (e) {
      debugPrint('❌ Ошибка загрузки локального бекапа: $e');
      return null;
    }
  }

  static Future<bool> hasLocalBackup() async {
    try {
      final dir = await _backupDir;
      final file = File('${dir.path}/$_backupFileName');
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  static Future<DateTime?> lastBackupDate() async {
    try {
      final dir = await _backupDir;
      final file = File('${dir.path}/$_backupFileName');
      if (!await file.exists()) return null;
      return await file.lastModified();
    } catch (_) {
      return null;
    }
  }

  /// Автобекап с ротацией (3 последние копии).
  static Future<void> autoBackup() async {
    try {
      final json = await buildConfigJson();
      final encrypted = encrypt(json);
      final dir = await _backupDir;

      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
          '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final newBackup = File('${dir.path}/backup_$dateStr.json');
      await newBackup.writeAsString(encrypted);

      final files = await dir.list().toList();
      final backups = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));

      if (backups.length > 3) {
        for (final old in backups.skip(3)) {
          await old.delete();
        }
      }

      await _saveLocalBackup(encrypted);
      debugPrint('✅ Автобекап выполнен (${backups.length} копий)');
    } catch (e) {
      debugPrint('❌ Ошибка автобекапа: $e');
    }
  }

  // ═══════════════════════════════════════════════════════
  // СБОРКА JSON
  // ═══════════════════════════════════════════════════════

  /// Собирает все данные в JSON-строку.
  static Future<String> buildConfigJson() async {
    final devices = await AppDatabase.getAllDevices();
    final rooms = await AppDatabase.getAllRooms();
    final scenes = await AppDatabase.getAllScenes();
    final timers = await AppDatabase.getActiveTimers();

    final prefs = await SharedPreferences.getInstance();
    final mqttBroker = prefs.getString('mqtt_broker') ?? '';
    final mqttPort = prefs.getString('mqtt_port') ?? '1883';
    final vkToken = prefs.getString('vk_token') ?? '';

    const storage = FlutterSecureStorage();
    final cloudLogin = await storage.read(key: 'mailru_login') ?? '';
    final cloudPassword = await storage.read(key: 'mailru_password') ?? '';

    final encryptedVkToken = vkToken.isNotEmpty ? encrypt(vkToken) : '';
    final encryptedCloudPassword = cloudPassword.isNotEmpty ? encrypt(cloudPassword) : '';

    final config = {
      'version': '3.0',
      'exported_at': DateTime.now().toIso8601String(),
      'devices': devices.map((d) => d.toMap()).toList(),
      'rooms': rooms.map((r) => r.toMap()).toList(),
      'scenes': scenes.map((s) => s.toMap()).toList(),
      'timers': timers.map((t) => {
        'id': t.id,
        'deviceId': t.deviceId,
        'deviceName': t.deviceName,
        'command': t.command,
        'executeAt': t.executeAt.toIso8601String(),
        'executed': t.executed,
      }).toList(),
      'settings': {
        'mqtt_broker': mqttBroker,
        'mqtt_port': mqttPort,
        'cloud_login': cloudLogin,
        'cloud_password_encrypted': encryptedCloudPassword,
        'vk_token_encrypted': encryptedVkToken,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(config);
  }

  // ═══════════════════════════════════════════════════════
  // ВОССТАНОВЛЕНИЕ ИЗ JSON
  // ═══════════════════════════════════════════════════════

  /// Восстанавливает все данные из JSON-строки.
  static Future<void> restoreFromJson(String jsonString) async {
    try {
      final config = jsonDecode(jsonString) as Map<String, dynamic>;

      if (config['rooms'] != null) {
        for (final room in (config['rooms'] as List)) {
          if (room is Map<String, dynamic>) {
            await AppDatabase.insertRoom(RoomEntity.fromMap(room));
          }
        }
      }

      if (config['devices'] != null) {
        for (final device in (config['devices'] as List)) {
          if (device is Map<String, dynamic>) {
            await AppDatabase.insertDevice(DeviceEntity.fromMap(device));
          }
        }
      }

      if (config['scenes'] != null) {
        for (final scene in (config['scenes'] as List)) {
          if (scene is Map<String, dynamic>) {
            await AppDatabase.insertScene(SceneEntity.fromMap(scene));
          }
        }
      }

      if (config['timers'] != null) {
        for (final timer in (config['timers'] as List)) {
          if (timer is! Map<String, dynamic>) continue;

          final id = timer['id']?.toString() ?? '';
          final deviceId = timer['deviceId']?.toString() ?? '';
          final deviceName = timer['deviceName']?.toString() ?? '';
          final command = timer['command']?.toString() ?? '';
          final executeAtStr = timer['executeAt']?.toString();
          final executed = timer['executed'] == true;

          if (id.isEmpty || executeAtStr == null) continue;

          await AppDatabase.insertTimer(DeviceTimer(
            id: id,
            deviceId: deviceId,
            deviceName: deviceName,
            command: command,
            executeAt: DateTime.parse(executeAtStr),
            executed: executed,
          ));
        }
      }

      if (config['settings'] != null && config['settings'] is Map) {
        final settings = config['settings'] as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        const storage = FlutterSecureStorage();

        final mqttBroker = settings['mqtt_broker']?.toString();
        final mqttPort = settings['mqtt_port']?.toString();
        if (mqttBroker != null && mqttBroker.isNotEmpty) {
          await prefs.setString('mqtt_broker', mqttBroker);
        }
        if (mqttPort != null && mqttPort.isNotEmpty) {
          await prefs.setString('mqtt_port', mqttPort);
        }

        final vkEnc = settings['vk_token_encrypted']?.toString();
        if (vkEnc != null && vkEnc.isNotEmpty) {
          try {
            await prefs.setString('vk_token', decrypt(vkEnc));
          } catch (_) {}
        }

        final cloudLogin = settings['cloud_login']?.toString();
        final cloudPassEnc = settings['cloud_password_encrypted']?.toString();
        if (cloudLogin != null && cloudLogin.isNotEmpty) {
          await storage.write(key: 'mailru_login', value: cloudLogin);
        }
        if (cloudPassEnc != null && cloudPassEnc.isNotEmpty) {
          try {
            await storage.write(key: 'mailru_password', value: decrypt(cloudPassEnc));
          } catch (_) {}
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка восстановления: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }
}