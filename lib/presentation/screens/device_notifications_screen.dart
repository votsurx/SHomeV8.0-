/// Экран уведомлений для конкретного устройства.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/state/devices_provider.dart';
import '../../domain/models/device.dart';
import '../../l10n/generated/app_localizations.dart';

class DeviceNotificationsScreen extends ConsumerStatefulWidget {
  const DeviceNotificationsScreen({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  ConsumerState<DeviceNotificationsScreen> createState() =>
      _DeviceNotificationsScreenState();
}

class _DeviceNotificationsScreenState
    extends ConsumerState<DeviceNotificationsScreen> {
  static const _zigbeeTypes = [
    'water_leak',
    'smoke',
    'gas',
    'motion',
    'contact',
    'low_battery',
  ];

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
    _condition =
        device?.properties['notify_condition'] as String? ?? 'always';
    _cooldown =
        device?.properties['notify_cooldown_min'] as int? ?? 1;
  }

  Device? _getDevice() {
    final devices = ref.read(devicesProvider);
    return devices.where((device) => device.id == widget.deviceId).firstOrNull;
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

    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.notificationSettingsSaved),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

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

  String _labelEmoji(String label) {
    switch (label) {
      case 'person':
        return '🚶';
      case 'car':
        return '🚗';
      case 'dog':
        return '🐕';
      case 'cat':
        return '🐱';
      case 'bird':
        return '🐦';
      case 'motorcycle':
        return '🏍️';
      case 'bicycle':
        return '🚲';
      case 'truck':
        return '🚚';
      case 'bus':
        return '🚌';
      case 'boat':
        return '⛵';
      case 'water_leak':
        return '💧';
      case 'smoke':
        return '🔥';
      case 'gas':
        return '💨';
      case 'motion':
        return '🏃';
      case 'contact':
        return '🚪';
      case 'low_battery':
        return '🔋';
      default:
        return '📦';
    }
  }

  String _typeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'water_leak':
        return '${_labelEmoji(type)} ${l10n.notificationWaterLeak}';
      case 'smoke':
        return '${_labelEmoji(type)} ${l10n.notificationSmoke}';
      case 'gas':
        return '${_labelEmoji(type)} ${l10n.notificationGas}';
      case 'motion':
        return '${_labelEmoji(type)} ${l10n.notificationMotion}';
      case 'contact':
        return '${_labelEmoji(type)} ${l10n.notificationContact}';
      case 'low_battery':
        return '${_labelEmoji(type)} ${l10n.notificationLowBattery}';
      case 'state_changed':
        return '🔄 ${l10n.notificationStateChanged}';
      case 'offline':
        return '📡 ${l10n.notificationOffline}';
      case 'error':
        return '❌ ${l10n.notificationError}';
      case 'temperature_above':
        return '🌡️ ${l10n.notificationTemperatureAbove}';
      case 'temperature_below':
        return '🌡️ ${l10n.notificationTemperatureBelow}';
      case 'humidity_above':
        return '💧 ${l10n.notificationHumidityAbove}';
      case 'humidity_below':
        return '💧 ${l10n.notificationHumidityBelow}';
      case 'power_above':
        return '⚡ ${l10n.notificationPowerAbove}';
      default:
        return type;
    }
  }

  String _frigateLabel(String label, AppLocalizations l10n) {
    switch (label) {
      case 'person':
        return l10n.notificationPerson;
      case 'car':
        return l10n.notificationCar;
      case 'dog':
        return l10n.notificationDog;
      case 'cat':
        return l10n.notificationCat;
      case 'bird':
        return l10n.notificationBird;
      case 'motorcycle':
        return l10n.notificationMotorcycle;
      case 'bicycle':
        return l10n.notificationBicycle;
      case 'truck':
        return l10n.notificationTruck;
      case 'bus':
        return l10n.notificationBus;
      case 'boat':
        return l10n.notificationBoat;
      default:
        return label;
    }
  }

  String _conditionLabel(String condition, AppLocalizations l10n) {
    switch (condition) {
      case 'always':
        return l10n.notificationConditionAlways;
      case 'away':
        return l10n.notificationConditionAway;
      case 'night':
        return l10n.notificationConditionNight;
      case 'away_or_night':
        return l10n.notificationConditionAwayOrNight;
      default:
        return l10n.notificationConditionAlways;
    }
  }

  String _thresholdLabel(String type, AppLocalizations l10n) {
    if (type.contains('temperature')) {
      return l10n.notificationTemperatureThreshold;
    }
    if (type.contains('humidity')) {
      return l10n.notificationHumidityThreshold;
    }
    if (type.contains('power')) {
      return l10n.notificationPowerThreshold;
    }
    return l10n.notificationThreshold;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devices = ref.watch(devicesProvider);
    final device =
        devices.where((item) => item.id == widget.deviceId).firstOrNull;

    if (device == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.deviceNotificationsTitle),
        ),
        body: Center(
          child: Text(l10n.deviceNotFound),
        ),
      );
    }

    final source = device.properties['source'] as String? ?? '';
    final isZigbee = source == 'zigbee';
    final isFrigate = source == 'frigate';
    final isTuya = !isZigbee && !isFrigate;
    final tuyaTypes = _tuyaTypesByDeviceType[device.type] ?? [];
    final isZigbeeBattery =
        isZigbee && device.properties['battery'] != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deviceNotificationsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: l10n.save,
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                    ? l10n.notificationDeviceZigbee
                    : isFrigate
                    ? l10n.notificationDeviceFrigate
                    : l10n.notificationDeviceTuya(device.type.name),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            l10n.notificationConditionSection,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<String>(
              groupValue: _condition,
              onChanged: (value) {
                setState(() => _condition = value ?? 'always');
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.notificationConditionAlways),
                    value: 'always',
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.notificationConditionAway),
                    value: 'away',
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.notificationConditionNight),
                    value: 'night',
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.notificationConditionAwayOrNight),
                    value: 'away_or_night',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            l10n.notificationCooldownSection,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: DropdownButtonFormField<int>(
              initialValue: _cooldown,
              decoration: InputDecoration(
                labelText: l10n.notificationInterval,
                prefixIcon: const Icon(Icons.timer),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Text(l10n.notificationMinute),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text(l10n.notificationMinutes5),
                ),
                DropdownMenuItem(
                  value: 15,
                  child: Text(l10n.notificationMinutes15),
                ),
                DropdownMenuItem(
                  value: 30,
                  child: Text(l10n.notificationMinutes30),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _cooldown = value);
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          if (isZigbee) ...[
            Text(
              l10n.notificationTypesTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _zigbeeTypes.map((type) {
                  final isBatteryType = type == 'low_battery';

                  return Column(
                    children: [
                      SwitchListTile(
                        title: Text(_typeLabel(type, l10n)),
                        value: _isTypeEnabled(type, _zigbeeTypes),
                        onChanged: (value) => _toggleType(type, value),
                      ),
                      if (isBatteryType &&
                          isZigbeeBattery &&
                          _isTypeEnabled(type, _zigbeeTypes))
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: _buildBatteryThresholdField(l10n),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (isFrigate) ...[
            Text(
              l10n.notificationFrigateLabelsTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _frigateLabels
                    .map(
                      (label) => SwitchListTile(
                    title: Text(
                      '${_labelEmoji(label)} ${_frigateLabel(label, l10n)}',
                    ),
                    value: _isLabelEnabled(label),
                    onChanged: (value) => _toggleLabel(label, value),
                  ),
                )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (isTuya && tuyaTypes.isNotEmpty) ...[
            Text(
              l10n.notificationTypesTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: tuyaTypes.map((type) {
                  final isThreshold = type.startsWith('temperature') ||
                      type.startsWith('humidity') ||
                      type.startsWith('power');
                  final isBatteryType = type == 'low_battery';

                  return Column(
                    children: [
                      SwitchListTile(
                        title: Text(_typeLabel(type, l10n)),
                        value: _isTypeEnabled(type, tuyaTypes),
                        onChanged: (value) => _toggleType(type, value),
                      ),
                      if (isThreshold && _isTypeEnabled(type, tuyaTypes))
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: _buildThresholdField(type, l10n),
                        ),
                      if (isBatteryType &&
                          _isTypeEnabled(type, tuyaTypes))
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: _buildBatteryThresholdField(l10n),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notificationHowItWorks,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _condition == 'always'
                      ? l10n.notificationAlwaysExplanation
                      : l10n.notificationConditionExplanation(
                    _conditionLabel(_condition, l10n),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdField(
      String type,
      AppLocalizations l10n,
      ) {
    final key = 'threshold_$type';
    final current = _getThreshold(key);

    return TextFormField(
      initialValue: current?.toStringAsFixed(1) ?? '',
      decoration: InputDecoration(
        labelText: _thresholdLabel(type, l10n),
        hintText: _thresholdHint(type),
        suffixText: _thresholdUnit(type),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        final parsed = double.tryParse(value);
        _setThreshold(key, parsed);
      },
    );
  }

  Widget _buildBatteryThresholdField(AppLocalizations l10n) {
    const key = 'threshold_battery_low';
    final current = _getThreshold(key) ?? 20;

    return TextFormField(
      initialValue: current.toStringAsFixed(0),
      decoration: InputDecoration(
        labelText: l10n.notificationBatteryThreshold,
        hintText: '20',
        suffixText: '%',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final parsed = double.tryParse(value);
        _setThreshold(key, parsed);
      },
    );
  }
}