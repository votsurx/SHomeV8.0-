/// Экран журнала событий.
/// Читает из StatsCache (последние 200) + БД (старые, пагинация).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/services/stats_cache.dart';
import '../../application/state/devices_provider.dart';

enum EventCategory { all, alerts, actions, errors }

enum _PresenceVisualState {
  away,
  homeCloud,
  homeWifi,
  home,
  unknown,
}

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  static const _pageSize = 50;

  // Последние события из StatsCache — показываются сверху.
  List<dynamic> _cacheEvents = [];

  // Более старые события из БД — подгружаются при прокрутке.
  final List<dynamic> _dbEvents = [];

  int _dbOffset = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMoreDb = true;

  EventCategory _category = EventCategory.all;
  String? _selectedDeviceId;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    StatsCache.instance.addListener(_onCacheChanged);
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    StatsCache.instance.removeListener(_onCacheChanged);
    _scrollController.dispose();
    super.dispose();
  }

  bool _isPresenceEvent(String event) {
    return event.startsWith('Присутствие:');
  }

  void _onCacheChanged() {
    if (!mounted) return;

    setState(() {
      _cacheEvents = StatsCache.instance.recentEvents.reversed.toList();
    });
  }

  Future<void> _loadInitial() async {
    if (mounted) {
      setState(() => _loading = true);
    }

    _cacheEvents = StatsCache.instance.recentEvents.reversed.toList();

    final exclude = _cacheEvents
        .map((event) =>
    '${event.timestamp}|${event.event}|${event.deviceId ?? ''}')
        .toSet();

    final dbEvents = await AppDatabase.getEventsPaginated(
      limit: _pageSize,
      offset: 0,
      excludeKeys: exclude,
    );

    if (!mounted) return;

    setState(() {
      _dbEvents
        ..clear()
        ..addAll(dbEvents);
      _dbOffset = _pageSize;
      _hasMoreDb = dbEvents.length == _pageSize;
      _loading = false;
    });
  }

  Future<void> _loadMoreFromDb() async {
    if (_loadingMore || !_hasMoreDb) return;

    setState(() => _loadingMore = true);

    final exclude = _cacheEvents
        .map((event) =>
    '${event.timestamp}|${event.event}|${event.deviceId ?? ''}')
        .toSet();

    final more = await AppDatabase.getEventsPaginated(
      limit: _pageSize,
      offset: _dbOffset,
      excludeKeys: exclude,
    );

    if (!mounted) return;

    setState(() {
      _dbEvents.addAll(more);
      _dbOffset += _pageSize;
      _hasMoreDb = more.length == _pageSize;
      _loadingMore = false;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreFromDb();
    }
  }

  // ═══ ФИЛЬТРАЦИЯ ═══

  List<dynamic> get _allEvents => [..._cacheEvents, ..._dbEvents];

  List<dynamic> get _filteredEvents {
    return _allEvents.where((eventEntity) {
      final event = eventEntity.event as String? ?? '';

      switch (_category) {
        case EventCategory.alerts:
          if (!event.startsWith('alarm_') &&
              !event.startsWith('frigate_')) {
            return false;
          }
          break;

        case EventCategory.actions:
          const actionEvents = {
            'turnOn',
            'turnOff',
            'scene',
            'roomAdded',
            'roomRemoved',
            'timer',
            'deviceAdded',
            'deviceRemoved',
            'sceneCreated',
            'sceneDeleted',
          };

          if (!actionEvents.contains(event) && !_isPresenceEvent(event)) {
            return false;
          }
          break;

        case EventCategory.errors:
          if (!{'offline', 'online', 'error'}.contains(event)) {
            return false;
          }
          break;

        case EventCategory.all:
          break;
      }

      if (_selectedDeviceId != null &&
          eventEntity.deviceId != _selectedDeviceId) {
        return false;
      }

      return true;
    }).toList();
  }

  // ═══ СОСТОЯНИЕ ПРИСУТСТВИЯ ═══

  /// Возвращает часть после стрелки, то есть новое состояние.
  ///
  /// Для старых записей без стрелки использует доступный текст события.
  String _presenceCurrentRaw(dynamic eventEntity) {
    final value = eventEntity.value?.toString().trim();

    if (value != null && value.isNotEmpty) {
      final parts = value.split('→');
      return parts.last.trim();
    }

    final event = eventEntity.event?.toString() ?? '';
    final parts = event.split('→');

    if (parts.length > 1) {
      return parts.last.trim();
    }

    return event.replaceFirst('Присутствие:', '').trim();
  }

  _PresenceVisualState _presenceVisualState(dynamic eventEntity) {
    final current = _presenceCurrentRaw(eventEntity).toLowerCase();

    if (current.contains('ушёл') || current.contains('ушел')) {
      return _PresenceVisualState.away;
    }

    if (current.contains('дома')) {
      if (current.contains('облако')) {
        return _PresenceVisualState.homeCloud;
      }

      if (current.contains('heartbeat') ||
          current.contains('wi-fi') ||
          current.contains('wifi')) {
        return _PresenceVisualState.homeWifi;
      }

      return _PresenceVisualState.home;
    }

    return _PresenceVisualState.unknown;
  }

  String _presenceLabel(dynamic eventEntity) {
    switch (_presenceVisualState(eventEntity)) {
      case _PresenceVisualState.away:
        return 'Ушёл';
      case _PresenceVisualState.homeCloud:
        return 'Дома (облако)';
      case _PresenceVisualState.homeWifi:
        return 'Дома (Wi-Fi)';
      case _PresenceVisualState.home:
        return 'Дома';
      case _PresenceVisualState.unknown:
        return 'Неизвестно';
    }
  }

  Color _presenceColor(dynamic eventEntity) {
    switch (_presenceVisualState(eventEntity)) {
      case _PresenceVisualState.away:
        return Colors.red;
      case _PresenceVisualState.homeCloud:
        return Colors.amber.shade800;
      case _PresenceVisualState.homeWifi:
      case _PresenceVisualState.home:
        return Colors.green;
      case _PresenceVisualState.unknown:
        return Colors.grey;
    }
  }

  // ═══ ИКОНКИ / ЦВЕТА / МЕТКИ ═══

  IconData _eventIcon(String event) {
    if (_isPresenceEvent(event)) {
      return Icons.person_pin_circle;
    }

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
      case 'online':
        return Icons.wifi;
      case 'offline':
        return Icons.wifi_off;
      case 'error':
        return Icons.error;
    }

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

    if (event == 'frigate_person') return Icons.person;
    if (event == 'frigate_car') return Icons.directions_car;
    if (event == 'frigate_dog' || event == 'frigate_cat') {
      return Icons.pets;
    }
    if (event == 'frigate_bird') return Icons.flutter_dash;
    if (event.startsWith('frigate_')) return Icons.videocam;

    return Icons.circle;
  }

  Color _eventColor(String event) {
    if (event.startsWith('alarm_') || event.startsWith('frigate_')) {
      return Colors.red;
    }
    if (event == 'offline') return Colors.grey;
    if (event == 'online') return Colors.green;
    if (event == 'error') return Colors.orange;
    if (event == 'turnOn') return Colors.green;
    if (event == 'turnOff') return Colors.red;
    if (event == 'scene') return Colors.purple;

    return Colors.blue;
  }

  String _eventLabel(String event) {
    if (_isPresenceEvent(event)) return 'Присутствие';

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
      case 'online':
        return 'В сети';
      case 'offline':
        return 'Не в сети';
      case 'error':
        return 'Ошибка';
    }

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

    if (event.startsWith('frigate_')) {
      final label = event.replaceFirst('frigate_', '');
      return '🎥 $label';
    }

    return event;
  }

  // ═══ BUILD ═══

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final filtered = _filteredEvents;

    final eventDeviceIds = _allEvents
        .map((event) => event.deviceId as String?)
        .whereType<String>()
        .toSet();

    final availableDevices =
    devices.where((device) => eventDeviceIds.contains(device.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('События'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _loadInitial,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Очистить всё',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Очистить события?'),
                  content: const Text(
                    'Все события будут удалены безвозвратно.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, false),
                      child: const Text('Отмена'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Очистить'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AppDatabase.clearEvents();
                StatsCache.instance.clear();
                await _loadInitial();
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('Все', EventCategory.all),
                      const SizedBox(width: 4),
                      _buildCategoryChip('Алерты', EventCategory.alerts),
                      const SizedBox(width: 4),
                      _buildCategoryChip(
                        'Действия',
                        EventCategory.actions,
                      ),
                      const SizedBox(width: 4),
                      _buildCategoryChip('Ошибки', EventCategory.errors),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
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
                    ...availableDevices.map(
                          (device) => DropdownMenuItem<String?>(
                        value: device.id,
                        child: Text(device.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedDeviceId = value);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
              child: Text('Нет событий по фильтру'),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount:
              filtered.length + (_loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= filtered.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final eventEntity = filtered[index];
                final timestamp =
                eventEntity.timestamp?.toString();

                if (timestamp == null) {
                  return const SizedBox.shrink();
                }

                final dateTime = DateTime.tryParse(timestamp);
                if (dateTime == null) {
                  return const SizedBox.shrink();
                }

                final dateStr =
                    '${dateTime.day.toString().padLeft(2, '0')}.'
                    '${dateTime.month.toString().padLeft(2, '0')}.'
                    '${dateTime.year}';

                final timeStr =
                    '${dateTime.hour.toString().padLeft(2, '0')}:'
                    '${dateTime.minute.toString().padLeft(2, '0')}:'
                    '${dateTime.second.toString().padLeft(2, '0')}';

                final eventType =
                    eventEntity.event as String? ?? '';
                final isPresence = _isPresenceEvent(eventType);
                final eventColor = isPresence
                    ? _presenceColor(eventEntity)
                    : _eventColor(eventType);

                final deviceName =
                eventEntity.deviceName?.toString();
                final sceneName =
                eventEntity.sceneName?.toString();

                final title = sceneName ??
                    (deviceName?.isNotEmpty == true
                        ? deviceName!
                        : eventType == 'error'
                        ? 'Системная ошибка'
                        : isPresence
                        ? 'Телефон'
                        : '');

                final subtitle = isPresence
                    ? _presenceLabel(eventEntity)
                    : sceneName != null
                    ? 'Сцена выполнена'
                    : eventType == 'error'
                    ? '${_eventLabel(eventType)}'
                    '${eventEntity.value != null ? '\n${eventEntity.value}' : ''}'
                    : _eventLabel(eventType);

                return Card(
                  child: ListTile(
                    leading: Icon(
                      _eventIcon(eventType),
                      color: eventColor,
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: eventColor,
                        fontSize: 13,
                        fontWeight: isPresence
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  Widget _buildCategoryChip(String label, EventCategory category) {
    return FilterChip(
      label: Text(label),
      selected: _category == category,
      onSelected: (_) => setState(() => _category = category),
    );
  }
}