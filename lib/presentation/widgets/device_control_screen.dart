import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../data/protocols/tuya_protocol.dart';
import '../../di/injection.dart';

class DeviceControlScreen extends ConsumerStatefulWidget {
  final Device device;
  const DeviceControlScreen({super.key, required this.device});

  @override
  ConsumerState<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends ConsumerState<DeviceControlScreen> {
  late final TuyaProtocol _tuyaProtocol = getIt<TuyaProtocol>();

  @override
  Widget build(BuildContext context) {
    final device = ref
        .watch(devicesProvider)
        .firstWhere((d) => d.id == widget.device.id, orElse: () => widget.device);

    final dpsMap = device.properties['dps_map'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: dpsMap.entries
            .where((entry) => (entry.value as Map<String, dynamic>?)?['role'] != 'info')
            .map((entry) => _buildControl(entry.key, entry.value as Map<String, dynamic>, device))
            .toList(),
      ),
    );
  }

  Widget _buildControl(String dpId, Map<String, dynamic> config, Device device) {
    final role = config['role'] as String? ?? 'action';
    final currentValue = device.properties['dps_$dpId'] ?? device.properties[dpId];

    switch (role) {
      case 'action':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton.icon(
            onPressed: () => _sendCommand(dpId, true),
            icon: const Icon(Icons.play_arrow),
            label: Text(config['label'] ?? dpId),
          ),
        );
      case 'toggle':
        return SwitchListTile(
          title: Text(config['label'] ?? dpId),
          value: currentValue == true,
          onChanged: (val) => _sendCommand(dpId, val),
        );
      case 'slider':
        double min = (config['min'] as num?)?.toDouble() ?? 0;
        double max = (config['max'] as num?)?.toDouble() ?? 100;
        double step = (config['step'] as num?)?.toDouble() ?? 1;
        int divisions = step > 0 ? ((max - min) / step).round() : 100;
        double currentVal = (currentValue as num?)?.toDouble() ?? min;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${config['label'] ?? dpId}: ${currentVal.round().toString()}'),
            Slider(
              value: currentVal,
              min: min,
              max: max,
              divisions: divisions,
              label: currentVal.round().toString(),
              onChanged: (val) {
                // локально обновляем для плавности
                final updatedProperties = Map<String, dynamic>.from(device.properties);
                updatedProperties['dps_$dpId'] = val.round();
                ref.read(devicesProvider.notifier).updateDeviceProperties(device.id, updatedProperties);
              },
              onChangeEnd: (val) => _sendCommand(dpId, val.round()),
            ),
          ],
        );
      case 'enum':
        final enumValues = (config['enum_values'] as List?)?.cast<String>() ?? [];
        // Убираем дубликаты
        final uniqueValues = enumValues.toSet().toList();
        return DropdownButtonFormField<String>(
          initialValue: uniqueValues.contains(currentValue?.toString())
              ? currentValue?.toString()
              : null,
          decoration: InputDecoration(labelText: config['label'] ?? dpId),
          items: uniqueValues
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (val) {
            if (val != null) _sendCommand(dpId, val);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _sendCommand(String dpId, dynamic value) async {
    // 1. Оптимистично обновляем UI (сохраняем старое значение для отката)
    final oldProperties = Map<String, dynamic>.from(widget.device.properties);
    final updatedProperties = Map<String, dynamic>.from(oldProperties);
    updatedProperties['dps_$dpId'] = value;

    ref.read(devicesProvider.notifier).updateDeviceProperties(widget.device.id, updatedProperties);

    // 2. Отправляем команду
    try {
      final success = await _tuyaProtocol.setDp(widget.device, int.parse(dpId), value);
      if (!success) {
        // 3. Если ошибка – откатываем UI обратно
        ref.read(devicesProvider.notifier).updateDeviceProperties(widget.device.id, oldProperties);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Не удалось отправить команду: DP $dpId = $value')),
          );
        }
      }
    } catch (e) {
      // 4. При исключении тоже откатываем
      ref.read(devicesProvider.notifier).updateDeviceProperties(widget.device.id, oldProperties);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    }
  }
}