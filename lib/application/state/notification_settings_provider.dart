import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local/secure_storage/encrypted_keys.dart';
import '../models/notification_settings.dart';

final notificationSettingsProvider =
StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      (ref) {
    return NotificationSettingsNotifier();
  },
);

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final EncryptedKeys _keys = EncryptedKeys();

  NotificationSettingsNotifier() : super(NotificationSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // ─── МИГРАЦИЯ: VK-токен из SharedPreferences → SecureStorage ───
    final oldToken = prefs.getString('vk_token');
    final oldUserId = prefs.getString('vk_user_id');

    String token = await _keys.getVkToken() ?? '';
    String userId = await _keys.getVkUserId() ?? '';

    if (token.isEmpty && oldToken != null && oldToken.isNotEmpty) {
      await _keys.saveVkToken(oldToken);
      token = oldToken;
      await prefs.remove('vk_token');   // убираем plaintext
    }
    if (userId.isEmpty && oldUserId != null && oldUserId.isNotEmpty) {
      await _keys.saveVkUserId(oldUserId);
      userId = oldUserId;
      await prefs.remove('vk_user_id');
    }

    // ─── ОСТАЛЬНЫЕ НАСТРОЙКИ — в SharedPreferences ───
    state = NotificationSettings(
      enabled: prefs.getBool('notifications_enabled') ?? false,
      vkToken: token,
      vkUserId: userId,
      notifyScenes: prefs.getBool('notify_scenes') ?? true,
      notifyDevices: prefs.getBool('notify_devices') ?? false,
      notifyAlarms: prefs.getBool('notify_alarms') ?? true,
      notifyErrors: prefs.getBool('notify_errors') ?? true,
      useSchedule: prefs.getBool('notify_use_schedule') ?? false,
      scheduleOnlyAlarms: prefs.getBool('notify_schedule_only_alarms') ?? true,
      startHour: prefs.getInt('notify_start_hour') ?? 9,
      startMinute: prefs.getInt('notify_start_minute') ?? 0,
      endHour: prefs.getInt('notify_end_hour') ?? 21,
      endMinute: prefs.getInt('notify_end_minute') ?? 0,
      daysOfWeek: prefs.getStringList('notify_days')?.map(int.parse).toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      smsEnabled: prefs.getBool('sms_enabled') ?? false,
      smsPhoneNumber: prefs.getString('sms_phone') ?? '',
    );
  }

  Future<void> update(NotificationSettings settings) async {
    state = settings;
    final prefs = await SharedPreferences.getInstance();

    // ─── Секреты — в SecureStorage ───
    if (settings.vkToken.isNotEmpty) {
      await _keys.saveVkToken(settings.vkToken);
    } else {
      await _keys.deleteVkToken();
    }
    if (settings.vkUserId.isNotEmpty) {
      await _keys.saveVkUserId(settings.vkUserId);
    } else {
      await _keys.deleteVkUserId();
    }

    // ─── Остальное — в SharedPreferences ───
    await prefs.setBool('notifications_enabled', settings.enabled);
    await prefs.setBool('notify_scenes', settings.notifyScenes);
    await prefs.setBool('notify_devices', settings.notifyDevices);
    await prefs.setBool('notify_alarms', settings.notifyAlarms);
    await prefs.setBool('notify_errors', settings.notifyErrors);
    await prefs.setBool('notify_use_schedule', settings.useSchedule);
    await prefs.setBool('notify_schedule_only_alarms', settings.scheduleOnlyAlarms);
    await prefs.setInt('notify_start_hour', settings.startHour);
    await prefs.setInt('notify_start_minute', settings.startMinute);
    await prefs.setInt('notify_end_hour', settings.endHour);
    await prefs.setInt('notify_end_minute', settings.endMinute);
    await prefs.setStringList(
      'notify_days',
      settings.daysOfWeek.map((e) => e.toString()).toList(),
    );
    await prefs.setBool('sms_enabled', settings.smsEnabled);
    await prefs.setString('sms_phone', settings.smsPhoneNumber);
  }
}