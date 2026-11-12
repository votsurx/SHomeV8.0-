/// Горизонтальный селектор комнат с чипсами.
/// Используется в DeviceListScreen для фильтрации устройств по комнатам.
/// Первый чип "Все" показывает все устройства.
/// Кнопка "+" позволяет быстро добавить новую комнату.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/room.dart';
import '../../application/state/rooms_provider.dart';

class RoomSelector extends ConsumerWidget {
  /// ID выбранной комнаты (для подсветки чипса)
  final String? selectedRoomId;
  /// Колбэк при выборе комнаты
  final Function(Room) onRoomSelected;

  const RoomSelector({
    super.key,
    this.selectedRoomId,
    required this.onRoomSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Чип "Все" — показывает все устройства
          _buildRoomChip(context, Room(id: 'all', name: 'Все', icon: '🏠'), selectedRoomId == 'all'),
          // Чипсы для каждой комнаты из БД
          ...rooms.map((room) => _buildRoomChip(context, room, selectedRoomId == room.id)),
          // Кнопка быстрого добавления комнаты
          IconButton(
            onPressed: () => _showAddRoomDialog(context, ref),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Добавить комнату',
          ),
        ],
      ),
    );
  }

  /// Строит один чип комнаты.
  /// isSelected — подсвечивает выбранную комнату цветом primaryContainer.
  Widget _buildRoomChip(BuildContext context, Room room, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text('${room.icon ?? '🏠'} ${room.name}'),
        onSelected: (_) => onRoomSelected(room),
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  /// Диалог быстрого добавления комнаты (без перехода на экран комнат).
  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить комнату'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Название комнаты', hintText: 'Гостиная'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final room = Room(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: controller.text,
                  sortOrder: ref.read(roomsProvider).length,
                );
                ref.read(roomsProvider.notifier).addRoom(room);
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