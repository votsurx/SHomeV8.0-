/// Сущность события для SQLite.
/// Представляет строку таблицы events — журнал всех действий в системе.
/// Используется EventLogger для записи и EventsScreen для отображения истории.
class EventEntity {
  /// Автоинкрементный ID (при вставке может быть null)
  final int? id;
  /// Тип события: turnOn, turnOff, scene, deviceAdded, deviceRemoved, roomAdded, roomRemoved, sceneCreated, sceneDeleted, timer, sensorData
  final String event;
  /// ID устройства (если событие связано с устройством)
  final String? deviceId;
  /// Название устройства для отображения
  final String? deviceName;
  /// Значение (температура, энергия, мощность)
  final String? value;
  /// Название сцены (для событий scene, sceneCreated, sceneDeleted)
  final String? sceneName;
  /// Название комнаты (для событий roomAdded, roomRemoved)
  final String? roomName;
  /// Название таймера (для событий timer)
  final String? timerName;
  /// ISO8601 временная метка события
  final String timestamp;

  EventEntity({
    this.id,
    required this.event,
    this.deviceId,
    this.deviceName,
    this.value,
    this.sceneName,
    this.roomName,
    this.timerName,
    required this.timestamp,
  });

  /// Преобразует сущность в Map для вставки в SQLite
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'event': event,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'value': value,
    'sceneName': sceneName,
    'roomName': roomName,
    'timerName': timerName,
    'timestamp': timestamp,
  };

  /// Создаёт сущность из Map (результат запроса SQLite)
  factory EventEntity.fromMap(Map<String, dynamic> map) => EventEntity(
    id: map['id'] as int?,
    event: map['event'] as String,
    deviceId: map['deviceId'] as String?,
    deviceName: map['deviceName'] as String?,
    value: map['value'] as String?,
    sceneName: map['sceneName'] as String?,
    roomName: map['roomName'] as String?,
    timerName: map['timerName'] as String?,
    timestamp: map['timestamp'] as String,
  );
}