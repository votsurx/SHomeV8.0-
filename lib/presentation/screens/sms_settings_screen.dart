import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/models/sms_phone.dart';
import '../../application/state/sms_settings_provider.dart';
import '../../data/services/sms_notification_service.dart';
import '../../l10n/generated/app_localizations.dart';

class SmsSettingsScreen extends ConsumerWidget {
  const SmsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(smsSettingsProvider);
    final notifier = ref.read(smsSettingsProvider.notifier);

    final weekdays = [
      l10n.smsSettingsMonday,
      l10n.smsSettingsTuesday,
      l10n.smsSettingsWednesday,
      l10n.smsSettingsThursday,
      l10n.smsSettingsFriday,
      l10n.smsSettingsSaturday,
      l10n.smsSettingsSunday,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.smsSettingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(l10n.smsSettingsEnable),
            subtitle: Text(l10n.smsSettingsEnableSubtitle),
            value: settings.enabled,
            onChanged: (value) {
              notifier.update(settings.copyWith(enabled: value));
            },
          ),
          const Divider(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.smsSettingsPhoneNumbers,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
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
                  l10n.smsSettingsNoPhones,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...settings.phones.map(
                  (phone) => Card(
                child: ListTile(
                  leading: const Icon(Icons.phone, color: Colors.blue),
                  title: Text(phone.name ?? phone.phone),
                  subtitle: phone.name != null ? Text(phone.phone) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: phone.enabled,
                        onChanged: (value) {
                          notifier.updatePhone(
                            phone.phone,
                            phone.copyWith(enabled: value),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: l10n.smsSettingsDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          notifier.removePhone(phone.phone);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const Divider(height: 32),

          Text(
            l10n.smsSettingsEventsTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: Text(l10n.smsSettingsScenes),
            value: settings.notifyScenes,
            onChanged: (value) {
              notifier.update(settings.copyWith(notifyScenes: value));
            },
          ),
          SwitchListTile(
            title: Text(l10n.smsSettingsDevices),
            value: settings.notifyDevices,
            onChanged: (value) {
              notifier.update(settings.copyWith(notifyDevices: value));
            },
          ),

          const Divider(height: 32),

          Text(
            l10n.smsSettingsAlarms,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: Text(l10n.smsSettingsZigbeeWaterLeak),
            value: settings.notifyZigbeeWaterLeak,
            onChanged: (value) {
              notifier.update(
                settings.copyWith(notifyZigbeeWaterLeak: value),
              );
            },
          ),
          SwitchListTile(
            title: Text(l10n.smsSettingsZigbeeSmoke),
            value: settings.notifyZigbeeSmoke,
            onChanged: (value) {
              notifier.update(settings.copyWith(notifyZigbeeSmoke: value));
            },
          ),
          SwitchListTile(
            title: Text(l10n.smsSettingsZigbeeGas),
            value: settings.notifyZigbeeGas,
            onChanged: (value) {
              notifier.update(settings.copyWith(notifyZigbeeGas: value));
            },
          ),
          SwitchListTile(
            title: Text(l10n.smsSettingsZigbeeMotion),
            value: settings.notifyZigbeeMotion,
            onChanged: (value) {
              notifier.update(
                settings.copyWith(notifyZigbeeMotion: value),
              );
            },
          ),
          SwitchListTile(
            title: Text(l10n.smsSettingsZigbeeContact),
            value: settings.notifyZigbeeContact,
            onChanged: (value) {
              notifier.update(
                settings.copyWith(notifyZigbeeContact: value),
              );
            },
          ),
          SwitchListTile(
            title: Text(l10n.smsSettingsFrigatePerson),
            value: settings.notifyFrigatePerson,
            onChanged: (value) {
              notifier.update(
                settings.copyWith(notifyFrigatePerson: value),
              );
            },
          ),
          SwitchListTile(
            title: Text(l10n.smsSettingsFrigateCar),
            value: settings.notifyFrigateCar,
            onChanged: (value) {
              notifier.update(settings.copyWith(notifyFrigateCar: value));
            },
          ),

          const Divider(height: 32),

          Text(
            l10n.smsSettingsErrors,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: Text(l10n.smsSettingsZigbeeOffline),
            subtitle: Text(l10n.smsSettingsZigbeeOfflineSubtitle),
            value: settings.notifyZigbeeOffline,
            onChanged: (value) {
              notifier.update(
                settings.copyWith(notifyZigbeeOffline: value),
              );
            },
          ),
          SwitchListTile(
            title: Text(l10n.smsSettingsFrigateOffline),
            subtitle: Text(l10n.smsSettingsFrigateOfflineSubtitle),
            value: settings.notifyFrigateOffline,
            onChanged: (value) {
              notifier.update(
                settings.copyWith(notifyFrigateOffline: value),
              );
            },
          ),

          const Divider(height: 32),

          DropdownButtonFormField<int>(
            initialValue: settings.smsCooldownMin,
            decoration: InputDecoration(
              labelText: l10n.smsSettingsCooldown,
              prefixIcon: const Icon(Icons.timer),
            ),
            items: [
              DropdownMenuItem(
                value: 1,
                child: Text(l10n.smsSettingsOneMinute),
              ),
              DropdownMenuItem(
                value: 5,
                child: Text(l10n.smsSettingsMinutes(5)),
              ),
              DropdownMenuItem(
                value: 15,
                child: Text(l10n.smsSettingsMinutes(15)),
              ),
              DropdownMenuItem(
                value: 30,
                child: Text(l10n.smsSettingsMinutes(30)),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                notifier.update(settings.copyWith(smsCooldownMin: value));
              }
            },
          ),

          const Divider(height: 32),

          SwitchListTile(
            title: Text(l10n.smsSettingsSchedule),
            subtitle: Text(l10n.smsSettingsScheduleSubtitle),
            value: settings.useSchedule,
            onChanged: (value) {
              notifier.update(settings.copyWith(useSchedule: value));
            },
          ),

          if (settings.useSchedule) ...[
            SwitchListTile(
              title: Text(l10n.smsSettingsAlarmsOutsideSchedule),
              value: settings.scheduleOnlyAlarms,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(scheduleOnlyAlarms: value),
                );
              },
            ),
            ListTile(
              title: Text(l10n.smsSettingsStartTime),
              subtitle: Text(
                '${settings.startHour.toString().padLeft(2, '0')}:'
                    '${settings.startMinute.toString().padLeft(2, '0')}',
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
              title: Text(l10n.smsSettingsEndTime),
              subtitle: Text(
                '${settings.endHour.toString().padLeft(2, '0')}:'
                    '${settings.endMinute.toString().padLeft(2, '0')}',
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
            Text(l10n.smsSettingsDaysOfWeek),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: weekdays.asMap().entries.map((entry) {
                final dayIndex = entry.key + 1;
                final selected = settings.daysOfWeek.contains(dayIndex);

                return FilterChip(
                  label: Text(entry.value),
                  selected: selected,
                  onSelected: (isSelected) {
                    final days = List<int>.from(settings.daysOfWeek);
                    if (isSelected) {
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
              if (settings.phones.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.smsSettingsAddPhoneRequired),
                  ),
                );
                return;
              }

              final phone = settings.phones.first;
              await SmsNotificationService().sendSms(
                phoneNumber: phone.phone,
                message: l10n.smsSettingsTestMessage,
              );
            },
            icon: const Icon(Icons.sms),
            label: Text(l10n.smsSettingsSendTest),
          ),
        ],
      ),
    );
  }

  void _showAddPhoneDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.smsSettingsAddPhoneTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.smsSettingsNameOptional,
                hintText: l10n.smsSettingsNameHint,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: l10n.smsSettingsPhoneLabel,
                hintText: l10n.smsSettingsPhoneHint,
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.smsSettingsCancel),
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

              Navigator.pop(dialogContext);
            },
            child: Text(l10n.smsSettingsAdd),
          ),
        ],
      ),
    );
  }
}