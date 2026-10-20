import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../di/injection.dart';
import '../../data/services/frigate_service.dart';

class FrigateCameraCard extends ConsumerStatefulWidget {
  final Device device;

  const FrigateCameraCard({required this.device, super.key});

  @override
  ConsumerState<FrigateCameraCard> createState() => _FrigateCameraCardState();
}

class _FrigateCameraCardState extends ConsumerState<FrigateCameraCard> {
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final interval = widget.device.properties['snapshot_interval'] as int? ?? 5;
    _timer = Timer.periodic(Duration(seconds: interval), (_) {
      if (mounted) setState(() => _tick++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = getIt<FrigateService>();
    final cameraName = widget.device.properties['camera_name'] as String? ?? widget.device.name;
    final isDetecting = widget.device.properties['isDetecting'] as bool? ?? false;
    final snapshotUrl = 'http://${service.host}:${service.port}/api/$cameraName/latest.jpg?t=$_tick';

    return Card(
      elevation: isDetecting ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDetecting
            ? const BorderSide(color: Colors.red, width: 3)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          // Снапшот
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              snapshotUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.videocam_off, size: 48, color: Colors.grey),
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          // Оверлей
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.device.isOnline ? Icons.circle : Icons.circle_outlined,
                    size: 12,
                    color: widget.device.isOnline ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.device.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 20),
                    onPressed: () {
                      // TODO: открыть FrigateCameraSettingsScreen (bottom sheet)
                    },
                  ),
                ],
              ),
            ),
          ),
          // Красная подсветка при детекции
          if (isDetecting)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}