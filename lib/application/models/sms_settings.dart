import 'sms_phone.dart';

class SmsSettings {
  final bool enabled;
  final List<SmsPhone> phones;
  final bool notifyScenes;
  final bool notifyDevices;
  final bool notifyAlarms;
  final bool notifyErrors;

  // Расписание (отдельное от VK)
  final bool useSchedule;
  final bool scheduleOnlyAlarms;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final List<int> daysOfWeek;

  SmsSettings({
    this.enabled = false,
    this.phones = const [],
    this.notifyScenes = false,
    this.notifyDevices = false,
    this.notifyAlarms = true,
    this.notifyErrors = false,
    this.useSchedule = false,
    this.scheduleOnlyAlarms = true,
    this.startHour = 9,
    this.startMinute = 0,
    this.endHour = 21,
    this.endMinute = 0,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
  });

  bool get isConfigured => enabled && phones.any((p) => p.enabled);

  SmsSettings copyWith({
    bool? enabled,
    List<SmsPhone>? phones,
    bool? notifyScenes,
    bool? notifyDevices,
    bool? notifyAlarms,
    bool? notifyErrors,
    bool? useSchedule,
    bool? scheduleOnlyAlarms,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    List<int>? daysOfWeek,
  }) {
    return SmsSettings(
      enabled: enabled ?? this.enabled,
      phones: phones ?? this.phones,
      notifyScenes: notifyScenes ?? this.notifyScenes,
      notifyDevices: notifyDevices ?? this.notifyDevices,
      notifyAlarms: notifyAlarms ?? this.notifyAlarms,
      notifyErrors: notifyErrors ?? this.notifyErrors,
      useSchedule: useSchedule ?? this.useSchedule,
      scheduleOnlyAlarms: scheduleOnlyAlarms ?? this.scheduleOnlyAlarms,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    );
  }
}