import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytuya/tinytuya.dart' hide Device;
import '../../../domain/models/device.dart';
import '../../../application/state/devices_provider.dart';

class DeviceSensorInfo extends ConsumerWidget {
  final Device device;

  const DeviceSensorInfo({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temp = device.properties['temperature'];
    final hum = device.properties['humidity'];
    final power = device.properties['power'];
    final current = device.properties['current'];
    final voltage = device.properties['voltage'];
    final sensorType = device.properties['sensorType'] as String?;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (temp != null) Text('${(temp as num).toDouble()}°C', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (hum != null) Text('${(hum as num).toDouble()}%', style: const TextStyle(fontSize: 14, color: Colors.blue)),
        if (power != null) Text('${(power as num).toDouble()} W', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (current != null) Text('${(current as num).toDouble()} mA', style: const TextStyle(fontSize: 14, color: Colors.orange)),
        if (voltage != null) Text('${(voltage as num).toDouble()} V', style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
        if (temp == null && hum == null && power == null && current == null && voltage == null)
          Text(sensorType ?? '---', style: TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _refreshSensorData(ref),
          child: const Icon(Icons.refresh, size: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _refreshSensorData(WidgetRef ref) async {
    try {
      final outlet = OutletDevice(deviceId: device.deviceId ?? '', address: device.address ?? '', localKey: device.localKey ?? '', version: device.version ?? 3.3);
      final result = await outlet.status();
      if (result['dps'] != null) {
        final dps = result['dps'] as Map<String, dynamic>;
        final sensorDps = device.properties['sensorDps'] ?? device.dpsIndex ?? 21;
        final divider = device.properties['sensorDivider'] ?? 10;
        final rawValue = dps[sensorDps] ?? dps[sensorDps.toString()];
        if (rawValue != null) {
          final value = (rawValue as num).toDouble() / divider;
          final sensorType = device.properties['sensorType'] as String?;
          ref.read(devicesProvider.notifier).updateDevice(device.copyWith(properties: {...device.properties, if (sensorType == 'temperature') 'temperature': value, if (sensorType == 'humidity') 'humidity': value, if (sensorType == 'power') 'power': value}));
        }
      }
    } catch (_) {}
  }
}