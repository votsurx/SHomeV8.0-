/// Интерфейс MQTT сервиса — заготовка на будущее.
/// Определяет методы для подключения к MQTT брокеру, подписки и публикации.
/// Реализован в MqttServiceImpl (не используется активно).
import 'dart:async';

abstract class MqttService {
  /// Подключается к MQTT брокеру по адресу и порту
  Future<void> connect(String broker, {int port = 1883});
  /// Отключается от брокера
  Future<void> disconnect();
  /// Подписывается на топик
  Future<void> subscribe(String topic);
  /// Публикует сообщение в топик
  Future<void> publish(String topic, String message);
  /// Поток входящих сообщений
  Stream<MqttMessageData> get messageStream;
  /// Проверяет, подключён ли клиент
  bool get isConnected;
}

/// Данные входящего MQTT сообщения.
class MqttMessageData {
  /// Топик, из которого пришло сообщение
  final String topic;
  /// Текст сообщения
  final String payload;
  /// Время получения
  final DateTime timestamp;

  MqttMessageData({
    required this.topic,
    required this.payload,
  }) : timestamp = DateTime.now();
}