// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presence_conditions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PresenceConditions _$PresenceConditionsFromJson(Map<String, dynamic> json) {
  return _PresenceConditions.fromJson(json);
}

/// @nodoc
mixin _$PresenceConditions {
  /// Использовать время суток
  bool get useTime => throw _privateConstructorUsedError;
  int get startHour => throw _privateConstructorUsedError;
  int get startMinute => throw _privateConstructorUsedError;
  int get endHour => throw _privateConstructorUsedError;
  int get endMinute => throw _privateConstructorUsedError;

  /// Использовать дни недели
  bool get useDays => throw _privateConstructorUsedError;
  List<int> get daysOfWeek => throw _privateConstructorUsedError;

  /// Использовать состояние устройства
  bool get useDevice => throw _privateConstructorUsedError;
  String? get deviceId => throw _privateConstructorUsedError;
  bool? get deviceOn => throw _privateConstructorUsedError;

  /// Serializes this PresenceConditions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PresenceConditions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresenceConditionsCopyWith<PresenceConditions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresenceConditionsCopyWith<$Res> {
  factory $PresenceConditionsCopyWith(
          PresenceConditions value, $Res Function(PresenceConditions) then) =
      _$PresenceConditionsCopyWithImpl<$Res, PresenceConditions>;
  @useResult
  $Res call(
      {bool useTime,
      int startHour,
      int startMinute,
      int endHour,
      int endMinute,
      bool useDays,
      List<int> daysOfWeek,
      bool useDevice,
      String? deviceId,
      bool? deviceOn});
}

