/// Модель таймера — отложенная команда для устройства.
/// Используется TimerEngine для выполнения команд по расписанию.
/// Хранится в таблице timers в SQLite.
library;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_timer.freezed.dart';
part 'device_timer.g.dart';

@freezed
class DeviceTimer with _$DeviceTimer {
  const factory DeviceTimer({
    /// Уникальный идентификатор таймера (UUID)
    required String id,
    /// ID устройства, к которому применяется команда
    required String deviceId,
    /// Название устройства для отображения
    required String deviceName,
    /// Команда: 'turnOn' или 'turnOff'
    required String command,
    /// Время выполнения команды
    required DateTime executeAt,
    /// Флаг выполнения (true — уже выполнено, не активно)
    required bool executed,
  }) = _DeviceTimer;

  /// Создаёт таймер из JSON (используется при экспорте/импорте)
  factory DeviceTimer.fromJson(Map<String, dynamic> json) => _$DeviceTimerFromJson(json);
}