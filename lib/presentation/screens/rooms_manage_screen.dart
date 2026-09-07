/// Экран управления комнатами.
/// Позволяет добавлять, переименовывать и удалять комнаты.
/// При удалении комнаты с устройствами — они переносятся в "all".
/// Показывает количество устройств в каждой комнате.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/room.dart';
import '../../application/state/rooms_provider.dart';
import '../../application/state/devices_provider.dart';

class RoomsManageScreen extends ConsumerWidget {
  const RoomsManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Комнаты')),
      body: rooms.isEmpty
          ? const Center(child: Text('Нет комнат. Добавьте первую!', style: TextStyle(fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          final deviceCount = devices.where((d) => d.roomId == room.id).length;

          return Card(
            child: ListTile(
              leading: Text(room.icon ?? '🏠', style: const TextStyle(fontSize: 32)),
              title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text('Устройств: $deviceCount'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showRenameDialog(context, ref, room)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteDialog(context, ref, room, deviceCount)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoomDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Диалог добавления новой комнаты.
  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String selectedIcon = '🏠';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Добавить комнату'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Название', hintText: 'Гостиная'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedIcon,
                decoration: const InputDecoration(labelText: 'Иконка'),
                items: const [
                  DropdownMenuItem(value: '🛋️', child: Text('🛋️ Гостиная')),
                  DropdownMenuItem(value: '🛏️', child: Text('🛏️ Спальня')),
                  DropdownMenuItem(value: '🍳', child: Text('🍳 Кухня')),
                  DropdownMenuItem(value: '🚿', child: Text('🚿 Ванная')),
                  DropdownMenuItem(value: '🚗', child: Text('🚗 Гараж')),
                  DropdownMenuItem(value: '🌳', child: Text('🌳 Двор')),
                  DropdownMenuItem(value: '👶', child: Text('👶 Детская')),
                  DropdownMenuItem(value: '📦', child: Text('📦 Кладовая')),
                  DropdownMenuItem(value: '💻', child: Text('💻 Кабинет')),
                  DropdownMenuItem(value: '🏠', child: Text('🏠 Дом')),
                  DropdownMenuItem(value: '🔌', child: Text('🔌 Техника')),
                ],
                onChanged: (v) => setDialogState(() => selectedIcon = v ?? '🏠'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(roomsProvider.notifier).addRoom(Room(
                    id: const Uuid().v4(),
                    name: controller.text,
                    icon: selectedIcon,
                    sortOrder: ref.read(roomsProvider).length,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  /// Диалог переименования комнаты.
  void _showRenameDialog(BuildContext context, WidgetRef ref, Room room) {
    final controller = TextEditingController(text: room.name);
    String selectedIcon = room.icon ?? '🏠';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Редактировать'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Название'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedIcon,
                decoration: const InputDecoration(labelText: 'Иконка'),
                items: const [
                  DropdownMenuItem(value: '🛋️', child: Text('🛋️ Гостиная')),
                  DropdownMenuItem(value: '🛏️', child: Text('🛏️ Спальня')),
                  DropdownMenuItem(value: '🍳', child: Text('🍳 Кухня')),
                  DropdownMenuItem(value: '🚿', child: Text('🚿 Ванная')),
                  DropdownMenuItem(value: '🚗', child: Text('🚗 Гараж')),
                  DropdownMenuItem(value: '🌳', child: Text('🌳 Двор')),
                  DropdownMenuItem(value: '👶', child: Text('👶 Детская')),
                  DropdownMenuItem(value: '📦', child: Text('📦 Кладовая')),
                  DropdownMenuItem(value: '💻', child: Text('💻 Кабинет')),
                  DropdownMenuItem(value: '🏠', child: Text('🏠 Дом')),
                  DropdownMenuItem(value: '🔌', child: Text('🔌 Техника')),
                ],
                onChanged: (v) => setDialogState(() => selectedIcon = v ?? '🏠'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(roomsProvider.notifier).renameRoom(room.id, controller.text);
                  // Обновляем иконку через update
                  final updated = room.copyWith(name: controller.text, icon: selectedIcon);
                  ref.read(roomsProvider.notifier).updateRoom(updated);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  /// Диалог удаления комнаты с предупреждением о переносе устройств.
  void _showDeleteDialog(BuildContext context, WidgetRef ref, Room room, int deviceCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить комнату?'),
        content: Text(deviceCount > 0
            ? 'В комнате $deviceCount устройств. Они будут перенесены в «Все устройства». Продолжить?'
            : 'Удалить комнату «${room.name}»?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              // Переносим устройства в "all"
              final devices = ref.read(devicesProvider);
              for (final device in devices.where((d) => d.roomId == room.id)) {
                ref.read(devicesProvider.notifier).updateDevice(device.copyWith(roomId: 'all'));
              }
              // Удаляем комнату
              ref.read(roomsProvider.notifier).deleteRoom(room.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Комната «${room.name}» удалена')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}