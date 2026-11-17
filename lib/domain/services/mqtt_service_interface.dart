
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
  /// Поток состояния подключения (true = connected, false = disconnected)
  Stream<bool> get connectionStream;   // ← NEW
  /// Проверяет, подключён ли клиент
  bool get isConnected;
  /// Закрыть ресурсы (контроллеры, соединение)
  Future<void> dispose();   // ← NEW
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