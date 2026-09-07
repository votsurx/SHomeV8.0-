// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SceneImpl _$$SceneImplFromJson(Map<String, dynamic> json) => _$SceneImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      actions: (json['actions'] as List<dynamic>)
          .map((e) => SceneAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      trigger: json['trigger'] == null
          ? null
          : SceneTrigger.fromJson(json['trigger'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SceneImplToJson(_$SceneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'actions': instance.actions,
      'trigger': instance.trigger,
    };

_$SceneActionImpl _$$SceneActionImplFromJson(Map<String, dynamic> json) =>
    _$SceneActionImpl(
      deviceId: json['deviceId'] as String,
      command: json['command'] as String,
      value: json['value'],
    );

Map<String, dynamic> _$$SceneActionImplToJson(_$SceneActionImpl instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'command': instance.command,
      'value': instance.value,
    };

_$SceneTriggerImpl _$$SceneTriggerImplFromJson(Map<String, dynamic> json) =>
    _$SceneTriggerImpl(
      type: $enumDecode(_$TriggerTypeEnumMap, json['type']),
      time: json['time'] as String?,
      deviceId: json['deviceId'] as String?,
      condition: json['condition'] as String?,
      repeat: $enumDecodeNullable(_$RepeatTypeEnumMap, json['repeat']) ??
          RepeatType.once,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      sensorDeviceId: json['sensorDeviceId'] as String?,
      sensorCondition: json['sensorCondition'] as String?,
      sensorThreshold: (json['sensorThreshold'] as num?)?.toDouble(),
      lastExecuted: json['lastExecuted'] as String?,
    );

Map<String, dynamic> _$$SceneTriggerImplToJson(_$SceneTriggerImpl instance) =>
    <String, dynamic>{
      'type': _$TriggerTypeEnumMap[instance.type]!,
      'time': instance.time,
      'deviceId': instance.deviceId,
      'condition': instance.condition,
      'repeat': _$RepeatTypeEnumMap[instance.repeat]!,
      'repeatDays': instance.repeatDays,
      'sensorDeviceId': instance.sensorDeviceId,
      'sensorCondition': instance.sensorCondition,
      'sensorThreshold': instance.sensorThreshold,
      'lastExecuted': instance.lastExecuted,
    };

const _$TriggerTypeEnumMap = {
  TriggerType.time: 'time',
  TriggerType.deviceState: 'deviceState',
  TriggerType.manual: 'manual',
};

const _$RepeatTypeEnumMap = {
  RepeatType.once: 'once',
  RepeatType.daily: 'daily',
  RepeatType.weekly: 'weekly',
  RepeatType.interval: 'interval',
};
