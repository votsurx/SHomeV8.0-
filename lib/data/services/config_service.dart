/// Сервис экспорта/импорта/автобекапа конфигурации.
/// Экспорт: собирает все данные из БД в JSON, шарит через Share.
/// Импорт: читает JSON через FilePicker.
/// Автобекап в облако Mail.ru делается отдельно (MailruCloudService).
/// Все бекапы шифруются (XOR + Base64).
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../local/database.dart';
import '../local/entities/device_entity.dart';
import '../local/entities/room_entity.dart';
import '../local/entities/scene_entity.dart';
import '../local/secure_storage/encrypted_keys.dart';
import '../../domain/models/device_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
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
  // ЭКСПОРТ (через Share Sheet)
  // ═══════════════════════════════════════════════════════

  /// Экспорт: собирает JSON, шифрует, шарит через Share Sheet.
  /// Пользователь может сохранить куда угодно: облако, почту, Telegram.
  static Future<void> exportConfig() async {
    final json = await buildConfigJson();
    final encrypted = encrypt(json);

    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/shome_backup_$dateStr.json');
    await file.writeAsString(encrypted);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Резервная копия SHome (зашифрована)',
    );
  }

  // ═══════════════════════════════════════════════════════
  // ИМПОРТ (через FilePicker)
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
  }

  // ═══════════════════════════════════════════════════════
  // СБОРКА JSON
  // ═══════════════════════════════════════════════════════

  /// Собирает все данные в JSON-строку.
  /// LocalKey устройств разворачивается из SecureStorage.
  /// VK-токен берётся из SecureStorage и шифруется XOR.
  static Future<String> buildConfigJson() async {
    final devices = await AppDatabase.getAllDevices();
    final rooms = await AppDatabase.getAllRooms();
    final scenes = await AppDatabase.getAllScenes();
    final timers = await AppDatabase.getActiveTimers();

    final prefs = await SharedPreferences.getInstance();
    final mqttBroker = prefs.getString('mqtt_broker') ?? '';
    final mqttPort = prefs.getString('mqtt_port') ?? '1883';

    final keys = EncryptedKeys();

    // MQTT
    final mqttUsername = await keys.getMqttUsername() ?? '';
    final mqttPassword = await keys.getMqttPassword() ?? '';

    // VK
    final vkToken = await keys.getVkToken() ?? '';
    final vkUserId = await keys.getVkUserId() ?? '';

    // Cloud
    final cloudLogin = await keys.getCloudLogin() ?? '';
    final cloudPassword = await keys.getCloudPassword() ?? '';

    // Разворачиваем localKey устройств: sec:<uuid> → plaintext
    final expandedDevices = <Map<String, dynamic>>[];
    for (final entity in devices) {
      final map = entity.toMap();
      final stored = entity.localKey;

      if (stored != null && stored.startsWith('sec:')) {
        final uuid = stored.substring(4);
        final key = await keys.getDeviceKey(uuid);
        map['localKey'] = key ?? '';
      }
      // Иначе — оставляем как было (совместимость)

      expandedDevices.add(map);
    }

    final encryptedVkToken =
    vkToken.isNotEmpty ? encrypt(vkToken) : '';
    final encryptedCloudPassword =
    cloudPassword.isNotEmpty ? encrypt(cloudPassword) : '';

    final config = {
      'version': '8.1',
      'exported_at': DateTime.now().toIso8601String(),
      'devices': expandedDevices,
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
        'mqtt_username': mqttUsername,
        'mqtt_password_encrypted': mqttPassword.isNotEmpty ? encrypt(mqttPassword) : '',
        'cloud_login': cloudLogin,
        'cloud_password_encrypted': encryptedCloudPassword,
        'vk_token_encrypted': encryptedVkToken,
        'vk_user_id': vkUserId,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(config);
  }

  // ═══════════════════════════════════════════════════════
  // ВОССТАНОВЛЕНИЕ ИЗ JSON
  // ═══════════════════════════════════════════════════════

  /// Восстанавливает все данные из JSON-строки.
  /// LocalKey устройств сохраняется в SecureStorage, в БД пишется ссылка.
  /// VK-токен сохраняется в SecureStorage.
  static Future<void> restoreFromJson(String jsonString) async {
    try {
      final config = jsonDecode(jsonString) as Map<String, dynamic>;
      final keys = EncryptedKeys();

      // ─── Комнаты ───
      if (config['rooms'] != null) {
        for (final room in (config['rooms'] as List)) {
          if (room is Map<String, dynamic>) {
            await AppDatabase.insertRoom(RoomEntity.fromMap(room));
          }
        }
      }

      // ─── Устройства ───
      if (config['devices'] != null) {
        for (final device in (config['devices'] as List)) {
          if (device is! Map<String, dynamic>) continue;

          final localKey = device['localKey'] as String?;

          if (localKey != null && localKey.isNotEmpty) {
            // Сохраняем в SecureStorage, в БД — ссылку
            final uuid = const Uuid().v4();
            await keys.saveDeviceKey(uuid, localKey);
            device['localKey'] = 'sec:$uuid';
          }

          await AppDatabase.insertDevice(DeviceEntity.fromMap(device));
        }
      }

      // ─── Сцены ───
      if (config['scenes'] != null) {
        for (final scene in (config['scenes'] as List)) {
          if (scene is Map<String, dynamic>) {
            await AppDatabase.insertScene(SceneEntity.fromMap(scene));
          }
        }
      }

      // ─── Таймеры ───
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

      // ─── Настройки ───
      if (config['settings'] != null && config['settings'] is Map) {
        final settings = config['settings'] as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();

        final mqttBroker = settings['mqtt_broker']?.toString();
        if (mqttBroker != null && mqttBroker.isNotEmpty) {
          await prefs.setString('mqtt_host', mqttBroker);
        }

        final mqttPort = settings['mqtt_port'];
        if (mqttPort != null) {
          final portInt = mqttPort is int
              ? mqttPort
              : int.tryParse(mqttPort.toString()) ?? 1883;
          await prefs.setInt('mqtt_port', portInt);
        }

        // MQTT username/password
        final mqttUsername = settings['mqtt_username']?.toString();
        if (mqttUsername != null && mqttUsername.isNotEmpty) {
          await keys.saveMqttUsername(mqttUsername);
        }

        final mqttPassEnc = settings['mqtt_password_encrypted']?.toString();
        if (mqttPassEnc != null && mqttPassEnc.isNotEmpty) {
          try {
            await keys.saveMqttPassword(decrypt(mqttPassEnc));
          } catch (_) {}
        }

        // VK-токен → SecureStorage
        final vkEnc = settings['vk_token_encrypted']?.toString();
        if (vkEnc != null && vkEnc.isNotEmpty) {
          try {
            await keys.saveVkToken(decrypt(vkEnc));
          } catch (_) {}
        }

        final vkUserId = settings['vk_user_id']?.toString();
        if (vkUserId != null && vkUserId.isNotEmpty) {
          await keys.saveVkUserId(vkUserId);
        }

        // Cloud Mail.ru → SecureStorage через EncryptedKeys
        final cloudLogin = settings['cloud_login']?.toString();
        final cloudPassEnc = settings['cloud_password_encrypted']?.toString();
        if (cloudLogin != null && cloudLogin.isNotEmpty) {
          await keys.saveCloudLogin(cloudLogin);
        }
        if (cloudPassEnc != null && cloudPassEnc.isNotEmpty) {
          try {
            await keys.saveCloudPassword(decrypt(cloudPassEnc));
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