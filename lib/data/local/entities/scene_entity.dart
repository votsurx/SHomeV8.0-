/// Сущность сцены для SQLite.
/// Представляет строку таблицы scenes в базе данных.
/// Действия (actions) хранятся в JSON-строке.
/// Маппится в доменную модель Scene через SceneMapper.
class SceneEntity {
  /// Уникальный идентификатор сцены (UUID)
  final String id;
  /// Название сцены (например, "Выключить всё")
  final String name;
  /// Emoji-иконка сцены (⏰, 🎬)
  final String icon;
  /// Список действий в формате JSON-строки: [{"deviceId":"...", "command":"turnOff"}]
  final String actions;
  /// Тип триггера: time, deviceState, manual (null если ручная)
  final String? triggerType;
  /// Время выполнения для time-триггера в формате HH:mm
  final String? triggerTime;
  /// Тип повтора: once, daily, weekly (null если без повтора)
  final String? triggerRepeat;

  SceneEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.actions,
    this.triggerType,
    this.triggerTime,
    this.triggerRepeat,
  });

  /// Преобразует сущность в Map для вставки/обновления в SQLite
  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'icon': icon, 'actions': actions,
    'triggerType': triggerType, 'triggerTime': triggerTime, 'triggerRepeat': triggerRepeat,
  };

  /// Создаёт сущность из Map (результат запроса SQLite)
  factory SceneEntity.fromMap(Map<String, dynamic> map) => SceneEntity(
    id: map['id'], name: map['name'], icon: map['icon'], actions: map['actions'],
    triggerType: map['triggerType'], triggerTime: map['triggerTime'], triggerRepeat: map['triggerRepeat'],
  );
}