import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/state/frigate_provider.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';   // ← НОВЫЙ ИМПОРТ
import '../../domain/models/device.dart';
import '../../domain/models/frigate_models.dart';
import '../../di/injection.dart';
import '../../data/services/frigate_service.dart';
import '../widgets/frigate_camera_settings.dart';

class FrigateScreen extends ConsumerStatefulWidget {
  const FrigateScreen({super.key});

  @override
  ConsumerState<FrigateScreen> createState() => _FrigateScreenState();
}

class _FrigateScreenState extends ConsumerState<FrigateScreen> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await ref.read(frigateCamerasProvider.notifier).refresh();
    final stats = await getIt<FrigateService>().getStats();
    ref.read(frigateStatsProvider.notifier).state = stats;
  }

  /// Получить имя комнаты по ID
  String _getRoomDisplay(String roomId) {
    final rooms = ref.read(roomsProvider);
    final room = rooms.where((r) => r.id == roomId).firstOrNull;
    if (room != null) {
      return '${room.icon ?? "🏠"} ${room.name}';
    }
    // Fallback
    if (roomId == 'other') return '🔌 Техника';
    if (roomId == 'living') return '🛋️ Гостиная';
    if (roomId == 'bedroom') return '🛏️ Спальня';
    if (roomId == 'kitchen') return '🍳 Кухня';
    return roomId;
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(frigateStatsProvider);
    final cameras = ref.watch(frigateCamerasProvider);
    final devices = ref.watch(devicesProvider);

    // ВАЖНО: подписываемся на roomsProvider, чтобы обновлять при изменении
    ref.watch(roomsProvider);

    final frigateDevices = devices
        .where((d) => d.properties['source'] == 'frigate')
        .toList();

    final addedNames = frigateDevices
        .map((d) => d.properties['camera_name'] as String?)
        .whereType<String>()
        .toSet();

    final availableCameras = cameras
        .where((c) => !addedNames.contains(c.name))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frigate NVR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки Frigate',
            onPressed: () => context.push('/frigate_settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (stats != null) _buildStatsCard(stats),
            const SizedBox(height: 16),

            if (frigateDevices.isNotEmpty) ...[
              const Text(
                '🎥 Камеры в SHome',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...frigateDevices.map((d) => _buildDeviceCard(d)),
              const SizedBox(height: 24),
            ],

            if (availableCameras.isNotEmpty) ...[
              const Text(
                '📍 Доступные в Frigate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...availableCameras.map((c) => _buildAvailableCameraCard(c)),
            ] else if (frigateDevices.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Нет доступных камер.\nПроверьте настройки Frigate.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '✅ Все камеры добавлены',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(FrigateStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Статистика',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Камеры', '${stats.camerasOnline}/${stats.camerasTotal}'),
                _statItem('Детекторы', '${stats.detectorsOnline}/${stats.detectorsTotal}'),
                _statItem('CPU', '${stats.cpuUsage.toStringAsFixed(1)}%'),
                _statItem('RAM', '${stats.memoryUsage.toStringAsFixed(0)} MB'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  /// Карточка добавленной камеры (в SHome)
  Widget _buildDeviceCard(Device device) {
    final roomDisplay = _getRoomDisplay(device.roomId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.videocam, color: Colors.green),
        title: Text(device.name),
        subtitle: Text('Комната: $roomDisplay'),  // ← имя вместо ID
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Настройки',
              onPressed: () => _showCameraSettings(device),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Удалить из SHome',
              onPressed: () => _removeDevice(device),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCameraCard(FrigateCamera camera) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.videocam_off, color: Colors.grey),
        title: Text(camera.name),
        subtitle: Text('${camera.width}x${camera.height} • ${camera.fps} fps'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          tooltip: 'Добавить в SHome',
          onPressed: () => _addCamera(camera),
        ),
      ),
    );
  }

  Future<void> _addCamera(FrigateCamera camera) async {
    final devices = ref.read(devicesProvider);
    final alreadyExists = devices.any((d) =>
    d.properties['source'] == 'frigate' &&
        d.properties['camera_name'] == camera.name);

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ ${camera.name} уже добавлена')),
      );
      return;
    }

    final device = Device(
      id: 'frigate_${camera.name}',
      name: camera.name,
      type: DeviceType.camera,
      roomId: 'other',
      isOnline: true,
      state: DeviceState.online,
      deviceId: camera.name,
      properties: {
        'source': 'frigate',
        'camera_name': camera.name,
        'frigate_host': getIt<FrigateService>().host,
        'frigate_port': getIt<FrigateService>().port,
        'rtsp_port': 8554,
        'snapshot_interval': 5,
        'notify_labels': ['person', 'car'],
        'isDetecting': false,
      },
    );

    await ref.read(devicesProvider.notifier).addDevice(device);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${camera.name} добавлена'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _removeDevice(Device device) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить камеру?'),
        content: Text('${device.name} будет удалена из SHome.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(devicesProvider.notifier).removeDevice(device.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🗑️ ${device.name} удалена')),
      );
    }
  }

  void _showCameraSettings(Device device) {
    FrigateCameraSettings.show(context, ref, device);
  }
}