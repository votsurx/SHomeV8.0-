/// MQTT-мост для Zigbee2MQTT.
/// Подписывается на bridge/devices, bridge/event, bridge/state и состояние устройств.
library;

import 'dart:async';
import 'dart:convert';
import 'package:talker/talker.dart';
import '../../domain/services/mqtt_service_interface.dart';
import '../../domain/models/zigbee_device.dart';

class ZigbeeBridge {
  final MqttService _mqttService;
  final Talker _talker;

  // Колбэки
  void Function(List<ZigbeeDevice> devices)? onDevicesList;
  void Function(ZigbeeEvent event)? onEvent;
  void Function(String friendlyName, Map<String, dynamic> state)? onState;
  void Function(bool online)? onBridgeState;

  StreamSubscription<MqttMessageData>? _subscription;
  bool _isRunning = false;

  ZigbeeBridge({
    required MqttService mqttService,
    required Talker talker,
  })  : _mqttService = mqttService,
        _talker = talker;

  Future<void> start() async {
    if (_isRunning) return;

    try {
      await _mqttService.subscribe('zigbee2mqtt/bridge/devices');
      await _mqttService.subscribe('zigbee2mqtt/bridge/event');
      await _mqttService.subscribe('zigbee2mqtt/bridge/state');
      await _mqttService.subscribe('zigbee2mqtt/+');

      _subscription = _mqttService.messageStream.listen(
        _handleMessage,
        onError: (error) => _talker.error('❌ ZigbeeBridge error', error),
      );

      _isRunning = true;
      _talker.info('🐝 ZigbeeBridge started');
    } catch (e) {
      _talker.error('❌ Failed to start ZigbeeBridge', e);
      rethrow;
    }
  }

  void stop() {
    _subscription?.cancel();
    _isRunning = false;
    _talker.info('🐝 ZigbeeBridge stopped');
  }

  void _handleMessage(MqttMessageData msg) {
    try {
      final topic = msg.topic;

      if (topic == 'zigbee2mqtt/bridge/devices') {
        final list = jsonDecode(msg.payload) as List<dynamic>;
        final devices = list
            .whereType<Map<String, dynamic>>()
            .map((j) => ZigbeeDevice.fromJson(j))
            .toList();
        onDevicesList?.call(devices);
      } else if (topic == 'zigbee2mqtt/bridge/event') {
        final event = ZigbeeEvent.fromJson(
          jsonDecode(msg.payload) as Map<String, dynamic>,
        );
        onEvent?.call(event);
      } else if (topic == 'zigbee2mqtt/bridge/state') {
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final online = data['state'] == 'online';
        onBridgeState?.call(online);
      } else if (topic.startsWith('zigbee2mqtt/') &&
          !topic.contains('/bridge/')) {
        final parts = topic.split('/');
        if (parts.length < 2) return;
        final friendlyName = parts[1];

        try {
          final state = jsonDecode(msg.payload) as Map<String, dynamic>;
          onState?.call(friendlyName, state);
        } catch (_) {
          // Не JSON — игнорируем
        }
      }
    } catch (e) {
      _talker.error('❌ Error handling Zigbee message', e);
    }
  }

  bool get isRunning => _isRunning;
}