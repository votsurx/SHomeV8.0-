/// Классы событий устройств для шины событий DeviceEventBus.
/// Используются для уведомления подписчиков об изменениях состояния устройств.
/// Sealed class — все возможные типы событий определены здесь.
import '../models/device.dart';

/// Базовый класс для всех событий устройств.
/// Содержит deviceId и временную метку.
sealed class DeviceEvent {
  /// ID устройства, с которым связано событие
  final String deviceId;
  /// Время возникновения события
  final DateTime timestamp;

  DeviceEvent(this.deviceId) : timestamp = DateTime.now();
}

/// Состояние устройства изменилось (вкл/выкл, онлайн/оффлайн).
/// newState — новое состояние устройства.
class DeviceStateChanged extends DeviceEvent {
  final DeviceState newState;
  DeviceStateChanged(String deviceId, this.newState) : super(deviceId);
}

/// Получены телеметрические данные от устройства (температура, влажность, мощность).
/// data — Map с DPS-данными.
class DeviceTelemetryReceived extends DeviceEvent {
  final Map<String, dynamic> data;
  DeviceTelemetryReceived(String deviceId, this.data) : super(deviceId);
}

/// Устройство потеряло связь (после нескольких неудачных попыток опроса).
class DeviceOffline extends DeviceEvent {
  DeviceOffline(String deviceId) : super(deviceId);
}

/// Устройство восстановило связь (после успешного опроса).
class DeviceOnline extends DeviceEvent {
  DeviceOnline(String deviceId) : super(deviceId);
}