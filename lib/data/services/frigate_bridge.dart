/// MQTT-мост для Frigate NVR.
library;

import 'dart:async';
import 'dart:convert';
import 'package:talker/talker.dart';
import '../../domain/services/mqtt_service_interface.dart';
import '../../domain/models/frigate_models.dart';

class FrigateBridge {
  final MqttService _mqttService;
  final Talker _talker;

  // Колбэки
  void Function(FrigateEvent event)? onEvent;
  void Function(String camera, int personCount)? onPersonCount;
  void Function(String camera, bool motion)? onMotion;
  void Function(String camera, bool online)? onCameraStatus;
  void Function(bool online)? onFrigateStatus;

  StreamSubscription<MqttMessageData>? _subscription;
  bool _isRunning = false;

  FrigateBridge({
    required MqttService mqttService,
    required Talker talker,
  })  : _mqttService = mqttService,
        _talker = talker;

  Future<void> start() async {
    if (_isRunning) return;

    try {
      await _mqttService.subscribe('frigate/events');
      await _mqttService.subscribe('frigate/+/person');
      await _mqttService.subscribe('frigate/+/motion');
      await _mqttService.subscribe('frigate/+/availability');
      await _mqttService.subscribe('frigate/available');

      _subscription = _mqttService.messageStream.listen(
        _handleMessage,
        onError: (error) => _talker.error('❌ FrigateBridge error', error),
      );

      _isRunning = true;
      _talker.info('🎥 FrigateBridge started');
    } catch (e) {
      _talker.error('❌ Failed to start FrigateBridge', e);
      rethrow;
    }
  }

  void stop() {
    _subscription?.cancel();
    _isRunning = false;
    _talker.info('🎥 FrigateBridge stopped');
  }

  void _handleMessage(MqttMessageData msg) {
    try {
      final topic = msg.topic;

      if (topic == 'frigate/events') {
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final event = FrigateEvent.fromJson(data);
        onEvent?.call(event);
      } else if (topic == 'frigate/available') {
        final online = msg.payload == 'online';
        onFrigateStatus?.call(online);
      } else if (topic.startsWith('frigate/') && topic.endsWith('/person')) {
        final camera = topic.split('/')[1];
        final count = int.tryParse(msg.payload) ?? 0;
        onPersonCount?.call(camera, count);
      } else if (topic.startsWith('frigate/') && topic.endsWith('/motion')) {
        final camera = topic.split('/')[1];
        final motion = msg.payload == 'ON';
        onMotion?.call(camera, motion);
      } else if (topic.startsWith('frigate/') && topic.endsWith('/availability')) {
        final camera = topic.split('/')[1];
        final online = msg.payload == 'online';
        onCameraStatus?.call(camera, online);
      }
    } catch (e) {
      _talker.error('❌ Error handling Frigate message', e);
    }
  }

  bool get isRunning => _isRunning;
}