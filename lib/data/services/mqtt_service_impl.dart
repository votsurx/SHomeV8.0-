/// Реализация MQTT клиента (заготовка на будущее).
/// Позволяет подключаться к MQTT брокеру, подписываться на топики,
/// публиковать сообщения и слушать входящие.
/// Не используется в текущей версии — устройства управляются через TuyaProtocol.
library;
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:talker/talker.dart';
import '../../domain/services/mqtt_service_interface.dart';

class MqttServiceImpl implements MqttService {
  final Talker _talker;
  /// MQTT клиент
  MqttServerClient? _client;
  /// Поток входящих сообщений
  final _messageController = StreamController<MqttMessageData>.broadcast();

  MqttServiceImpl(this._talker);

  /// Проверяет, подключён ли клиент к брокеру.
  @override
  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  /// Поток входящих MQTT сообщений.
  @override
  Stream<MqttMessageData> get messageStream => _messageController.stream;

  /// Подключается к MQTT брокеру по указанному адресу и порту.
  /// Подписывается на входящие сообщения и передаёт их в messageStream.
  @override
  Future<void> connect(String broker, {int port = 1883}) async {
    try {
      _talker.info('Connecting to MQTT broker: $broker:$port');

      _client = MqttServerClient(broker, 'shome_client_01');  // ← ФИКСИРОВАННЫЙ ID
      _client!.port = port;
      _client!.keepAlivePeriod = 20;
      _client!.logging(on: false);
      _client!.setProtocolV311();  // ← MQTT 3.1.1 (поддержка больших сообщений)
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('shome_client_01')
      // ❌ НЕ ВЫЗЫВАЕМ .startClean() → сессия сохраняется
          .withWillQos(MqttQos.atMostOnce);
      _client!.connectionMessage = connMessage;

      await _client!.connect();

      // Слушаем входящие сообщения
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
        for (final msg in messages) {
          final recMessage = msg.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMessage.payload.message,
          );
          final mqttMessage = MqttMessageData(topic: msg.topic, payload: payload);
          _messageController.add(mqttMessage);
        }
      });

      _talker.info('Connected to MQTT broker');
    } catch (e, stackTrace) {
      _talker.error('Failed to connect to MQTT broker', e, stackTrace);
    }
  }

  void _onDisconnected() {
    _talker.warning('⚠️ MQTT disconnected');
  }

  void _onConnected() {
    _talker.info('✅ MQTT reconnected');
  }

  /// Отключается от MQTT брокера.
  @override
  Future<void> disconnect() async {
    _client?.disconnect();
  }

  /// Подписывается на указанный топик.
  @override
  Future<void> subscribe(String topic) async {
    if (_client != null && isConnected) {
      _client!.subscribe(topic, MqttQos.atMostOnce);  // ← QoS 0
      // Ждём, пока брокер подтвердит подписку
      await Future.delayed(const Duration(milliseconds: 200));
      _talker.info('Subscribed to topic: $topic (QoS 0)');
      _talker.info('Subscribed to topic: $topic');
    }
  }

  /// Публикует сообщение в указанный топик.
  @override
  Future<void> publish(String topic, String message) async {
    if (_client != null && isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
  }
}