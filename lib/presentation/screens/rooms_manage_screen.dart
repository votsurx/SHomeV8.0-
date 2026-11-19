/// Экран управления комнатами.
/// Позволяет добавлять, переименовывать и удалять комнаты.
/// При удалении комнаты устройства переносятся в раздел «Все устройства».
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';
import '../../domain/models/room.dart';
import '../../l10n/generated/app_localizations.dart';

class RoomsManageScreen extends ConsumerWidget {
  const RoomsManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rooms = ref.watch(roomsProvider);
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.roomsTitle),
      ),
      body: rooms.isEmpty
          ? Center(
        child: Text(
          l10n.roomsManageEmpty,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          final deviceCount =
              devices.where((device) => device.roomId == room.id).length;

          return Card(
            child: ListTile(
              leading: Text(
                room.icon ?? '🏠',
                style: const TextStyle(fontSize: 32),
              ),
              title: Text(
                room.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(l10n.roomsDeviceCount(deviceCount)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l10n.roomsEditDialogTitle,
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () =>
                        _showRenameDialog(context, ref, room),
                  ),
                  IconButton(
                    tooltip: l10n.roomsDeleteDialogTitle,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(
                      context,
                      ref,
                      room,
                      deviceCount,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.roomAddDialogTitle,
        onPressed: () => _showAddRoomDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _iconLabel(String icon, AppLocalizations l10n) {
    switch (icon) {
      case '🛋️':
        return l10n.roomIconLiving;
      case '🛏️':
        return l10n.roomIconBedroom;
      case '🍳':
        return l10n.roomIconKitchen;
      case '🚿':
        return l10n.roomIconBathroom;
      case '🚗':
        return l10n.roomIconGarage;
      case '🌳':
        return l10n.roomIconYard;
      case '👶':
        return l10n.roomIconKids;
      case '📦':
        return l10n.roomIconStorage;
      case '💻':
        return l10n.roomIconOffice;
      case '🏠':
        return l10n.roomIconHome;
      case '🔌':
        return l10n.roomIconAppliances;
      default:
        return icon;
    }
  }

  List<DropdownMenuItem<String>> _iconItems(AppLocalizations l10n) {
    const icons = [
      '🛋️',
      '🛏️',
      '🍳',
      '🚿',
      '🚗',
      '🌳',
      '👶',
      '📦',
      '💻',
      '🏠',
      '🔌',
    ];

    return icons
        .map(
          (icon) => DropdownMenuItem<String>(
        value: icon,
        child: Text('$icon ${_iconLabel(icon, l10n)}'),
      ),
    )
        .toList();
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    String selectedIcon = '🏠';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.roomAddDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.roomNameLabel,
                  hintText: l10n.roomNameHint,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedIcon,
                decoration: InputDecoration(
                  labelText: l10n.roomIconHome,
                ),
                items: _iconItems(l10n),
                onChanged: (value) {
                  setDialogState(() {
                    selectedIcon = value ?? '🏠';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                ref.read(roomsProvider.notifier).addRoom(
                  Room(
                    id: const Uuid().v4(),
                    name: name,
                    icon: selectedIcon,
                    sortOrder: ref.read(roomsProvider).length,
                  ),
                );

                Navigator.pop(dialogContext);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context,
      WidgetRef ref,
      Room room,
      ) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: room.name);
    String selectedIcon = room.icon ?? '🏠';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.roomsEditDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.roomNameLabel,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedIcon,
                decoration: InputDecoration(
                  labelText: l10n.roomIconHome,
                ),
                items: _iconItems(l10n),
                onChanged: (value) {
                  setDialogState(() {
                    selectedIcon = value ?? '🏠';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                ref.read(roomsProvider.notifier).renameRoom(room.id, name);

                final updatedRoom = room.copyWith(
                  name: name,
                  icon: selectedIcon,
                );
                ref
                    .read(roomsProvider.notifier)
                    .updateRoom(updatedRoom);

                Navigator.pop(dialogContext);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context,
      WidgetRef ref,
      Room room,
      int deviceCount,
      ) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.roomsDeleteDialogTitle),
        content: Text(
          deviceCount > 0
              ? l10n.roomsDeleteWithDevices(deviceCount)
              : l10n.roomsDeleteConfirmation(room.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // Переносим устройства в раздел «Все устройства».
              final devices = ref.read(devicesProvider);
              for (final device
              in devices.where((item) => item.roomId == room.id)) {
                ref.read(devicesProvider.notifier).updateDevice(
                  device.copyWith(roomId: 'all'),
                );
              }

              ref.read(roomsProvider.notifier).deleteRoom(room.id);
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.roomsDeletedMessage(room.name)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.roomsDeleteButton),
          ),
        ],
      ),
    );
  }
}