/// Экран сцен — создание, редактирование и выполнение сценариев автоматизации.
/// Сцены могут запускаться вручную (тап), по времени (через AutomationEngine)
/// или по датчику (через AdaptivePoller).
/// Поддерживаются повторы: один раз, каждый день, по дням недели.
/// Долгое нажатие открывает меню редактирования/удаления.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/device.dart';
import '../../domain/models/scene.dart';
import '../../application/state/scenes_provider.dart';
import '../../application/state/devices_provider.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesProvider);
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Сцены')),
      body: scenes.isEmpty
          ? const Center(child: Text('Нет сцен. Создайте первую!'))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
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
                        style: const TextStyle(fontSize: 12),
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Заголовок: иконка + название
                    Row(
                      children: [
                        Text(scene.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            scene.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Информация о триггере
                    _buildTriggerInfo(scene),

                    const SizedBox(height: 4),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 4),

                    // Список действий
                    Expanded(
                      child: _buildActionsList(scene, devices),
                    ),

                    // Количество устройств
                    Text(
                      '${scene.actions.length} ${_pluralize(scene.actions.length)}',
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
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

  /// Отображает информацию о типе запуска
  Widget _buildTriggerInfo(Scene scene) {
    if (scene.trigger == null || scene.trigger!.type == TriggerType.manual) {
      return Row(
        children: [
          Icon(Icons.touch_app, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 2),
          Text(
            'Вручную',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
                Text('⏰', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 2),
                Text(
                  scene.trigger!.time ?? '--:--',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (scene.trigger!.repeat != RepeatType.once) ...[
              const SizedBox(height: 2),
              if (scene.trigger!.repeat == RepeatType.weekly &&
                  scene.trigger!.repeatDays?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Text('🔄', style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        _daysLabel(scene.trigger!.repeatDays),
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Text('🔄', style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        _repeatLabel(scene.trigger!.repeat),
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (scene.trigger!.repeat == RepeatType.weekly &&
                    scene.trigger!.repeatDays?.isNotEmpty != true)
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      _repeatLabel(scene.trigger!.repeat),
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
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
            Text('🌡️', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                _sensorConditionLabel(scene.trigger!),
                style: const TextStyle(fontSize: 9),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Отображает список действий компактно
  Widget _buildActionsList(Scene scene, List<Device> devices) {
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
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Text(deviceIcon, style: const TextStyle(fontSize: 10)),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  deviceName,
                  style: const TextStyle(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 8,
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

    // Переменные для сенсорного триггера
    String? selectedSensorId = existingScene?.trigger?.sensorDeviceId;
    String selectedSensorCondition = existingScene?.trigger?.sensorCondition ?? 'temperature_above';
    final sensorThresholdController = TextEditingController(
        text: '${existingScene?.trigger?.sensorThreshold ?? 30}'
    );

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
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'manual', label: Text('Вручную')),
                    ButtonSegment(value: 'time', label: Text('По времени')),
                    ButtonSegment(value: 'sensor', label: Text('По датчику')),
                  ],
                  selected: {triggerType},
                  onSelectionChanged: (value) => setDialogState(() => triggerType = value.first),
                ),
                const SizedBox(height: 16),

                // ====== Триггер по времени ======
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

                // ====== Триггер по датчику ======
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

                  final scene = Scene(
                    id: existingScene?.id ?? const Uuid().v4(),
                    name: nameController.text,
                    icon: triggerType == 'time' ? '⏰' : (triggerType == 'sensor' ? '🌡️' : '🎬'),
                    actions: actions,
                    trigger: triggerType == 'time'
                        ? SceneTrigger(
                      type: TriggerType.time,
                      time: timeStr,
                      repeat: RepeatType.values.firstWhere((r) => r.name == repeatType),
                      repeatDays: repeatType == 'weekly' ? selectedDays.toList() : null,
                    )
                        : triggerType == 'sensor'
                        ? SceneTrigger(
                      type: TriggerType.deviceState,
                      sensorDeviceId: selectedSensorId,
                      sensorCondition: selectedSensorCondition,
                      sensorThreshold: double.tryParse(sensorThresholdController.text) ?? 30,
                    )
                        : null,
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

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}