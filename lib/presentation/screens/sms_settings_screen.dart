import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/models/sms_phone.dart';
import '../../application/state/sms_settings_provider.dart';
import '../../data/services/sms_notification_service.dart';

class SmsSettingsScreen extends ConsumerWidget {
  const SmsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(smsSettingsProvider);
    final notifier = ref.read(smsSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('SMS уведомления')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Включить SMS
          SwitchListTile(
            title: const Text('Включить SMS'),
            subtitle: const Text('Отправлять уведомления по SMS'),
            value: settings.enabled,
            onChanged: (val) {
              notifier.update(settings.copyWith(enabled: val));
            },
          ),
          const Divider(height: 32),

          // Номера телефонов
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Номера телефонов',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddPhoneDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (settings.phones.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Нет добавленных номеров',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...settings.phones.map((phone) => Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: Text(phone.name ?? phone.phone),
                subtitle: phone.name != null ? Text(phone.phone) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: phone.enabled,
                      onChanged: (val) {
                        notifier.updatePhone(
                          phone.phone,
                          phone.copyWith(enabled: val),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        notifier.removePhone(phone.phone);
                      },
                    ),
                  ],
                ),
              ),
            )),

          const Divider(height: 32),

          // События
          const Text(
            'События для SMS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Сцены'),
            value: settings.notifyScenes,
            onChanged: (val) {
              notifier.update(settings.copyWith(notifyScenes: val));
            },
          ),
          SwitchListTile(
            title: const Text('Устройства'),
            value: settings.notifyDevices,
            onChanged: (val) {
              notifier.update(settings.copyWith(notifyDevices: val));
            },
          ),
          SwitchListTile(
            title: const Text('Тревоги'),
            value: settings.notifyAlarms,
            onChanged: (val) {
              notifier.update(settings.copyWith(notifyAlarms: val));
            },
          ),
          SwitchListTile(
            title: const Text('Ошибки'),
            value: settings.notifyErrors,
            onChanged: (val) {
              notifier.update(settings.copyWith(notifyErrors: val));
            },
          ),

          const Divider(height: 32),

          // Расписание
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
                  notifier.update(settings.copyWith(
                    startHour: time.hour,
                    startMinute: time.minute,
                  ));
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
                  notifier.update(settings.copyWith(
                    endHour: time.hour,
                    endMinute: time.minute,
                  ));
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

          // Тест
          ElevatedButton.icon(
            onPressed: () async {
              if (settings.phones.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Добавьте хотя бы один номер')),
                );
                return;
              }
              final phone = settings.phones.first;
              await SmsNotificationService.sendSms(
                phoneNumber: phone.phone,
                message: '✅ Тестовое SMS из SHome!',
              );
            },
            icon: const Icon(Icons.sms),
            label: const Text('Отправить тест SMS'),
          ),
        ],
      ),
    );
  }

  void _showAddPhoneDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить номер'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Имя (необязательно)',
                hintText: 'Мой телефон',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Номер',
                hintText: '+79991234567',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final phone = phoneController.text.trim();
              if (phone.isEmpty) return;

              ref.read(smsSettingsProvider.notifier).addPhone(
                SmsPhone(
                  phone: phone,
                  name: nameController.text.trim().isEmpty
                      ? null
                      : nameController.text.trim(),
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}