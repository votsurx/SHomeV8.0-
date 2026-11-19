/// Экран управления камерами Frigate.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/state/devices_provider.dart';
import '../../application/state/frigate_provider.dart';
import '../../application/state/rooms_provider.dart';
import '../../data/services/frigate_service.dart';
import '../../di/injection.dart';
import '../../domain/models/device.dart';
import '../../domain/models/frigate_models.dart';
import '../../l10n/generated/app_localizations.dart';
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

  String _getRoomDisplay(String roomId, AppLocalizations l10n) {
    final rooms = ref.read(roomsProvider);
    final room = rooms.where((item) => item.id == roomId).firstOrNull;

    if (room != null) {
      return '${room.icon ?? "🏠"} ${room.name}';
    }

    switch (roomId) {
      case 'other':
        return l10n.frigateRoomOther;
      case 'living':
        return l10n.frigateRoomLiving;
      case 'bedroom':
        return l10n.frigateRoomBedroom;
      case 'kitchen':
        return l10n.frigateRoomKitchen;
      default:
        return roomId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(frigateStatsProvider);
    final cameras = ref.watch(frigateCamerasProvider);
    final devices = ref.watch(devicesProvider);

    // Подписываемся, чтобы обновить названия комнат при их изменении.
    ref.watch(roomsProvider);

    final frigateDevices = devices
        .where((device) => device.properties['source'] == 'frigate')
        .toList();

    final addedNames = frigateDevices
        .map((device) => device.properties['camera_name'] as String?)
        .whereType<String>()
        .toSet();

    final availableCameras =
    cameras.where((camera) => !addedNames.contains(camera.name)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frigate NVR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.frigateSettingsTooltip,
            onPressed: () => context.push('/frigate_settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.frigateRefreshTooltip,
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (stats != null) _buildStatsCard(stats, l10n),
            const SizedBox(height: 16),

            if (frigateDevices.isNotEmpty) ...[
              Text(
                l10n.frigateSHomeCameras,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...frigateDevices.map(
                    (device) => _buildDeviceCard(device, l10n),
              ),
              const SizedBox(height: 24),
            ],

            if (availableCameras.isNotEmpty) ...[
              Text(
                l10n.frigateAvailableCameras,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...availableCameras.map(
                    (camera) => _buildAvailableCameraCard(camera, l10n),
              ),
            ] else if (frigateDevices.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.frigateNoCameras,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.frigateAllCamerasAdded,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
      FrigateStats stats,
      AppLocalizations l10n,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.frigateStatistics,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(
                  l10n.frigateStatCameras,
                  '${stats.camerasOnline}/${stats.camerasTotal}',
                ),
                _statItem(
                  l10n.frigateStatDetectors,
                  '${stats.detectorsOnline}/${stats.detectorsTotal}',
                ),
                _statItem(
                  l10n.frigateStatCpu,
                  '${stats.cpuUsage.toStringAsFixed(1)}%',
                ),
                _statItem(
                  l10n.frigateStatRam,
                  '${stats.memoryUsage.toStringAsFixed(0)} MB',
                ),
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(
      Device device,
      AppLocalizations l10n,
      ) {
    final roomDisplay = _getRoomDisplay(device.roomId, l10n);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.videocam, color: Colors.green),
        title: Text(device.name),
        subtitle: Text(l10n.frigateRoomPrefix(roomDisplay)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: l10n.frigateCameraSettingsTooltip,
              onPressed: () => _showCameraSettings(device),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: l10n.frigateRemoveFromSHomeTooltip,
              onPressed: () => _removeDevice(device),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCameraCard(
      FrigateCamera camera,
      AppLocalizations l10n,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.videocam_off, color: Colors.grey),
        title: Text(camera.name),
        subtitle: Text('${camera.width}x${camera.height} • ${camera.fps} fps'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          tooltip: l10n.frigateAddToSHomeTooltip,
          onPressed: () => _addCamera(camera),
        ),
      ),
    );
  }

  Future<void> _addCamera(FrigateCamera camera) async {
    final l10n = AppLocalizations.of(context);
    final devices = ref.read(devicesProvider);

    final alreadyExists = devices.any(
          (device) =>
      device.properties['source'] == 'frigate' &&
          device.properties['camera_name'] == camera.name,
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.frigateCameraAlreadyAdded(camera.name)),
        ),
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
        content: Text(l10n.frigateCameraAdded(camera.name)),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _removeDevice(Device device) async {
    final l10n = AppLocalizations.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.frigateDeleteCameraTitle),
        content: Text(l10n.frigateDeleteCameraMessage(device.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.frigateCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.frigateDelete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(devicesProvider.notifier).removeDevice(device.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.frigateCameraRemoved(device.name)),
      ),
    );
  }

  void _showCameraSettings(Device device) {
    FrigateCameraSettings.show(context, ref, device);
  }
}