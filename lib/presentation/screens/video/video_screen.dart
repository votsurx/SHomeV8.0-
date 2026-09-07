/// Экран видеонаблюдения — Legion NVR + локальная камера.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/state/devices_provider.dart';
import '../../../domain/models/device.dart';
import '../../widgets/device_card.dart';
import '../../widgets/myispy_camera_card.dart';

class VideoScreen extends ConsumerWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider);
    final cameras = devices.where((d) => d.type == DeviceType.camera).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📹 Видеонаблюдение'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Открыть Legion NVR',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Открыть http://192.168.1.100:8080')),
              );
            },
          ),
        ],
      ),
      body: cameras.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Нет камер', style: TextStyle(color: Colors.grey, fontSize: 18)),
                  SizedBox(height: 8),
                  Text(
                    'Добавьте камеру в Legion NVR\nс типом "mjpeg" и укажите ссылку',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: cameras.length,
        itemBuilder: (context, index) {
          final camera = cameras[index];
          final cameraType = camera.properties['cameraType'] as String? ?? '';

          if (cameraType == 'ispy') {
            return MyiSpyCameraCard(device: camera);  // Самостоятельная карточка!
          }
          return DeviceCard(device: camera);
        },
            ),
    );
  }
}