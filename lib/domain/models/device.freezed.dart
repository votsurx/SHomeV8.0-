// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Device _$DeviceFromJson(Map<String, dynamic> json) {
  return _Device.fromJson(json);
}

/// @nodoc
mixin _$Device {
  /// Внутренний уникальный идентификатор (UUID)
  String get id => throw _privateConstructorUsedError;

  /// Человекочитаемое название устройства
  String get name => throw _privateConstructorUsedError;

  /// Тип устройства: outlet, switch1/2/3, sensor, curtain, hvac, light, camera, button
  DeviceType get type => throw _privateConstructorUsedError;

  /// ID комнаты, к которой привязано устройство
  String get roomId => throw _privateConstructorUsedError;

  /// Флаг "в сети"
  bool get isOnline => throw _privateConstructorUsedError;

  /// Текущее состояние: online, offline, pending, error
  DeviceState get state => throw _privateConstructorUsedError;

  /// Tuya Device ID (внешний идентификатор устройства в облаке Tuya)
  String? get deviceId => throw _privateConstructorUsedError;

  /// Локальный ключ шифрования для Tuya-протокола
  String? get localKey => throw _privateConstructorUsedError;

  /// IP-адрес устройства в локальной сети
  String? get address => throw _privateConstructorUsedError;

  /// Версия протокола Tuya: 3.1, 3.3, 3.4, 3.5
  double? get version => throw _privateConstructorUsedError;

  /// Индекс DPS для вкл/выкл (по умолчанию 1, для SimPal-TY130 = 2)
  int? get dpsIndex => throw _privateConstructorUsedError;

  /// MQTT-топик (для будущей интеграции с Zigbee/MQTT)
  String? get mqttTopic => throw _privateConstructorUsedError;

  /// Последнее значение температуры (для датчиков)
  double? get temperature => throw _privateConstructorUsedError;

  /// Последнее значение влажности (для датчиков)
  double? get humidity => throw _privateConstructorUsedError;

  /// Последнее значение датчика движения
  bool? get motion => throw _privateConstructorUsedError;

  /// Последнее значение датчика открытия двери
  bool? get doorOpen => throw _privateConstructorUsedError;

  /// Уровень заряда батареи (для беспроводных датчиков)
  double? get battery => throw _privateConstructorUsedError;

  /// Гибкие свойства: isOn, states, channels, brightness, position,
  /// sensorType, sensorDps, sensorDivider, temperature, humidity, power...
  Map<String, dynamic> get properties => throw _privateConstructorUsedError;

  /// Serializes this Device to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceCopyWith<Device> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceCopyWith<$Res> {
  factory $DeviceCopyWith(Device value, $Res Function(Device) then) =
      _$DeviceCopyWithImpl<$Res, Device>;
  @useResult
  $Res call(
      {String id,
      String name,
      DeviceType type,
      String roomId,
      bool isOnline,
      DeviceState state,
      String? deviceId,
      String? localKey,
      String? address,
      double? version,
      int? dpsIndex,
      String? mqttTopic,
      double? temperature,
      double? humidity,
      bool? motion,
      bool? doorOpen,
      double? battery,
      Map<String, dynamic> properties});
}

/// @nodoc
class _$DeviceCopyWithImpl<$Res, $Val extends Device>
    implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? roomId = null,
    Object? isOnline = null,
    Object? state = null,
    Object? deviceId = freezed,
    Object? localKey = freezed,
    Object? address = freezed,
    Object? version = freezed,
    Object? dpsIndex = freezed,
    Object? mqttTopic = freezed,
    Object? temperature = freezed,
    Object? humidity = freezed,
    Object? motion = freezed,
    Object? doorOpen = freezed,
    Object? battery = freezed,
    Object? properties = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DeviceType,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as DeviceState,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      localKey: freezed == localKey
          ? _value.localKey
          : localKey // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as double?,
      dpsIndex: freezed == dpsIndex
          ? _value.dpsIndex
          : dpsIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      mqttTopic: freezed == mqttTopic
          ? _value.mqttTopic
          : mqttTopic // ignore: cast_nullable_to_non_nullable
              as String?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      humidity: freezed == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double?,
      motion: freezed == motion
          ? _value.motion
          : motion // ignore: cast_nullable_to_non_nullable
              as bool?,
      doorOpen: freezed == doorOpen
          ? _value.doorOpen
          : doorOpen // ignore: cast_nullable_to_non_nullable
              as bool?,
      battery: freezed == battery
          ? _value.battery
          : battery // ignore: cast_nullable_to_non_nullable
              as double?,
      properties: null == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceImplCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$$DeviceImplCopyWith(
          _$DeviceImpl value, $Res Function(_$DeviceImpl) then) =
      __$$DeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      DeviceType type,
      String roomId,
      bool isOnline,
      DeviceState state,
      String? deviceId,
      String? localKey,
      String? address,
      double? version,
      int? dpsIndex,
      String? mqttTopic,
      double? temperature,
      double? humidity,
      bool? motion,
      bool? doorOpen,
      double? battery,
      Map<String, dynamic> properties});
}

