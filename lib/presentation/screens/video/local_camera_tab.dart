import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../domain/models/device.dart';
import '../../../application/state/devices_provider.dart';

class LocalCameraTab extends ConsumerStatefulWidget {
  const LocalCameraTab({super.key});

  @override
  ConsumerState<LocalCameraTab> createState() => _LocalCameraTabState();
}

class _LocalCameraTabState extends ConsumerState<LocalCameraTab> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _lensIndex = 0;
  bool _isReady = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _checkWidgetExists();
    _initCamera();
  }

  void _checkWidgetExists() {
    final devices = ref.read(devicesProvider);
    final hasCamera = devices.any((d) => d.type == DeviceType.camera && d.properties['cameraType'] == 'device');
    _isActive = hasCamera;
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;
      if (_lensIndex >= _cameras!.length) _lensIndex = 0;

      _controller = CameraController(_cameras![_lensIndex], ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isReady = true);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    _lensIndex = _lensIndex == 0 ? 1 : 0;
    await _controller?.dispose();
    _isReady = false;
    setState(() {});
    await _initCamera();
  }

  void _toggleWidget() {
    final devices = ref.read(devicesProvider);
    final existingCamera = devices.where((d) => d.type == DeviceType.camera && d.properties['cameraType'] == 'device').firstOrNull;

    if (existingCamera != null) {
      ref.read(devicesProvider.notifier).removeDevice(existingCamera.id);
      setState(() => _isActive = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Виджет камеры удалён с главного экрана')));
    } else {
      ref.read(devicesProvider.notifier).addDevice(Device(
        id: 'builtin_camera',
        name: 'Камера планшета',
        type: DeviceType.camera,
        roomId: 'other',
        isOnline: true,
        state: DeviceState.online,
        properties: {'cameraType': 'device', 'cameraLens': _lensIndex, 'resolution': 'high'},
      ));
      setState(() => _isActive = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Виджет камеры создан на главном экране')));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Статус
        Card(
          child: ListTile(
            leading: Icon(_isActive ? Icons.check_circle : Icons.radio_button_unchecked, color: _isActive ? Colors.green : Colors.grey),
            title: const Text('Виджет на главном экране'),
            subtitle: Text(_isActive ? 'Активен' : 'Неактивен'),
          ),
        ),

        const SizedBox(height: 8),

        // Кнопка создать/удалить виджет
        Card(
          child: ListTile(
            leading: Icon(_isActive ? Icons.delete : Icons.add, color: _isActive ? Colors.red : Colors.blue),
            title: Text(_isActive ? 'Удалить виджет' : 'Создать виджет'),
            subtitle: const Text('На главном экране'),
            onTap: _toggleWidget,
          ),
        ),

        const SizedBox(height: 16),

        // Превью камеры
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: _isReady && _controller != null
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller!),
                    if (_cameras != null && _cameras!.length > 1)
                      Positioned(
                        bottom: 12, right: 12,
                        child: FloatingActionButton.small(
                          onPressed: _switchCamera,
                          child: const Icon(Icons.flip_camera_android),
                        ),
                      ),
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                        child: Text(_lensIndex == 0 ? '📷 Тыловая' : '🤳 Фронтальная', style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}