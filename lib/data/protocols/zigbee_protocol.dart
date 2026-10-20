/// Протокол управления Zigbee-устройствами через MQTT.
/// Аналог TuyaProtocol, но для Zigbee2MQTT.
library;

import 'dart:convert';
import 'package:talker/talker.dart';
import '../../domain/services/mqtt_service_interface.dart';

class ZigbeeProtocol {
  final MqttService _mqttService;
  final Talker _talker;

  ZigbeeProtocol(this._mqttService, this._talker);

  /// Открывает/закрывает сеть для сопряжения.
  Future<void> permitJoin(bool enable, {int time = 254}) async {
    await _mqttService.publish(
      'zigbee2mqtt/bridge/request/permit_join',
      jsonEncode({'value': enable, 'time': time}),
    );
    _talker.info('🐝 Permit join: $enable (${time}s)');
  }

  /// Переименовывает устройство.
  Future<void> rename(String from, String to) async {
    await _mqttService.publish(
      'zigbee2mqtt/bridge/request/device/rename',
      jsonEncode({'from': from, 'to': to}),
    );
  }

  /// Удаляет устройство из сети.
  Future<void> remove(String friendlyName) async {
    await _mqttService.publish(
      'zigbee2mqtt/bridge/request/device/remove',
      jsonEncode({'id': friendlyName}),
    );
  }

  /// Запускает интервью устройства (перечитывает exposes).
  Future<void> interview(String friendlyName) async {
    await _mqttService.publish(
      'zigbee2mqtt/bridge/request/device/interview',
      jsonEncode({'id': friendlyName}),
    );
  }

  /// Отправляет команду устройству (state, brightness, color_temp...).
  Future<void> setState(String friendlyName, Map<String, dynamic> payload) async {
    await _mqttService.publish(
      'zigbee2mqtt/$friendlyName/set',
      jsonEncode(payload),
    );
  }

  /// Включает устройство (розетка, лампа, выключатель).
  Future<void> turnOn(String friendlyName) =>
      setState(friendlyName, {'state': 'ON'});

  /// Выключает устройство.
  Future<void> turnOff(String friendlyName) =>
      setState(friendlyName, {'state': 'OFF'});

  /// Устанавливает яркость (0–254).
  Future<void> setBrightness(String friendlyName, int value) =>
      setState(friendlyName, {'brightness': value});

  /// Устанавливает цветовую температуру.
  Future<void> setColorTemp(String friendlyName, int value) =>
      setState(friendlyName, {'color_temp': value});

  /// Запрашивает карту сети.
  Future<void> requestNetworkMap() async {
    await _mqttService.publish(
      'zigbee2mqtt/bridge/request/networkmap',
      jsonEncode({'type': 'raw'}),
    );
  }

  /// Запрашивает бэкап сети.
  Future<void> requestBackup() async {
    await _mqttService.publish(
      'zigbee2mqtt/bridge/request/backup',
      jsonEncode({}),
    );
  }
}