/// Сервис логирования событий в журнал.
/// Все действия в системе (вкл/выкл, сцены, добавление/удаление устройств и комнат)
/// записываются в таблицу events через этот класс.
/// Используется DevicesNotifier, RoomsNotifier, ScenesNotifier, AdaptivePoller.
library;
import '../local/database.dart';
import '../local/entities/event_entity.dart';

class EventLogger {
  /// Записывает событие в БД.
  ///
  /// Параметры:
  /// - event: тип события (turnOn, turnOff, scene, deviceAdded, deviceRemoved, roomAdded, roomRemoved, sceneCreated, sceneDeleted)
  /// - deviceId: ID устройства (опционально)
  /// - deviceName: название устройства для отображения
  /// - value: дополнительное значение (температура, энергия)
  /// - sceneName: название сцены
  /// - roomName: название комнаты
  /// - timerName: название таймера
  static Future<void> log({
    required String event,
    String? deviceId,
    String? deviceName,
    String? value,
    String? sceneName,
    String? roomName,
    String? timerName,
  }) async {
    final entity = EventEntity(
      event: event,
      deviceId: deviceId,
      deviceName: deviceName,
      value: value,
      sceneName: sceneName,
      roomName: roomName,
      timerName: timerName,
      timestamp: DateTime.now().toIso8601String(),
    );
    await AppDatabase.insertEvent(entity);
  }
}