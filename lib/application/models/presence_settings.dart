class PresencePhone {
  final String phoneId;
  final String phoneName;
  final String ip;
  final bool enabled;

  PresencePhone({
    required this.phoneId,
    required this.phoneName,
    this.ip = '',
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
    'phoneId': phoneId,
    'phoneName': phoneName,
    'ip': ip,
    'enabled': enabled,
  };

  factory PresencePhone.fromJson(Map<String, dynamic> json) => PresencePhone(
    phoneId: json['phoneId'] as String,
    phoneName: json['phoneName'] as String,
    ip: json['ip'] as String? ?? '',
    enabled: json['enabled'] as bool? ?? true,
  );

  PresencePhone copyWith({
    String? phoneId,
    String? phoneName,
    String? ip,
    bool? enabled,
  }) {
    return PresencePhone(
      phoneId: phoneId ?? this.phoneId,
      phoneName: phoneName ?? this.phoneName,
      ip: ip ?? this.ip,
      enabled: enabled ?? this.enabled,
    );
  }
}

class PresenceSettings {
  final bool enabled;
  final List<PresencePhone> phones;
  final double homeLat;
  final double homeLng;
  final int homeRadius;
  final int awayTimeoutMin;

  PresenceSettings({
    this.enabled = false,
    this.phones = const [],
    this.homeLat = 0.0,
    this.homeLng = 0.0,
    this.homeRadius = 100,
    this.awayTimeoutMin = 5,
  });

  bool get isConfigured => phones.any((p) => p.enabled);

  PresenceSettings copyWith({
    bool? enabled,
    List<PresencePhone>? phones,
    double? homeLat,
    double? homeLng,
    int? homeRadius,
    int? awayTimeoutMin,
  }) {
    return PresenceSettings(
      enabled: enabled ?? this.enabled,
      phones: phones ?? this.phones,
      homeLat: homeLat ?? this.homeLat,
      homeLng: homeLng ?? this.homeLng,
      homeRadius: homeRadius ?? this.homeRadius,
      awayTimeoutMin: awayTimeoutMin ?? this.awayTimeoutMin,
    );
  }
}