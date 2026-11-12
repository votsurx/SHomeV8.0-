import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local/secure_storage/encrypted_keys.dart';

class NotificationSettingsService {
  static Future<bool> shouldSendDeviceNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    final notifyDevices = prefs.getBool('notify_devices') ?? false;

    // VK-токен и userId — в SecureStorage
    final keys = EncryptedKeys();
    final token = await keys.getVkToken() ?? '';
    final userId = await keys.getVkUserId() ?? '';

    return enabled &&
        notifyDevices &&
        token.isNotEmpty &&
        userId.isNotEmpty;
  }

  static Future<bool> shouldSendSceneNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    final notifyScenes = prefs.getBool('notify_scenes') ?? true;

    final keys = EncryptedKeys();
    final token = await keys.getVkToken() ?? '';
    final userId = await keys.getVkUserId() ?? '';

    return enabled &&
        notifyScenes &&
        token.isNotEmpty &&
        userId.isNotEmpty;
  }
}