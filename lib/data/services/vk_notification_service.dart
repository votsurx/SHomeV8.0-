/// Сервис отправки уведомлений через VK Bot API.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VkNotificationService {
  static const String _apiVersion = '5.199';
  static const String _apiUrl = 'https://api.vk.com/method';

  String? _token;
  int? _userId;

  /// Загружает настройки из SharedPreferences.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('vk_token');
    _userId = int.tryParse(prefs.getString('vk_user_id') ?? '');
  }

  /// Проверяет, настроен ли сервис.
  bool get isConfigured => _token != null && _userId != null;

  /// Отправляет текстовое уведомление.
  Future<bool> sendMessage(String message) async {
    if (!isConfigured) {
      debugPrint('❌ VK: не настроен');
      return false;
    }

    try {
      final randomId = DateTime.now().millisecondsSinceEpoch;
      final url = Uri.parse(
          '$_apiUrl/messages.send'
              '?user_id=$_userId'
              '&message=${Uri.encodeComponent(message)}'
              '&random_id=$randomId'
              '&access_token=$_token'
              '&v=$_apiVersion'
      );

      final response = await http.get(url);

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
      default: return '⚠️';
    }
  }
}