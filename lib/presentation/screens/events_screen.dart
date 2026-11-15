/// Экран журнала событий.
/// Показывает историю всех действий: вкл/выкл, сцены, ошибки, онлайн/оффлайн,
/// алерты Zigbee/Frigate.
/// Каждый тип события имеет свой цвет и иконку.
/// Фильтры: чипсы по категориям + dropdown по устройствам.
/// Кнопки: обновить, очистить всё.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../application/state/devices_provider.dart';

/// Категории событий для фильтра.
enum EventCategory { all, alerts, actions, errors }

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  List<dynamic> _events = [];
  bool _loading = true;
  EventCategory _category = EventCategory.all;
  String? _selectedDeviceId;   // null = все устройства

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await AppDatabase.getRecentEvents(limit: 200);
    if (!mounted) return;
    setState(() {
      _events = events;
      _loading = false;
    });
  }

  // ═══════════════════════════════════════════════════════════
  // ФИЛЬТРАЦИЯ
  // ═══════════════════════════════════════════════════════════

  List<dynamic> get _filteredEvents {
    return _events.where((e) {
      final event = e.event as String? ?? '';

      // Фильтр по категории
      switch (_category) {
        case EventCategory.alerts:
          if (!event.startsWith('alarm_') &&
              !event.startsWith('frigate_')) {
            return false;
          }
          break;
        case EventCategory.actions:
          if (!['turnOn', 'turnOff', 'scene', 'roomAdded', 'roomRemoved',
            'timer', 'deviceAdded', 'deviceRemoved', 'sceneCreated',
            'sceneDeleted'].contains(event)) {
            return false;
          }
          break;
        case EventCategory.errors:
          if (!['offline', 'online', 'error'].contains(event)) {
            return false;
          }
          break;
        case EventCategory.all:
          break;
      }

      // Фильтр по устройству
      if (_selectedDeviceId != null && e.deviceId != _selectedDeviceId) {
        return false;
      }

      return true;
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════
  // ИКОНКИ / ЦВЕТА / МЕТКИ
  // ═══════════════════════════════════════════════════════════

  IconData _eventIcon(String event) {
    // Действия
    switch (event) {
      case 'turnOn':
        return Icons.power_settings_new;
      case 'turnOff':
        return Icons.power_off;
      case 'scene':
        return Icons.movie;
      case 'roomAdded':
        return Icons.add_home;
      case 'roomRemoved':
        return Icons.remove_circle;
      case 'timer':
        return Icons.timer;
      case 'deviceAdded':
        return Icons.add_circle;
      case 'deviceRemoved':
        return Icons.delete;
      case 'sceneCreated':
        return Icons.movie_creation;
      case 'sceneDeleted':
        return Icons.movie_filter;
    }

    // Алерты
    if (event == 'alarm_water_leak') return Icons.water_drop;
    if (event == 'alarm_smoke') return Icons.local_fire_department;
    if (event == 'alarm_gas') return Icons.gas_meter;
    if (event == 'alarm_motion') return Icons.directions_run;
    if (event == 'alarm_contact_open' ||
        event == 'alarm_contact_closed') {
      return Icons.door_front_door;
    }
    if (event == 'alarm_temperature_above' ||
        event == 'alarm_temperature_below') {
      return Icons.thermostat;
    }
    if (event == 'alarm_humidity_above' ||
        event == 'alarm_humidity_below') {
      return Icons.water;
    }

    // Frigate
    if (event == 'frigate_person') return Icons.person;
    if (event == 'frigate_car') return Icons.directions_car;
    if (event == 'frigate_dog') return Icons.pets;
    if (event == 'frigate_cat') return Icons.pets;
    if (event == 'frigate_bird') return Icons.flutter_dash;
    if (event.startsWith('frigate_')) return Icons.videocam;

    // Ошибки
    switch (event) {
      case 'online':
        return Icons.wifi;
      case 'offline':
        return Icons.wifi_off;
      case 'error':
        return Icons.error;
    }

    return Icons.circle;
  }

  Color _eventColor(String event) {
    // Алерты
    if (event.startsWith('alarm_') || event.startsWith('frigate_')) {
      return Colors.red;
    }

    // Ошибки
    if (event == 'offline') return Colors.grey;
    if (event == 'online') return Colors.green;
    if (event == 'error') return Colors.orange;

    // Действия
    if (event == 'turnOn') return Colors.green;
    if (event == 'turnOff') return Colors.red;
    if (event == 'scene') return Colors.purple;

    return Colors.blue;
  }

  String _eventLabel(String event) {
    // Действия
    switch (event) {
      case 'turnOn':
        return 'Включено';
      case 'turnOff':
        return 'Выключено';
      case 'scene':
        return 'Сцена';
      case 'roomAdded':
        return 'Комната добавлена';
      case 'roomRemoved':
        return 'Комната удалена';
      case 'timer':
        return 'Таймер';
      case 'deviceAdded':
        return 'Устройство добавлено';
      case 'deviceRemoved':
        return 'Устройство удалено';
      case 'sceneCreated':
        return 'Сцена создана';
      case 'sceneDeleted':
        return 'Сцена удалена';
    }

    // Алерты
    if (event == 'alarm_water_leak') return '💧 Протечка';
    if (event == 'alarm_smoke') return '🔥 Дым';
    if (event == 'alarm_gas') return '💨 Газ';
    if (event == 'alarm_motion') return '🏃 Движение';
    if (event == 'alarm_contact_open') return '🚪 Открыто';
    if (event == 'alarm_contact_closed') return '🚪 Закрыто';
    if (event == 'alarm_temperature_above') return '🌡️ Температура >';
    if (event == 'alarm_temperature_below') return '🌡️ Температура <';
    if (event == 'alarm_humidity_above') return '💧 Влажность >';
    if (event == 'alarm_humidity_below') return '💧 Влажность <';

    // Frigate
    if (event.startsWith('frigate_')) {
      final label = event.replaceFirst('frigate_', '');
      return '🎥 $label';
    }

    // Ошибки
    switch (event) {
      case 'online':
        return 'В сети';
      case 'offline':
        return 'Не в сети';
      case 'error':
        return 'Ошибка';
    }

    return event;
  }

  // ═══════════════════════════════════════════════════════════
  // ФОРМИРОВАНИЕ TITLE / SUBTITLE
  // ═══════════════════════════════════════════════════════════

  /// Title: имя устройства (или сцены) + канал в скобках, если есть.
  /// Пример: "Свет Зал (Канал 2)" или "Розетка".
  String _buildTitle(dynamic event) {
    // Сцена — показываем имя сцены
    if (event.sceneName != null) {
      return '${event.sceneName}';
    }

    final deviceName = (event.deviceName as String?) ?? '';
    final value = (event.value as String?) ?? '';

    // Если value — "Канал N", добавляем в скобках к имени
    if (value.startsWith('Канал ')) {
      return '$deviceName ($value)';
    }

    return deviceName;
  }

  /// Subtitle: действие + дополнительное значение (если оно не канал).
  /// Пример: "Включено" или "🌡️ Температура > · 32.5°C".
  String _buildSubtitle(dynamic event) {
    if (event.sceneName != null) {
      return 'Сцена выполнена';
    }

    final eventType = (event.event as String?) ?? '';
    final value = (event.value as String?) ?? '';
    final label = _eventLabel(eventType);

    // Канал уже в title — не дублируем
    if (value.startsWith('Канал ')) {
      return label;
    }

    // Для алертов и Frigate value — полезная инфа (температура, %)
    if (value.isNotEmpty) {
      return '$label · $value';
    }

    return label;
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final filtered = _filteredEvents;

    // Устройства, у которых есть события
    final eventDeviceIds = _events
        .map((e) => e.deviceId as String?)
        .whereType<String>()
        .toSet();
    final availableDevices = devices
        .where((d) => eventDeviceIds.contains(d.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('События'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _loadEvents,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Очистить всё',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Очистить события?'),
                  content: const Text(
                      'Все события будут удалены безвозвратно.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text('Очистить'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await AppDatabase.clearEvents();
                _loadEvents();
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // ─── Фильтры ───
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Чипсы по категориям
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(
                          'Все', EventCategory.all, null),
                      const SizedBox(width: 4),
                      _buildCategoryChip(
                          'Алерты', EventCategory.alerts, null),
                      const SizedBox(width: 4),
                      _buildCategoryChip(
                          'Действия', EventCategory.actions, null),
                      const SizedBox(width: 4),
                      _buildCategoryChip(
                          'Ошибки', EventCategory.errors, null),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Dropdown по устройствам
                DropdownButtonFormField<String?>(
                  initialValue: _selectedDeviceId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Устройство',
                    prefixIcon: Icon(Icons.devices),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Все устройства'),
                    ),
                    ...availableDevices.map((d) => DropdownMenuItem<String?>(
                      value: d.id,
                      child: Text(d.name),
                    )),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedDeviceId = v),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ─── Список событий ───
          Expanded(
            child: filtered.isEmpty
                ? const Center(
              child: Text('Нет событий по фильтру'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final event = filtered[index];
                final timestamp = event.timestamp;
                if (timestamp == null) {
                  return const SizedBox.shrink();
                }

                final time = DateTime.parse(timestamp);
                final timeStr =
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
                final eventType = event.event ?? '';

                return Card(
                  child: ListTile(
                    leading: Icon(
                      _eventIcon(eventType),
                      color: _eventColor(eventType),
                    ),
                    title: Text(
                      _buildTitle(event),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      _buildSubtitle(event),
                      style: TextStyle(
                        color: _eventColor(eventType),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: Text(
                      timeStr,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
      String label,
      EventCategory category,
      IconData? icon,
      ) {
    return FilterChip(
      label: Text(label),
      selected: _category == category,
      onSelected: (_) => setState(() => _category = category),
    );
  }
}