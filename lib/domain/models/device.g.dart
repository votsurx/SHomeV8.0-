// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceImpl _$$DeviceImplFromJson(Map<String, dynamic> json) => _$DeviceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$DeviceTypeEnumMap, json['type']),
      roomId: json['roomId'] as String,
      isOnline: json['isOnline'] as bool,
      state: $enumDecode(_$DeviceStateEnumMap, json['state']),
      deviceId: json['deviceId'] as String?,
      localKey: json['localKey'] as String?,
      address: json['address'] as String?,
      version: (json['version'] as num?)?.toDouble(),
      dpsIndex: (json['dpsIndex'] as num?)?.toInt(),
      mqttTopic: json['mqttTopic'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      motion: json['motion'] as bool?,
      doorOpen: json['doorOpen'] as bool?,
      battery: (json['battery'] as num?)?.toDouble(),
      properties: json['properties'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$DeviceImplToJson(_$DeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$DeviceTypeEnumMap[instance.type]!,
      'roomId': instance.roomId,
      'isOnline': instance.isOnline,
      'state': _$DeviceStateEnumMap[instance.state]!,
      'deviceId': instance.deviceId,
      'localKey': instance.localKey,
      'address': instance.address,
      'version': instance.version,
      'dpsIndex': instance.dpsIndex,
      'mqttTopic': instance.mqttTopic,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'motion': instance.motion,
      'doorOpen': instance.doorOpen,
      'battery': instance.battery,
      'properties': instance.properties,
    };

const _$DeviceTypeEnumMap = {
  DeviceType.outlet: 'outlet',
  DeviceType.switch1: 'switch1',
  DeviceType.switch2: 'switch2',
  DeviceType.switch3: 'switch3',
  DeviceType.sensor: 'sensor',
  DeviceType.curtain: 'curtain',
  DeviceType.hvac: 'hvac',
  DeviceType.light: 'light',
  DeviceType.camera: 'camera',
  DeviceType.button: 'button',
  DeviceType.compound: 'compound',
};

const _$DeviceStateEnumMap = {
  DeviceState.online: 'online',
  DeviceState.offline: 'offline',
  DeviceState.pending: 'pending',
  DeviceState.error: 'error',
};
