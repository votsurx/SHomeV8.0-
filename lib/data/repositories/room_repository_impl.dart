/// Реализация репозитория комнат.
/// Кэширует комнаты в Map(String, Room).
/// При первом запросе загружает из БД, сортирует по sortOrder.
library;
import '../../domain/models/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../local/database.dart';
import '../mappers/room_mapper.dart';

class RoomRepositoryImpl implements RoomRepository {
  /// Кэш комнат в памяти
  final Map<String, Room> _rooms = {};

  /// Возвращает все комнаты, отсортированные по sortOrder.
  /// При первом вызове загружает из БД.
  @override
  Future<List<Room>> getAllRooms() async {
    if (_rooms.isEmpty) {
      final entities = await AppDatabase.getAllRooms();
      for (final entity in entities) {
        _rooms[entity.id] = RoomMapper.toDomain(entity);
      }
    }
    return _rooms.values.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Находит комнату по ID. Если нет в кэше — загружает из БД.
  @override
  Future<Room?> getRoomById(String id) async {
    if (!_rooms.containsKey(id)) {
      await getAllRooms();
    }
    return _rooms[id];
  }

  /// Сохраняет комнату в кэш и БД.
  @override
  Future<void> saveRoom(Room room) async {
    _rooms[room.id] = room;
    await AppDatabase.insertRoom(RoomMapper.toEntity(room));
  }

  /// Удаляет комнату из кэша и БД.
  @override
  Future<void> deleteRoom(String id) async {
    _rooms.remove(id);
    await AppDatabase.deleteRoom(id);
  }
}