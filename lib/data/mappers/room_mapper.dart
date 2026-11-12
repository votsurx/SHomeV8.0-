/// Маппер между доменной моделью Room и сущностью SQLite RoomEntity.
/// Простой маппинг один-к-одному без сложных преобразований.
library;
import '../../domain/models/room.dart';
import '../local/entities/room_entity.dart';

class RoomMapper {
  /// Преобразует сущность БД в доменную модель Room.
  /// Все поля копируются напрямую.
  static Room toDomain(RoomEntity entity) {
    return Room(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      sortOrder: entity.sortOrder,
    );
  }

  /// Преобразует доменную модель Room в сущность для сохранения в БД.
  /// Все поля копируются напрямую.
  static RoomEntity toEntity(Room room) {
    return RoomEntity(
      id: room.id,
      name: room.name,
      icon: room.icon,
      sortOrder: room.sortOrder,
    );
  }
}