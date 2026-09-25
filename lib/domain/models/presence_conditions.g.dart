// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_conditions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresenceConditionsImpl _$$PresenceConditionsImplFromJson(
        Map<String, dynamic> json) =>
    _$PresenceConditionsImpl(
      useTime: json['useTime'] as bool? ?? false,
      startHour: (json['startHour'] as num?)?.toInt() ?? 0,
      startMinute: (json['startMinute'] as num?)?.toInt() ?? 0,
      endHour: (json['endHour'] as num?)?.toInt() ?? 23,
      endMinute: (json['endMinute'] as num?)?.toInt() ?? 59,
      useDays: json['useDays'] as bool? ?? false,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      useDevice: json['useDevice'] as bool? ?? false,
      deviceId: json['deviceId'] as String?,
      deviceOn: json['deviceOn'] as bool?,
    );

Map<String, dynamic> _$$PresenceConditionsImplToJson(
        _$PresenceConditionsImpl instance) =>
    <String, dynamic>{
      'useTime': instance.useTime,
      'startHour': instance.startHour,
      'startMinute': instance.startMinute,
      'endHour': instance.endHour,
      'endMinute': instance.endMinute,
      'useDays': instance.useDays,
      'daysOfWeek': instance.daysOfWeek,
      'useDevice': instance.useDevice,
      'deviceId': instance.deviceId,
      'deviceOn': instance.deviceOn,
    };
