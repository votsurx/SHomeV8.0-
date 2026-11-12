import 'package:flutter/material.dart';
import '../../../domain/models/device.dart';

class DeviceCurtainInfo extends StatelessWidget {
  final Device device;
  const DeviceCurtainInfo({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final pos = device.properties['position'] as int? ?? 100;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$pos%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(pos == 0 ? 'Закрыто' : pos == 100 ? 'Открыто' : '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}