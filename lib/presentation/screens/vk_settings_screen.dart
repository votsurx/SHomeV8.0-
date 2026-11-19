import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/state/notification_settings_provider.dart';
import '../../data/services/vk_notification_service.dart';
import '../../l10n/generated/app_localizations.dart';

class VkSettingsScreen extends ConsumerWidget {
  const VkSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    final weekdays = [
      l10n.vkSettingsMonday,
      l10n.vkSettingsTuesday,
      l10n.vkSettingsWednesday,
      l10n.vkSettingsThursday,
      l10n.vkSettingsFriday,
      l10n.vkSettingsSaturday,
      l10n.vkSettingsSunday,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vkSettingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(l10n.vkSettingsEnable),
            subtitle: Text(l10n.vkSettingsEnableSubtitle),
            value: settings.enabled,
            onChanged: (value) {
              notifier.update(settings.copyWith(enabled: value));
            },
          ),
          const SizedBox(height: 16),

          if (settings.enabled) ...[
            TextFormField(
              initialValue: settings.vkToken,
              decoration: InputDecoration(
                labelText: l10n.vkSettingsTokenLabel,
                hintText: l10n.vkSettingsTokenHint,
              ),
              onChanged: (value) {
                notifier.update(settings.copyWith(vkToken: value));
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: settings.vkUserId,
              decoration: InputDecoration(
                labelText: l10n.vkSettingsUserIdLabel,
                hintText: l10n.vkSettingsUserIdHint,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                notifier.update(settings.copyWith(vkUserId: value));
              },
            ),
            const Divider(height: 32),

            Text(
              l10n.vkSettingsEvents,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(l10n.vkSettingsScenes),
              subtitle: Text(l10n.vkSettingsScenesSubtitle),
              value: settings.notifyScenes,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyScenes: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.vkSettingsDevices),
              subtitle: Text(l10n.vkSettingsDevicesSubtitle),
              value: settings.notifyDevices,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyDevices: value),
                );
              },
            ),

            const Divider(height: 32),

            Text(
              l10n.vkSettingsAlarms,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(l10n.vkSettingsZigbeeWaterLeak),
              value: settings.notifyZigbeeWaterLeak,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyZigbeeWaterLeak: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.vkSettingsZigbeeSmoke),
              value: settings.notifyZigbeeSmoke,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyZigbeeSmoke: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.vkSettingsZigbeeGas),
              value: settings.notifyZigbeeGas,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyZigbeeGas: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.vkSettingsZigbeeMotion),
              value: settings.notifyZigbeeMotion,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyZigbeeMotion: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.vkSettingsZigbeeContact),
              value: settings.notifyZigbeeContact,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyZigbeeContact: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.vkSettingsFrigatePerson),
              value: settings.notifyFrigatePerson,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyFrigatePerson: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.vkSettingsFrigateCar),
              value: settings.notifyFrigateCar,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyFrigateCar: value),
                );
              },
            ),

            const Divider(height: 32),

            Text(
              l10n.vkSettingsErrors,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(l10n.vkSettingsZigbeeOffline),
              subtitle: Text(l10n.vkSettingsZigbeeOfflineSubtitle),
              value: settings.notifyZigbeeOffline,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyZigbeeOffline: value),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.vkSettingsFrigateOffline),
              subtitle: Text(l10n.vkSettingsFrigateOfflineSubtitle),
              value: settings.notifyFrigateOffline,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(notifyFrigateOffline: value),
                );
              },
            ),

            const Divider(height: 32),

            DropdownButtonFormField<int>(
              initialValue: settings.vkCooldownMin,
              decoration: InputDecoration(
                labelText: l10n.vkSettingsCooldown,
                prefixIcon: const Icon(Icons.timer),
              ),
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Text(l10n.vkSettingsCooldown1),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text(l10n.vkSettingsCooldown5),
                ),
                DropdownMenuItem(
                  value: 15,
                  child: Text(l10n.vkSettingsCooldown15),
                ),
                DropdownMenuItem(
                  value: 30,
                  child: Text(l10n.vkSettingsCooldown30),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  notifier.update(
                    settings.copyWith(vkCooldownMin: value),
                  );
                }
              },
            ),

            const Divider(height: 32),

            SwitchListTile(
              title: Text(l10n.vkSettingsSchedule),
              subtitle: Text(l10n.vkSettingsScheduleSubtitle),
              value: settings.useSchedule,
              onChanged: (value) {
                notifier.update(
                  settings.copyWith(useSchedule: value),
                );
              },
            ),

            if (settings.useSchedule) ...[
              SwitchListTile(
                title: Text(l10n.vkSettingsAlarmsOutsideSchedule),
                subtitle: Text(l10n.vkSettingsAlarmsAlways),
                value: settings.scheduleOnlyAlarms,
                onChanged: (value) {
                  notifier.update(
                    settings.copyWith(scheduleOnlyAlarms: value),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.vkSettingsStartTime),
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
                title: Text(l10n.vkSettingsEndTime),
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
              Text(l10n.vkSettingsDaysOfWeek),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: weekdays.asMap().entries.map((entry) {
                  final dayIndex = entry.key + 1;
                  final selected =
                  settings.daysOfWeek.contains(dayIndex);

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

                      notifier.update(
                        settings.copyWith(daysOfWeek: days),
                      );
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final service = VkNotificationService();
                await service.loadSettings();
                await service.sendMessage(l10n.vkSettingsTestMessage);
              },
              icon: const Icon(Icons.send),
              label: Text(l10n.vkSettingsSendTest),
            ),
          ],
        ],
      ),
    );
  }
}