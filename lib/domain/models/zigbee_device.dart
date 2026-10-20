/// Модели Zigbee-устройств из Zigbee2MQTT.
/// Парсятся из JSON-топика `zigbee2mqtt/bridge/devices`.
library;

/// Zigbee-устройство из Z2M.
class ZigbeeDevice {
  final String ieeeAddress;
  final String friendlyName;
  final String model;
  final String vendor;
  final String type;  // Coordinator, Router, EndDevice
  final List<ZigbeeExpose> exposes;
  final bool available;
  final String? description;

  ZigbeeDevice({
    required this.ieeeAddress,
    required this.friendlyName,
    required this.model,
    required this.vendor,
    required this.type,
    required this.exposes,
    this.available = true,
    this.description,
  });

  factory ZigbeeDevice.fromJson(Map<String, dynamic> json) {
    final definition = json['definition'] as Map<String, dynamic>?;
    final exposesRaw = definition?['exposes'] as List<dynamic>? ?? [];

    return ZigbeeDevice(
      ieeeAddress: json['ieee_address'] as String? ?? '',
      friendlyName: json['friendly_name'] as String? ?? '',
      model: json['model'] as String? ?? '',
      vendor: json['vendor'] as String? ?? '',
      type: json['type'] as String? ?? 'EndDevice',
      available: json['disabled'] != true,
      description: json['description'] as String?,
      exposes: exposesRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => ZigbeeExpose.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'ieee_address': ieeeAddress,
    'friendly_name': friendlyName,
    'model': model,
    'vendor': vendor,
    'type': type,
    'available': available,
    'description': description,
    'exposes': exposes.map((e) => e.toJson()).toList(),
  };

  bool get isCoordinator => type == 'Coordinator';
  bool get isRouter => type == 'Router';
  bool get isEndDevice => type == 'EndDevice';
}

/// Один expose (возможность) Zigbee-устройства.
class ZigbeeExpose {
  final String type;      // numeric, binary, enum, switch, text, composite
  final String name;      // temperature, occupancy, action, state
  final int? access;      // 1 = read, 2 = write, 3 = read/write
  final String? unit;     // °C, %, hPa
  final List<String>? values;  // для enum
  final double? valueMin;
  final double? valueMax;
  final String? property;  // для composite
  final String? description;

  ZigbeeExpose({
    required this.type,
    required this.name,
    this.access,
    this.unit,
    this.values,
    this.valueMin,
    this.valueMax,
    this.property,
    this.description,
  });

  factory ZigbeeExpose.fromJson(Map<String, dynamic> json) {
    return ZigbeeExpose(
      type: json['type'] as String? ?? 'text',
      name: json['name'] as String? ?? '',
      access: json['access'] as int?,
      unit: json['unit'] as String?,
      values: (json['values'] as List<dynamic>?)?.cast<String>(),
      valueMin: (json['value_min'] as num?)?.toDouble(),
      valueMax: (json['value_max'] as num?)?.toDouble(),
      property: json['property'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'access': access,
    'unit': unit,
    'values': values,
    'value_min': valueMin,
    'value_max': valueMax,
    'property': property,
    'description': description,
  };

  bool get isReadOnly => access == 1;
  bool get isWritable => access == 2 || access == 3;
}

/// Событие от Zigbee2MQTT (сопряжение, интервью).
class ZigbeeEvent {
  final String type;        // device_joined, device_interview, device_announce
  final String ieeeAddress;
  final String? friendlyName;
  final String? status;     // successful, failed

  ZigbeeEvent({
    required this.type,
    required this.ieeeAddress,
    this.friendlyName,
    this.status,
  });

  factory ZigbeeEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ZigbeeEvent(
      type: json['type'] as String? ?? '',
      ieeeAddress: data['ieee_address'] as String? ?? '',
      friendlyName: data['friendly_name'] as String?,
      status: data['status'] as String?,
    );
  }

  bool get isJoined => type == 'device_joined';
  bool get isInterviewSuccessful =>
      type == 'device_interview' && status == 'successful';
}