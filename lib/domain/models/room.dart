/// Доменная модель комнаты.
/// Используется RoomSelector и RoomsManageScreen для группировки устройств.
/// Сортировка по sortOrder.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    /// Уникальный идентификатор комнаты
    required String id,
    /// Название комнаты (Гостиная, Спальня...)
    required String name,
    /// Emoji-иконка (🛋️, 🛏️, 🍳...)
    String? icon,
    /// Порядок сортировки при отображении (0, 1, 2...)
    @Default(0) int sortOrder,
  }) = _Room;

  /// Создаёт комнату из JSON (экспорт/импорт)
  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}