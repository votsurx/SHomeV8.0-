import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/device.dart';
import '../../../application/state/devices_provider.dart';

class DeviceCompound extends ConsumerWidget {
  final Device device;
  const DeviceCompound({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dpsMap = device.properties['dps_map'] as Map<String, dynamic>? ?? {};
    final isOnline = device.state != DeviceState.offline;

    // Разделяем DPS по ролям
    final mainDps = dpsMap.entries.where((e) => e.value['role'] == 'main').toList();
    final actionDps = dpsMap.entries.where((e) => e.value['role'] == 'action').toList();
    final toggleDps = dpsMap.entries.where((e) => e.value['role'] == 'toggle').toList();
    final infoDps = dpsMap.entries.where((e) => e.value['role'] == 'info').toList();
    final statusDps = dpsMap.entries.where((e) => e.value['role'] == 'status').toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Статус
        if (statusDps.isNotEmpty)
          Text(
            _dpsValue(statusDps.first)?.toString() ?? '--',
            style: const TextStyle(fontSize: 10),
          ),

        // Инфо-строка
        if (infoDps.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 0,
            children: infoDps.map((e) {
              final icon = e.value['icon'] as String?;
              final val = _dpsValue(e);
              return Text(
                '${_infoIcon(icon)}${val ?? "--"}',
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              );
            }).toList(),
          ),

        // Кнопки управления
        if (mainDps.isNotEmpty || actionDps.isNotEmpty || toggleDps.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 140;
              final allButtons = <Widget>[];
              allButtons.addAll(mainDps.map((e) => _dpsButton(ref, context, isOnline, e)));
              allButtons.addAll(actionDps.map((e) => _dpsButton(ref, context, isOnline, e)));
              allButtons.addAll(toggleDps.map((e) => _dpsToggle(ref, context, isOnline, e)));

              if (narrow) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < allButtons.length; i += 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            allButtons[i],
                            if (i + 1 < allButtons.length) const SizedBox(width: 2),
                            if (i + 1 < allButtons.length) allButtons[i + 1],
                          ],
                        ),
                      ),
                  ],
                );
              }

              return Wrap(
                alignment: WrapAlignment.center,
                spacing: 2,
                runSpacing: 2,
                children: allButtons,
              );
            },
          ),
      ],
    );
  }

  dynamic _dpsValue(MapEntry<String, dynamic> entry) {
    final key = 'dps_${entry.key}';
    return device.properties[key];
  }

  Widget _dpsButton(WidgetRef ref, BuildContext ctx, bool online, MapEntry<String, dynamic> entry) {
    final label = entry.value['label'] as String? ?? '';
    final isOn = _dpsValue(entry) == true || _dpsValue(entry) == 1;
    final iconName = entry.value['icon'] as String? ?? '';
    final icon = _getIconFromName(iconName, label, isOn);
    final color = isOn ? Colors.green : Colors.grey;
    final dpsNumber = int.tryParse(entry.key) ?? 1;

    return _btn(ref, ctx, online, icon, color, () {
      ref.read(devicesProvider.notifier).setSwitchChannel(device.id, dpsNumber, !isOn);
    });
  }

  Widget _dpsToggle(WidgetRef ref, BuildContext ctx, bool online, MapEntry<String, dynamic> entry) {
    final label = entry.value['label'] as String? ?? '';
    final isOn = _dpsValue(entry) == true || _dpsValue(entry) == 1;
    final iconName = entry.value['icon'] as String? ?? '';
    final icon = _getIconFromName(iconName, label, isOn);
    final color = isOn ? Colors.blue : Colors.grey;
    final dpsNumber = int.tryParse(entry.key) ?? 1;

    return _btn(ref, ctx, online, icon, color, () {
      ref.read(devicesProvider.notifier).setSwitchChannel(device.id, dpsNumber, !isOn);
    });
  }

  IconData _getIconFromName(String? iconName, String label, bool isOn) {
    if (iconName != null && iconName.isNotEmpty) {
      switch (iconName) {
        case 'play': return isOn ? Icons.stop : Icons.play_arrow;
        case 'home': return Icons.home;
        case 'power': return Icons.power_settings_new;
        case 'water': return Icons.water_drop;
        case 'mop': return Icons.cleaning_services;
        case 'do_not_disturb': return Icons.do_not_disturb;
        case 'battery': return isOn ? Icons.battery_full : Icons.battery_std;
        case 'fan': return Icons.air;
        case 'temp': return Icons.thermostat;
        case 'ac': return Icons.ac_unit;
        case 'heater': return Icons.local_fire_department;
        case 'air': return Icons.air;
        case 'suction': return Icons.storm;
        case 'wait': return Icons.hourglass_empty;
        case 'sync': return Icons.sync;
        default: return Icons.circle;
      }
    }
    // Fallback
    if (label.contains('Уборка')) return isOn ? Icons.stop : Icons.play_arrow;
    if (label.contains('базу') || label.contains('Базу')) return Icons.home;
    if (label.contains('беспокоить')) return Icons.do_not_disturb;
    if (label.contains('Влажная') || label.contains('Мытьё')) return Icons.water_drop;
    return Icons.circle;
  }

  Widget _btn(WidgetRef ref, BuildContext ctx, bool online, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        if (!online) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Offline'), duration: Duration(seconds: 1)),
          );
          return;
        }
        onTap();
      },
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  IconData _actionIcon(String label, bool isOn) {
    if (label.contains('Уборка')) return isOn ? Icons.stop : Icons.play_arrow;
    if (label.contains('базу') || label.contains('Базу')) return Icons.home;
    return Icons.circle;
  }

  IconData _toggleIcon(String label) {
    if (label.contains('беспокоить')) return Icons.do_not_disturb;
    if (label.contains('Влажная') || label.contains('Мытьё')) return Icons.water_drop;
    return Icons.toggle_off;
  }

  String _infoIcon(String? icon) {
    switch (icon) {
      case 'battery': return '🔋';
      case 'timer': return '⏱';
      case 'area': return '📐';
      default: return '';
    }
  }
}