/// Интерфейс репозитория комнат — контракт между доменным и data-слоем.
/// Определяет CRUD-операции с комнатами.
/// Реализован в RoomRepositoryImpl.
library;
import '../models/room.dart';

abstract class RoomRepository {
  /// Возвращает все комнаты, отсортированные по sortOrder
  Future<List<Room>> getAllRooms();
  /// Находит комнату по ID
  Future<Room?> getRoomById(String id);
  /// Сохраняет комнату (создаёт или обновляет)
  Future<void> saveRoom(Room room);
  /// Удаляет комнату по ID
  Future<void> deleteRoom(String id);
}