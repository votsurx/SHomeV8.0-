/// Провайдер списка устройств на Riverpod.
/// Центральный узел управления устройствами: вкл/выкл, многоканальные, датчики.
/// Использует прямое управление через TuyaProtocol (без CommandHandler).
/// Логирует все действия через EventLogger.
/// При старте все устройства переводятся в offline — AdaptivePoller актуализирует состояние.
library;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/protocols/zigbee_protocol.dart';
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../../data/protocols/tuya_protocol.dart';
import '../../di/injection.dart';
import '../../data/services/event_logger.dart';
import '../../application/constants/debug_config.dart';
import '../../data/services/vk_notification_service.dart';
import 'package:flutter/foundation.dart';
import '../../application/services/notification_settings_service.dart';

/// Глобальный провайдер списка устройств.
/// Все виджеты, подписанные через ref.watch, перестраиваются при изменении state.
final devicesProvider = StateNotifierProvider<DevicesNotifier, List<Device>>((ref) {
  return DevicesNotifier();
});

/// Управляет списком устройств: загрузка, добавление, удаление, вкл/выкл, перестановка.
/// Поддерживает многоканальные устройства и датчики.
class DevicesNotifier extends StateNotifier<List<Device>> {
  final DeviceRepository _repository = getIt<DeviceRepository>();
  final TuyaProtocol _tuyaProtocol = getIt<TuyaProtocol>();

  void Function(String)? onCommandSent;

  DevicesNotifier() : super([]) {
    _loadDevices();
  }

  List<Device> get devices => state;

  // ═══════════ ЗАГРУЗКА И ПОРЯДОК ═══════════

  Future<void> _loadDevices() async {
    final devices = await _repository.getAllDevices();
    state = devices.map((d) {
      final props = Map<String, dynamic>.from(d.properties);

      // Добавляем dps_map для многоканальных устройств, если его нет
      if (d.type == DeviceType.switch1 ||
          d.type == DeviceType.switch2 ||
          d.type == DeviceType.switch3) {
        if (props['dps_map'] == null || (props['dps_map'] as Map).isEmpty) {
          final channels = props['channels'] as int? ??
              (d.type == DeviceType.switch3 ? 3 : d.type == DeviceType.switch2 ? 2 : 1);
          props['dps_map'] = {
            for (var i = 1; i <= channels; i++)
              '$i': {'label': 'Канал $i', 'type': 'bool', 'role': 'channel'},
          };
        }
      }

      props['isOn'] = false;
      if (props['states'] != null) {
        props['states'] = List<bool>.filled((props['channels'] as int?) ?? 1, false);
      }

      return d.copyWith(
        isOnline: false,
        state: DeviceState.offline,
        properties: props,
      );
    }).toList();
    _restoreOrder();
  }

  /// Переставляет устройства и сохраняет порядок.
  void reorderDevices(int oldIndex, int newIndex) {
    final list = [...state];
    if (oldIndex < newIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    _saveOrder();
  }

  Future<void> _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = state.map((d) => d.id).toList();
    await prefs.setString('device_order', jsonEncode(ids));
  }

  Future<void> _restoreOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final orderJson = prefs.getString('device_order');
    if (orderJson == null) return;

    final orderIds = (jsonDecode(orderJson) as List).cast<String>();
    final list = [...state];

    list.sort((a, b) {
      final aIndex = orderIds.indexOf(a.id);
      final bIndex = orderIds.indexOf(b.id);
      if (aIndex == -1 && bIndex == -1) return 0;
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });

