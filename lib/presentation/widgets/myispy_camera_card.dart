/// Виджет карточки камеры MyiSpy с RTSP плеером (VLC) — самостоятельная карточка
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';
import 'package:video_player/video_player.dart';

class MyiSpyCameraCard extends ConsumerStatefulWidget {
  final Device device;

  const MyiSpyCameraCard({
    super.key,
    required this.device,
  });

  @override
  ConsumerState<MyiSpyCameraCard> createState() => _MyiSpyCameraCardState();
}

class _MyiSpyCameraCardState extends ConsumerState<MyiSpyCameraCard> {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  bool _hasVideoError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initVideo() {
    final rtspUrl = widget.device.properties['rtspUrl'] as String?;
    if (rtspUrl == null || rtspUrl.isEmpty) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(rtspUrl));
    _videoController!.initialize().then((_) {
      if (mounted) {
        setState(() => _isVideoReady = true);
        _videoController!.play();
      }
    }).catchError((_) {
      if (mounted) setState(() => _hasVideoError = true);
    });
  }

  // ============================================================
  // 🎨 BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final currentDevice = devices.firstWhere(
          (d) => d.id == widget.device.id,
      orElse: () => widget.device,
    );

    final isOnline = currentDevice.isOnline;
    print('🔵🔵🔵 MyiSpyCameraCard: ${currentDevice.name} isOnline=$isOnline');
    final lastDetection = currentDevice.properties['lastDetection'] as String?;
    final lastDetectionTime = currentDevice.properties['lastDetectionTime'] as String?;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // ============================================================
          // ЗАГОЛОВОК
          // ============================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Индикатор онлайн
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                // Имя камеры
                Expanded(
                  child: Text(
                    currentDevice.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Шестерёнка (настройки комнаты)
                GestureDetector(
                  onTap: () => _showCameraSettings(context, ref, currentDevice),
                  child: const Icon(Icons.settings, size: 18, color: Colors.grey),
                ),
              ],
            ),
          ),

          // ============================================================
          // RTSP ВИДЕО (VLC)
          // ============================================================
          Expanded(
            child: _buildVideoPreview(),
          ),

          // ============================================================
          // AI ДЕТЕКЦИЯ
          // ============================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                if (lastDetection != null)
                  Text('🧠 $lastDetection', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                if (lastDetectionTime != null)
                  Text(' 🕐 ${lastDetectionTime.substring(11, 19)}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                if (lastDetection == null)
                  Text('Нет обнаружений', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_hasVideoError || _videoController == null) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Нет видеопотока', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (!_isVideoReady) {
      return Container(
        color: Colors.grey[900],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: Container(
        color: Colors.black,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    if (_videoController == null || !_isVideoReady) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              widget.device.name,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
      ),
    ).then((_) {
      // Возвращаемся из полноэкранного режима — продолжаем играть
      _videoController?.play();
    });
  }

  // ============================================================
  // ⚙️ НАСТРОЙКИ КОМНАТЫ
  // ============================================================

  void _showCameraSettings(BuildContext context, WidgetRef ref, Device device) {
    final rooms = ref.watch(roomsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String selectedRoomId = device.roomId;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(device.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRoomId,
                    decoration: const InputDecoration(
                      labelText: 'Комната',
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('🏠 Все')),
                      ...rooms.map((r) => DropdownMenuItem(value: r.id, child: Text('${r.icon ?? "🏠"} ${r.name}'))),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedRoomId = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final updated = device.copyWith(roomId: selectedRoomId);
                            ref.read(devicesProvider.notifier).updateDevice(updated);
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Сохранить'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: ctx,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Удалить камеру?'),
                                content: Text('Удалить "${device.name}" из SHome?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Отмена')),
                                  ElevatedButton(
                                    onPressed: () {
                                      ref.read(devicesProvider.notifier).removeDevice(device.id);
                                      Navigator.pop(dCtx);
                                      Navigator.pop(ctx);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    child: const Text('Удалить'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Удалить'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('📷 Название и настройки камеры управляются в MyiSpy',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}