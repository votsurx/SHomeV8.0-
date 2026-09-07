/// Доменные модели сцен и автоматизации.
/// Scene — сцена (группа действий для устройств).
/// SceneAction — одно действие в сцене (вкл/выкл конкретного устройства).
/// SceneTrigger — условие запуска сцены (время, состояние датчика, вручную).
library;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene.freezed.dart';
part 'scene.g.dart';

/// Сцена — именованный набор действий для выполнения.
/// Может иметь триггер для автоматического запуска.
@freezed
class Scene with _$Scene {
  const factory Scene({
    required String id,
    required String name,
    required String icon,
    /// Список действий (какие устройства и что сделать)
    required List<SceneAction> actions,
    /// Триггер запуска (time, deviceState, manual). null = ручная сцена.
    SceneTrigger? trigger,
  }) = _Scene;

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);
}

/// Одно действие в сцене — команда для конкретного устройства.
@freezed
class SceneAction with _$SceneAction {
  const factory SceneAction({
    /// ID устройства
    required String deviceId,
    /// Команда: 'turnOn', 'turnOff', 'setBrightness'
    required String command,
    /// Значение для команды (яркость 0-255)
    dynamic value,
  }) = _SceneAction;

  factory SceneAction.fromJson(Map<String, dynamic> json) => _$SceneActionFromJson(json);
}

/// Триггер — условие автоматического запуска сцены.
@freezed
class SceneTrigger with _$SceneTrigger {
  const factory SceneTrigger({
    /// Тип триггера: time (по времени), deviceState (по состоянию), manual (вручную)
    required TriggerType type,
    /// Время срабатывания в формате HH:mm (для time)
    String? time,
    /// ID устройства-триггера (для deviceState)
    String? deviceId,
    /// Условие срабатывания: 'on', 'off' (для deviceState)
    String? condition,
    /// Тип повтора: once (один раз), daily (каждый день), weekly (по дням), interval
    @Default(RepeatType.once) RepeatType repeat,
    /// Дни недели для weekly (1=Пн, 7=Вс)
    List<int>? repeatDays,
    // Новые поля для датчиков
    String? sensorDeviceId,    // ID датчика
    String? sensorCondition,   // temperature_above, temperature_below, humidity_above, humidity_below
    double? sensorThreshold,   // Пороговое значение
    String? lastExecuted,      // Время последнего выполнения (ISO8601)
  }) = _SceneTrigger;

  factory SceneTrigger.fromJson(Map<String, dynamic> json) => _$SceneTriggerFromJson(json);
}

/// Тип триггера сцены.
enum TriggerType {
  time,         // По времени (HH:mm)
  deviceState,  // По состоянию устройства
  manual,       // Вручную (по нажатию)
}

/// Тип повтора сцены.
enum RepeatType {
  once,      // Один раз
  daily,     // Каждый день
  weekly,    // По дням недели
  interval,  // С интервалом
}