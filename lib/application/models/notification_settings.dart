class NotificationSettings {
  final bool enabled;
  final String vkToken;
  final String vkUserId;

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

  // Cooldown VK
  final int vkCooldownMin;

  final bool smsEnabled;
  final String smsPhoneNumber;

  // Расписание
  final bool useSchedule;
  final bool scheduleOnlyAlarms;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final List<int> daysOfWeek;

  NotificationSettings({
    this.enabled = false,
    this.vkToken = '',
    this.vkUserId = '',
    this.notifyScenes = true,
    this.notifyDevices = false,
    this.notifyAlarms = true,
    this.notifyErrors = true,
    // Zigbee alerts
    this.notifyZigbeeWaterLeak = true,
    this.notifyZigbeeSmoke = true,
    this.notifyZigbeeGas = true,
    this.notifyZigbeeMotion = true,
    this.notifyZigbeeContact = true,
    // Frigate
    this.notifyFrigatePerson = true,
    this.notifyFrigateCar = false,
    // Availability
    this.notifyZigbeeOffline = true,
    this.notifyFrigateOffline = true,
    // Cooldown
    this.vkCooldownMin = 1,
    // Schedule
    this.useSchedule = false,
    this.scheduleOnlyAlarms = true,
    this.startHour = 9,
    this.startMinute = 0,
    this.endHour = 21,
    this.endMinute = 0,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.smsEnabled = false,
    this.smsPhoneNumber = '',
  });

  bool get isConfigured =>
      enabled && vkToken.isNotEmpty && vkUserId.isNotEmpty;

  NotificationSettings copyWith({
    bool? enabled,
    String? vkToken,
    String? vkUserId,
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
    int? vkCooldownMin,
    // Schedule
    bool? useSchedule,
    bool? scheduleOnlyAlarms,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    List<int>? daysOfWeek,
    bool? smsEnabled,
    String? smsPhoneNumber,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      vkToken: vkToken ?? this.vkToken,
      vkUserId: vkUserId ?? this.vkUserId,
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
      vkCooldownMin: vkCooldownMin ?? this.vkCooldownMin,
      // Schedule
      useSchedule: useSchedule ?? this.useSchedule,
      scheduleOnlyAlarms: scheduleOnlyAlarms ?? this.scheduleOnlyAlarms,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      smsPhoneNumber: smsPhoneNumber ?? this.smsPhoneNumber,
    );
  }
}