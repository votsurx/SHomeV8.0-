/// Экран настройки комнат при первом запуске (онбординг).
/// Позволяет создать комнаты, удалить их.
/// Кнопка "Готово!" завершает онбординг и переходит на Dashboard.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/onboarding_manager.dart';
import '../../../domain/models/room.dart';
import '../../../application/state/rooms_provider.dart';

class RoomsSetupScreen extends ConsumerWidget {
  const RoomsSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Комнаты')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Создайте комнаты', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Организуйте устройства по комнатам', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            // Список комнат или заглушка
            Expanded(
              child: rooms.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.meeting_room, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('Добавьте первую комнату'),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: Text(rooms[index].icon ?? '🏠', style: const TextStyle(fontSize: 32)),
                    title: Text(rooms[index].name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => ref.read(roomsProvider.notifier).deleteRoom(rooms[index].id),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопка добавления комнаты
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _showAddRoomDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Добавить комнату', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 8),
            // Кнопка завершения онбординга
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await OnboardingManager.complete();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                child: const Text('Готово!', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Диалог добавления новой комнаты.
  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить комнату'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Название', hintText: 'Спальня'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(roomsProvider.notifier).addRoom(Room(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: controller.text,
                  sortOrder: ref.read(roomsProvider).length,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}