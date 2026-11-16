import 'vk_notification_service.dart';

/// Абстракция отправки уведомлений (для тестируемости).
abstract class NotificationSender {
  Future<bool> send(String message);
}

/// Реализация через VK.
class VkNotificationSender implements NotificationSender {
  final VkNotificationService _vk = VkNotificationService();

  @override
  Future<bool> send(String message) async {
    await _vk.loadSettings();
    return _vk.sendMessage(message);
  }
}