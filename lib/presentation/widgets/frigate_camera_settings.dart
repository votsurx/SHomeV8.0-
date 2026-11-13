/// Полные настройки Frigate-камеры.
/// Диалог с редактированием:
/// - Название
/// - Комната
/// - Уведомления (labels)
/// - Snapshot interval
/// - RTSP порт
/// - Удаление
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';
import '../../domain/models/device.dart';

class FrigateCameraSettings {
  /// Все возможные labels Frigate
  static const _allLabels = [
    'person',
    'car',
    'dog',
    'cat',
    'bird',
    'motorcycle',
    'bicycle',
    'truck',
    'bus',
    'boat',
  ];

  static void show(BuildContext context, WidgetRef ref, Device device) {
    // ─── Контроллеры ───
    final nameController = TextEditingController(text: device.name);
    final rtspPortController = TextEditingController(
      text: (device.properties['rtsp_port'] as int?)?.toString() ?? '8554',
    );

    // ─── Существующие значения ───
    String selectedRoomId = device.roomId;
    Set<String> selectedLabels = Set.from(
      (device.properties['notify_labels'] as List?)?.cast<String>() ??
          ['person', 'car'],
    );
    int snapshotInterval = (device.properties['snapshot_interval'] as int?) ?? 5;

    // ─── Доступные комнаты ───
    final rooms = ref.read(roomsProvider);

    // ─── Строим список комнат для dropdown ───
    // Убираем хардкод 'other' — берём из БД, fallback если 'other' нет
    final Map<String, DropdownMenuItem<String>> roomItemsMap = {};

    // Добавляем все комнаты из БД
    for (final r in rooms) {
      roomItemsMap[r.id] = DropdownMenuItem(
        value: r.id,
        child: Text('${r.icon ?? "🏠"} ${r.name}'),
      );
    }

    // Fallback: если 'other' нет — добавляем
    if (!roomItemsMap.containsKey('other')) {
      roomItemsMap['other'] = const DropdownMenuItem(
        value: 'other',
        child: Text('🔌 Техника'),
      );
    }

    // Проверяем что selectedRoomId валиден
    if (!roomItemsMap.containsKey(selectedRoomId)) {
      // Fallback: 'other' или первая комната
      selectedRoomId = roomItemsMap.containsKey('other')
          ? 'other'
          : roomItemsMap.keys.first;
    }

    final roomItems = roomItemsMap.values.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          // Актуальное устройство
          final latestDevice = ref.watch(devicesProvider).firstWhere(
                (d) => d.id == device.id,
            orElse: () => device,
          );

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Заголовок ───
                  Row(
                    children: [
                      const Icon(Icons.videocam, color: Colors.red, size: 28),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Настройки камеры',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Название ───
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── Комната ───
                  DropdownButtonFormField<String>(
                    initialValue: selectedRoomId,
                    decoration: const InputDecoration(
                      labelText: 'Комната',
                      prefixIcon: Icon(Icons.meeting_room),
                      border: OutlineInputBorder(),
                    ),
                    items: roomItems,
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedRoomId = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // ─── Snapshot interval ───
                  DropdownButtonFormField<int>(
                    initialValue: snapshotInterval,
                    decoration: const InputDecoration(
                      labelText: 'Интервал снимков',
                      prefixIcon: Icon(Icons.timer),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 секунд')),
                      DropdownMenuItem(value: 10, child: Text('10 секунд')),
                      DropdownMenuItem(value: 30, child: Text('30 секунд')),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => snapshotInterval = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // ─── RTSP порт ───
                  TextField(
                    controller: rtspPortController,
                    decoration: const InputDecoration(
                      labelText: 'RTSP порт',
                      hintText: '8554',
                      prefixIcon: Icon(Icons.settings_ethernet),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // ─── Уведомления (labels) ───
                  const Text(
                    'Уведомления',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Какие объекты отслеживать',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _allLabels.map((label) {
                      final isSelected = selectedLabels.contains(label);
                      return FilterChip(
                        label: Text('${_labelEmoji(label)} $label'),
                        selected: isSelected,
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              selectedLabels.add(label);
                            } else {
                              selectedLabels.remove(label);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ─── Кнопки ───
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _confirmDelete(ctx, ref, latestDevice),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Удалить',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Валидация
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text('Название не может быть пустым'),
                                ),
                              );
                              return;
                            }

                            final rtspPort =
                                int.tryParse(rtspPortController.text) ?? 8554;
                            if (rtspPort < 1 || rtspPort > 65535) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text('RTSP порт должен быть 1-65535'),
                                ),
                              );
                              return;
                            }

                            if (selectedLabels.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text('Выберите хотя бы один объект'),
                                ),
                              );
                              return;
                            }

                            // Сохраняем
                            final updated = latestDevice.copyWith(
                              name: name,
                              roomId: selectedRoomId,
                              properties: {
                                ...latestDevice.properties,
                                'camera_name': name,
                                'notify_labels': selectedLabels.toList(),
                                'snapshot_interval': snapshotInterval,
                                'rtsp_port': rtspPort,
                              },
                            );

                            await ref
                                .read(devicesProvider.notifier)
                                .updateDevice(updated);

                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Настройки сохранены'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Сохранить'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _labelEmoji(String label) {
    switch (label) {
      case 'person':
        return '🚶';
      case 'car':
        return '🚗';
      case 'dog':
        return '🐕';
      case 'cat':
        return '🐱';
      case 'bird':
        return '🐦';
      case 'motorcycle':
        return '🏍️';
      case 'bicycle':
        return '🚲';
      case 'truck':
        return '🚚';
      case 'bus':
        return '🚌';
      case 'boat':
        return '⛵';
      default:
        return '📦';
    }
  }

  static Future<void> _confirmDelete(
      BuildContext ctx,
      WidgetRef ref,
      Device device,
      ) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Удалить камеру?'),
        content: Text('${device.name} будет удалена из SHome.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(devicesProvider.notifier).removeDevice(device.id);
      if (ctx.mounted) Navigator.pop(ctx);
    }
  }
}