/// Компактная карточка для составных устройств (пылесос, кондиционер).
/// Показывает только информационные DP из dps_map.
/// По тапу открывает DeviceControlScreen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import 'device_control_screen.dart';

class CompoundDeviceCard extends ConsumerWidget {
  final Device device;
  const CompoundDeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем актуальное состояние устройства из провайдера
    final currentDevice = ref
        .watch(devicesProvider)
        .firstWhere((d) => d.id == device.id, orElse: () => device);

    final dpsMap = currentDevice.properties['dps_map'] as Map<String, dynamic>? ?? {};

    // Фильтруем DP: только info и status, у которых show_on_card != false
    final infoItems = dpsMap.entries.where((entry) {
      final config = entry.value as Map<String, dynamic>?;
      if (config == null) return false;
      final role = config['role'] as String? ?? '';
      if (role != 'info' && role != 'status') return false;
      return config['show_on_card'] != false;
    }).toList();

    // Контент без карточки, но с кликабельностью
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceControlScreen(device: currentDevice),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Если нет информационных полей — показываем заглушку
            if (infoItems.isEmpty)
              Row(
                children: [
                  Icon(
                    currentDevice.isOnline ? Icons.circle : Icons.circle_outlined,
                    size: 12,
                    color: currentDevice.isOnline ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    currentDevice.isOnline ? 'Онлайн' : 'Офлайн',
                    style: TextStyle(
                      fontSize: 12,
                      color: currentDevice.isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              )
            else ...[
              // Компактный список информационных полей
              const SizedBox(height: 4),
              ...infoItems.map((entry) {
                final config = entry.value as Map<String, dynamic>;
                return _buildCompactInfoRow(
                  config: config,
                  currentValue: currentDevice.properties['dps_${entry.key}'] ??
                      currentDevice.properties[entry.key],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  /// Компактная строка с информацией — без лишних отступов
  Widget _buildCompactInfoRow({
    required Map<String, dynamic> config,
    dynamic currentValue,
  }) {
    final label = config['label'] as String? ?? '';
    final iconName = config['icon'] as String?;
    final displayValue = _formatValue(currentValue, config);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          if (iconName != null && iconName.isNotEmpty) ...[
            Icon(_getIcon(iconName), size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
          ],
          // Лейбл
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          // Точки-разделители
          Text('•', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
          const SizedBox(width: 4),
          // Значение
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Преобразует значение DP в читаемый вид
  String _formatValue(dynamic value, Map<String, dynamic> config) {
    if (value == null) return '--';
    final type = config['type'] as String? ?? '';
    if (type == 'value') {
      final unit = config['unit'] as String? ?? '';
      return '$value$unit';
    }
    if (type == 'bool') {
      return value == true || value == 'true' || value == 1 ? 'Вкл' : 'Выкл';
    }
    return value.toString();
  }

  /// Возвращает иконку по строковому ключу из dps_map
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'battery':
        return Icons.battery_std;
      case 'timer':
        return Icons.timer;
      case 'area':
        return Icons.square_foot;
      case 'temp':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water_drop;
      case 'power':
        return Icons.power;
      case 'water':
        return Icons.water;
      case 'fan':
        return Icons.air;
      default:
        return Icons.info_outline;
    }
  }
}