    state = list;
  }

  // ═══════════ ОБНОВЛЕНИЕ СОСТОЯНИЙ ═══════════

  void updateDeviceLocal(Device device) {
    state = state.map((d) => d.id == device.id ? device : d).toList();
  }

  void updateDeviceState(String id, bool isOn) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {
        ...device.properties,
        'isOn': isOn,
        if (device.properties['states'] != null)
          'states': device.properties['states'],
      },
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  void updateDeviceStates(String id, List<bool> states) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {...device.properties, 'states': states, 'isOn': states.any((s) => s)},
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  void updateOnlineState(String id, bool isOnline) {
    if (DebugConfig.showDebug) {
    }
    if (DebugConfig.showDebug) {
    }
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      isOnline: isOnline,
      state: isOnline ? DeviceState.online : DeviceState.offline,
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  void updateDeviceProperties(String id, Map<String, dynamic> properties) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(properties: properties);
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  // ═══════════ CRUD ═══════════

  Future<void> addDevice(Device device) async {
    await _repository.saveDevice(device);
    state = [...state, device];
    _saveOrder();
    EventLogger.log(event: 'deviceAdded', deviceId: device.id, deviceName: device.name);
  }

  Future<void> updateDevice(Device device) async {
    await _repository.saveDevice(device);
    await _loadDevices();
    onCommandSent?.call(device.id);
  }

  Future<void> removeDevice(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    EventLogger.log(event: 'deviceRemoved', deviceId: id, deviceName: device.name);
    await _repository.deleteDevice(id);
    state = state.where((d) => d.id != id).toList();
    _saveOrder();
  }

  // ═══════════ КОМАНДЫ ═══════════

  Future<bool> turnOn(String id) async {
    final device = state.firstWhere((d) => d.id == id);

    // 🎥 Frigate-камера — не управляется через turnOn
    if (device.properties['source'] == 'frigate') {
      return false;
    }

    // ═══════════════════════════════════════════════════════════
    // 🐝 ZIGBEE — через MQTT
    // ═══════════════════════════════════════════════════════════
    if (device.properties['source'] == 'zigbee') {
      try {
        final friendlyName = device.properties['friendly_name'] as String?
            ?? device.name;
        final protocol = getIt<ZigbeeProtocol>();
        await protocol.turnOn(friendlyName);
        _updateLocalState(id, true);
        EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOn');
        _sendDeviceNotification(device.name, 'Включено', true);
        return true;
      } catch (e) {
        debugPrint('❌ Zigbee turnOn error: $e');
        return false;
      }
    }

    // ═══════════════════════════════════════════════════════════
    // 🔌 TUYA — как раньше
    // ═══════════════════════════════════════════════════════════
    EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOn');
    onCommandSent?.call(id);
    _updateLocalState(id, true);
    final success = await _tuyaProtocol.turnOn(device);
    if (!success) _updateLocalState(id, false);

    if (success) {
      _sendDeviceNotification(device.name, 'Включено', true);
    } else {
      _sendDeviceNotification(device.name, 'Включено', false);
    }

    return success;
  }

  Future<bool> turnOff(String id) async {
    final device = state.firstWhere((d) => d.id == id);

    // 🎥 Frigate-камера — не управляется через turnOff
    if (device.properties['source'] == 'frigate') {
      return false;
    }

    // ═══════════════════════════════════════════════════════════
    // 🐝 ZIGBEE — через MQTT
    // ═══════════════════════════════════════════════════════════
    if (device.properties['source'] == 'zigbee') {
      try {
        final friendlyName = device.properties['friendly_name'] as String?
            ?? device.name;
        final protocol = getIt<ZigbeeProtocol>();
        await protocol.turnOff(friendlyName);
        _updateLocalState(id, false);
        EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOff');
        _sendDeviceNotification(device.name, 'Выключено', true);
        return true;
      } catch (e) {
        debugPrint('❌ Zigbee turnOff error: $e');
        return false;
      }
    }

    // ═══════════════════════════════════════════════════════════
    // 🔌 TUYA — как раньше
    // ═══════════════════════════════════════════════════════════
    EventLogger.log(deviceId: id, deviceName: device.name, event: 'turnOff');
    onCommandSent?.call(id);
    _updateLocalState(id, false);
    final success = await _tuyaProtocol.turnOff(device);
    if (!success) _updateLocalState(id, true);

    if (success) {
      _sendDeviceNotification(device.name, 'Выключено', true);
    } else {
      _sendDeviceNotification(device.name, 'Выключено', false);
    }

    return success;
  }

  Future<void> _sendDeviceNotification(String deviceName, String action, bool success) async {
    try {
      final shouldSend = await NotificationSettingsService.shouldSendDeviceNotification();
      if (shouldSend) {
        final vk = VkNotificationService();
        await vk.loadSettings();
        await vk.sendDeviceNotification(
          deviceName: deviceName,
          action: action,
          success: success,
        );
      }
    } catch (e) {
      debugPrint('❌ VK device notification error: $e');
    }
  }

  Future<bool> setSwitchChannel(String id, int channel, bool value) async {
    final device = state.firstWhere((d) => d.id == id);

    // 🐝 Zigbee
    if (device.properties['source'] == 'zigbee') {
      try {
        final friendlyName = device.properties['friendly_name'] as String?
            ?? device.name;
        final protocol = getIt<ZigbeeProtocol>();
        // Для многоканальных: state_l1, state_l2, ...
        await protocol.setState(friendlyName, {'state_l$channel': value ? 'ON' : 'OFF'});
        _updateChannelState(id, channel, value);
        return true;
      } catch (e) {
        debugPrint('❌ Zigbee setSwitchChannel error: $e');
        return false;
      }
    }

    // 🔌 Tuya
    onCommandSent?.call(id);
    _updateChannelState(id, channel, value);
    final success = await _tuyaProtocol.setSwitchChannel(device, channel, value);
    if (!success) _updateChannelState(id, channel, !value);
    return success;
  }

  void _updateLocalState(String id, bool isOn) {
    final device = state.firstWhere((d) => d.id == id);
    final updated = device.copyWith(
      properties: {...device.properties, 'isOn': isOn},
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  void _updateChannelState(String id, int channel, bool value) {
    final device = state.firstWhere((d) => d.id == id);
    final states = List<bool>.from(device.properties['states'] ?? [false, false]);
    if (channel <= states.length) {
      states[channel - 1] = value;
    }
    final updated = device.copyWith(
      properties: {...device.properties, 'states': states},
    );
    state = state.map((d) => d.id == id ? updated : d).toList();
  }

  Future<bool> pingDevice(String id) async {
    return await _repository.pingDevice(id);
  }

  Future<bool> setCurtainPosition(String id, int position) async {
    final device = state.firstWhere((d) => d.id == id);
    final success = await _tuyaProtocol.setCurtainPosition(device, position);
    if (success) {
      final updated = device.copyWith(
        properties: {...device.properties, 'position': position},
      );
      state = state.map((d) => d.id == id ? updated : d).toList();
    }
    return success;
  }

  Future<bool> setHvac(String id, {required bool power, required double targetTemp, required String mode, required int fanSpeed}) async {
    return await _repository.setHvac(id, power: power, targetTemp: targetTemp, mode: mode, fanSpeed: fanSpeed);
  }

  Future<bool> setBrightness(String id, int brightness) async {
    final device = state.firstWhere((d) => d.id == id);

    // 🐝 Zigbee
    if (device.properties['source'] == 'zigbee') {
      try {
        final friendlyName = device.properties['friendly_name'] as String?
            ?? device.name;
        final protocol = getIt<ZigbeeProtocol>();
        await protocol.setBrightness(friendlyName, brightness);
        final updated = device.copyWith(
          properties: {
            ...device.properties,
            'brightness': brightness,
            'isOn': brightness > 0,
          },
        );
        state = state.map((d) => d.id == id ? updated : d).toList();
        return true;
      } catch (e) {
        debugPrint('❌ Zigbee setBrightness error: $e');
        return false;
      }
    }

    // 🔌 Tuya
    final success = await _tuyaProtocol.setBrightness(device, brightness);
    if (success) {
      final updated = device.copyWith(
        properties: {
          ...device.properties,
          'brightness': brightness,
          'isOn': brightness > 0,
        },
      );
      state = state.map((d) => d.id == id ? updated : d).toList();
    }
    return success;
  }

  Future<Map<String, dynamic>?> getDeviceDps(String id) async {
    final device = state.firstWhere((d) => d.id == id);
    return await _tuyaProtocol.getStatus(device);
  }

  /// Возвращает свойства по умолчанию для указанного типа устройства.
  /// Используется при добавлении нового устройства вручную или через сканер.
  static Map<String, dynamic> defaultProperties(DeviceType type) {
    switch (type) {
      case DeviceType.switch1:
        return {
          'channels': 1,
          'states': [false],
          'dps_map': {
            '1': {'label': 'Канал 1', 'type': 'bool', 'role': 'channel'},
          },
        };
      case DeviceType.switch2:
        return {
          'channels': 2,
          'states': [false, false],
          'dps_map': {
            '1': {'label': 'Канал 1', 'type': 'bool', 'role': 'channel'},
            '2': {'label': 'Канал 2', 'type': 'bool', 'role': 'channel'},
          },
        };
      case DeviceType.switch3:
        return {
          'channels': 3,
          'states': [false, false, false],
          'dps_map': {
            '1': {'label': 'Канал 1', 'type': 'bool', 'role': 'channel'},
            '2': {'label': 'Канал 2', 'type': 'bool', 'role': 'channel'},
            '3': {'label': 'Канал 3', 'type': 'bool', 'role': 'channel'},
          },
        };
      case DeviceType.curtain:
        return {'position': 100, 'isMoving': false};
      case DeviceType.light:
        return {'brightness': 255, 'isOn': false};
      case DeviceType.hvac:
        return {
          'isOn': false,
          'temperature': 22,
          'targetTemp': 24,
          'mode': 'auto',
          'fanSpeed': 1,
          'dps_map': {
            '1': {'label': 'Питание', 'type': 'bool', 'role': 'action', 'show_on_card': true},
            '2': {'label': 'Температура', 'type': 'value', 'role': 'slider', 'min': 16, 'max': 30, 'step': 1, 'divider': 10, 'show_on_card': true},
            '3': {'label': 'Текущая темп.', 'type': 'value', 'role': 'info', 'icon': 'temp', 'show_on_card': true},
            '4': {'label': 'Режим', 'type': 'enum', 'role': 'enum', 'enum_values': ['auto', 'cold', 'heat', 'fan', 'dry'], 'show_on_card': true},
            '5': {'label': 'Вентилятор', 'type': 'enum', 'role': 'enum', 'enum_values': ['auto', 'low', 'mid', 'high'], 'show_on_card': true},
            '18': {'label': 'Влажность', 'type': 'value', 'role': 'info', 'icon': 'humidity', 'show_on_card': true},
            '19': {'label': 'Ед. темп.', 'type': 'enum', 'role': 'enum', 'enum_values': ['c', 'f'], 'show_on_card': false},
            '20': {'label': 'Ошибка', 'type': 'value', 'role': 'info', 'show_on_card': false},
            '101': {'label': 'PM2.5', 'type': 'value', 'role': 'info', 'show_on_card': false},
            '102': {'label': 'Свежий воздух', 'type': 'enum', 'role': 'enum', 'enum_values': ['off', 'on'], 'show_on_card': false},
            '105': {'label': 'Сон', 'type': 'enum', 'role': 'enum', 'enum_values': ['off', 'sleep', 'smart'], 'show_on_card': false},
            '113': {'label': 'Верт. жалюзи', 'type': 'enum', 'role': 'enum', 'enum_values': ['0', '1', '2', '3'], 'icon': 'swing_vertical', 'show_on_card': false},
            '114': {'label': 'Гор. жалюзи', 'type': 'enum', 'role': 'enum', 'enum_values': ['0', '1', '2', '3'], 'icon': 'swing_horizontal', 'show_on_card': false},
            '120': {'label': 'Энергосбережение', 'type': 'enum', 'role': 'enum', 'enum_values': ['off', 'on'], 'show_on_card': false},
            '125': {'label': 'Качество воздуха', 'type': 'enum', 'role': 'info', 'enum_values': ['great', 'good', 'bad'], 'icon': 'air_quality', 'show_on_card': true},
            '129': {'label': 'кВт⋅ч', 'type': 'value', 'role': 'info', 'show_on_card': false},
            '130': {'label': 'Эконом. темп.', 'type': 'value', 'role': 'slider', 'min': 16, 'max': 30, 'step': 1, 'divider': 10, 'show_on_card': false},
            '131': {'label': 'Фильтр', 'type': 'bool', 'role': 'info', 'icon': 'filter', 'show_on_card': false},
            '132': {'label': 'Тёплый/холодный ветер', 'type': 'bool', 'role': 'toggle', 'show_on_card': false},
            '133': {'label': 'Ветер', 'type': 'enum', 'role': 'enum', 'enum_values': ['0', '1', '2', '3'], 'show_on_card': false},
          }
        };
      case DeviceType.compound:
        return {
          'isOn': false,
          'dps_map': {
            '1': {'label': 'Уборка', 'type': 'bool', 'role': 'action'},
            '2': {'label': 'Пауза', 'type': 'bool', 'role': 'action'},
            '3': {'label': 'На базу', 'type': 'bool', 'role': 'action'},
            '4': {'label': 'Режим', 'type': 'enum', 'role': 'enum', 'enum_values': ['chargego', 'clean', 'pause', 'charge']},
            '5': {'label': 'Статус', 'type': 'enum', 'role': 'info', 'show_on_card': true},
            '6': {'label': 'Время уборки', 'type': 'value', 'role': 'info', 'icon': 'timer', 'show_on_card': false},
            '7': {'label': 'Площадь', 'type': 'value', 'role': 'info', 'icon': 'area', 'show_on_card': false},
            '8': {'label': 'Заряд', 'type': 'value', 'role': 'info', 'icon': 'battery', 'show_on_card': true},
            '9': {'label': 'Всасывание', 'type': 'enum', 'role': 'enum', 'enum_values': ['normal', 'turbo', 'eco']},
            '10': {'label': 'Бак воды', 'type': 'enum', 'role': 'enum', 'enum_values': ['low', 'high']},
            '25': {'label': 'Не беспокоить', 'type': 'bool', 'role': 'toggle'},
            '26': {'label': 'Громкость', 'type': 'value', 'role': 'slider', 'min': 0, 'max': 100, 'step': 1},
            '104': {'label': 'Влажная уборка', 'type': 'bool', 'role': 'toggle'},
          }
        };
      default:
        return {'isOn': false};
    }
  }
}