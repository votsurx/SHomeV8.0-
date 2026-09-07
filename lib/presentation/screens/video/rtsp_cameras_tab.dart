import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/device.dart';
import '../../../application/state/devices_provider.dart';

class RtspCamerasTab extends ConsumerStatefulWidget {
  const RtspCamerasTab({super.key});

  @override
  ConsumerState<RtspCamerasTab> createState() => _RtspCamerasTabState();
}

class _RtspCamerasTabState extends ConsumerState<RtspCamerasTab> {
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  List<Device> get _rtspCameras => ref.watch(devicesProvider).where((d) => d.type == DeviceType.camera && d.properties['cameraType'] == 'rtsp').toList();

  void _addCamera() {
    final url = _urlController.text.trim();
    final name = _nameController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите RTSP URL')));
      return;
    }

    ref.read(devicesProvider.notifier).addDevice(Device(
      id: 'rtsp_${DateTime.now().millisecondsSinceEpoch}',
      name: name.isNotEmpty ? name : 'Камера ${_rtspCameras.length + 1}',
      type: DeviceType.camera,
      roomId: 'other',
      isOnline: true,
      state: DeviceState.online,
      properties: {'cameraType': 'rtsp', 'rtspUrl': url},
    ));

    _urlController.clear();
    _nameController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Камера "$name" добавлена')));
  }

  void _editCamera(Device camera) {
    _nameController.text = camera.name;
    _urlController.text = camera.properties['rtspUrl'] as String? ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редактировать камеру'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Название')),
          const SizedBox(height: 8),
          TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'RTSP URL')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(onPressed: () {
            ref.read(devicesProvider.notifier).updateDevice(camera.copyWith(
              name: _nameController.text,
              properties: {...camera.properties, 'rtspUrl': _urlController.text},
            ));
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Камера обновлена')));
          }, child: const Text('Сохранить')),
        ],
      ),
    );
  }

  void _deleteCamera(Device camera) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить?'),
        content: Text('Удалить камеру "${camera.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(onPressed: () {
            ref.read(devicesProvider.notifier).removeDevice(camera.id);
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🗑️ Камера "${camera.name}" удалена')));
          }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Удалить')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameras = _rtspCameras;

    return Scaffold(
      body: cameras.isEmpty
          ? Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.videocam_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Нет RTSP камер', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: _showAddDialog, icon: const Icon(Icons.add), label: const Text('Добавить камеру')),
        ]),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: cameras.length,
        itemBuilder: (context, index) {
          final cam = cameras[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.videocam, color: Colors.blue),
              title: Text(cam.name),
              subtitle: Text(cam.properties['rtspUrl'] as String? ?? '', style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editCamera(cam)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCamera(cam)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: cameras.isNotEmpty
          ? FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add))
          : null,
    );
  }

  void _showAddDialog() {
    _urlController.clear();
    _nameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить RTSP камеру'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Название')),
          const SizedBox(height: 8),
          TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'RTSP URL', hintText: 'rtsp://192.168.1.xxx:554/stream')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(onPressed: _addCamera, child: const Text('Добавить')),
        ],
      ),
    );
  }
}