/// @nodoc
class __$$DeviceImplCopyWithImpl<$Res>
    extends _$DeviceCopyWithImpl<$Res, _$DeviceImpl>
    implements _$$DeviceImplCopyWith<$Res> {
  __$$DeviceImplCopyWithImpl(
      _$DeviceImpl _value, $Res Function(_$DeviceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? roomId = null,
    Object? isOnline = null,
    Object? state = null,
    Object? deviceId = freezed,
    Object? localKey = freezed,
    Object? address = freezed,
    Object? version = freezed,
    Object? dpsIndex = freezed,
    Object? mqttTopic = freezed,
    Object? temperature = freezed,
    Object? humidity = freezed,
    Object? motion = freezed,
    Object? doorOpen = freezed,
    Object? battery = freezed,
    Object? properties = null,
  }) {
    return _then(_$DeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DeviceType,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as DeviceState,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      localKey: freezed == localKey
          ? _value.localKey
          : localKey // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as double?,
      dpsIndex: freezed == dpsIndex
          ? _value.dpsIndex
          : dpsIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      mqttTopic: freezed == mqttTopic
          ? _value.mqttTopic
          : mqttTopic // ignore: cast_nullable_to_non_nullable
              as String?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      humidity: freezed == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double?,
      motion: freezed == motion
          ? _value.motion
          : motion // ignore: cast_nullable_to_non_nullable
              as bool?,
      doorOpen: freezed == doorOpen
          ? _value.doorOpen
          : doorOpen // ignore: cast_nullable_to_non_nullable
              as bool?,
      battery: freezed == battery
          ? _value.battery
          : battery // ignore: cast_nullable_to_non_nullable
              as double?,
      properties: null == properties
          ? _value._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceImpl implements _Device {
  const _$DeviceImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.roomId,
      required this.isOnline,
      required this.state,
      this.deviceId,
      this.localKey,
      this.address,
      this.version,
      this.dpsIndex,
      this.mqttTopic,
      this.temperature,
      this.humidity,
      this.motion,
      this.doorOpen,
      this.battery,
      final Map<String, dynamic> properties = const {}})
      : _properties = properties;

  factory _$DeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceImplFromJson(json);

  /// Внутренний уникальный идентификатор (UUID)
  @override
  final String id;

  /// Человекочитаемое название устройства
  @override
  final String name;

  /// Тип устройства: outlet, switch1/2/3, sensor, curtain, hvac, light, camera, button
  @override
  final DeviceType type;

  /// ID комнаты, к которой привязано устройство
  @override
  final String roomId;

  /// Флаг "в сети"
  @override
  final bool isOnline;

  /// Текущее состояние: online, offline, pending, error
  @override
  final DeviceState state;

  /// Tuya Device ID (внешний идентификатор устройства в облаке Tuya)
  @override
  final String? deviceId;

  /// Локальный ключ шифрования для Tuya-протокола
  @override
  final String? localKey;

  /// IP-адрес устройства в локальной сети
  @override
  final String? address;

  /// Версия протокола Tuya: 3.1, 3.3, 3.4, 3.5
  @override
  final double? version;

  /// Индекс DPS для вкл/выкл (по умолчанию 1, для SimPal-TY130 = 2)
  @override
  final int? dpsIndex;

  /// MQTT-топик (для будущей интеграции с Zigbee/MQTT)
  @override
  final String? mqttTopic;

  /// Последнее значение температуры (для датчиков)
  @override
  final double? temperature;

  /// Последнее значение влажности (для датчиков)
  @override
  final double? humidity;

  /// Последнее значение датчика движения
  @override
  final bool? motion;

  /// Последнее значение датчика открытия двери
  @override
  final bool? doorOpen;

  /// Уровень заряда батареи (для беспроводных датчиков)
  @override
  final double? battery;

  /// Гибкие свойства: isOn, states, channels, brightness, position,
  /// sensorType, sensorDps, sensorDivider, temperature, humidity, power...
  final Map<String, dynamic> _properties;

  /// Гибкие свойства: isOn, states, channels, brightness, position,
  /// sensorType, sensorDps, sensorDivider, temperature, humidity, power...
  @override
  @JsonKey()
  Map<String, dynamic> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  @override
  String toString() {
    return 'Device(id: $id, name: $name, type: $type, roomId: $roomId, isOnline: $isOnline, state: $state, deviceId: $deviceId, localKey: $localKey, address: $address, version: $version, dpsIndex: $dpsIndex, mqttTopic: $mqttTopic, temperature: $temperature, humidity: $humidity, motion: $motion, doorOpen: $doorOpen, battery: $battery, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.localKey, localKey) ||
                other.localKey == localKey) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.dpsIndex, dpsIndex) ||
                other.dpsIndex == dpsIndex) &&
            (identical(other.mqttTopic, mqttTopic) ||
                other.mqttTopic == mqttTopic) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.motion, motion) || other.motion == motion) &&
            (identical(other.doorOpen, doorOpen) ||
                other.doorOpen == doorOpen) &&
            (identical(other.battery, battery) || other.battery == battery) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      type,
      roomId,
      isOnline,
      state,
      deviceId,
      localKey,
      address,
      version,
      dpsIndex,
      mqttTopic,
      temperature,
      humidity,
      motion,
      doorOpen,
      battery,
      const DeepCollectionEquality().hash(_properties));

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      __$$DeviceImplCopyWithImpl<_$DeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceImplToJson(
      this,
    );
  }
}

