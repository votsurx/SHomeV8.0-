/// Экран сцен — создание, редактирование и выполнение сценариев автоматизации.
/// Сцены могут запускаться вручную (тап), по времени (через AutomationEngine)
/// или по датчику (через AdaptivePoller), или по присутствию.
/// Поддерживаются повторы: один раз, каждый день, по дням недели.
/// Долгое нажатие открывает меню редактирования/удаления.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/device.dart';
import '../../domain/models/scene.dart';
import '../../domain/models/presence_conditions.dart';
import '../../application/state/scenes_provider.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/presence_provider.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesProvider);
    final devices = ref.watch(devicesProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final crossAxisCount = _calculateCrossAxisCount(screenWidth, isLandscape);
    final tileWidth = _calculateTileWidth(
      screenWidth,
      crossAxisCount,
    );
    final scale = (tileWidth / 160).clamp(0.9, 1.8);

    return Scaffold(
      appBar: AppBar(title: const Text('Сцены')),
      body: scenes.isEmpty
          ? const Center(child: Text('Нет сцен. Создайте первую!'))
          : GridView.builder(
        padding: EdgeInsets.all(8 * scale),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8 * scale,
          mainAxisSpacing: 8 * scale,
        ),
        itemCount: scenes.length,
        itemBuilder: (context, index) {
          final scene = scenes[index];
          return Card(
            child: InkWell(
              onTap: () {
                if (scene.trigger == null || scene.trigger!.type == TriggerType.manual) {
                  ref.read(scenesProvider.notifier).executeScene(scene.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '⏰ Сцена "${scene.name}" запускается автоматически по триггеру',
                        style: TextStyle(fontSize: 12 * scale),
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onLongPress: () => _showSceneMenu(context, ref, scene),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(6 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Заголовок: иконка + название
                    Row(
                      children: [
                        Text(scene.icon, style: TextStyle(fontSize: 16 * scale)),
                        SizedBox(width: 4 * scale),
                        Expanded(
                          child: Text(
                            scene.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11 * scale,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5 * scale),

                    // Информация о триггере
                    _buildTriggerInfo(scene, scale),

                    SizedBox(height: 4 * scale),
                    Divider(height: 1, thickness: 0.5),
                    SizedBox(height: 4 * scale),

                    // Список действий
                    Expanded(
                      child: _buildActionsList(scene, devices, scale),
                    ),

                    // Количество устройств
                    Text(
                      '${scene.actions.length} ${_pluralize(scene.actions.length)}',
                      style: TextStyle(fontSize: 8 * scale, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSceneDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  int _calculateCrossAxisCount(double width, bool isLandscape) {
    if (isLandscape) {
      if (width >= 1200) return 5;
      if (width >= 900) return 4;
      if (width >= 700) return 3;
      return 2;
    }
    if (width >= 900) return 3;
    if (width >= 300) return 2;
    return 1;
  }

  double _calculateTileWidth(double screenWidth, int crossAxisCount) {
    const horizontalPadding = 16.0;
    const spacing = 8.0;
    final available = screenWidth - horizontalPadding - (spacing * (crossAxisCount - 1));
    return available / crossAxisCount;
  }

  /// Отображает информацию о типе запуска
  Widget _buildTriggerInfo(Scene scene, double scale) {
    if (scene.trigger == null || scene.trigger!.type == TriggerType.manual) {
      return Row(
        children: [
          Icon(Icons.touch_app, size: 11 * scale, color: Colors.grey[600]),
          SizedBox(width: 2 * scale),
          Text(
            'Вручную',
            style: TextStyle(fontSize: 9 * scale, color: Colors.grey[600]),
          ),
        ],
      );
    }

    switch (scene.trigger!.type) {
      case TriggerType.time:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('⏰', style: TextStyle(fontSize: 11 * scale)),
                SizedBox(width: 2 * scale),
                Text(
                  scene.trigger!.time ?? '--:--',
                  style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (scene.trigger!.repeat != RepeatType.once) ...[
              SizedBox(height: 2 * scale),
              if (scene.trigger!.repeat == RepeatType.weekly &&
                  scene.trigger!.repeatDays?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Text('🔄', style: TextStyle(fontSize: 9 * scale)),
                    SizedBox(width: 2 * scale),
                    Expanded(
                      child: Text(
                        _daysLabel(scene.trigger!.repeatDays),
                        style: TextStyle(fontSize: 8 * scale, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Text('🔄', style: TextStyle(fontSize: 9 * scale)),
                    SizedBox(width: 2 * scale),
                    Expanded(
                      child: Text(
                        _repeatLabel(scene.trigger!.repeat),
                        style: TextStyle(fontSize: 8 * scale, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (scene.trigger!.repeat == RepeatType.weekly &&
                    scene.trigger!.repeatDays?.isNotEmpty != true)
                  Padding(
                    padding: EdgeInsets.only(left: 14 * scale),
                    child: Text(
                      _repeatLabel(scene.trigger!.repeat),
                      style: TextStyle(fontSize: 7 * scale, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ],
          ],
        );

      case TriggerType.deviceState:
        return Row(
          children: [
            Text('🌡️', style: TextStyle(fontSize: 11 * scale)),
            SizedBox(width: 2 * scale),
            Expanded(
              child: Text(
                _sensorConditionLabel(scene.trigger!),
                style: TextStyle(fontSize: 8 * scale),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

      case TriggerType.presence:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('📍', style: TextStyle(fontSize: 11 * scale)),
                SizedBox(width: 2 * scale),
                Expanded(
                  child: Text(
                    _presenceEventLabel(scene.trigger!),
                    style: TextStyle(fontSize: 9 * scale, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (scene.trigger!.presencePhoneId != null) ...[
              SizedBox(height: 2 * scale),
              Text(
                _presencePhoneLabel(scene.trigger!),
                style: TextStyle(fontSize: 8 * scale, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (scene.trigger!.presenceChannel != PresenceChannel.any) ...[
              SizedBox(height: 2 * scale),
              Text(
                _presenceChannelLabel(scene.trigger!.presenceChannel),
                style: TextStyle(fontSize: 7 * scale, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Отображает список действий компактно
  Widget _buildActionsList(Scene scene, List<Device> devices, double scale) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scene.actions.length,
      itemBuilder: (context, index) {
        final action = scene.actions[index];
        final device = devices.where((d) => d.id == action.deviceId).firstOrNull;
        final deviceName = device?.name ?? 'Устройство';
        final deviceIcon = _getDeviceIcon(device?.type);
        final actionLabel = _actionLabel(action.command);
        final actionColor = _actionColor(action.command);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 1 * scale),
          child: Row(
            children: [
              Text(deviceIcon, style: TextStyle(fontSize: 9 * scale)),
              SizedBox(width: 2 * scale),
              Expanded(
                child: Text(
                  deviceName,
                  style: TextStyle(fontSize: 8 * scale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3 * scale, vertical: 1),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 7 * scale,
                    fontWeight: FontWeight.bold,
                    color: actionColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Возвращает иконку устройства
  String _getDeviceIcon(DeviceType? type) {
    switch (type) {
      case DeviceType.outlet: return '🔌';
      case DeviceType.switch1:
      case DeviceType.switch2:
      case DeviceType.switch3: return '💡';
      case DeviceType.light: return '💡';
      case DeviceType.sensor: return '🌡️';
      case DeviceType.camera: return '📹';
      case DeviceType.compound: return '🤖';
      default: return '📦';
    }
  }

  /// Возвращает текст действия
  String _actionLabel(String command) {
    switch (command) {
      case 'turnOn': return 'ВКЛ';
      case 'turnOff': return 'ВЫКЛ';
      case 'setBrightness': return 'ЯРК';
      default: return command.toUpperCase();
    }
  }

  /// Возвращает цвет действия
  Color _actionColor(String command) {
    switch (command) {
      case 'turnOn': return Colors.green;
      case 'turnOff': return Colors.red;
      case 'setBrightness': return Colors.orange;
      default: return Colors.blue;
    }
  }

  /// Возвращает текст условия датчика
  String _sensorConditionLabel(SceneTrigger trigger) {
    final condition = trigger.sensorCondition ?? '';
    final threshold = trigger.sensorThreshold ?? 0;

    switch (condition) {
      case 'temperature_above': return 'Темп. > $threshold°C';
      case 'temperature_below': return 'Темп. < $threshold°C';
      case 'humidity_above': return 'Влаж. > $threshold%';
      case 'humidity_below': return 'Влаж. < $threshold%';
      default: return '$condition $threshold';
    }
  }

  /// Возвращает текст события присутствия
  String _presenceEventLabel(SceneTrigger trigger) {
    final event = trigger.presenceEvent;
    if (event == null) return 'Присутствие';

    switch (event) {
      case PresenceEvent.someoneHome: return 'Кто-то пришёл';
      case PresenceEvent.nobodyHome: return 'Никого нет';
      case PresenceEvent.allHome: return 'Все дома';
      case PresenceEvent.phoneArrived: return 'Телефон пришёл';
      case PresenceEvent.phoneLeft: return 'Телефон ушёл';
      case PresenceEvent.phoneUnknown: return 'Телефон потерян';
    }
  }

  /// Возвращает имя телефона для триггера присутствия
  String _presencePhoneLabel(SceneTrigger trigger) {
    return trigger.presencePhoneId ?? '';
  }

  /// Возвращает текст канала
  String _presenceChannelLabel(PresenceChannel channel) {
    switch (channel) {
      case PresenceChannel.any: return 'Любой канал';
      case PresenceChannel.wifi: return 'Wi-Fi';
      case PresenceChannel.gps: return 'GPS';
    }
  }

  /// Склонение слова "устройство"
  String _pluralize(int count) {
    if (count == 1) return 'устр.';
    if (count >= 2 && count <= 4) return 'устр.';
    return 'устр.';
  }

  String _repeatLabel(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.daily: return 'Каждый день';
      case RepeatType.weekly: return 'По дням недели';
      case RepeatType.interval: return 'Интервал';
      default: return '';
    }
  }

  String _daysLabel(List<int>? days) {
    if (days == null || days.isEmpty) return '';
    final names = ['', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days.map((d) => names[d]).join(', ');
  }

  void _showSceneMenu(BuildContext context, WidgetRef ref, Scene scene) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Редактировать'),
              onTap: () { Navigator.pop(ctx); _showCreateSceneDialog(context, ref, existingScene: scene); },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить'),
              onTap: () { Navigator.pop(ctx); ref.read(scenesProvider.notifier).deleteScene(scene.id); },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSceneDialog(BuildContext context, WidgetRef ref, {Scene? existingScene}) {
    final isEditing = existingScene != null;
    final nameController = TextEditingController(text: existingScene?.name ?? '');
    final allDevices = ref.read(devicesProvider);

    final devices = allDevices.where((d) {
      return d.type == DeviceType.outlet || d.type == DeviceType.switch1 ||
          d.type == DeviceType.switch2 || d.type == DeviceType.switch3 || d.type == DeviceType.light;
    }).toList();

    final Map<String, String?> selectedActions = {};
    if (existingScene != null) {
      for (final action in existingScene.actions) {
        selectedActions[action.deviceId] = action.command;
      }
    }

    String triggerType = existingScene?.trigger?.type.name ?? 'manual';
    TimeOfDay selectedTime = _parseTime(existingScene?.trigger?.time) ?? const TimeOfDay(hour: 22, minute: 0);
    String repeatType = existingScene?.trigger?.repeat.name ?? 'once';
    final Set<int> selectedDays = Set.from(existingScene?.trigger?.repeatDays ?? []);

    String? selectedSensorId = existingScene?.trigger?.sensorDeviceId;
    String selectedSensorCondition = existingScene?.trigger?.sensorCondition ?? 'temperature_above';
    final sensorThresholdController = TextEditingController(
        text: '${existingScene?.trigger?.sensorThreshold ?? 30}'
    );

    // ─── Присутствие ───
    PresenceEvent selectedPresenceEvent =
        existingScene?.trigger?.presenceEvent ?? PresenceEvent.someoneHome;
    String? selectedPresencePhoneId = existingScene?.trigger?.presencePhoneId;
    PresenceChannel selectedPresenceChannel =
        existingScene?.trigger?.presenceChannel ?? PresenceChannel.gps;
    int presenceDelayMin = existingScene?.trigger?.presenceDelayMin ?? 0;
    int presenceCooldownMin = existingScene?.trigger?.presenceCooldownMin ?? 1;
    PresenceConditions? presenceConditions = existingScene?.trigger?.presenceConditions;
    bool showPresenceAdvanced = false;

    // Телефоны из настроек присутствия
    final presenceSettings = ref.read(presenceSettingsProvider);
    final presencePhones = presenceSettings.phones;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Редактировать сцену' : 'Новая сцена'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название', hintText: 'Выключить всё')),
                const SizedBox(height: 16),
                const Text('Тип запуска:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Dropdown вместо SegmentedButton — 4 типа не влезают
                DropdownButtonFormField<String>(
                  initialValue: triggerType,
                  decoration: const InputDecoration(labelText: 'Тип запуска'),
                  items: const [
                    DropdownMenuItem(value: 'manual', child: Text('🎬 Вручную')),
                    DropdownMenuItem(value: 'time', child: Text('⏰ По времени')),
                    DropdownMenuItem(value: 'sensor', child: Text('🌡️ По датчику')),
                    DropdownMenuItem(value: 'presence', child: Text('📍 По присутствию')),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => triggerType = value);
                  },
                ),
                const SizedBox(height: 16),

                // ─── ТРИГГЕР ПО ВРЕМЕНИ ───
                if (triggerType == 'time') ...[
                  ListTile(
                    title: Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async { final time = await showTimePicker(context: context, initialTime: selectedTime); if (time != null) setDialogState(() => selectedTime = time); },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: repeatType, decoration: const InputDecoration(labelText: 'Повтор'),
                    items: const [DropdownMenuItem(value: 'once', child: Text('Один раз')), DropdownMenuItem(value: 'daily', child: Text('Каждый день')), DropdownMenuItem(value: 'weekly', child: Text('По дням недели'))],
                    onChanged: (value) { if (value != null) setDialogState(() => repeatType = value); },
                  ),
                  if (repeatType == 'weekly') ...[
                    const SizedBox(height: 8), const Text('Дни недели:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(spacing: 4, children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'].asMap().entries.map((e) {
                      final dayIndex = e.key + 1;
                      return FilterChip(label: Text(e.value, style: const TextStyle(fontSize: 11)), selected: selectedDays.contains(dayIndex), onSelected: (sel) { setDialogState(() { if (sel) { selectedDays.add(dayIndex); } else { selectedDays.remove(dayIndex); } }); },);
                    }).toList()),
                  ],
                  const SizedBox(height: 16),
                ],

                // ─── ТРИГГЕР ПО ДАТЧИКУ ───
                if (triggerType == 'sensor') ...[
                  DropdownButtonFormField<String>(
                    initialValue: selectedSensorId,
                    decoration: const InputDecoration(labelText: 'Датчик'),
                    hint: const Text('Выберите датчик'),
                    items: allDevices.where((d) => d.type == DeviceType.sensor).map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                    onChanged: (value) => setDialogState(() => selectedSensorId = value),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSensorCondition,
                    decoration: const InputDecoration(labelText: 'Условие'),
                    items: const [
                      DropdownMenuItem(value: 'temperature_above', child: Text('Температура >')),
                      DropdownMenuItem(value: 'temperature_below', child: Text('Температура <')),
                      DropdownMenuItem(value: 'humidity_above', child: Text('Влажность >')),
                      DropdownMenuItem(value: 'humidity_below', child: Text('Влажность <')),
                    ],
                    onChanged: (value) => setDialogState(() => selectedSensorCondition = value ?? 'temperature_above'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: sensorThresholdController,
                    decoration: const InputDecoration(labelText: 'Порог'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                ],

                // ─── ТРИГГЕР ПО ПРИСУТСТВИЮ ───
                if (triggerType == 'presence') ...[
                  // Событие
                  DropdownButtonFormField<PresenceEvent>(
                    initialValue: selectedPresenceEvent,
                    decoration: const InputDecoration(labelText: 'Событие'),
                    items: const [
                      DropdownMenuItem(value: PresenceEvent.someoneHome, child: Text('Кто-то пришёл')),
                      DropdownMenuItem(value: PresenceEvent.nobodyHome, child: Text('Никого нет')),
                      DropdownMenuItem(value: PresenceEvent.allHome, child: Text('Все дома')),
                      DropdownMenuItem(value: PresenceEvent.phoneArrived, child: Text('Телефон пришёл')),
                      DropdownMenuItem(value: PresenceEvent.phoneLeft, child: Text('Телефон ушёл')),
                      DropdownMenuItem(value: PresenceEvent.phoneUnknown, child: Text('Телефон потерян')),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedPresenceEvent = value);
                    },
                  ),
                  const SizedBox(height: 8),

                  // Телефон (для конкретных событий)
                  if (selectedPresenceEvent == PresenceEvent.phoneArrived ||
                      selectedPresenceEvent == PresenceEvent.phoneLeft ||
                      selectedPresenceEvent == PresenceEvent.phoneUnknown) ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedPresencePhoneId,
                      decoration: const InputDecoration(labelText: 'Телефон'),
                      hint: const Text('Выберите телефон'),
                      items: presencePhones
                          .map((p) => DropdownMenuItem(
                        value: p.phoneId,
                        child: Text(p.phoneName),
                      ))
                          .toList(),
                      onChanged: (value) => setDialogState(() => selectedPresencePhoneId = value),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Раскрывающиеся "Дополнительно"
                  InkWell(
                    onTap: () => setDialogState(() => showPresenceAdvanced = !showPresenceAdvanced),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            showPresenceAdvanced ? Icons.expand_less : Icons.expand_more,
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

                  if (showPresenceAdvanced) ...[
                    // Канал
                    DropdownButtonFormField<PresenceChannel>(
                      initialValue: selectedPresenceChannel,
                      decoration: const InputDecoration(labelText: 'Канал определения'),
                      items: const [
                        DropdownMenuItem(value: PresenceChannel.any, child: Text('Любой')),
                        DropdownMenuItem(value: PresenceChannel.wifi, child: Text('Только Wi-Fi')),
                        DropdownMenuItem(value: PresenceChannel.gps, child: Text('Только GPS')),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => selectedPresenceChannel = value);
                      },
                    ),
                    const SizedBox(height: 8),

                    // Задержка
                    DropdownButtonFormField<int>(
                      initialValue: presenceDelayMin,
                      decoration: const InputDecoration(labelText: 'Задержка перед запуском'),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Без задержки')),
                        DropdownMenuItem(value: 1, child: Text('1 минута')),
                        DropdownMenuItem(value: 5, child: Text('5 минут')),
                        DropdownMenuItem(value: 30, child: Text('30 минут')),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => presenceDelayMin = value);
                      },
                    ),
                    const SizedBox(height: 8),

                    // Антидребезг
                    DropdownButtonFormField<int>(
                      initialValue: presenceCooldownMin,
                      decoration: const InputDecoration(labelText: 'Антидребезг'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 минута')),
                        DropdownMenuItem(value: 5, child: Text('5 минут')),
                        DropdownMenuItem(value: 15, child: Text('15 минут')),
                        DropdownMenuItem(value: 30, child: Text('30 минут')),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => presenceCooldownMin = value);
                      },
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Кнопка "Настроить условия"
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await _showConditionsDialog(
                        context,
                        presenceConditions,
                      );
                      if (result != null) {
                        setDialogState(() => presenceConditions = result);
                      }
                    },
                    icon: const Icon(Icons.tune, size: 16),
                    label: Text(
                      presenceConditions == null
                          ? 'Настроить условия'
                          : 'Условия настроены ✓',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Text('Действия:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
                if (devices.isEmpty) const Text('Нет устройств', style: TextStyle(color: Colors.grey))
                else ...devices.map((device) {
                  final action = selectedActions[device.id];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(children: [
                        Expanded(child: Text(device.name, style: const TextStyle(fontSize: 14))),
                        ChoiceChip(label: const Text('ВКЛ', style: TextStyle(fontSize: 11)), selected: action == 'turnOn', selectedColor: Colors.green.withValues(alpha: 0.3), onSelected: (s) => setDialogState(() => selectedActions[device.id] = s ? 'turnOn' : null)),
                        const SizedBox(width: 4),
                        ChoiceChip(label: const Text('ВЫКЛ', style: TextStyle(fontSize: 11)), selected: action == 'turnOff', selectedColor: Colors.red.withValues(alpha: 0.3), onSelected: (s) => setDialogState(() => selectedActions[device.id] = s ? 'turnOff' : null)),
                      ]),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                final hasActions = selectedActions.values.any((a) => a != null);
                if (nameController.text.isNotEmpty && hasActions) {
                  final actions = selectedActions.entries.where((e) => e.value != null).map((e) => SceneAction(deviceId: e.key, command: e.value!)).toList();
                  final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                  SceneTrigger? trigger;

                  if (triggerType == 'time') {
                    trigger = SceneTrigger(
                      type: TriggerType.time,
                      time: timeStr,
                      repeat: RepeatType.values.firstWhere((r) => r.name == repeatType),
                      repeatDays: repeatType == 'weekly' ? selectedDays.toList() : null,
                    );
                  } else if (triggerType == 'sensor') {
                    trigger = SceneTrigger(
                      type: TriggerType.deviceState,
                      sensorDeviceId: selectedSensorId,
                      sensorCondition: selectedSensorCondition,
                      sensorThreshold: double.tryParse(sensorThresholdController.text) ?? 30,
                    );
                  } else if (triggerType == 'presence') {
                    trigger = SceneTrigger(
                      type: TriggerType.presence,
                      presenceEvent: selectedPresenceEvent,
                      presencePhoneId: selectedPresencePhoneId,
                      presenceChannel: selectedPresenceChannel,
                      presenceDelayMin: presenceDelayMin,
                      presenceCooldownMin: presenceCooldownMin,
                      presenceConditions: presenceConditions,
                    );
                  }

                  final scene = Scene(
                    id: existingScene?.id ?? const Uuid().v4(),
                    name: nameController.text,
                    icon: triggerType == 'time'
                        ? '⏰'
                        : triggerType == 'sensor'
                        ? '🌡️'
                        : triggerType == 'presence'
                        ? '📍'
                        : '🎬',
                    actions: actions,
                    trigger: trigger,
                  );

                  ref.read(scenesProvider.notifier).addScene(scene);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? '✅ Сцена обновлена!' : '✅ Сцена создана!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Введите название и выберите действия')));
                }
              },
              child: Text(isEditing ? 'Сохранить' : 'Создать'),
            ),
          ],
        ),
      ),
    );
  }

  /// Диалог условий для триггера присутствия.
  Future<PresenceConditions?> _showConditionsDialog(
      BuildContext context,
      PresenceConditions? current,
      ) async {
    final conditions = current ?? const PresenceConditions();

    bool useTime = conditions.useTime;
    TimeOfDay startTime = TimeOfDay(
      hour: conditions.startHour,
      minute: conditions.startMinute,
    );
    TimeOfDay endTime = TimeOfDay(
      hour: conditions.endHour,
      minute: conditions.endMinute,
    );
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
                // Время суток
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
                      'С ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                      );
                      if (time != null) setState(() => startTime = time);
                    },
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      'По ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                      );
                      if (time != null) setState(() => endTime = time);
                    },
                  ),
                ],
                const Divider(),

                // Дни недели
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
                        label: Text(e.value, style: const TextStyle(fontSize: 11)),
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
              onPressed: () => Navigator.pop(ctx, const PresenceConditions()),
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

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}