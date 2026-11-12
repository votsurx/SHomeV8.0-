/// MQTT-мост для Zigbee2MQTT.
/// Подписывается на bridge/devices, bridge/event, bridge/state и состояние устройств.
library;

import 'dart:async';
import 'dart:convert';
import 'package:talker/talker.dart';
import '../../domain/services/mqtt_service_interface.dart';
import '../../domain/models/zigbee_device.dart';

class ZigbeeBridge {
  List<ZigbeeDevice> _lastDevices = [];
  List<ZigbeeDevice> get lastDevices => _lastDevices;
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
      // ✅ СНАЧАЛА СЛУШАЕМ (чтобы не потерять retained)
      _subscription = _mqttService.messageStream.listen(
        _handleMessage,
        onError: (error) => _talker.error('❌ ZigbeeBridge error', error),
      );

      // ✅ ПОТОМ ПОДПИСЫВАЕМСЯ
      await _mqttService.subscribe('zigbee2mqtt/bridge/devices');
      await _mqttService.subscribe('zigbee2mqtt/bridge/event');
      await _mqttService.subscribe('zigbee2mqtt/bridge/state');
      await _mqttService.subscribe('zigbee2mqtt/#');

      // ✅ ЗАПРОС СПИСКА (fallback)
      await Future.delayed(const Duration(milliseconds: 500));
      await _mqttService.publish(
        'zigbee2mqtt/bridge/request/devices',
        '',
      );
      _talker.info('🐝 Запрос списка устройств (bridge/request/devices)');

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
    _talker.info('🐝 MQTT: ${msg.topic}');
    try {
      final topic = msg.topic;

      // ═══════════════════════════════════════════════════════════
      // ✅ ИГНОРИРУЕМ ЭХО НАШИХ ЗАПРОСОВ (/get, /set)
      // ═══════════════════════════════════════════════════════════
      if (topic.endsWith('/get') || topic.endsWith('/set')) {
        return;
      }

      // ═══════════════════════════════════════════════════════════
      // ✅ СПИСОК УСТРОЙСТВ (retained)
      // ═══════════════════════════════════════════════════════════
      if (topic == 'zigbee2mqtt/bridge/devices') {
        final list = jsonDecode(msg.payload) as List<dynamic>;
        final devices = list
            .whereType<Map<String, dynamic>>()
            .map((j) => ZigbeeDevice.fromJson(j))
            .toList();

        _lastDevices = devices;
        onDevicesList?.call(devices);
        _talker.info('🐝 bridge/devices: ${devices.length} шт.');

        // ✅ ЗАПРАШИВАЕМ КОНКРЕТНЫЕ АТРИБУТЫ (из exposes)
        for (final device in devices) {
          if (device.friendlyName.isEmpty || device.isCoordinator) continue;

          // Собираем имена всех атрибутов, которые можно прочитать
          final attributes = device.exposes
              .where((e) => e.name.isNotEmpty && e.isReadOnly)
              .map((e) => e.name)
              .toList();

          if (attributes.isEmpty) continue;

          // Отправляем запрос: {"water_leak": "", "battery": "", "linkquality": ""}
          final payload = <String, dynamic>{
            for (final attr in attributes) attr: '',
          };

          _mqttService.publish(
            'zigbee2mqtt/${device.friendlyName}/get',
            jsonEncode(payload),
          );
          _talker.info('🐝 Запрос состояния: ${device.friendlyName} → $payload');
        }
      }

      // ═══════════════════════════════════════════════════════════
      // ✅ ОТВЕТ НА ЗАПРОС СПИСКА (fallback)
      // ═══════════════════════════════════════════════════════════
      else if (topic == 'zigbee2mqtt/bridge/response/devices') {
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final devicesList = data['data'] as List<dynamic>? ?? [];

        if (_lastDevices.isEmpty) {
          final devices = devicesList
              .whereType<Map<String, dynamic>>()
              .map((j) => ZigbeeDevice.fromJson(j))
              .toList();
          _lastDevices = devices;
          onDevicesList?.call(devices);
          _talker.info('🐝 response/devices: ${devices.length} шт.');
        }
      }

      // ═══════════════════════════════════════════════════════════
      // ✅ СОБЫТИЯ (сопряжение)
      // ═══════════════════════════════════════════════════════════
      else if (topic == 'zigbee2mqtt/bridge/event') {
        final event = ZigbeeEvent.fromJson(
          jsonDecode(msg.payload) as Map<String, dynamic>,
        );
        onEvent?.call(event);

        if (event.isJoined || event.isInterviewSuccessful) {
          if (event.friendlyName != null && event.friendlyName!.isNotEmpty) {
            _mqttService.publish(
              'zigbee2mqtt/${event.friendlyName}/get',
              '{}',
            );
            _talker.info('🐝 Запрос состояния (новое): ${event.friendlyName}');
          }
        }
      }

      // ═══════════════════════════════════════════════════════════
      // ✅ СТАТУС МОСТА
      // ═══════════════════════════════════════════════════════════
      else if (topic == 'zigbee2mqtt/bridge/state') {
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final online = data['state'] == 'online';
        onBridgeState?.call(online);
      }

      // ═══════════════════════════════════════════════════════════
      // ✅ СОСТОЯНИЕ УСТРОЙСТВА (zigbee2mqtt/<friendly_name>)
      // ═══════════════════════════════════════════════════════════
      else if (topic.startsWith('zigbee2mqtt/') &&
          !topic.startsWith('zigbee2mqtt/bridge/')) {
        final parts = topic.split('/');
        if (parts.length < 2) return;
        final friendlyName = parts[1];

        try {
          final state = jsonDecode(msg.payload) as Map<String, dynamic>;
          // Игнорируем пустые ответы
          if (state.isEmpty) return;
          _talker.info('🐝 State: $friendlyName → $state');
          onState?.call(friendlyName, state);
        } catch (_) {}
      }
    } catch (e) {
      _talker.error('❌ Error handling Zigbee message', e);
    }
  }

  bool get isRunning => _isRunning;
}