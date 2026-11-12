// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_timer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeviceTimer _$DeviceTimerFromJson(Map<String, dynamic> json) {
  return _DeviceTimer.fromJson(json);
}

/// @nodoc
mixin _$DeviceTimer {
  /// Уникальный идентификатор таймера (UUID)
  String get id => throw _privateConstructorUsedError;

  /// ID устройства, к которому применяется команда
  String get deviceId => throw _privateConstructorUsedError;

  /// Название устройства для отображения
  String get deviceName => throw _privateConstructorUsedError;

  /// Команда: 'turnOn' или 'turnOff'
  String get command => throw _privateConstructorUsedError;

  /// Время выполнения команды
  DateTime get executeAt => throw _privateConstructorUsedError;

  /// Флаг выполнения (true — уже выполнено, не активно)
  bool get executed => throw _privateConstructorUsedError;

  /// Serializes this DeviceTimer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceTimer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceTimerCopyWith<DeviceTimer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceTimerCopyWith<$Res> {
  factory $DeviceTimerCopyWith(
          DeviceTimer value, $Res Function(DeviceTimer) then) =
      _$DeviceTimerCopyWithImpl<$Res, DeviceTimer>;
  @useResult
  $Res call(
      {String id,
      String deviceId,
      String deviceName,
      String command,
      DateTime executeAt,
      bool executed});
}

/// @nodoc
class _$DeviceTimerCopyWithImpl<$Res, $Val extends DeviceTimer>
    implements $DeviceTimerCopyWith<$Res> {
  _$DeviceTimerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceTimer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? deviceName = null,
    Object? command = null,
    Object? executeAt = null,
    Object? executed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      command: null == command
          ? _value.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      executeAt: null == executeAt
          ? _value.executeAt
          : executeAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      executed: null == executed
          ? _value.executed
          : executed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceTimerImplCopyWith<$Res>
    implements $DeviceTimerCopyWith<$Res> {
  factory _$$DeviceTimerImplCopyWith(
          _$DeviceTimerImpl value, $Res Function(_$DeviceTimerImpl) then) =
      __$$DeviceTimerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deviceId,
      String deviceName,
      String command,
      DateTime executeAt,
      bool executed});
}

/// @nodoc
class __$$DeviceTimerImplCopyWithImpl<$Res>
    extends _$DeviceTimerCopyWithImpl<$Res, _$DeviceTimerImpl>
    implements _$$DeviceTimerImplCopyWith<$Res> {
  __$$DeviceTimerImplCopyWithImpl(
      _$DeviceTimerImpl _value, $Res Function(_$DeviceTimerImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeviceTimer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? deviceName = null,
    Object? command = null,
    Object? executeAt = null,
    Object? executed = null,
  }) {
    return _then(_$DeviceTimerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      command: null == command
          ? _value.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      executeAt: null == executeAt
          ? _value.executeAt
          : executeAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      executed: null == executed
          ? _value.executed
          : executed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceTimerImpl implements _DeviceTimer {
  const _$DeviceTimerImpl(
      {required this.id,
      required this.deviceId,
      required this.deviceName,
      required this.command,
      required this.executeAt,
      required this.executed});

  factory _$DeviceTimerImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceTimerImplFromJson(json);

  /// Уникальный идентификатор таймера (UUID)
  @override
  final String id;

  /// ID устройства, к которому применяется команда
  @override
  final String deviceId;

  /// Название устройства для отображения
  @override
  final String deviceName;

  /// Команда: 'turnOn' или 'turnOff'
  @override
  final String command;

  /// Время выполнения команды
  @override
  final DateTime executeAt;

  /// Флаг выполнения (true — уже выполнено, не активно)
  @override
  final bool executed;

  @override
  String toString() {
    return 'DeviceTimer(id: $id, deviceId: $deviceId, deviceName: $deviceName, command: $command, executeAt: $executeAt, executed: $executed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceTimerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.command, command) || other.command == command) &&
            (identical(other.executeAt, executeAt) ||
                other.executeAt == executeAt) &&
            (identical(other.executed, executed) ||
                other.executed == executed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, deviceId, deviceName, command, executeAt, executed);

  /// Create a copy of DeviceTimer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceTimerImplCopyWith<_$DeviceTimerImpl> get copyWith =>
      __$$DeviceTimerImplCopyWithImpl<_$DeviceTimerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceTimerImplToJson(
      this,
    );
  }
}

abstract class _DeviceTimer implements DeviceTimer {
  const factory _DeviceTimer(
      {required final String id,
      required final String deviceId,
      required final String deviceName,
      required final String command,
      required final DateTime executeAt,
      required final bool executed}) = _$DeviceTimerImpl;

  factory _DeviceTimer.fromJson(Map<String, dynamic> json) =
      _$DeviceTimerImpl.fromJson;

  /// Уникальный идентификатор таймера (UUID)
  @override
  String get id;

  /// ID устройства, к которому применяется команда
  @override
  String get deviceId;

  /// Название устройства для отображения
  @override
  String get deviceName;

  /// Команда: 'turnOn' или 'turnOff'
  @override
  String get command;

  /// Время выполнения команды
  @override
  DateTime get executeAt;

  /// Флаг выполнения (true — уже выполнено, не активно)
  @override
  bool get executed;

  /// Create a copy of DeviceTimer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceTimerImplCopyWith<_$DeviceTimerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
