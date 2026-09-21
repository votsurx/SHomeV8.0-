import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sms_settings.dart';
import '../models/sms_phone.dart';

final smsSettingsProvider =
StateNotifierProvider<SmsSettingsNotifier, SmsSettings>((ref) {
  return SmsSettingsNotifier();
});

class SmsSettingsNotifier extends StateNotifier<SmsSettings> {
  SmsSettingsNotifier() : super(SmsSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Загружаем номера
    final phonesJson = prefs.getString('sms_phones') ?? '[]';
    final phonesList = (jsonDecode(phonesJson) as List)
        .map((e) => SmsPhone.fromJson(e as Map<String, dynamic>))
        .toList();

    state = SmsSettings(
      enabled: prefs.getBool('sms_enabled') ?? false,
      phones: phonesList,
      notifyScenes: prefs.getBool('sms_notify_scenes') ?? false,
      notifyDevices: prefs.getBool('sms_notify_devices') ?? false,
      notifyAlarms: prefs.getBool('sms_notify_alarms') ?? true,
      notifyErrors: prefs.getBool('sms_notify_errors') ?? false,
      useSchedule: prefs.getBool('sms_use_schedule') ?? false,
      scheduleOnlyAlarms: prefs.getBool('sms_schedule_only_alarms') ?? true,
      startHour: prefs.getInt('sms_start_hour') ?? 9,
      startMinute: prefs.getInt('sms_start_minute') ?? 0,
      endHour: prefs.getInt('sms_end_hour') ?? 21,
      endMinute: prefs.getInt('sms_end_minute') ?? 0,
      daysOfWeek: prefs.getStringList('sms_days')?.map(int.parse).toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
    );
  }

  Future<void> update(SmsSettings settings) async {
    state = settings;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('sms_enabled', settings.enabled);
    await prefs.setString(
      'sms_phones',
      jsonEncode(settings.phones.map((p) => p.toJson()).toList()),
    );
    await prefs.setBool('sms_notify_scenes', settings.notifyScenes);
    await prefs.setBool('sms_notify_devices', settings.notifyDevices);
    await prefs.setBool('sms_notify_alarms', settings.notifyAlarms);
    await prefs.setBool('sms_notify_errors', settings.notifyErrors);
    await prefs.setBool('sms_use_schedule', settings.useSchedule);
    await prefs.setBool('sms_schedule_only_alarms', settings.scheduleOnlyAlarms);
    await prefs.setInt('sms_start_hour', settings.startHour);
    await prefs.setInt('sms_start_minute', settings.startMinute);
    await prefs.setInt('sms_end_hour', settings.endHour);
    await prefs.setInt('sms_end_minute', settings.endMinute);
    await prefs.setStringList(
      'sms_days',
      settings.daysOfWeek.map((e) => e.toString()).toList(),
    );
  }

  /// Добавить номер
  Future<void> addPhone(SmsPhone phone) async {
    final updated = [...state.phones, phone];
    await update(state.copyWith(phones: updated));
  }

  /// Удалить номер
  Future<void> removePhone(String phone) async {
    final updated = state.phones.where((p) => p.phone != phone).toList();
    await update(state.copyWith(phones: updated));
  }

  /// Обновить номер
  Future<void> updatePhone(String oldPhone, SmsPhone newPhone) async {
    final updated = state.phones.map((p) {
      return p.phone == oldPhone ? newPhone : p;
    }).toList();
    await update(state.copyWith(phones: updated));
  }
}