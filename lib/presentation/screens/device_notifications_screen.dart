/// Экран уведомлений для конкретного устройства.
/// Позволяет настроить:
/// - Тип уведомлений (Zigbee / Frigate / Tuya — по типу устройства)
/// - Условие отправки (всегда / никого нет / ночью / никого нет ИЛИ ночью)
/// - Антидребезг (per-device)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/state/devices_provider.dart';
import '../../domain/models/device.dart';

class DeviceNotificationsScreen extends ConsumerStatefulWidget {
  final String deviceId;
  const DeviceNotificationsScreen({super.key, required this.deviceId});

  @override
  ConsumerState<DeviceNotificationsScreen> createState() =>
      _DeviceNotificationsScreenState();
}

class _DeviceNotificationsScreenState
    extends ConsumerState<DeviceNotificationsScreen> {
  // Zigbee
  static const _zigbeeTypes = [
    'water_leak',
    'smoke',
    'gas',
    'motion',
    'contact',
  ];

  // Frigate
  static const _frigateLabels = [
    'person',
    'car',
    'dog',
    'cat',
    'bird',
    'motorcycle',
    'bicycle',
    'truck',
    'bus',
    'boat',
  ];

  // Tuya — по типам устройств
  static const _tuyaTypesByDeviceType = {
    DeviceType.outlet: ['state_changed', 'offline', 'error'],
    DeviceType.switch1: ['state_changed', 'offline', 'error'],
    DeviceType.switch2: ['state_changed', 'offline', 'error'],
    DeviceType.switch3: ['state_changed', 'offline', 'error'],
    DeviceType.light: ['state_changed', 'offline', 'error'],
    DeviceType.hvac: ['state_changed', 'offline', 'error'],
    DeviceType.curtain: ['state_changed', 'offline', 'error'],
    DeviceType.sensor: [
      'temperature_above',
      'temperature_below',
      'humidity_above',
      'humidity_below',
      'power_above',
      'offline',
      'error',
    ],
    DeviceType.compound: [
      'state_changed',
      'offline',
      'error',
      'low_battery',
    ],
  };

  String _condition = 'always';
  int _cooldown = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final device = _getDevice();
    _condition = device?.properties['notify_condition'] as String? ?? 'always';
    _cooldown = device?.properties['notify_cooldown_min'] as int? ?? 1;
  }

  Device? _getDevice() {
    final devices = ref.read(devicesProvider);
    return devices.where((d) => d.id == widget.deviceId).firstOrNull;
  }

  Future<void> _save() async {
    final device = _getDevice();
    if (device == null) return;

    final updated = device.copyWith(
      properties: {
        ...device.properties,
        'notify_condition': _condition,
        'notify_cooldown_min': _cooldown,
      },
    );
    await ref.read(devicesProvider.notifier).updateDevice(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Настройки сохранены'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  // ═══════════════════════════════════════════════════════════
  // TOGGLE
  // ═══════════════════════════════════════════════════════════

  void _toggleType(String type, bool enabled) {
    final device = _getDevice();
    if (device == null) return;

    final current =
        (device.properties['notify_types'] as List?)?.cast<String>() ?? [];
    final updated = List<String>.from(current);

    if (enabled) {
      if (!updated.contains(type)) updated.add(type);
    } else {
      updated.remove(type);
    }

    final updatedDevice = device.copyWith(
      properties: {
        ...device.properties,
        'notify_types': updated,
      },
    );
    ref.read(devicesProvider.notifier).updateDeviceLocal(updatedDevice);
    setState(() {});
  }

  bool _isTypeEnabled(String type, List<String> defaults) {
    final device = _getDevice();
    if (device == null) return false;
    final types =
    (device.properties['notify_types'] as List?)?.cast<String>();
    if (types == null) return defaults.contains(type);
    return types.contains(type);
  }

  void _toggleLabel(String label, bool enabled) {
    final device = _getDevice();
    if (device == null) return;

    final current =
        (device.properties['notify_labels'] as List?)?.cast<String>() ??
            ['person'];
    final updated = List<String>.from(current);

    if (enabled) {
      if (!updated.contains(label)) updated.add(label);
    } else {
      updated.remove(label);
    }

    final updatedDevice = device.copyWith(
      properties: {
        ...device.properties,
        'notify_labels': updated,
      },
    );
    ref.read(devicesProvider.notifier).updateDeviceLocal(updatedDevice);
    setState(() {});
  }

  bool _isLabelEnabled(String label) {
    final device = _getDevice();
    if (device == null) return false;
    final labels =
        (device.properties['notify_labels'] as List?)?.cast<String>() ??
            ['person'];
    return labels.contains(label);
  }

  // ═══════════════════════════════════════════════════════════
  // THRESHOLD (Tuya-датчики)
  // ═══════════════════════════════════════════════════════════

  void _setThreshold(String key, double? value) {
    final device = _getDevice();
    if (device == null) return;

    final updatedProperties = Map<String, dynamic>.from(device.properties);
    if (value == null) {
      updatedProperties.remove(key);
    } else {
      updatedProperties[key] = value;
    }

    final updatedDevice = device.copyWith(properties: updatedProperties);
    ref.read(devicesProvider.notifier).updateDeviceLocal(updatedDevice);
    setState(() {});
  }

  double? _getThreshold(String key) {
    final device = _getDevice();
    if (device == null) return null;
    return (device.properties[key] as num?)?.toDouble();
  }

  // ═══════════════════════════════════════════════════════════
  // UI HELPERS
  // ═══════════════════════════════════════════════════════════

  String _labelEmoji(String label) {
    switch (label) {
      case 'person': return '🚶';
      case 'car': return '🚗';
      case 'dog': return '🐕';
      case 'cat': return '🐱';
      case 'bird': return '🐦';
      case 'motorcycle': return '🏍️';
      case 'bicycle': return '🚲';
      case 'truck': return '🚚';
      case 'bus': return '🚌';
      case 'boat': return '⛵';
      case 'water_leak': return '💧';
      case 'smoke': return '🔥';
      case 'gas': return '💨';
      case 'motion': return '🏃';
      case 'contact': return '🚪';
      default: return '📦';
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'water_leak': return '💧 Протечка';
      case 'smoke': return '🔥 Дым';
      case 'gas': return '💨 Газ';
      case 'motion': return '🏃 Движение';
      case 'contact': return '🚪 Контакт';
      case 'state_changed': return '🔄 Вкл/Выкл';
      case 'offline': return '📡 Offline';
      case 'error': return '❌ Ошибка';
      case 'low_battery': return '🔋 Низкий заряд';
      case 'temperature_above': return '🌡️ Температура >';
      case 'temperature_below': return '🌡️ Температура <';
      case 'humidity_above': return '💧 Влажность >';
      case 'humidity_below': return '💧 Влажность <';
      case 'power_above': return '⚡ Мощность >';
      default: return type;
    }
  }

  String _conditionLabel(String condition) {
    switch (condition) {
      case 'always': return 'Всегда';
      case 'away': return 'Только когда никого нет дома';
      case 'night': return 'Только ночью (22:00 – 06:00)';
      case 'away_or_night': return 'Никого нет дома ИЛИ ночью';
      default: return 'Всегда';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final device =
        devices.where((d) => d.id == widget.deviceId).firstOrNull;

    if (device == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Уведомления')),
        body: const Center(child: Text('Устройство не найдено')),
      );
    }

    final source = device.properties['source'] as String? ?? '';
    final isZigbee = source == 'zigbee';
    final isFrigate = source == 'frigate';
    final isTuya = !isZigbee && !isFrigate;

    // Типы для Tuya (по типу устройства)
    final tuyaTypes = _tuyaTypesByDeviceType[device.type] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления устройства'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Сохранить',
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Заголовок ───
          Card(
            child: ListTile(
              leading: Icon(
                isZigbee
                    ? Icons.memory
                    : isFrigate
                    ? Icons.videocam
                    : Icons.devices,
                color: Colors.blue,
                size: 32,
              ),
              title: Text(
                device.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isZigbee
                    ? 'Zigbee-датчик'
                    : isFrigate
                    ? 'Frigate-камера'
                    : 'Tuya (${device.type.name})',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Условие отправки ───
          const Text(
            '⏱ Условие отправки',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<String>(
              groupValue: _condition,
              onChanged: (v) => setState(() => _condition = v ?? 'always'),
              child: const Column(
                children: [
                  RadioListTile<String>(
                    title: Text('Всегда'),
                    value: 'always',
                  ),
                  RadioListTile<String>(
                    title: Text('Только когда никого нет дома'),
                    value: 'away',
                  ),
                  RadioListTile<String>(
                    title: Text('Только ночью (22:00 – 06:00)'),
                    value: 'night',
                  ),
                  RadioListTile<String>(
                    title: Text('Никого нет дома ИЛИ ночью'),
                    value: 'away_or_night',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Антидребезг ───
          const Text(
            '⏱ Антидребезг',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: DropdownButtonFormField<int>(
              initialValue: _cooldown,
              decoration: const InputDecoration(
                labelText: 'Интервал',
                prefixIcon: Icon(Icons.timer),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 минута')),
                DropdownMenuItem(value: 5, child: Text('5 минут')),
                DropdownMenuItem(value: 15, child: Text('15 минут')),
                DropdownMenuItem(value: 30, child: Text('30 минут')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _cooldown = v);
              },
            ),
          ),
          const SizedBox(height: 16),

          // ─── Zigbee ───
          if (isZigbee) ...[
            const Text(
              '🔔 Типы уведомлений',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _zigbeeTypes
                    .map((type) => SwitchListTile(
                  title: Text(_typeLabel(type)),
                  value: _isTypeEnabled(type, _zigbeeTypes),
                  onChanged: (v) => _toggleType(type, v),
                ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ─── Frigate ───
          if (isFrigate) ...[
            const Text(
              '🔔 Объекты для детекции',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _frigateLabels
                    .map((label) => SwitchListTile(
                  title: Text('${_labelEmoji(label)} $label'),
                  value: _isLabelEnabled(label),
                  onChanged: (v) => _toggleLabel(label, v),
                ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ─── Tuya ───
          if (isTuya && tuyaTypes.isNotEmpty) ...[
            const Text(
              '🔔 Типы уведомлений',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: tuyaTypes.map((type) {
                  // Для threshold-типов — SwitchListTile + TextField
                  final isThreshold = type.startsWith('temperature') ||
                      type.startsWith('humidity') ||
                      type.startsWith('power');

                  return Column(
                    children: [
                      SwitchListTile(
                        title: Text(_typeLabel(type)),
                        value: _isTypeEnabled(type, tuyaTypes),
                        onChanged: (v) => _toggleType(type, v),
                      ),
                      if (isThreshold &&
                          _isTypeEnabled(type, tuyaTypes))
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 8),
                          child: _buildThresholdField(type),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ─── Сохранить ───
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Сохранить'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ─── Пояснение ───
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 Как это работает',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _condition == 'always'
                      ? 'Уведомления отправляются всегда при срабатывании.'
                      : 'Уведомления отправляются только при выполнении условия '
                      '"${_conditionLabel(_condition)}".',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdField(String type) {
    final key = 'threshold_$type';
    final current = _getThreshold(key);
    final controller =
    TextEditingController(text: current?.toStringAsFixed(1) ?? '');

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _thresholdLabel(type),
        hintText: _thresholdHint(type),
        suffixText: _thresholdUnit(type),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType:
      const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) {
        final parsed = double.tryParse(v);
        _setThreshold(key, parsed);
      },
    );
  }

  String _thresholdLabel(String type) {
    if (type.contains('temperature')) return 'Порог температуры';
    if (type.contains('humidity')) return 'Порог влажности';
    if (type.contains('power')) return 'Порог мощности';
    return 'Порог';
  }

  String _thresholdHint(String type) {
    if (type.contains('temperature')) return '30';
    if (type.contains('humidity')) return '80';
    if (type.contains('power')) return '1000';
    return '';
  }

  String _thresholdUnit(String type) {
    if (type.contains('temperature')) return '°C';
    if (type.contains('humidity')) return '%';
    if (type.contains('power')) return 'W';
    return '';
  }
}