class SmsPhone {
  final String phone;
  final String? name;
  final bool enabled;

  SmsPhone({
    required this.phone,
    this.name,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'name': name,
    'enabled': enabled,
  };

  factory SmsPhone.fromJson(Map<String, dynamic> json) => SmsPhone(
    phone: json['phone'] as String,
    name: json['name'] as String?,
    enabled: json['enabled'] as bool? ?? true,
  );

  SmsPhone copyWith({
    String? phone,
    String? name,
    bool? enabled,
  }) {
    return SmsPhone(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
    );
  }
}