import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/device.dart';
import '../../../application/state/devices_provider.dart';

class DevicePowerButton extends ConsumerWidget {
  final Device device;
  final String? label;

  const DevicePowerButton({super.key, required this.device, this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = device.state != DeviceState.offline && device.state != DeviceState.offline;
    final isOn = device.properties['isOn'] == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (!isOnline) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Устройство offline'), duration: Duration(seconds: 1)),
              );
              return;
            }
            if (isOn) {
              ref.read(devicesProvider.notifier).turnOff(device.id);
            } else {
              ref.read(devicesProvider.notifier).turnOn(device.id);
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.power_settings_new, size: 28, color: isOn ? Colors.green : Colors.grey),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(label!, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ],
    );
  }
}