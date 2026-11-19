/// Карточка устройства — основной виджет для отображения устройства в сетке.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/state/devices_provider.dart';
import '../../domain/models/device.dart';
import '../../l10n/generated/app_localizations.dart';
import 'compound_device_card.dart';
import 'device_controls/camera_preview.dart';
import 'device_controls/curtain_info.dart';
import 'device_controls/multi_switch.dart';
import 'device_controls/power_button.dart';
import 'device_controls/sensor_info.dart';
import 'device_icons.dart';
import 'device_settings.dart';

class DeviceCard extends ConsumerWidget {
  const DeviceCard({
    super.key,
    required this.device,
  });

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Следим за актуальным состоянием и свойствами устройства,
    // например battery и linkquality.
    final latestDevice = ref.watch(
      devicesProvider.select(
            (list) => list.firstWhere(
              (item) => item.id == device.id,
          orElse: () => device,
        ),
      ),
    );

    final isOnline = latestDevice.state != DeviceState.offline;

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(context, ref, latestDevice),
                Expanded(
                  child: Center(
                    child: _buildControls(ref, latestDevice, l10n),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              size: 16,
              color: isOnline
                  ? Colors.green.withValues(alpha: 0.6)
                  : Colors.red.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      WidgetRef ref,
      Device latestDevice,
      ) {
    return Row(
      children: [
        Icon(
          getDeviceIcon(latestDevice),
          size: 20,
          color: Colors.blue,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            latestDevice.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        GestureDetector(
          onTap: () => DeviceSettings.show(context, ref, latestDevice),
          child: const Icon(
            Icons.settings,
            size: 18,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(
      WidgetRef ref,
      Device latestDevice,
      AppLocalizations l10n,
      ) {
    // Zigbee compound-устройства имеют отдельную карточку.
    if (latestDevice.type == DeviceType.compound &&
        latestDevice.properties['source'] == 'zigbee') {
      return _buildZigbeeCard(latestDevice, l10n);
    }

    switch (latestDevice.type) {
      case DeviceType.outlet:
      case DeviceType.light:
        return DevicePowerButton(device: latestDevice);
      case DeviceType.switch1:
      case DeviceType.switch2:
      case DeviceType.switch3:
        return DeviceMultiSwitch(device: latestDevice);
      case DeviceType.sensor:
        return DeviceSensorInfo(device: latestDevice);
      case DeviceType.curtain:
        return DeviceCurtainInfo(device: latestDevice);
      case DeviceType.camera:
        return DeviceCameraPreview(device: latestDevice);
      case DeviceType.compound:
      case DeviceType.hvac:
        return CompoundDeviceCard(device: latestDevice);
      default:
        return DevicePowerButton(device: latestDevice);
    }
  }

  /// Карточка Zigbee-устройства: батарея, качество связи и состояния датчиков.
  Widget _buildZigbeeCard(
      Device latestDevice,
      AppLocalizations l10n,
      ) {
    final properties = latestDevice.properties;

    final battery = properties['battery'] as num?;
    final linkquality = properties['linkquality'] as num?;
    final waterLeak = properties['water_leak'] as bool?;
    final batteryLow = properties['battery_low'] as bool?;
    final occupancy = properties['occupancy'] as bool?;
    final contact = properties['contact'] as bool?;

    final hasInfo = battery != null ||
        linkquality != null ||
        waterLeak != null ||
        batteryLow != null ||
        occupancy != null ||
        contact != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (occupancy != null)
          Icon(
            occupancy ? Icons.directions_walk : Icons.accessibility_new,
            size: 28,
            color: occupancy ? Colors.orange : Colors.grey,
          )
        else if (contact != null)
          Icon(
            contact
                ? Icons.door_front_door
                : Icons.door_front_door_outlined,
            size: 28,
            color: contact ? Colors.blue : Colors.grey,
          )
        else if (waterLeak != null)
            Icon(
              waterLeak ? Icons.water_drop : Icons.water_drop_outlined,
              size: 28,
              color: waterLeak ? Colors.red : Colors.grey,
            )
          else
            const Icon(
              Icons.sensors,
              size: 28,
              color: Colors.purple,
            ),
        const SizedBox(height: 6),
        if (hasInfo)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 2,
            children: [
              if (battery != null)
                _infoChip(
                  icon: batteryLow == true
                      ? Icons.battery_alert
                      : Icons.battery_full,
                  label: '${battery.toInt()}%',
                  color: battery > 20 ? Colors.green : Colors.red,
                ),
              if (linkquality != null)
                _infoChip(
                  icon: Icons.signal_cellular_alt,
                  label: '${linkquality.toInt()} lqi',
                  color: Colors.blue,
                ),
              if (waterLeak == true)
                _infoChip(
                  icon: Icons.warning_amber,
                  label: l10n.deviceCardWaterLeak,
                  color: Colors.red,
                ),
              if (occupancy == true)
                _infoChip(
                  icon: Icons.directions_walk,
                  label: l10n.deviceCardMotion,
                  color: Colors.orange,
                ),
              if (contact == true)
                _infoChip(
                  icon: Icons.door_front_door,
                  label: l10n.deviceCardContactOpen,
                  color: Colors.blue,
                ),
            ],
          ),
      ],
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}