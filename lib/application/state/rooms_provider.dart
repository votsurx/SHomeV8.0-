/// Провайдер комнат на Riverpod.
/// Управляет списком комнат: добавление, удаление, переименование.
/// При удалении комнаты все устройства из неё переносятся в "all".
/// Логирует события через EventLogger.
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/event_logger.dart';
import '../../domain/models/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../../di/injection.dart';
//import 'devices_provider.dart';

/// Глобальный провайдер списка комнат.
final roomsProvider = StateNotifierProvider<RoomsNotifier, List<Room>>((ref) {
  return RoomsNotifier();
});

/// Управляет комнатами: загрузка, добавление, переименование, удаление.
class RoomsNotifier extends StateNotifier<List<Room>> {
  final RoomRepository _repository = getIt<RoomRepository>();

  RoomsNotifier() : super([]) {
    _loadRooms();
  }
  Future<void> updateRoom(Room room) async {
    await _repository.saveRoom(room);
    state = state.map((r) => r.id == room.id ? room : r).toList();
  }

  /// Загружает все комнаты из БД
  Future<void> _loadRooms() async {
    final rooms = await _repository.getAllRooms();
    state = rooms;
  }

  /// Добавляет новую комнату. Логирует событие roomAdded.
  Future<void> addRoom(Room room) async {
    await _repository.saveRoom(room);
    state = [...state, room];
    EventLogger.log(event: 'roomAdded', roomName: room.name);
  }

  /// Удаляет комнату по ID (без переноса устройств).
  /// Для удаления с переносом используй deleteRoomAndMoveDevices.
  Future<void> deleteRoom(String id) async {
    await _repository.deleteRoom(id);
    state = state.where((r) => r.id != id).toList();
  }

  /// Переименовывает комнату.
  Future<void> renameRoom(String id, String newName) async {
    final room = state.firstWhere((r) => r.id == id);
    final updated = room.copyWith(name: newName);
    await _repository.saveRoom(updated);
    state = state.map((r) => r.id == id ? updated : r).toList();
  }
}