import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService {
  static Future<bool> shouldSendDeviceNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    final notifyDevices = prefs.getBool('notify_devices') ?? false;
    final token = prefs.getString('vk_token') ?? '';
    final userId = prefs.getString('vk_user_id') ?? '';
    return enabled && notifyDevices && token.isNotEmpty && userId.isNotEmpty;
  }

  static Future<bool> shouldSendSceneNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    final notifyScenes = prefs.getBool('notify_scenes') ?? true;
    final token = prefs.getString('vk_token') ?? '';
    final userId = prefs.getString('vk_user_id') ?? '';
    return enabled && notifyScenes && token.isNotEmpty && userId.isNotEmpty;
  }
}