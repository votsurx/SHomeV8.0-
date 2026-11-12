/// Доменные модели сцен и автоматизации.
/// Scene — сцена (группа действий для устройств).
/// SceneAction — одно действие в сцене (вкл/выкл конкретного устройства).
/// SceneTrigger — условие запуска сцены (время, состояние датчика, вручную).
library;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'presence_conditions.dart';

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
    /// Тип триггера: time (по времени), deviceState (по состоянию), manual (вручную), presence (по присутствию)
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
    // Датчики
    String? sensorDeviceId,
    String? sensorCondition,
    double? sensorThreshold,
    String? lastExecuted,
    // Присутствие
    /// Событие присутствия
    PresenceEvent? presenceEvent,
    /// ID телефона (null = любой)
    String? presencePhoneId,
    /// Канал определения: any, wifi, gps
    @Default(PresenceChannel.any) PresenceChannel presenceChannel,
    /// Задержка перед запуском (минуты)
    @Default(0) int presenceDelayMin,
    /// Антидребезг (минуты)
    @Default(1) int presenceCooldownMin,
    /// Условия для присутствия
    PresenceConditions? presenceConditions,
  }) = _SceneTrigger;

  factory SceneTrigger.fromJson(Map<String, dynamic> json) =>
      _$SceneTriggerFromJson(json);
}

/// Тип триггера сцены.
enum TriggerType {
  time,         // По времени (HH:mm)
  deviceState,  // По состоянию устройства
  manual,       // Вручную (по нажатию)
  presence,     // По присутствию
}

/// Тип повтора сцены.
enum RepeatType {
  once,      // Один раз
  daily,     // Каждый день
  weekly,    // По дням недели
  interval,  // С интервалом
}

/// Событие присутствия для триггера.
enum PresenceEvent {
  /// Кто-то пришёл домой (любой телефон)
  someoneHome,
  /// Никого не осталось дома (последний ушёл)
  nobodyHome,
  /// Вся семья дома (все телефоны)
  allHome,
  /// Конкретный телефон пришёл
  phoneArrived,
  /// Конкретный телефон ушёл
  phoneLeft,
  /// Конкретный телефон неизвестен
  phoneUnknown,
}

/// Канал определения присутствия.
enum PresenceChannel {
  /// Любой (Wi-Fi или GPS)
  any,
  /// Только Wi-Fi (пинг)
  wifi,
  /// Только GPS (Mail.ru)
  gps,
}