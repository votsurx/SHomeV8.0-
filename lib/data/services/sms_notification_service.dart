import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsNotificationService {
  static const _channel = MethodChannel('com.example.shome/installer');

  static Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  static Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        debugPrint('❌ Нет разрешения на SMS');
        return false;
      }

      final result = await _channel.invokeMethod('sendSms', {
        'phone': phoneNumber,
        'message': message,
      });

      debugPrint('✅ SMS отправлено: $result');
      return result == true;
    } catch (e) {
      debugPrint('❌ Ошибка отправки SMS: $e');
      return false;
    }
  }

  static Future<bool> sendAlarm({
    required String phoneNumber,
    required String cameraName,
    required String event,
    double? percent,
  }) async {
    final percentText = percent != null ? ' (${percent.toStringAsFixed(1)}%)' : '';
    final message = '🏃 SHome: Тревога!\n'
        '📹 Камера: $cameraName\n'
        '🎯 Событие: $event$percentText\n'
        '🕐 ${DateTime.now().toString().substring(0, 19)}';

    return sendSms(phoneNumber: phoneNumber, message: message);
  }
}