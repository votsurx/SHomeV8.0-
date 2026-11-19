/// Экран настройки комнат при первом запуске (онбординг).
/// Позволяет создать и удалить комнаты.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/onboarding_manager.dart';
import '../../../application/state/rooms_provider.dart';
import '../../../domain/models/room.dart';
import '../../../l10n/generated/app_localizations.dart';

class RoomsSetupScreen extends ConsumerWidget {
  const RoomsSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rooms = ref.watch(roomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.roomsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.roomsCreateTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.roomsOrganizeHint, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),

            Expanded(
              child: rooms.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.meeting_room,
                      size: 56,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.roomsAddFirst,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];

                  return Card(
                    child: ListTile(
                      leading: Text(
                        room.icon ?? '🏠',
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(room.name),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          ref
                              .read(roomsProvider.notifier)
                              .deleteRoom(room.id);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _showAddRoomDialog(context, ref),
                icon: const Icon(Icons.add),
                label: Text(l10n.roomsAddButton, style: const TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 8),

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
                child: Text(l10n.onboardingFinishButton, style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Диалог добавления новой комнаты.
  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => const _AddRoomDialog(),
    );
  }
}
class _AddRoomDialog extends ConsumerStatefulWidget {
  const _AddRoomDialog();

  @override
  ConsumerState<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends ConsumerState<_AddRoomDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void _saveRoom() {
    final roomName = _controller.text.trim();
    if (roomName.isEmpty) return;

    final rooms = ref.read(roomsProvider);

    ref.read(roomsProvider.notifier).addRoom(
      Room(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: roomName,
        sortOrder: rooms.length,
      ),
    );

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.roomAddDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _saveRoom(),
        decoration: InputDecoration(
          labelText: l10n.roomNameLabel,
          hintText: l10n.roomNameHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _saveRoom,
          child: Text(l10n.add),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}