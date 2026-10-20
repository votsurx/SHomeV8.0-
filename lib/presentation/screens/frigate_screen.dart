import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/state/frigate_provider.dart';
import '../../application/state/devices_provider.dart';
import '../../domain/models/device.dart';
import '../../domain/models/frigate_models.dart';
import '../../di/injection.dart';
import '../../data/services/frigate_service.dart';

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

  Future<void> _showAddCameraDialog() async {
    final allCameras = ref.read(frigateCamerasProvider);
    final existingDevices = ref.read(devicesProvider);
    final existingNames = existingDevices
        .where((d) => d.properties['source'] == 'frigate')
        .map((d) => d.properties['camera_name'] as String?)
        .whereType<String>()
        .toSet();

    final available = allCameras
        .where((c) => !existingNames.contains(c.name))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Все камеры уже добавлены')),
      );
      return;
    }

    final selected = await showDialog<FrigateCamera>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Добавить камеру'),
        children: available.map((cam) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, cam),
            child: ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: Text(cam.name),
              subtitle: Text('${cam.width}x${cam.height} • ${cam.fps} fps'),
            ),
          );
        }).toList(),
      ),
    );

    if (selected == null) return;

    final device = Device(
      id: 'frigate_${selected.name}',
      name: selected.name,
      type: DeviceType.camera,
      roomId: 'other',
      isOnline: true,
      state: DeviceState.online,
      deviceId: selected.name,
      properties: {
        'source': 'frigate',
        'camera_name': selected.name,
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
      SnackBar(content: Text('✅ ${selected.name} добавлена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(frigateStatsProvider);
    final cameras = ref.watch(frigateCamerasProvider);
    final devices = ref.watch(devicesProvider);
    final frigateDevices = devices
        .where((d) => d.properties['source'] == 'frigate')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frigate NVR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/frigate_settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Статистика
          if (stats != null) _buildStatsCard(stats),
          const SizedBox(height: 16),

          // Кнопка «Добавить камеру»
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddCameraDialog,
              icon: const Icon(Icons.add),
              label: const Text('Добавить камеру'),
            ),
          ),
          const SizedBox(height: 16),

          // Камеры в SHome
          if (frigateDevices.isNotEmpty) ...[
            const Text(
              'Камеры в SHome',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...frigateDevices.map((d) => _buildDeviceCard(d)),
            const SizedBox(height: 16),
          ],

          // Камеры в Frigate (но не в SHome)
          if (cameras.isNotEmpty) ...[
            const Text(
              'Камеры в Frigate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...cameras.map((c) => _buildCameraCard(c)),
          ],
        ],
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
              'Статистика',
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

  Widget _buildDeviceCard(Device device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.videocam, color: Colors.red),
        title: Text(device.name),
        subtitle: Text('Комната: ${device.roomId}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showCameraSettings(device),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeDevice(device),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraCard(FrigateCamera camera) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.videocam_off, color: Colors.grey),
        title: Text(camera.name),
        subtitle: Text('${camera.width}x${camera.height} • ${camera.fps} fps'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          onPressed: () => _addCameraFromFrigate(camera),
        ),
      ),
    );
  }

  Future<void> _addCameraFromFrigate(FrigateCamera camera) async {
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
    setState(() {});
  }

  Future<void> _removeDevice(Device device) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить камеру?'),
        content: Text('${device.name} будет удалена из SHome, но останется в Frigate.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(devicesProvider.notifier).removeDevice(device.id);
      if (!mounted) return;
      setState(() {});
    }
  }

  void _showCameraSettings(Device device) {
    // TODO: открыть FrigateCameraSettingsScreen (bottom sheet)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TODO: настройки камеры')),
    );
  }
}