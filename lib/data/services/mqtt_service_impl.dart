library;

import 'dart:async';
import 'dart:math' as math;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import '../../domain/services/mqtt_service_interface.dart';

class MqttServiceImpl implements MqttService {
  MqttServiceImpl(this._talker);

  static const String _clientIdKey = 'mqtt_client_id';

  final Talker _talker;

  /// MQTT-клиент.
  MqttServerClient? _client;

  /// Подписка на поток входящих сообщений клиента.
  StreamSubscription<dynamic>? _updatesSubscription;

  /// Защита от повторного dispose.
  bool _disposed = false;

  /// Поток входящих MQTT-сообщений.
  final StreamController<MqttMessageData> _messageController =
  StreamController<MqttMessageData>.broadcast();

  /// Поток состояния подключения: true = подключён.
  final StreamController<bool> _connectionController =
  StreamController<bool>.broadcast();

  /// Поток состояния подключения.
  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Проверяет, подключён ли клиент к брокеру.
  @override
  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  /// Поток входящих MQTT-сообщений.
  @override
  Stream<MqttMessageData> get messageStream => _messageController.stream;

  /// Возвращает постоянный Client ID этой установки приложения.
  ///
  /// Сохранённый ID нужен, чтобы при переподключении устройство продолжало
  /// использовать тот же идентификатор, но другой телефон или планшет получил
  /// свой собственный.
  Future<String> _getClientId() async {
    final prefs = await SharedPreferences.getInstance();

    final savedClientId = prefs.getString(_clientIdKey);
    if (savedClientId != null && savedClientId.isNotEmpty) {
      return savedClientId;
    }

    final random = math.Random.secure();
    final suffix = List<String>.generate(
      8,
          (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();

    // 22 символа: укладывается в распространённый лимит 23 символа.
    final clientId = 'shome_$suffix';

    await prefs.setString(_clientIdKey, clientId);
    return clientId;
  }

  /// Подключается к MQTT-брокеру по указанному адресу и порту.
  ///
  /// Повторными попытками управляет MqttConnectionManager.
  @override
  Future<void> connect(String broker, {int port = 1883}) async {
    if (_disposed) {
      throw StateError('MqttServiceImpl уже закрыт');
    }

    try {
      _talker.info('Connecting to MQTT broker: $broker:$port');

      // Убираем подписку и отключаем клиент от предыдущей попытки.
      await _updatesSubscription?.cancel();
      _updatesSubscription = null;
      _client?.disconnect();
      _client = null;

      final clientId = await _getClientId();
      _talker.info('MQTT Client ID: $clientId');

      final client = MqttServerClient(broker, clientId);
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
          .withClientIdentifier(clientId)
          .withWillQos(MqttQos.atMostOnce);

      client.connectionMessage = connMessage;

      await client.connect();

      // connect() может завершиться без исключения, но соединения не будет.
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

      // Сначала подписываемся на сообщения, затем сообщаем об успехе.
      _updatesSubscription = updates.listen(
            (List<MqttReceivedMessage<MqttMessage?>> messages) {
          for (final message in messages) {
            final payloadMessage =
            message.payload as MqttPublishMessage;
            final payload = MqttPublishPayload.bytesToStringAsString(
              payloadMessage.payload.message,
            );

            if (!_messageController.isClosed) {
              _messageController.add(
                MqttMessageData(
                  topic: message.topic,
                  payload: payload,
                ),
              );
            }
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          _talker.error(
            'Ошибка потока MQTT-сообщений',
            error,
            stackTrace,
          );
        },
      );

      _talker.info('Connected to MQTT broker');

      if (!_connectionController.isClosed) {
        _connectionController.add(true);
      }
    } catch (error, stackTrace) {
      _talker.error(
        'Failed to connect to MQTT broker',
        error,
        stackTrace,
      );

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
    // Успех первоначального подключения отправляется из connect()
    // после настройки updates.listen.
    _talker.info('✅ MQTT connected');
  }

  /// Отключается от MQTT-брокера.
  @override
  Future<void> disconnect() async {
    await _updatesSubscription?.cancel();
    _updatesSubscription = null;

    _client?.disconnect();
    _client = null;
  }

  /// Подписывается на указанный топик.
  @override
  Future<void> subscribe(String topic) async {
    final client = _client;

    if (client != null && isConnected) {
      client.subscribe(topic, MqttQos.atMostOnce);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _talker.info('Subscribed to topic: $topic (QoS 0)');
    }
  }

  /// Публикует сообщение в указанный топик.
  @override
  Future<void> publish(String topic, String message) async {
    final client = _client;

    if (client != null && isConnected) {
      final builder = MqttClientPayloadBuilder()..addString(message);
      final payload = builder.payload;

      if (payload != null) {
        client.publishMessage(
          topic,
          MqttQos.atLeastOnce,
          payload,
        );
      }
    }
  }

  /// Закрывает клиент и контроллеры.
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