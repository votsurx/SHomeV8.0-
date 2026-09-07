import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/device.dart';
import '../../../application/state/devices_provider.dart';

class DeviceMultiSwitch extends ConsumerWidget {
  final Device device;

  const DeviceMultiSwitch({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channels = device.properties['channels'] as int?
        ?? (device.type == DeviceType.switch3 ? 3
            : device.type == DeviceType.switch2 ? 2
            : 1);
    final states = List<bool>.from(device.properties['states'] ?? List.filled(channels, false));
    final isThreeChannel = channels == 3;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(isThreeChannel ? 2 : channels, (i) {
            return Expanded(
              child: _ChannelButton(device: device, channel: i + 1, isOn: i < states.length ? states[i] : false, showLabel: channels > 1),
            );
          }),
        ),
        if (isThreeChannel) ...[
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _ChannelButton(device: device, channel: 3, isOn: states.length > 2 ? states[2] : false, showLabel: true),
          ]),
        ],
      ],
    );
  }
}

class _ChannelButton extends ConsumerWidget {
  final Device device;
  final int channel;
  final bool isOn;
  final bool showLabel;

  const _ChannelButton({required this.device, required this.channel, required this.isOn, required this.showLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = device.state != DeviceState.offline && device.state != DeviceState.offline;

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
            ref.read(devicesProvider.notifier).setSwitchChannel(device.id, channel, !isOn);
          },
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.power_settings_new, size: 24, color: isOn ? Colors.green : Colors.grey),
          ),
        ),
        if (showLabel)
          Padding(padding: const EdgeInsets.only(top: 2), child: Text('Кан.$channel', style: TextStyle(fontSize: 9, color: Colors.grey[600]))),
      ],
    );
  }
}