/// Диалог создания/редактирования сцены.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../application/state/devices_provider.dart';
import '../../../application/state/presence_provider.dart';
import '../../../application/state/scenes_provider.dart';
import '../../../domain/models/device.dart';
import '../../../domain/models/presence_conditions.dart';
import '../../../domain/models/scene.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'scene_helpers.dart';

class SceneEditorDialog extends ConsumerStatefulWidget {
  const SceneEditorDialog({super.key, this.existingScene});

  final Scene? existingScene;

  @override
  ConsumerState<SceneEditorDialog> createState() =>
      _SceneEditorDialogState();
}

class _SceneEditorDialogState extends ConsumerState<SceneEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _sensorThresholdController;

  late String _triggerType;
  late TimeOfDay _selectedTime;
  late String _repeatType;
  late final Set<int> _selectedDays;

  String? _selectedSensorId;
  late String _selectedSensorCondition;

  late PresenceEvent _selectedPresenceEvent;
  String? _selectedPresencePhoneId;
  late PresenceChannel _selectedPresenceChannel;
  late int _presenceDelayMin;
  late int _presenceCooldownMin;
  PresenceConditions? _presenceConditions;
  bool _showPresenceAdvanced = false;

  final Map<String, String?> _selectedActions = {};

  bool get _isEditing => widget.existingScene != null;

  @override
  void initState() {
    super.initState();

    final scene = widget.existingScene;
    final trigger = scene?.trigger;

    _nameController = TextEditingController(text: scene?.name ?? '');
    _sensorThresholdController = TextEditingController(
      text: '${trigger?.sensorThreshold ?? 30}',
    );

    _triggerType = _triggerTypeToString(trigger?.type);
    _selectedTime = SceneHelpers.parseTime(trigger?.time) ??
        const TimeOfDay(hour: 22, minute: 0);
    _repeatType = _repeatTypeToString(trigger?.repeat);
    _selectedDays = Set.from(trigger?.repeatDays ?? []);

    _selectedSensorId = trigger?.sensorDeviceId;
    _selectedSensorCondition =
        trigger?.sensorCondition ?? 'temperature_above';

    _selectedPresenceEvent =
        trigger?.presenceEvent ?? PresenceEvent.someoneHome;
    _selectedPresencePhoneId = trigger?.presencePhoneId;
    _selectedPresenceChannel =
        trigger?.presenceChannel ?? PresenceChannel.gps;
    _presenceDelayMin = trigger?.presenceDelayMin ?? 0;
    _presenceCooldownMin = trigger?.presenceCooldownMin ?? 1;
    _presenceConditions = trigger?.presenceConditions;

    if (scene != null) {
      for (final action in scene.actions) {
        _selectedActions[action.deviceId] = action.command;
      }
    }
  }

  String _repeatTypeToString(RepeatType? type) {
    switch (type) {
      case RepeatType.daily:
        return 'daily';
      case RepeatType.weekly:
        return 'weekly';
      case RepeatType.interval:
      case RepeatType.once:
      case null:
        return 'once';
    }
  }

  String _triggerTypeToString(TriggerType? type) {
    switch (type) {
      case TriggerType.time:
        return 'time';
      case TriggerType.deviceState:
        return 'sensor';
      case TriggerType.presence:
        return 'presence';
      case TriggerType.manual:
      case null:
        return 'manual';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sensorThresholdController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  List<String> _weekDays(AppLocalizations l10n) => [
    l10n.sceneEditorMonday,
    l10n.sceneEditorTuesday,
    l10n.sceneEditorWednesday,
    l10n.sceneEditorThursday,
    l10n.sceneEditorFriday,
    l10n.sceneEditorSaturday,
    l10n.sceneEditorSunday,
  ];

  String _minuteLabel(int value, AppLocalizations l10n) {
    if (value == 0) return l10n.sceneEditorNoDelay;
    if (value == 1) return l10n.sceneEditorMinute;
    return l10n.sceneEditorMinutes(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allDevices = ref.watch(devicesProvider);
    final devices = allDevices.where((device) {
      return device.type == DeviceType.outlet ||
          device.type == DeviceType.switch1 ||
          device.type == DeviceType.switch2 ||
          device.type == DeviceType.switch3 ||
          device.type == DeviceType.light;
    }).toList();

    final presencePhones = ref.watch(presenceSettingsProvider).phones;

    return AlertDialog(
      title: Text(
        _isEditing
            ? l10n.sceneEditorTitleEdit
            : l10n.sceneEditorTitleNew,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.sceneEditorName,
                hintText: l10n.sceneEditorNameHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.sceneEditorTriggerType}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _triggerType,
              decoration: InputDecoration(
                labelText: l10n.sceneEditorTriggerType,
              ),
              items: [
                DropdownMenuItem(
                  value: 'manual',
                  child: Text(l10n.sceneEditorTriggerManual),
                ),
                DropdownMenuItem(
                  value: 'time',
                  child: Text(l10n.sceneEditorTriggerTime),
                ),
                DropdownMenuItem(
                  value: 'sensor',
                  child: Text(l10n.sceneEditorTriggerSensor),
                ),
                DropdownMenuItem(
                  value: 'presence',
                  child: Text(l10n.sceneEditorTriggerPresence),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _triggerType = value);
                }
              },
            ),
            const SizedBox(height: 16),

            if (_triggerType == 'time') ...[
              ListTile(
                title: Text(_formatTime(_selectedTime)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() => _selectedTime = time);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _repeatType,
                decoration: InputDecoration(
                  labelText: l10n.sceneEditorRepeat,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'once',
                    child: Text(l10n.sceneEditorRepeatOnce),
                  ),
                  DropdownMenuItem(
                    value: 'daily',
                    child: Text(l10n.sceneEditorRepeatDaily),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text(l10n.sceneEditorRepeatWeekly),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _repeatType = value);
                  }
                },
              ),
              if (_repeatType == 'weekly') ...[
                const SizedBox(height: 8),
                Text(
                  l10n.sceneEditorDaysOfWeek,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 4,
                  children: _weekDays(l10n).asMap().entries.map((entry) {
                    final dayIndex = entry.key + 1;

                    return FilterChip(
                      label: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: _selectedDays.contains(dayIndex),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(dayIndex);
                          } else {
                            _selectedDays.remove(dayIndex);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
            ],

            if (_triggerType == 'sensor') ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedSensorId,
                decoration: InputDecoration(
                  labelText: l10n.sceneEditorSensor,
                ),
                hint: Text(l10n.sceneEditorSelectSensor),
                items: allDevices
                    .where(
                      (device) =>
                  device.type == DeviceType.sensor ||
                      (device.properties['source'] == 'zigbee' &&
                          device.properties['exposes'] != null),
                )
                    .map(
                      (device) => DropdownMenuItem(
                    value: device.id,
                    child: Text(device.name),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedSensorId = value);
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedSensorCondition,
                decoration: InputDecoration(
                  labelText: l10n.sceneEditorCondition,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'temperature_above',
                    child: Text(
                      l10n.sceneEditorTemperatureAbove('…'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'temperature_below',
                    child: Text(
                      l10n.sceneEditorTemperatureBelow('…'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'humidity_above',
                    child: Text(l10n.sceneEditorHumidityAbove('…')),
                  ),
                  DropdownMenuItem(
                    value: 'humidity_below',
                    child: Text(l10n.sceneEditorHumidityBelow('…')),
                  ),
                  DropdownMenuItem(
                    value: 'water_leak',
                    child: Text(l10n.sceneEditorWaterLeak),
                  ),
                  DropdownMenuItem(
                    value: 'motion',
                    child: Text(l10n.sceneEditorMotion),
                  ),
                  DropdownMenuItem(
                    value: 'contact_open',
                    child: Text(l10n.sceneEditorContactOpen),
                  ),
                  DropdownMenuItem(
                    value: 'contact_closed',
                    child: Text(l10n.sceneEditorContactClosed),
                  ),
                  DropdownMenuItem(
                    value: 'smoke',
                    child: Text(l10n.sceneEditorSmoke),
                  ),
                  DropdownMenuItem(
                    value: 'gas',
                    child: Text(l10n.sceneEditorGas),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSensorCondition =
                        value ?? 'temperature_above';
                  });
                },
              ),
              const SizedBox(height: 8),
              if (_selectedSensorCondition.startsWith('temperature') ||
                  _selectedSensorCondition.startsWith('humidity'))
                TextField(
                  controller: _sensorThresholdController,
                  decoration: InputDecoration(
                    labelText: l10n.sceneEditorThreshold,
                  ),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 16),
            ],

            if (_triggerType == 'presence') ...[
              DropdownButtonFormField<PresenceEvent>(
                initialValue: _selectedPresenceEvent,
                decoration: InputDecoration(
                  labelText: l10n.sceneEditorPresenceEvent,
                ),
                items: [
                  DropdownMenuItem(
                    value: PresenceEvent.someoneHome,
                    child: Text(l10n.sceneEditorSomeoneHome),
                  ),
                  DropdownMenuItem(
                    value: PresenceEvent.nobodyHome,
                    child: Text(l10n.sceneEditorNobodyHome),
                  ),
                  DropdownMenuItem(
                    value: PresenceEvent.allHome,
                    child: Text(l10n.sceneEditorAllHome),
                  ),
                  DropdownMenuItem(
                    value: PresenceEvent.phoneArrived,
                    child: Text(l10n.sceneEditorPhoneArrived),
                  ),
                  DropdownMenuItem(
                    value: PresenceEvent.phoneLeft,
                    child: Text(l10n.sceneEditorPhoneLeft),
                  ),
                  DropdownMenuItem(
                    value: PresenceEvent.phoneUnknown,
                    child: Text(l10n.sceneEditorPhoneUnknown),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPresenceEvent = value);
                  }
                },
              ),
              const SizedBox(height: 8),

              if (_selectedPresenceEvent == PresenceEvent.phoneArrived ||
                  _selectedPresenceEvent == PresenceEvent.phoneLeft ||
                  _selectedPresenceEvent == PresenceEvent.phoneUnknown) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedPresencePhoneId,
                  decoration: InputDecoration(
                    labelText: l10n.sceneEditorPhone,
                  ),
                  hint: Text(l10n.sceneEditorSelectPhone),
                  items: presencePhones
                      .map(
                        (phone) => DropdownMenuItem(
                      value: phone.phoneId,
                      child: Text(phone.phoneName),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedPresencePhoneId = value);
                  },
                ),
                const SizedBox(height: 8),
              ],

              InkWell(
                onTap: () {
                  setState(() {
                    _showPresenceAdvanced = !_showPresenceAdvanced;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        _showPresenceAdvanced
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.sceneEditorAdvanced,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_showPresenceAdvanced) ...[
                DropdownButtonFormField<PresenceChannel>(
                  initialValue: _selectedPresenceChannel,
                  decoration: InputDecoration(
                    labelText: l10n.sceneEditorDetectionChannel,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: PresenceChannel.any,
                      child: Text(l10n.sceneEditorChannelAny),
                    ),
                    DropdownMenuItem(
                      value: PresenceChannel.wifi,
                      child: Text(l10n.sceneEditorChannelWifi),
                    ),
                    DropdownMenuItem(
                      value: PresenceChannel.gps,
                      child: Text(l10n.sceneEditorChannelGps),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPresenceChannel = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _presenceDelayMin,
                  decoration: InputDecoration(
                    labelText: l10n.sceneEditorStartDelay,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text(l10n.sceneEditorNoDelay),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(l10n.sceneEditorMinute),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text(l10n.sceneEditorMinutes(5)),
                    ),
                    DropdownMenuItem(
                      value: 30,
                      child: Text(l10n.sceneEditorMinutes(30)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _presenceDelayMin = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _presenceCooldownMin,
                  decoration: InputDecoration(
                    labelText: l10n.sceneEditorCooldown,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text(l10n.sceneEditorMinute),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text(l10n.sceneEditorMinutes(5)),
                    ),
                    DropdownMenuItem(
                      value: 15,
                      child: Text(l10n.sceneEditorMinutes(15)),
                    ),
                    DropdownMenuItem(
                      value: 30,
                      child: Text(l10n.sceneEditorMinutes(30)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _presenceCooldownMin = value);
                    }
                  },
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await _showConditionsDialog(context);
                  if (result != null) {
                    setState(() => _presenceConditions = result);
                  }
                },
                icon: const Icon(Icons.tune, size: 16),
                label: Text(
                  _presenceConditions == null
                      ? l10n.sceneEditorConfigureConditions
                      : l10n.sceneEditorConditionsConfigured,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              l10n.sceneEditorActions,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (devices.isEmpty)
              Text(
                l10n.sceneEditorNoDevices,
                style: const TextStyle(color: Colors.grey),
              )
            else
              ...devices.map((device) {
                final action = _selectedActions[device.id];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            device.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        ChoiceChip(
                          label: Text(
                            l10n.sceneEditorActionOn,
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: action == 'turnOn',
                          selectedColor:
                          Colors.green.withValues(alpha: 0.3),
                          onSelected: (selected) {
                            setState(() {
                              _selectedActions[device.id] =
                              selected ? 'turnOn' : null;
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: Text(
                            l10n.sceneEditorActionOff,
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: action == 'turnOff',
                          selectedColor:
                          Colors.red.withValues(alpha: 0.3),
                          onSelected: (selected) {
                            setState(() {
                              _selectedActions[device.id] =
                              selected ? 'turnOff' : null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.sceneEditorCancel),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(
            _isEditing
                ? l10n.sceneEditorSave
                : l10n.sceneEditorCreate,
          ),
        ),
      ],
    );
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final hasActions = _selectedActions.values.any((action) => action != null);

    if (_nameController.text.trim().isEmpty || !hasActions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sceneEditorValidation)),
      );
      return;
    }

    final actions = _selectedActions.entries
        .where((entry) => entry.value != null)
        .map(
          (entry) => SceneAction(
        deviceId: entry.key,
        command: entry.value!,
      ),
    )
        .toList();

    final timeString = _formatTime(_selectedTime);

    SceneTrigger? trigger;

    if (_triggerType == 'time') {
      trigger = SceneTrigger(
        type: TriggerType.time,
        time: timeString,
        repeat: RepeatType.values.firstWhere(
              (repeat) => repeat.name == _repeatType,
        ),
        repeatDays:
        _repeatType == 'weekly' ? _selectedDays.toList() : null,
      );
    } else if (_triggerType == 'sensor') {
      trigger = SceneTrigger(
        type: TriggerType.deviceState,
        sensorDeviceId: _selectedSensorId,
        sensorCondition: _selectedSensorCondition,
        sensorThreshold:
        double.tryParse(_sensorThresholdController.text) ?? 30,
      );
    } else if (_triggerType == 'presence') {
      trigger = SceneTrigger(
        type: TriggerType.presence,
        presenceEvent: _selectedPresenceEvent,
        presencePhoneId: _selectedPresencePhoneId,
        presenceChannel: _selectedPresenceChannel,
        presenceDelayMin: _presenceDelayMin,
        presenceCooldownMin: _presenceCooldownMin,
        presenceConditions: _presenceConditions,
      );
    }

    final scene = Scene(
      id: widget.existingScene?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      icon: _triggerType == 'time'
          ? '⏰'
          : _triggerType == 'sensor'
          ? '🌡️'
          : _triggerType == 'presence'
          ? '📍'
          : '🎬',
      actions: actions,
      trigger: trigger,
    );

    // Сохраняем так же, как было в исходном диалоге.
    // При наличии отдельного updateScene в scenesProvider нужно проверить,
    // следует ли вызывать его для редактирования вместо addScene.
    ref.read(scenesProvider.notifier).addScene(scene);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? l10n.sceneEditorUpdated
              : l10n.sceneEditorCreated,
        ),
      ),
    );
  }

  Future<PresenceConditions?> _showConditionsDialog(
      BuildContext context,
      ) async {
    final l10n = AppLocalizations.of(context);
    final conditions = _presenceConditions ?? const PresenceConditions();

    var useTime = conditions.useTime;
    var startTime = TimeOfDay(
      hour: conditions.startHour,
      minute: conditions.startMinute,
    );
    var endTime = TimeOfDay(
      hour: conditions.endHour,
      minute: conditions.endMinute,
    );
    var useDays = conditions.useDays;
    final days = Set<int>.from(conditions.daysOfWeek);

    return showDialog<PresenceConditions>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.sceneEditorConditionsTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  dense: true,
                  title: Text(l10n.sceneEditorTimeOfDay),
                  value: useTime,
                  onChanged: (value) {
                    setDialogState(() => useTime = value);
                  },
                ),
                if (useTime) ...[
                  ListTile(
                    dense: true,
                    title: Text(
                      l10n.sceneEditorFromTime(_formatTime(startTime)),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: dialogContext,
                        initialTime: startTime,
                      );
                      if (time != null) {
                        setDialogState(() => startTime = time);
                      }
                    },
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      l10n.sceneEditorUntilTime(_formatTime(endTime)),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: dialogContext,
                        initialTime: endTime,
                      );
                      if (time != null) {
                        setDialogState(() => endTime = time);
                      }
                    },
                  ),
                ],
                const Divider(),
                SwitchListTile(
                  dense: true,
                  title: Text(l10n.sceneEditorDaysCondition),
                  value: useDays,
                  onChanged: (value) {
                    setDialogState(() => useDays = value);
                  },
                ),
                if (useDays)
                  Wrap(
                    spacing: 4,
                    children: _weekDays(l10n).asMap().entries.map((entry) {
                      final dayIndex = entry.key + 1;

                      return FilterChip(
                        label: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 11),
                        ),
                        selected: days.contains(dayIndex),
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              days.add(dayIndex);
                            } else {
                              days.remove(dayIndex);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  const PresenceConditions(),
                );
              },
              child: Text(l10n.sceneEditorReset),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.sceneEditorCancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  PresenceConditions(
                    useTime: useTime,
                    startHour: startTime.hour,
                    startMinute: startTime.minute,
                    endHour: endTime.hour,
                    endMinute: endTime.minute,
                    useDays: useDays,
                    daysOfWeek: days.toList(),
                  ),
                );
              },
              child: Text(l10n.sceneEditorSave),
            ),
          ],
        ),
      ),
    );
  }
}