import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/models/notification_settings.dart';
import '../../application/state/notification_settings_provider.dart';
import '../../data/services/vk_notification_service.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    final tokenController = TextEditingController(text: settings.vkToken);
    final userIdController = TextEditingController(text: settings.vkUserId);

    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Включить уведомления'),
            subtitle: const Text('Отправка сообщений в VK'),
            value: settings.enabled,
            onChanged: (val) {
              notifier.update(settings.copyWith(enabled: val));
            },
          ),
          const SizedBox(height: 16),
          if (settings.enabled) ...[
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: 'VK Token',
                hintText: 'Вставьте токен бота',
              ),
              onChanged: (val) {
                notifier.update(settings.copyWith(vkToken: val));
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'VK User ID',
                hintText: 'Например, 123456789',
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                notifier.update(settings.copyWith(vkUserId: val));
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Сцены'),
              subtitle: const Text('Уведомления о выполнении сцен'),
              value: settings.notifyScenes,
              onChanged: (val) {
                notifier.update(settings.copyWith(notifyScenes: val));
              },
            ),
            SwitchListTile(
              title: const Text('Устройства'),
              subtitle: const Text('Изменение состояния устройств'),
              value: settings.notifyDevices,
              onChanged: (val) {
                notifier.update(settings.copyWith(notifyDevices: val));
              },
            ),
            SwitchListTile(
              title: const Text('Тревоги'),
              subtitle: const Text('Обнаружение движения'),
              value: settings.notifyAlarms,
              onChanged: (val) {
                notifier.update(settings.copyWith(notifyAlarms: val));
              },
            ),
            SwitchListTile(
              title: const Text('Ошибки'),
              subtitle: const Text('Сбои и ошибки'),
              value: settings.notifyErrors,
              onChanged: (val) {
                notifier.update(settings.copyWith(notifyErrors: val));
              },
            ),
            const Divider(height: 32),
            SwitchListTile(
              title: const Text('Расписание'),
              subtitle: const Text('Отправлять только в указанное время'),
              value: settings.useSchedule,
              onChanged: (val) {
                notifier.update(settings.copyWith(useSchedule: val));
              },
            ),
            if (settings.useSchedule) ...[
              SwitchListTile(
                title: const Text('Тревоги вне расписания'),
                subtitle: const Text('Тревоги отправлять всегда'),
                value: settings.scheduleOnlyAlarms,
                onChanged: (val) {
                  notifier.update(settings.copyWith(scheduleOnlyAlarms: val));
                },
              ),
              ListTile(
                title: const Text('Время начала'),
                subtitle: Text(
                  '${settings.startHour.toString().padLeft(2, '0')}:${settings.startMinute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.startHour,
                      minute: settings.startMinute,
                    ),
                  );
                  if (time != null) {
                    notifier.update(
                      settings.copyWith(
                        startHour: time.hour,
                        startMinute: time.minute,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                title: const Text('Время окончания'),
                subtitle: Text(
                  '${settings.endHour.toString().padLeft(2, '0')}:${settings.endMinute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.endHour,
                      minute: settings.endMinute,
                    ),
                  );
                  if (time != null) {
                    notifier.update(
                      settings.copyWith(
                        endHour: time.hour,
                        endMinute: time.minute,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              const Text('Дни недели:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                    .asMap()
                    .entries
                    .map((e) {
                  final dayIndex = e.key + 1;
                  final selected = settings.daysOfWeek.contains(dayIndex);
                  return FilterChip(
                    label: Text(e.value),
                    selected: selected,
                    onSelected: (sel) {
                      final days = List<int>.from(settings.daysOfWeek);
                      if (sel) {
                        days.add(dayIndex);
                      } else {
                        days.remove(dayIndex);
                      }
                      notifier.update(settings.copyWith(daysOfWeek: days));
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final vk = VkNotificationService();
                await vk.loadSettings();
                await vk.sendMessage('✅ Тестовое уведомление из SHome!');
              },
              icon: const Icon(Icons.send),
              label: const Text('Отправить тест'),
            ),
          ],
        ],
      ),
    );
  }
}