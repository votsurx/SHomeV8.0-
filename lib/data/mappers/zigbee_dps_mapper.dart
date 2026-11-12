/// Маппер: exposes Zigbee2MQTT → DPS-карта SHome.
/// DPS-карта — это Map<String, dynamic>, который хранится в Device.properties['dps_map'].
library;

import '../../domain/models/zigbee_device.dart';

class ZigbeeDpsMapper {
  /// Преобразует список exposes в DPS-карту для compound-устройства.
  static Map<String, dynamic> toDpsMap(List<ZigbeeExpose> exposes) {
    final map = <String, dynamic>{};
    for (final e in exposes) {
      if (e.name.isEmpty) continue;
      map[e.name] = {
        'label': _humanName(e.name),
        'type': _typeFor(e),
        'role': _roleFor(e),
        'icon': _iconFor(e.name),
        if (e.unit != null) 'unit': e.unit,
        if (e.values != null) 'enum_values': e.values,
        if (e.valueMin != null) 'min': e.valueMin,
        if (e.valueMax != null) 'max': e.valueMax,
        'show_on_card': _showOnCard(e.name),
      };
    }
    return map;
  }

  static String _humanName(String name) {
    final map = {
      'temperature': 'Температура',
      'humidity': 'Влажность',
      'battery': 'Батарея',
      'occupancy': 'Движение',
      'contact': 'Открытие',
      'action': 'Действие',
      'state': 'Состояние',
      'brightness': 'Яркость',
      'color_temp': 'Цвет. температура',
      'linkquality': 'Качество связи',
      'voltage': 'Напряжение',
      'power': 'Мощность',
      'current': 'Ток',
      'energy': 'Энергия',
      'illuminance': 'Освещённость',
      'illuminance_lux': 'Освещённость (лк)',
      'pressure': 'Давление',
      'water_leak': 'Протечка',
      'smoke': 'Дым',
      'carbon_monoxide': 'CO',
      'tamper': 'Вскрытие',
    };
    return map[name] ?? name;
  }

  static String _typeFor(ZigbeeExpose e) {
    switch (e.type) {
      case 'numeric':
        return 'value';
      case 'binary':
        return 'bool';
      case 'enum':
        return 'enum';
      case 'switch':
        return 'bool';
      case 'text':
        return 'text';
      default:
        return 'value';
    }
  }

  static String _roleFor(ZigbeeExpose e) {
    if (e.name == 'action') return 'action';
    if (e.name == 'state' && e.type == 'switch') return 'toggle';
    if (e.name == 'brightness') return 'slider';
    if (e.name == 'color_temp') return 'slider';
    if (e.isReadOnly) return 'info';
    if (e.type == 'binary') return 'status';
    if (e.type == 'numeric' && e.isWritable) return 'slider';
    if (e.type == 'enum' && e.isWritable) return 'enum';
    return 'info';
  }

  static String _iconFor(String name) {
    final map = {
      'temperature': 'temp',
      'humidity': 'humidity',
      'battery': 'battery',
      'occupancy': 'motion',
      'contact': 'door',
      'action': 'button',
      'brightness': 'brightness',
      'color_temp': 'color_temp',
      'linkquality': 'signal',
      'voltage': 'voltage',
      'power': 'power',
      'current': 'current',
      'energy': 'energy',
      'illuminance': 'light',
      'illuminance_lux': 'light',
      'pressure': 'pressure',
      'water_leak': 'water',
      'smoke': 'smoke',
      'carbon_monoxide': 'co',
      'tamper': 'tamper',
    };
    return map[name] ?? 'sensor';
  }

  static bool _showOnCard(String name) {
    return const {
      'temperature',
      'humidity',
      'battery',
      'occupancy',
      'contact',
      'state',
      'brightness',
      'power',
      'voltage',
      'current',
    }.contains(name);
  }
}