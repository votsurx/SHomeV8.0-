/// Экран таймеров — отложенное включение/выключение устройств.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../application/state/devices_provider.dart';
import '../../data/local/database.dart';
import '../../domain/models/device.dart';
import '../../domain/models/device_timer.dart';
import '../../l10n/generated/app_localizations.dart';

class TimersScreen extends ConsumerStatefulWidget {
  const TimersScreen({super.key});

  @override
  ConsumerState<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends ConsumerState<TimersScreen> {
  List<DeviceTimer> _timers = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadTimers();

    // Обновляем обратный отсчёт раз в минуту.
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
          (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTimers() async {
    final timers = await AppDatabase.getActiveTimers();
    if (!mounted) return;

    setState(() => _timers = timers);
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _countdown(
      DateTime executeAt,
      AppLocalizations l10n,
      ) {
    final difference = executeAt.difference(DateTime.now());

    if (difference.isNegative) {
      return l10n.timersAlreadyFired;
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return l10n.timersCountdownHoursMinutes(hours, minutes);
    }

    if (minutes > 0) {
      return l10n.timersCountdownMinutes(minutes);
    }

    return l10n.timersLessThanMinute;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devices = ref.watch(devicesProvider);

    final controllableDevices = devices
        .where(
          (device) =>
      device.type == DeviceType.outlet ||
          device.type == DeviceType.light,
    )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timersTitle),
      ),
      body: _timers.isEmpty
          ? Center(child: Text(l10n.timersEmpty))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _timers.length,
        itemBuilder: (context, index) {
          final timer = _timers[index];
          final isTurnOn = timer.command == 'turnOn';

          return Card(
            child: ListTile(
              leading: Icon(
                isTurnOn
                    ? Icons.power_settings_new
                    : Icons.power_off,
                color: isTurnOn ? Colors.green : Colors.red,
              ),
              title: Text(timer.deviceName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isTurnOn ? l10n.timersTurnOn : l10n.timersTurnOff} '
                        '${_countdown(timer.executeAt, l10n)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    l10n.timersTodayAt(
                      _formatTime(timer.executeAt),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                tooltip: l10n.timersDeleteTooltip,
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await AppDatabase.deleteTimer(timer.id);
                  await _loadTimers();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTimerDialog(
          context,
          controllableDevices,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTimerDialog(
      BuildContext context,
      List<Device> devices,
      ) {
    final l10n = AppLocalizations.of(context);

    Device? selectedDevice;
    var command = 'turnOff';
    var selectedTime = TimeOfDay.now();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.timersNewTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Device>(
                  decoration: InputDecoration(
                    labelText: l10n.timersDeviceLabel,
                  ),
                  items: devices
                      .map(
                        (device) => DropdownMenuItem<Device>(
                      value: device,
                      child: Text(device.name),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedDevice = value);
                  },
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'turnOff',
                      label: Text(l10n.timersCommandOff),
                    ),
                    ButtonSegment(
                      value: 'turnOn',
                      label: Text(l10n.timersCommandOn),
                    ),
                  ],
                  selected: {command},
                  onSelectionChanged: (values) {
                    setDialogState(() => command = values.first);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    _formatTime(
                      DateTime(
                        2024,
                        1,
                        1,
                        selectedTime.hour,
                        selectedTime.minute,
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: dialogContext,
                      initialTime: selectedTime,
                    );

                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.timersCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final device = selectedDevice;
                if (device == null) return;

                final now = DateTime.now();
                final executeAt = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final timer = DeviceTimer(
                  id: const Uuid().v4(),
                  deviceId: device.id,
                  deviceName: device.name,
                  command: command,
                  executeAt: executeAt.isBefore(now)
                      ? executeAt.add(const Duration(days: 1))
                      : executeAt,
                  executed: false,
                );

                await AppDatabase.insertTimer(timer);
                if (!mounted) return;

                await _loadTimers();
                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);
              },
              child: Text(l10n.timersCreate),
            ),
          ],
        ),
      ),
    );
  }
}