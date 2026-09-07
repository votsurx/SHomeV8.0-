/// Шина событий устройств (Singleton).
/// Позволяет компонентам подписываться на события устройств
/// и отправлять события без прямой связи между собой.
/// Используется для уведомления UI об изменениях состояния устройств.
import 'dart:async';
import 'device_events.dart';

class DeviceEventBus {
  /// Синглтон — единственный экземпляр на всё приложение
  static final DeviceEventBus _instance = DeviceEventBus._();
  factory DeviceEventBus() => _instance;
  DeviceEventBus._();

  /// Контроллер потока событий (broadcast — можно много подписчиков)
  final _controller = StreamController<DeviceEvent>.broadcast();

  /// Поток событий, на который подписываются слушатели
  Stream<DeviceEvent> get stream => _controller.stream;

  /// Отправляет событие всем подписчикам.
  /// Вызывается из CommandHandler, HeartbeatService, DevicesNotifier.
  void fire(DeviceEvent event) {
    _controller.add(event);
  }

  /// Закрывает поток событий (вызывается при завершении приложения)
  void dispose() {
    _controller.close();
  }
}