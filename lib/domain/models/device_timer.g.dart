// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_timer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceTimerImpl _$$DeviceTimerImplFromJson(Map<String, dynamic> json) =>
    _$DeviceTimerImpl(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      command: json['command'] as String,
      executeAt: DateTime.parse(json['executeAt'] as String),
      executed: json['executed'] as bool,
    );

Map<String, dynamic> _$$DeviceTimerImplToJson(_$DeviceTimerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'command': instance.command,
      'executeAt': instance.executeAt.toIso8601String(),
      'executed': instance.executed,
    };
