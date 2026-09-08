class NotificationSettings {
  final bool enabled;
  final String vkToken;
  final String vkUserId;

  final bool notifyScenes;
  final bool notifyDevices;
  final bool notifyAlarms;
  final bool notifyErrors;

  // Расписание
  final bool useSchedule;
  final bool scheduleOnlyAlarms; // true — вне расписания слать только тревоги
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final List<int> daysOfWeek; // 1=Пн, 7=Вс

  NotificationSettings({
    this.enabled = false,
    this.vkToken = '',
    this.vkUserId = '',
    this.notifyScenes = true,
    this.notifyDevices = false,
    this.notifyAlarms = true,
    this.notifyErrors = true,
    this.useSchedule = false,
    this.scheduleOnlyAlarms = true,
    this.startHour = 9,
    this.startMinute = 0,
    this.endHour = 21,
    this.endMinute = 0,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
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
    bool? useSchedule,
    bool? scheduleOnlyAlarms,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    List<int>? daysOfWeek,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      vkToken: vkToken ?? this.vkToken,
      vkUserId: vkUserId ?? this.vkUserId,
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