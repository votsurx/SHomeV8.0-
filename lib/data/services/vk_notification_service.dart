/// Сервис отправки уведомлений через VK Bot API.
/// Токен хранится в SecureStorage (Android Keystore).
/// Отправка через POST — токен НЕ попадает в URL/логи.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../local/secure_storage/encrypted_keys.dart';

class VkNotificationService {
  static const String _apiVersion = '5.199';
  static const String _apiUrl = 'https://api.vk.com/method';

  final EncryptedKeys _keys = EncryptedKeys();

  String? _token;
  int? _userId;

  /// Загружает токен и userId из SecureStorage.
  Future<void> loadSettings() async {
    _token = await _keys.getVkToken();
    _userId = int.tryParse(await _keys.getVkUserId() ?? '');
  }

  /// Проверяет, настроен ли сервис.
  bool get isConfigured =>
      _token != null && _token!.isNotEmpty &&
          _userId != null;

  /// Отправляет текстовое уведомление через POST.
  Future<bool> sendMessage(String message) async {
    if (!isConfigured) {
      debugPrint('❌ VK: не настроен');
      return false;
    }

    try {
      final randomId = DateTime.now().millisecondsSinceEpoch;
      final url = Uri.parse('$_apiUrl/messages.send');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': _userId!.toString(),
          'message': message,
          'random_id': randomId.toString(),
          'access_token': _token!,
          'v': _apiVersion,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] != null) {
          debugPrint('✅ VK: сообщение отправлено');
          return true;
        } else {
          debugPrint('❌ VK ошибка: ${data['error']?['error_msg']}');
          return false;
        }
      }
    } catch (e) {
      debugPrint('❌ VK: $e');
    }

    return false;
  }

  /// Отправляет уведомление о тревоге.
  Future<bool> sendAlarm({
    required String cameraName,
    required String label,
    required double score,
  }) async {
    final percent = (score * 100).round();
    final emoji = _getLabelEmoji(label);
    final message = '$emoji Тревога!\n'
        '📹 Камера: $cameraName\n'
        '🎯 Объект: $label\n'
        '📊 Уверенность: $percent%\n'
        '🕐 ${DateTime.now().toString().substring(0, 19)}';

    return sendMessage(message);
  }

  String _getLabelEmoji(String label) {
    switch (label) {
      case 'person': return '🚶';
      case 'car': return '🚗';
      case 'cat': return '🐱';
      case 'dog': return '🐕';
      case 'bird': return '🐦';
      case 'motion': return '🏃';
      default: return '⚠️';
    }
  }

  /// Уведомление о сцене.
  Future<bool> sendSceneNotification({
    required String sceneName,
    required bool success,
  }) async {
    final emoji = success ? '✅' : '❌';
    final message = '$emoji Сцена\n'
        '🎬 Название: $sceneName\n'
        '🕐 ${DateTime.now().toString().substring(0, 19)}';

    return sendMessage(message);
  }

  /// Уведомление об устройстве.
  Future<bool> sendDeviceNotification({
    required String deviceName,
    required String action,
    required bool success,
  }) async {
    final emoji = success ? '✅' : '❌';
    final message = '$emoji Устройство\n'
        '📦 $deviceName\n'
        '🔧 $action\n'
        '🕐 ${DateTime.now().toString().substring(0, 19)}';

    return sendMessage(message);
  }

  /// Уведомление для составного устройства.
  Future<bool> sendCompoundNotification({
    required String deviceName,
    required Map<String, String> changes,
  }) async {
    final lines = changes.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
    final message = '🤖 $deviceName\n'
        '$lines\n'
        '🕐 ${DateTime.now().toString().substring(0, 19)}';

    return sendMessage(message);
  }
}