/// @nodoc
class _$PresenceConditionsCopyWithImpl<$Res, $Val extends PresenceConditions>
    implements $PresenceConditionsCopyWith<$Res> {
  _$PresenceConditionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresenceConditions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? useTime = null,
    Object? startHour = null,
    Object? startMinute = null,
    Object? endHour = null,
    Object? endMinute = null,
    Object? useDays = null,
    Object? daysOfWeek = null,
    Object? useDevice = null,
    Object? deviceId = freezed,
    Object? deviceOn = freezed,
  }) {
    return _then(_value.copyWith(
      useTime: null == useTime
          ? _value.useTime
          : useTime // ignore: cast_nullable_to_non_nullable
              as bool,
      startHour: null == startHour
          ? _value.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as int,
      startMinute: null == startMinute
          ? _value.startMinute
          : startMinute // ignore: cast_nullable_to_non_nullable
              as int,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as int,
      endMinute: null == endMinute
          ? _value.endMinute
          : endMinute // ignore: cast_nullable_to_non_nullable
              as int,
      useDays: null == useDays
          ? _value.useDays
          : useDays // ignore: cast_nullable_to_non_nullable
              as bool,
      daysOfWeek: null == daysOfWeek
          ? _value.daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      useDevice: null == useDevice
          ? _value.useDevice
          : useDevice // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceOn: freezed == deviceOn
          ? _value.deviceOn
          : deviceOn // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PresenceConditionsImplCopyWith<$Res>
    implements $PresenceConditionsCopyWith<$Res> {
  factory _$$PresenceConditionsImplCopyWith(_$PresenceConditionsImpl value,
          $Res Function(_$PresenceConditionsImpl) then) =
      __$$PresenceConditionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool useTime,
      int startHour,
      int startMinute,
      int endHour,
      int endMinute,
      bool useDays,
      List<int> daysOfWeek,
      bool useDevice,
      String? deviceId,
      bool? deviceOn});
}

/// @nodoc
class __$$PresenceConditionsImplCopyWithImpl<$Res>
    extends _$PresenceConditionsCopyWithImpl<$Res, _$PresenceConditionsImpl>
    implements _$$PresenceConditionsImplCopyWith<$Res> {
  __$$PresenceConditionsImplCopyWithImpl(_$PresenceConditionsImpl _value,
      $Res Function(_$PresenceConditionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of PresenceConditions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? useTime = null,
    Object? startHour = null,
    Object? startMinute = null,
    Object? endHour = null,
    Object? endMinute = null,
    Object? useDays = null,
    Object? daysOfWeek = null,
    Object? useDevice = null,
    Object? deviceId = freezed,
    Object? deviceOn = freezed,
  }) {
    return _then(_$PresenceConditionsImpl(
      useTime: null == useTime
          ? _value.useTime
          : useTime // ignore: cast_nullable_to_non_nullable
              as bool,
      startHour: null == startHour
          ? _value.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as int,
      startMinute: null == startMinute
          ? _value.startMinute
          : startMinute // ignore: cast_nullable_to_non_nullable
              as int,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as int,
      endMinute: null == endMinute
          ? _value.endMinute
          : endMinute // ignore: cast_nullable_to_non_nullable
              as int,
      useDays: null == useDays
          ? _value.useDays
          : useDays // ignore: cast_nullable_to_non_nullable
              as bool,
      daysOfWeek: null == daysOfWeek
          ? _value._daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      useDevice: null == useDevice
          ? _value.useDevice
          : useDevice // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceOn: freezed == deviceOn
          ? _value.deviceOn
          : deviceOn // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresenceConditionsImpl implements _PresenceConditions {
  const _$PresenceConditionsImpl(
      {this.useTime = false,
      this.startHour = 0,
      this.startMinute = 0,
      this.endHour = 23,
      this.endMinute = 59,
      this.useDays = false,
      final List<int> daysOfWeek = const [],
      this.useDevice = false,
      this.deviceId,
      this.deviceOn})
      : _daysOfWeek = daysOfWeek;

  factory _$PresenceConditionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresenceConditionsImplFromJson(json);

  /// Использовать время суток
  @override
  @JsonKey()
  final bool useTime;
  @override
  @JsonKey()
  final int startHour;
  @override
  @JsonKey()
  final int startMinute;
  @override
  @JsonKey()
  final int endHour;
  @override
  @JsonKey()
  final int endMinute;

  /// Использовать дни недели
  @override
  @JsonKey()
  final bool useDays;
  final List<int> _daysOfWeek;
  @override
  @JsonKey()
  List<int> get daysOfWeek {
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daysOfWeek);
  }

  /// Использовать состояние устройства
  @override
  @JsonKey()
  final bool useDevice;
  @override
  final String? deviceId;
  @override
  final bool? deviceOn;

  @override
  String toString() {
    return 'PresenceConditions(useTime: $useTime, startHour: $startHour, startMinute: $startMinute, endHour: $endHour, endMinute: $endMinute, useDays: $useDays, daysOfWeek: $daysOfWeek, useDevice: $useDevice, deviceId: $deviceId, deviceOn: $deviceOn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresenceConditionsImpl &&
            (identical(other.useTime, useTime) || other.useTime == useTime) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.startMinute, startMinute) ||
                other.startMinute == startMinute) &&
            (identical(other.endHour, endHour) || other.endHour == endHour) &&
            (identical(other.endMinute, endMinute) ||
                other.endMinute == endMinute) &&
            (identical(other.useDays, useDays) || other.useDays == useDays) &&
            const DeepCollectionEquality()
                .equals(other._daysOfWeek, _daysOfWeek) &&
            (identical(other.useDevice, useDevice) ||
                other.useDevice == useDevice) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceOn, deviceOn) ||
                other.deviceOn == deviceOn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      useTime,
      startHour,
      startMinute,
      endHour,
      endMinute,
      useDays,
      const DeepCollectionEquality().hash(_daysOfWeek),
      useDevice,
      deviceId,
      deviceOn);

  /// Create a copy of PresenceConditions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresenceConditionsImplCopyWith<_$PresenceConditionsImpl> get copyWith =>
      __$$PresenceConditionsImplCopyWithImpl<_$PresenceConditionsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresenceConditionsImplToJson(
      this,
    );
  }
}

abstract class _PresenceConditions implements PresenceConditions {
  const factory _PresenceConditions(
      {final bool useTime,
      final int startHour,
      final int startMinute,
      final int endHour,
      final int endMinute,
      final bool useDays,
      final List<int> daysOfWeek,
      final bool useDevice,
      final String? deviceId,
      final bool? deviceOn}) = _$PresenceConditionsImpl;

  factory _PresenceConditions.fromJson(Map<String, dynamic> json) =
      _$PresenceConditionsImpl.fromJson;

  /// Использовать время суток
  @override
  bool get useTime;
  @override
  int get startHour;
  @override
  int get startMinute;
  @override
  int get endHour;
  @override
  int get endMinute;

  /// Использовать дни недели
  @override
  bool get useDays;
  @override
  List<int> get daysOfWeek;

  /// Использовать состояние устройства
  @override
  bool get useDevice;
  @override
  String? get deviceId;
  @override
  bool? get deviceOn;

  /// Create a copy of PresenceConditions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresenceConditionsImplCopyWith<_$PresenceConditionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
