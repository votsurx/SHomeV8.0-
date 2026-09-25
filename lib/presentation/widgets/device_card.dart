/// Карточка устройства — основной виджет для отображения устройства в сетке.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import 'compound_device_card.dart';
import 'device_icons.dart';
import 'device_settings.dart';
import 'device_controls/power_button.dart';
import 'device_controls/multi_switch.dart';
import 'device_controls/sensor_info.dart';
import 'device_controls/curtain_info.dart';
import 'device_controls/camera_preview.dart';


class DeviceCard extends ConsumerWidget {
  final Device device;
  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = device.state != DeviceState.offline && device.state != DeviceState.offline;

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(context, ref),
                Expanded(child: Center(child: _buildControls(ref))),
              ],
            ),
          ),
          Positioned(
            left: 8, bottom: 8,
            child: Icon(isOnline ? Icons.wifi : Icons.wifi_off, size: 16,
                color: isOnline ? Colors.green.withValues(alpha: 0.6) : Colors.red.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(children: [
      Icon(getDeviceIcon(device), size: 20, color: Colors.blue),
      const SizedBox(width: 6),
      Expanded(child: Text(device.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 2)),
      GestureDetector(onTap: () => DeviceSettings.show(context, ref, device), child: const Icon(Icons.settings, size: 18, color: Colors.grey)),
    ]);
  }

  Widget _buildControls(WidgetRef ref) {
    switch (device.type) {
      case DeviceType.outlet:
      case DeviceType.light:
        return DevicePowerButton(device: device);
      case DeviceType.switch1:
      case DeviceType.switch2:
      case DeviceType.switch3:
        return DeviceMultiSwitch(device: device);
      case DeviceType.sensor:
        return DeviceSensorInfo(device: device);
      case DeviceType.curtain:
        return DeviceCurtainInfo(device: device);
      case DeviceType.camera:
        return DeviceCameraPreview(device: device);
      case DeviceType.compound:
      case DeviceType.hvac:
        return CompoundDeviceCard(device: device);
      default:
        return DevicePowerButton(device: device);
    }
  }
}