abstract class _Device implements Device {
  const factory _Device(
      {required final String id,
      required final String name,
      required final DeviceType type,
      required final String roomId,
      required final bool isOnline,
      required final DeviceState state,
      final String? deviceId,
      final String? localKey,
      final String? address,
      final double? version,
      final int? dpsIndex,
      final String? mqttTopic,
      final double? temperature,
      final double? humidity,
      final bool? motion,
      final bool? doorOpen,
      final double? battery,
      final Map<String, dynamic> properties}) = _$DeviceImpl;

  factory _Device.fromJson(Map<String, dynamic> json) = _$DeviceImpl.fromJson;

  /// Внутренний уникальный идентификатор (UUID)
  @override
  String get id;

  /// Человекочитаемое название устройства
  @override
  String get name;

  /// Тип устройства: outlet, switch1/2/3, sensor, curtain, hvac, light, camera, button
  @override
  DeviceType get type;

  /// ID комнаты, к которой привязано устройство
  @override
  String get roomId;

  /// Флаг "в сети"
  @override
  bool get isOnline;

  /// Текущее состояние: online, offline, pending, error
  @override
  DeviceState get state;

  /// Tuya Device ID (внешний идентификатор устройства в облаке Tuya)
  @override
  String? get deviceId;

  /// Локальный ключ шифрования для Tuya-протокола
  @override
  String? get localKey;

  /// IP-адрес устройства в локальной сети
  @override
  String? get address;

  /// Версия протокола Tuya: 3.1, 3.3, 3.4, 3.5
  @override
  double? get version;

  /// Индекс DPS для вкл/выкл (по умолчанию 1, для SimPal-TY130 = 2)
  @override
  int? get dpsIndex;

  /// MQTT-топик (для будущей интеграции с Zigbee/MQTT)
  @override
  String? get mqttTopic;

  /// Последнее значение температуры (для датчиков)
  @override
  double? get temperature;

  /// Последнее значение влажности (для датчиков)
  @override
  double? get humidity;

  /// Последнее значение датчика движения
  @override
  bool? get motion;

  /// Последнее значение датчика открытия двери
  @override
  bool? get doorOpen;

  /// Уровень заряда батареи (для беспроводных датчиков)
  @override
  double? get battery;

  /// Гибкие свойства: isOn, states, channels, brightness, position,
  /// sensorType, sensorDps, sensorDivider, temperature, humidity, power...
  @override
  Map<String, dynamic> get properties;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
