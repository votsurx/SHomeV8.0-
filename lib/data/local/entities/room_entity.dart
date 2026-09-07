/// Сущность комнаты для SQLite.
/// Представляет строку таблицы rooms в базе данных.
/// Маппится в доменную модель Room через RoomMapper.
class RoomEntity {
  /// Уникальный идентификатор комнаты
  final String id;
  /// Название комнаты (Гостиная, Спальня, Кухня...)
  final String name;
  /// Emoji-иконка комнаты (🛋️, 🛏️, 🍳...)
  final String? icon;
  /// Порядок сортировки при отображении (0, 1, 2...)
  final int sortOrder;

  RoomEntity({
    required this.id,
    required this.name,
    this.icon,
    required this.sortOrder,
  });

  /// Преобразует сущность в Map для вставки/обновления в SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'sortOrder': sortOrder,
    };
  }

  /// Создаёт сущность из Map (результат запроса SQLite)
  factory RoomEntity.fromMap(Map<String, dynamic> map) {
    return RoomEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      sortOrder: map['sortOrder'] as int,
    );
  }
}