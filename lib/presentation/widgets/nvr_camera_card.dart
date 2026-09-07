/// Виджет карточки NVR-камеры для главного экрана
library;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/nvr_provider.dart';
import '../../application/state/rooms_provider.dart';
import '../../data/services/mjpeg_stream_service.dart';
import '../../data/services/nvr_api_client.dart';
import 'fullscreen_camera_screen.dart';

class NvrCameraCard extends ConsumerStatefulWidget {
  final Device device;

  const NvrCameraCard({
    super.key,
    required this.device,
  });

  @override
  ConsumerState<NvrCameraCard> createState() => _NvrCameraCardState();
}

class _NvrCameraCardState extends ConsumerState<NvrCameraCard> {
  MjpegStreamService? _mjpegService;
  Stream<Uint8List>? _stream;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isUpdating = false;
  late final int _nvrId;
  bool _streamStarted = false;

  @override
  void initState() {
    super.initState();
    _nvrId = widget.device.properties['nvrId'] as int? ?? 0;
    _startStream();
  }

  @override
  void dispose() {
    _mjpegService?.dispose();
    _mjpegService = null;
    _stream = null;
    _streamStarted = false;
    super.dispose();
  }

  void _startStream() {
    if (_streamStarted) return;

    final mjpegUrl = widget.device.properties['mjpegUrl'] as String?;
    if (mjpegUrl == null || mjpegUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    _mjpegService = MjpegStreamService();
    _stream = _mjpegService!.subscribe(mjpegUrl);
    _streamStarted = true;

    _stream?.listen(
          (_) {
        if (_isLoading) {
          setState(() => _isLoading = false);
        }
      },
      onError: (_) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 🔧 ДЕЙСТВИЯ
  // ════════════════════════════════════════════════════════════════

  Future<void> _toggleCamera() async {
    if (_isUpdating) return;

    await Future.delayed(const Duration(milliseconds: 500));

    final devices = ref.read(devicesProvider);
    final currentDevice = devices.firstWhere(
          (d) => d.id == widget.device.id,
      orElse: () => widget.device,
    );

    final settings = ref.read(nvrSettingsProvider);
    if (settings.host.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ NVR не настроен, сохраните IP в настройках')),
        );
      }
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final client = NvrApiClient(
        host: settings.host,
        port: settings.port,
      );

      final currentEnabled = currentDevice.properties['enabled'] == true;
      final newEnabled = !currentEnabled;

      await client.updateCamera(_nvrId, {'enabled': newEnabled ? 1 : 0});
      await client.applyCamera(_nvrId);

      final updated = currentDevice.copyWith(
        properties: {
          ...currentDevice.properties,
          'enabled': newEnabled,
        },
        isOnline: newEnabled,
        state: newEnabled ? DeviceState.online : DeviceState.offline,
      );
      ref.read(devicesProvider.notifier).updateDevice(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newEnabled ? '✅ Камера включена' : '🔴 Камера выключена'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isUpdating) return;

    await Future.delayed(const Duration(milliseconds: 500));

    final devices = ref.read(devicesProvider);
    final currentDevice = devices.firstWhere(
          (d) => d.id == widget.device.id,
      orElse: () => widget.device,
    );

    final settings = ref.read(nvrSettingsProvider);
    if (settings.host.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ NVR не настроен, сохраните IP в настройках')),
        );
      }
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final client = NvrApiClient(
        host: settings.host,
        port: settings.port,
      );

      final current = currentDevice.properties['recordEnabled'] == true;
      final newState = !current;

      await client.updateCamera(_nvrId, {'record_enabled': newState ? 1 : 0});
      await client.applyCamera(_nvrId);

      final updated = currentDevice.copyWith(
        properties: {
          ...currentDevice.properties,
          'recordEnabled': newState,
        },
      );
      ref.read(devicesProvider.notifier).updateDevice(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newState ? '📼 Запись включена' : '⏹️ Запись выключена'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _toggleMotion() async {
    if (_isUpdating) return;

    await Future.delayed(const Duration(milliseconds: 500));

    final devices = ref.read(devicesProvider);
    final currentDevice = devices.firstWhere(
          (d) => d.id == widget.device.id,
      orElse: () => widget.device,
    );

    final settings = ref.read(nvrSettingsProvider);
    if (settings.host.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ NVR не настроен, сохраните IP в настройках')),
        );
      }
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final client = NvrApiClient(
        host: settings.host,
        port: settings.port,
      );

      final current = currentDevice.properties['motionEnabled'] == true;
      final newState = !current;

      await client.updateCamera(_nvrId, {'motion_enabled': newState ? 1 : 0});
      await client.applyCamera(_nvrId);

      final updated = currentDevice.copyWith(
        properties: {
          ...currentDevice.properties,
          'motionEnabled': newState,
        },
      );
      ref.read(devicesProvider.notifier).updateDevice(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newState ? '🔍 Детектор включен' : '🔍 Детектор выключен'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _openFullscreen(BuildContext context, Device device) {
    final mjpegUrl = device.properties['mjpegUrl'] as String?;
    if (mjpegUrl == null || mjpegUrl.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullscreenCameraScreen(
          device: device,
          mjpegUrl: mjpegUrl,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 🎨 BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final currentDevice = devices.firstWhere(
          (d) => d.id == widget.device.id,
      orElse: () => widget.device,
    );

    final isEnabled = currentDevice.properties['enabled'] == true;
    final isRecording = currentDevice.properties['recordEnabled'] == true;
    final isMotionEnabled = currentDevice.properties['motionEnabled'] == true;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // ============================================================
          // ЗАГОЛОВОК
          // ============================================================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.videocam,
                  size: 20,
                  color: isEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentDevice.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, size: 18),
                  onPressed: () => _showCameraSettings(context, ref, currentDevice),
                ),
              ],
            ),
          ),

          // ============================================================
          // ВИДЕО
          // ============================================================
          Expanded(
            child: _buildVideoPreview(currentDevice),
          ),

          // ============================================================
          // КНОПКИ УПРАВЛЕНИЯ
          // ============================================================
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.power_settings_new,
                  label: isEnabled ? 'ON' : 'OFF',
                  color: isEnabled ? Colors.green : Colors.grey,
                  onTap: _toggleCamera,
                ),
                const SizedBox(width: 12),
                _buildControlButton(
                  icon: Icons.fiber_manual_record,
                  label: 'REC',
                  color: isRecording ? Colors.red : Colors.grey,
                  onTap: _toggleRecording,
                ),
                const SizedBox(width: 12),
                _buildControlButton(
                  icon: Icons.motion_photos_on,
                  label: 'MOTION',
                  color: isMotionEnabled ? Colors.orange : Colors.grey,
                  onTap: _toggleMotion,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(Device device) {
    final isEnabled = device.properties['enabled'] == true;

    if (!isEnabled) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.power_off, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text('Отключено', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _stream == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Нет сигнала', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openFullscreen(context, device),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: StreamBuilder<Uint8List>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image(
                image: MemoryImage(snapshot.data!),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) {
                  return const Center(child: Icon(Icons.error, color: Colors.grey));
                },
              );
            }

            if (snapshot.hasError) {
              return const Center(child: Icon(Icons.error_outline, color: Colors.red));
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    double buttonSize;
    double iconSize;
    double fontSize;

    if (isTablet) {
      buttonSize = 40;
      iconSize = 20;
      fontSize = 9;
    } else if (isPortrait) {
      buttonSize = 28;
      iconSize = 14;
      fontSize = 7;
    } else {
      buttonSize = 34;
      iconSize = 17;
      fontSize = 8;
    }

    return GestureDetector(
      onTap: _isUpdating ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: _isUpdating
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(icon, color: color, size: iconSize),
          ),
          Text(
            label,
            style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

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
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedRoomId,
                    decoration: const InputDecoration(
                      labelText: 'Комната',
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('🏠 Все'),
                      ),
                      ...rooms.map((r) => DropdownMenuItem(
                        value: r.id,
                        child: Text('${r.icon ?? "🏠"} ${r.name}'),
                      )),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() {
                          selectedRoomId = v;
                        });
                      }
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
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
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: const Text('Отмена'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      ref.read(devicesProvider.notifier).removeDevice(device.id);
                                      Navigator.pop(dCtx);
                                      Navigator.pop(ctx);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Удалить'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Удалить'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
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
                    child: const Text(
                      '📷 Название камеры управляется в LegionNVR',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
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