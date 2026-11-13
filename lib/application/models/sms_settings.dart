import 'sms_phone.dart';

class SmsSettings {
  final bool enabled;
  final List<SmsPhone> phones;
  final bool notifyScenes;
  final bool notifyDevices;
  final bool notifyAlarms;
  final bool notifyErrors;

  // Zigbee alerts
  final bool notifyZigbeeWaterLeak;
  final bool notifyZigbeeSmoke;
  final bool notifyZigbeeGas;
  final bool notifyZigbeeMotion;
  final bool notifyZigbeeContact;

  // Frigate
  final bool notifyFrigatePerson;
  final bool notifyFrigateCar;

  // Availability
  final bool notifyZigbeeOffline;
  final bool notifyFrigateOffline;

  // Cooldown SMS
  final int smsCooldownMin;

  // Расписание
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
    // Zigbee alerts
    this.notifyZigbeeWaterLeak = true,
    this.notifyZigbeeSmoke = true,
    this.notifyZigbeeGas = true,
    this.notifyZigbeeMotion = false,
    this.notifyZigbeeContact = false,
    // Frigate
    this.notifyFrigatePerson = false,
    this.notifyFrigateCar = false,
    // Availability
    this.notifyZigbeeOffline = false,
    this.notifyFrigateOffline = false,
    // Cooldown
    this.smsCooldownMin = 1,
    // Schedule
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
    // Zigbee alerts
    bool? notifyZigbeeWaterLeak,
    bool? notifyZigbeeSmoke,
    bool? notifyZigbeeGas,
    bool? notifyZigbeeMotion,
    bool? notifyZigbeeContact,
    // Frigate
    bool? notifyFrigatePerson,
    bool? notifyFrigateCar,
    // Availability
    bool? notifyZigbeeOffline,
    bool? notifyFrigateOffline,
    // Cooldown
    int? smsCooldownMin,
    // Schedule
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
      // Zigbee alerts
      notifyZigbeeWaterLeak:
      notifyZigbeeWaterLeak ?? this.notifyZigbeeWaterLeak,
      notifyZigbeeSmoke: notifyZigbeeSmoke ?? this.notifyZigbeeSmoke,
      notifyZigbeeGas: notifyZigbeeGas ?? this.notifyZigbeeGas,
      notifyZigbeeMotion: notifyZigbeeMotion ?? this.notifyZigbeeMotion,
      notifyZigbeeContact: notifyZigbeeContact ?? this.notifyZigbeeContact,
      // Frigate
      notifyFrigatePerson: notifyFrigatePerson ?? this.notifyFrigatePerson,
      notifyFrigateCar: notifyFrigateCar ?? this.notifyFrigateCar,
      // Availability
      notifyZigbeeOffline: notifyZigbeeOffline ?? this.notifyZigbeeOffline,
      notifyFrigateOffline: notifyFrigateOffline ?? this.notifyFrigateOffline,
      // Cooldown
      smsCooldownMin: smsCooldownMin ?? this.smsCooldownMin,
      // Schedule
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