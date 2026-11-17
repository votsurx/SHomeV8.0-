
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

  /// Подписка на поток сообщений клиента.
  StreamSubscription<dynamic>? _updatesSubscription;

  /// Защита от повторного dispose.
  bool _disposed = false;
  /// Поток входящих сообщений
  final _messageController = StreamController<MqttMessageData>.broadcast();

  /// Поток состояния подключения (true = connected, false = disconnected)
  final _connectionController = StreamController<bool>.broadcast();

  /// Поток состояния подключения.
  @override
  Stream<bool> get connectionStream => _connectionController.stream;

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
    if (_disposed) {
      throw StateError('MqttServiceImpl уже закрыт');
    }

    try {
      _talker.info('Connecting to MQTT broker: $broker:$port');

      // Убираем подписку и клиент от предыдущей попытки.
      await _updatesSubscription?.cancel();
      _updatesSubscription = null;
      _client?.disconnect();

      final client = MqttServerClient(broker, 'shome_client_01');
      _client = client;

      client.port = port;
      client.keepAlivePeriod = 20;
      client.logging(on: false);
      client.setProtocolV311();

      // Повторными попытками управляет MqttConnectionManager.
      client.autoReconnect = false;

      client.onDisconnected = _onDisconnected;
      client.onConnected = _onConnected;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('shome_client_01')
      // Сессию не сбрасываем.
          .withWillQos(MqttQos.atMostOnce);
      client.connectionMessage = connMessage;

      await client.connect();

      // connect() может завершиться без исключения, но без соединения.
      if (!isConnected) {
        throw StateError(
          'MQTT-клиент не подключился: '
              '${client.connectionStatus?.state}',
        );
      }

      final updates = client.updates;
      if (updates == null) {
        throw StateError('MQTT-клиент не предоставил поток updates');
      }

      // Слушатель сообщений устанавливаем до уведомления менеджера
      // об успешном подключении.
      _updatesSubscription = updates.listen(
            (List<MqttReceivedMessage<MqttMessage?>> messages) {
          for (final msg in messages) {
            final recMessage = msg.payload as MqttPublishMessage;
            final payload = MqttPublishPayload.bytesToStringAsString(
              recMessage.payload.message,
            );

            _messageController.add(
              MqttMessageData(topic: msg.topic, payload: payload),
            );
          }
        },
      );

      _talker.info('Connected to MQTT broker');
      if (!_connectionController.isClosed) {
        _connectionController.add(true);
      }
    } catch (e, stackTrace) {
      _talker.error('Failed to connect to MQTT broker', e, stackTrace);

      if (!_connectionController.isClosed) {
        _connectionController.add(false);
      }

      rethrow;
    }
  }

  void _onDisconnected() {
    _talker.warning('⚠️ MQTT disconnected');

    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
  }

  void _onConnected() {
    // Успех первоначального подключения будет отправлен из connect()
    // после настройки updates.listen.
    _talker.info('✅ MQTT connected');
  }

  /// Отключается от MQTT брокера.
  @override
  Future<void> disconnect() async {
    await _updatesSubscription?.cancel();
    _updatesSubscription = null;
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
  /// Закрыть контроллеры.
  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    await _updatesSubscription?.cancel();
    _updatesSubscription = null;

    _client?.disconnect();
    _client = null;

    if (!_messageController.isClosed) {
      await _messageController.close();
    }
    if (!_connectionController.isClosed) {
      await _connectionController.close();
    }
  }
}