/// Диалог создания/редактирования сцены.
/// Вынесен из scenes_screen.dart — здесь всё состояние в State,
/// а не в 400-строчном StatefulBuilder.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/device.dart';
import '../../../domain/models/scene.dart';
import '../../../domain/models/presence_conditions.dart';
import '../../../application/state/scenes_provider.dart';
import '../../../application/state/devices_provider.dart';
import '../../../application/state/presence_provider.dart';
import 'scene_helpers.dart';

class SceneEditorDialog extends ConsumerStatefulWidget {
  const SceneEditorDialog({super.key, this.existingScene});

  final Scene? existingScene;

  @override
  ConsumerState<SceneEditorDialog> createState() => _SceneEditorDialogState();
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
        return 'once';  // interval → once, т.к. в UI нет interval
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

  @override
  Widget build(BuildContext context) {
    final allDevices = ref.watch(devicesProvider);
    final devices = allDevices.where((d) {
      return d.type == DeviceType.outlet ||
          d.type == DeviceType.switch1 ||
          d.type == DeviceType.switch2 ||
          d.type == DeviceType.switch3 ||
          d.type == DeviceType.light;
    }).toList();

    final presencePhones = ref.watch(presenceSettingsProvider).phones;

    return AlertDialog(
      title: Text(_isEditing ? 'Редактировать сцену' : 'Новая сцена'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Выключить всё',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Тип запуска:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _triggerType,
              decoration: const InputDecoration(labelText: 'Тип запуска'),
              items: const [
                DropdownMenuItem(value: 'manual', child: Text('🎬 Вручную')),
                DropdownMenuItem(value: 'time', child: Text('⏰ По времени')),
                DropdownMenuItem(value: 'sensor', child: Text('🌡️ По датчику')),
                DropdownMenuItem(
                    value: 'presence', child: Text('📍 По присутствию')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _triggerType = value);
              },
            ),
            const SizedBox(height: 16),

            // ─── ТРИГГЕР ПО ВРЕМЕНИ ───
            if (_triggerType == 'time') ...[
              ListTile(
                title: Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:'
                      '${_selectedTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) setState(() => _selectedTime = time);
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _repeatType,
                decoration: const InputDecoration(labelText: 'Повтор'),
                items: const [
                  DropdownMenuItem(value: 'once', child: Text('Один раз')),
                  DropdownMenuItem(value: 'daily', child: Text('Каждый день')),
                  DropdownMenuItem(
                      value: 'weekly', child: Text('По дням недели')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _repeatType = value);
                },
              ),
              if (_repeatType == 'weekly') ...[
                const SizedBox(height: 8),
                const Text('Дни недели:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 4,
                  children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                      .asMap()
                      .entries
                      .map((e) {
                    final dayIndex = e.key + 1;
                    return FilterChip(
                      label: Text(e.value,
                          style: const TextStyle(fontSize: 11)),
                      selected: _selectedDays.contains(dayIndex),
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
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

            // ─── ТРИГГЕР ПО ДАТЧИКУ ───
            if (_triggerType == 'sensor') ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedSensorId,
                decoration: const InputDecoration(labelText: 'Датчик'),
                hint: const Text('Выберите датчик'),
                items: allDevices
                    .where((d) =>
                d.type == DeviceType.sensor ||
                    (d.properties['source'] == 'zigbee' &&
                        d.properties['exposes'] != null))
                    .map((d) => DropdownMenuItem(
                  value: d.id,
                  child: Text(d.name),
                ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedSensorId = value),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedSensorCondition,
                decoration: const InputDecoration(labelText: 'Условие'),
                items: const [
                  DropdownMenuItem(
                      value: 'temperature_above',
                      child: Text('🌡️ Температура >')),
                  DropdownMenuItem(
                      value: 'temperature_below',
                      child: Text('🌡️ Температура <')),
                  DropdownMenuItem(
                      value: 'humidity_above',
                      child: Text('💧 Влажность >')),
                  DropdownMenuItem(
                      value: 'humidity_below',
                      child: Text('💧 Влажность <')),
                  DropdownMenuItem(
                      value: 'water_leak', child: Text('💧 Протечка')),
                  DropdownMenuItem(
                      value: 'motion', child: Text('🏃 Движение')),
                  DropdownMenuItem(
                      value: 'contact_open', child: Text('🚪 Открыто')),
                  DropdownMenuItem(
                      value: 'contact_closed', child: Text('🚪 Закрыто')),
                  DropdownMenuItem(value: 'smoke', child: Text('🔥 Дым')),
                  DropdownMenuItem(value: 'gas', child: Text('💨 Газ')),
                ],
                onChanged: (value) => setState(() =>
                _selectedSensorCondition =
                    value ?? 'temperature_above'),
              ),
              const SizedBox(height: 8),
              if (_selectedSensorCondition.startsWith('temperature') ||
                  _selectedSensorCondition.startsWith('humidity')) ...[
                TextField(
                  controller: _sensorThresholdController,
                  decoration: const InputDecoration(labelText: 'Порог'),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 16),
            ],

            // ─── ТРИГГЕР ПО ПРИСУТСТВИЮ ───
            if (_triggerType == 'presence') ...[
              DropdownButtonFormField<PresenceEvent>(
                initialValue: _selectedPresenceEvent,
                decoration: const InputDecoration(labelText: 'Событие'),
                items: const [
                  DropdownMenuItem(
                      value: PresenceEvent.someoneHome,
                      child: Text('Кто-то пришёл')),
                  DropdownMenuItem(
                      value: PresenceEvent.nobodyHome,
                      child: Text('Никого нет')),
                  DropdownMenuItem(
                      value: PresenceEvent.allHome,
                      child: Text('Все дома')),
                  DropdownMenuItem(
                      value: PresenceEvent.phoneArrived,
                      child: Text('Телефон пришёл')),
                  DropdownMenuItem(
                      value: PresenceEvent.phoneLeft,
                      child: Text('Телефон ушёл')),
                  DropdownMenuItem(
                      value: PresenceEvent.phoneUnknown,
                      child: Text('Телефон потерян')),
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
                  decoration: const InputDecoration(labelText: 'Телефон'),
                  hint: const Text('Выберите телефон'),
                  items: presencePhones
                      .map((p) => DropdownMenuItem(
                    value: p.phoneId,
                    child: Text(p.phoneName),
                  ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedPresencePhoneId = value),
                ),
                const SizedBox(height: 8),
              ],

              InkWell(
                onTap: () => setState(
                        () => _showPresenceAdvanced = !_showPresenceAdvanced),
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
                        'Дополнительно',
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
                  decoration: const InputDecoration(
                      labelText: 'Канал определения'),
                  items: const [
                    DropdownMenuItem(
                        value: PresenceChannel.any, child: Text('Любой')),
                    DropdownMenuItem(
                        value: PresenceChannel.wifi,
                        child: Text('Только Wi-Fi')),
                    DropdownMenuItem(
                        value: PresenceChannel.gps,
                        child: Text('Только GPS')),
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
                  decoration: const InputDecoration(
                      labelText: 'Задержка перед запуском'),
                  items: const [
                    DropdownMenuItem(
                        value: 0, child: Text('Без задержки')),
                    DropdownMenuItem(value: 1, child: Text('1 минута')),
                    DropdownMenuItem(value: 5, child: Text('5 минут')),
                    DropdownMenuItem(value: 30, child: Text('30 минут')),
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
                  decoration:
                  const InputDecoration(labelText: 'Антидребезг'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 минута')),
                    DropdownMenuItem(value: 5, child: Text('5 минут')),
                    DropdownMenuItem(value: 15, child: Text('15 минут')),
                    DropdownMenuItem(value: 30, child: Text('30 минут')),
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
                      ? 'Настроить условия'
                      : 'Условия настроены ✓',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Действия:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (devices.isEmpty)
              const Text('Нет устройств', style: TextStyle(color: Colors.grey))
            else
              ...devices.map((device) {
                final action = _selectedActions[device.id];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(device.name,
                              style: const TextStyle(fontSize: 14)),
                        ),
                        ChoiceChip(
                          label: const Text('ВКЛ',
                              style: TextStyle(fontSize: 11)),
                          selected: action == 'turnOn',
                          selectedColor: Colors.green.withValues(alpha: 0.3),
                          onSelected: (s) => setState(() =>
                          _selectedActions[device.id] =
                          s ? 'turnOn' : null),
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('ВЫКЛ',
                              style: TextStyle(fontSize: 11)),
                          selected: action == 'turnOff',
                          selectedColor: Colors.red.withValues(alpha: 0.3),
                          onSelected: (s) => setState(() =>
                          _selectedActions[device.id] =
                          s ? 'turnOff' : null),
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
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(_isEditing ? 'Сохранить' : 'Создать'),
        ),
      ],
    );
  }

  void _save() {
    final hasActions = _selectedActions.values.any((a) => a != null);
    if (_nameController.text.isEmpty || !hasActions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Введите название и выберите действия'),
        ),
      );
      return;
    }

    final actions = _selectedActions.entries
        .where((e) => e.value != null)
        .map((e) => SceneAction(deviceId: e.key, command: e.value!))
        .toList();

    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime.minute.toString().padLeft(2, '0')}';

    SceneTrigger? trigger;

    if (_triggerType == 'time') {
      trigger = SceneTrigger(
        type: TriggerType.time,
        time: timeStr,
        repeat: RepeatType.values.firstWhere((r) => r.name == _repeatType),
        repeatDays: _repeatType == 'weekly' ? _selectedDays.toList() : null,
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
      name: _nameController.text,
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

    ref.read(scenesProvider.notifier).addScene(scene);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? '✅ Сцена обновлена!' : '✅ Сцена создана!'),
      ),
    );
  }

  Future<PresenceConditions?> _showConditionsDialog(
      BuildContext context) async {
    final conditions = _presenceConditions ?? const PresenceConditions();

    bool useTime = conditions.useTime;
    TimeOfDay startTime = TimeOfDay(
        hour: conditions.startHour, minute: conditions.startMinute);
    TimeOfDay endTime =
    TimeOfDay(hour: conditions.endHour, minute: conditions.endMinute);
    bool useDays = conditions.useDays;
    final Set<int> days = Set.from(conditions.daysOfWeek);

    return showDialog<PresenceConditions>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Условия'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  dense: true,
                  title: const Text('Время суток'),
                  value: useTime,
                  onChanged: (val) => setState(() => useTime = val),
                ),
                if (useTime) ...[
                  ListTile(
                    dense: true,
                    title: Text(
                        'С ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: startTime);
                      if (time != null) setState(() => startTime = time);
                    },
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                        'По ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: endTime);
                      if (time != null) setState(() => endTime = time);
                    },
                  ),
                ],
                const Divider(),
                SwitchListTile(
                  dense: true,
                  title: const Text('Дни недели'),
                  value: useDays,
                  onChanged: (val) => setState(() => useDays = val),
                ),
                if (useDays) ...[
                  Wrap(
                    spacing: 4,
                    children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                        .asMap()
                        .entries
                        .map((e) {
                      final dayIndex = e.key + 1;
                      return FilterChip(
                        label: Text(e.value,
                            style: const TextStyle(fontSize: 11)),
                        selected: days.contains(dayIndex),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, const PresenceConditions()),
              child: const Text('Сбросить'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
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
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}