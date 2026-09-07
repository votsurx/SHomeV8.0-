/// Сущность устройства для SQLite.
/// Представляет строку таблицы devices в базе данных.
/// Свойства хранятся в JSON-строке для гибкости (разные типы устройств).
/// Маппится в доменную модель через DeviceMapper.
class DeviceEntity {
  /// Уникальный идентификатор устройства (внутренний UUID)
  final String id;
  /// Человекочитаемое название
  final String name;
  /// Тип устройства: outlet, switch1, switch2, switch3, sensor, curtain, hvac, light, camera, button
  final String type;
  /// ID комнаты, к которой привязано устройство
  final String roomId;
  /// Флаг онлайн: 1 = в сети, 0 = не в сети
  final int isOnline;
  /// Состояние: online, offline, pending, error
  final String state;
  /// Tuya Device ID (внешний идентификатор устройства)
  final String? deviceId;
  /// Локальный ключ шифрования Tuya
  final String? localKey;
  /// IP-адрес устройства в локальной сети
  final String? address;
  /// Версия протокола Tuya: 3.1, 3.3, 3.4, 3.5
  final double? version;
  /// Индекс DPS для вкл/выкл (по умолчанию 1)
  final int? dpsIndex;
  /// Дополнительные свойства в JSON-строке (isOn, states, temperature, humidity, channels...)
  final String properties;

  DeviceEntity({
    required this.id,
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
    required this.properties,
  });

  /// Преобразует сущность в Map для вставки/обновления в SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'roomId': roomId,
      'isOnline': isOnline,
      'state': state,
      'deviceId': deviceId,
      'localKey': localKey,
      'address': address,
      'version': version,
      'dpsIndex': dpsIndex,
      'properties': properties,
    };
  }

  /// Создаёт сущность из Map (результат запроса SQLite)
  factory DeviceEntity.fromMap(Map<String, dynamic> map) {
    return DeviceEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      roomId: map['roomId'] as String,
      isOnline: map['isOnline'] as int,
      state: map['state'] as String,
      deviceId: map['deviceId'] as String?,
      localKey: map['localKey'] as String?,
      address: map['address'] as String?,
      version: map['version'] as double?,
      dpsIndex: map['dpsIndex'] as int?,
      properties: map['properties'] as String,
    );
  }
}