/// Менеджер жизненного цикла MQTT-подключения.
library;

import 'dart:async';
import 'dart:io';

import 'package:talker/talker.dart';

import '../../domain/services/mqtt_service_interface.dart';
import 'event_logger.dart';

enum MqttState {
  disconnected,
  connecting,
  connected,
  failed,
}

class MqttConnectionManager {
  final MqttService _mqtt;
  final Talker _talker;

  final StreamController<MqttState> _stateController =
  StreamController<MqttState>.broadcast();

  Stream<MqttState> get stateStream => _stateController.stream;

  MqttState _state = MqttState.disconnected;
  MqttState get state => _state;

  StreamSubscription<bool>? _connectionSubscription;
  Timer? _retryTimer;

  String? _lastHost;
  int? _lastPort;

  bool _errorLoggedForCurrentOutage = false;
  int _retryAttempt = 0;

  bool _enabled = false;
  bool _attemptInProgress = false;
  bool _disposed = false;

  MqttConnectionManager(this._mqtt, this._talker);

  /// Начать подключение и продолжать попытки, пока менеджер включён.
  Future<void> connect(String host, int port) async {
    if (_disposed) {
      throw StateError('MqttConnectionManager уже закрыт');
    }
    if (host.trim().isEmpty) {
      await _reportFailure('MQTT host не настроен');
      return;
    }

    _lastHost = host;
    _lastPort = port;
    _enabled = true;

    await _ensureConnectionListener();
    await _attemptConnection();
  }

  /// Повторить подключение к последнему заданному адресу.
  Future<void> reconnect() async {
    final host = _lastHost;
    final port = _lastPort;

    if (host == null || port == null || _disposed) return;

    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;

    try {
      await _mqtt.disconnect();
    } catch (e, st) {
      _talker.warning('Ошибка перед повторным MQTT-подключением: $e', e, st);
    }

    _enabled = true;
    await _ensureConnectionListener();
    await _attemptConnection();
  }

  /// Остановить повторные попытки и отключиться.
  Future<void> disconnect() async {
    _enabled = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;

    try {
      await _mqtt.disconnect();
    } catch (e, st) {
      _talker.warning('Ошибка при отключении MQTT: $e', e, st);
    }

    _setState(MqttState.disconnected);
  }

  Future<void> _ensureConnectionListener() async {
    if (_connectionSubscription != null) return;

    _connectionSubscription = _mqtt.connectionStream.listen(
      _handleConnectionEvent,
      onError: (Object error, StackTrace stackTrace) {
        _talker.error('Ошибка потока состояния MQTT', error, stackTrace);
      },
    );
  }

  void _handleConnectionEvent(bool connected) {
    if (!_enabled || _disposed) return;

    if (connected) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
      _setState(MqttState.connected);
      return;
    }

    // Событие false при первоначальном connect обрабатывает сам
    // _attemptConnection(), чтобы не запланировать две попытки.
    if (_state == MqttState.connected) {
      unawaited(_reportFailure('MQTT-соединение потеряно'));
    }
  }

  Future<void> _attemptConnection() async {
    if (!_enabled || _disposed || _attemptInProgress) return;

    final host = _lastHost;
    final port = _lastPort;
    if (host == null || port == null) return;

    _attemptInProgress = true;
    _setState(MqttState.connecting);

    try {
      final reachabilityError = await _checkBroker(host, port);
      if (!_enabled || _disposed) return;

      if (reachabilityError != null) {
        await _reportFailure(
          'TCP-подключение к $host:$port не удалось: $reachabilityError',
        );
        return;
      }

      await _mqtt.connect(host, port: port);
      if (!_enabled || _disposed) return;

      // Успешное завершение connect() само по себе не гарантирует
      // фактического соединения с брокером.
      if (!_mqtt.isConnected) {
        await _reportFailure(
          'MQTT-клиент не подключён после connect(): $host:$port',
        );
        return;
      }

      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
      _errorLoggedForCurrentOutage = false;
      _setState(MqttState.connected);
      _talker.info('✅ MQTT подключён: $host:$port');
    } catch (e, st) {
      if (_enabled && !_disposed) {
        await _reportFailure('Не удалось подключиться к $host:$port: $e');
      }
      _talker.error('Ошибка MQTT-подключения', e, st);
    } finally {
      _attemptInProgress = false;
    }
  }

  Future<String?> _checkBroker(String host, int port) async {
    Socket? socket;

    try {
      socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );
      return null;
    } catch (e) {
      // Сохраняем исходную причину, например SocketException или timeout.
      return e.toString();
    } finally {
      socket?.destroy();
    }
  }

  Future<void> _reportFailure(String reason) async {
    _setState(MqttState.failed);

    // В журнал событий — одна запись за весь период недоступности.
    if (!_errorLoggedForCurrentOutage) {
      _errorLoggedForCurrentOutage = true;

      _talker.error('❌ MQTT: $reason');

      try {
        await EventLogger.log(
          event: 'error',
          deviceName: 'MQTT',
          value: reason,
        );
      } catch (e, st) {
        _talker.error('Не удалось записать ошибку MQTT в журнал', e, st);
      }
    } else {
      // Повторные попытки остаются только в техническом логе.
      _talker.warning('Повторная попытка MQTT не удалась: $reason');
    }

    if (_enabled && !_disposed) {
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (!_enabled || _disposed || _retryTimer != null) return;

    const delays = <Duration>[
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 20),
      Duration(seconds: 40),
      Duration(seconds: 60),
    ];

    final index = _retryAttempt < delays.length
        ? _retryAttempt
        : delays.length - 1;
    final delay = delays[index];
    _retryAttempt++;

    _talker.info(
      '🔄 Повтор MQTT-подключения через ${delay.inSeconds} сек.',
    );

    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      unawaited(_attemptConnection());
    });
  }

  void _setState(MqttState newState) {
    if (_state == newState || _disposed) return;

    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;

    _disposed = true;
    _enabled = false;
    _retryTimer?.cancel();
    _retryTimer = null;

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    await _stateController.close();
  }
}