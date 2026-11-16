/// Экран журнала событий.
/// Читает из StatsCache (последние 200) + БД (старые, пагинация).
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../data/services/stats_cache.dart';
import '../../application/state/devices_provider.dart';

enum EventCategory { all, alerts, actions, errors }

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  static const _pageSize = 50;

  // события из памяти (StatsCache) — всегда сверху
  List<dynamic> _cacheEvents = [];
  // события из БД (старше памяти) — подгружаются при скролле
  final List<dynamic> _dbEvents = [];
  int _dbOffset = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMoreDb = true;

  EventCategory _category = EventCategory.all;
  String? _selectedDeviceId;

  final _scrollController = ScrollController();

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

  void _onCacheChanged() {
    if (!mounted) return;
    setState(() {
      _cacheEvents = StatsCache.instance.recentEvents.reversed.toList();
    });
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    // из памяти (синхронно)
    _cacheEvents = StatsCache.instance.recentEvents.reversed.toList();

    // из БД (первая страница, исключая память)
    final exclude = _cacheEvents
        .map((e) => '${e.timestamp}|${e.event}|${e.deviceId ?? ''}')
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
        .map((e) => '${e.timestamp}|${e.event}|${e.deviceId ?? ''}')
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreFromDb();
    }
  }

  // ═══ ФИЛЬТРАЦИЯ ═══

  List<dynamic> get _allEvents => [..._cacheEvents, ..._dbEvents];

  List<dynamic> get _filteredEvents {
    return _allEvents.where((e) {
      final event = e.event as String? ?? '';
      switch (_category) {
        case EventCategory.alerts:
          if (!event.startsWith('alarm_') && !event.startsWith('frigate_')) return false;
          break;
        case EventCategory.actions:
          if (!['turnOn', 'turnOff', 'scene', 'roomAdded', 'roomRemoved',
            'timer', 'deviceAdded', 'deviceRemoved', 'sceneCreated',
            'sceneDeleted'].contains(event)) return false;
          break;
        case EventCategory.errors:
          if (!['offline', 'online', 'error'].contains(event)) return false;
          break;
        case EventCategory.all:
          break;
      }
      if (_selectedDeviceId != null && e.deviceId != _selectedDeviceId) return false;
      return true;
    }).toList();
  }

  // ═══ ИКОНКИ / ЦВЕТА / МЕТКИ ═══

  IconData _eventIcon(String event) {
    switch (event) {
      case 'turnOn': return Icons.power_settings_new;
      case 'turnOff': return Icons.power_off;
      case 'scene': return Icons.movie;
      case 'roomAdded': return Icons.add_home;
      case 'roomRemoved': return Icons.remove_circle;
      case 'timer': return Icons.timer;
      case 'deviceAdded': return Icons.add_circle;
      case 'deviceRemoved': return Icons.delete;
      case 'sceneCreated': return Icons.movie_creation;
      case 'sceneDeleted': return Icons.movie_filter;
    }
    if (event == 'alarm_water_leak') return Icons.water_drop;
    if (event == 'alarm_smoke') return Icons.local_fire_department;
    if (event == 'alarm_gas') return Icons.gas_meter;
    if (event == 'alarm_motion') return Icons.directions_run;
    if (event == 'alarm_contact_open' || event == 'alarm_contact_closed') return Icons.door_front_door;
    if (event == 'alarm_temperature_above' || event == 'alarm_temperature_below') return Icons.thermostat;
    if (event == 'alarm_humidity_above' || event == 'alarm_humidity_below') return Icons.water;
    if (event == 'frigate_person') return Icons.person;
    if (event == 'frigate_car') return Icons.directions_car;
    if (event == 'frigate_dog' || event == 'frigate_cat') return Icons.pets;
    if (event == 'frigate_bird') return Icons.flutter_dash;
    if (event.startsWith('frigate_')) return Icons.videocam;
    switch (event) {
      case 'online': return Icons.wifi;
      case 'offline': return Icons.wifi_off;
      case 'error': return Icons.error;
    }
    return Icons.circle;
  }

  Color _eventColor(String event) {
    if (event.startsWith('alarm_') || event.startsWith('frigate_')) return Colors.red;
    if (event == 'offline') return Colors.grey;
    if (event == 'online') return Colors.green;
    if (event == 'error') return Colors.orange;
    if (event == 'turnOn') return Colors.green;
    if (event == 'turnOff') return Colors.red;
    if (event == 'scene') return Colors.purple;
    return Colors.blue;
  }

  String _eventLabel(String event) {
    switch (event) {
      case 'turnOn': return 'Включено';
      case 'turnOff': return 'Выключено';
      case 'scene': return 'Сцена';
      case 'roomAdded': return 'Комната добавлена';
      case 'roomRemoved': return 'Комната удалена';
      case 'timer': return 'Таймер';
      case 'deviceAdded': return 'Устройство добавлено';
      case 'deviceRemoved': return 'Устройство удалено';
      case 'sceneCreated': return 'Сцена создана';
      case 'sceneDeleted': return 'Сцена удалена';
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
    switch (event) {
      case 'online': return 'В сети';
      case 'offline': return 'Не в сети';
      case 'error': return 'Ошибка';
    }
    return event;
  }

  // ═══ BUILD ═══

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final filtered = _filteredEvents;

    final eventDeviceIds = _allEvents
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
            onPressed: _loadInitial,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Очистить всё',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Очистить события?'),
                  content: const Text('Все события будут удалены безвозвратно.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Очистить'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await AppDatabase.clearEvents();
                StatsCache.instance.clear();
                _loadInitial();
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
                      _buildCategoryChip('Действия', EventCategory.actions),
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
                    const DropdownMenuItem<String?>(value: null, child: Text('Все устройства')),
                    ...availableDevices.map((d) => DropdownMenuItem<String?>(
                      value: d.id,
                      child: Text(d.name),
                    )),
                  ],
                  onChanged: (v) => setState(() => _selectedDeviceId = v),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Нет событий по фильтру'))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: filtered.length + (_loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= filtered.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final event = filtered[index];
                final timestamp = event.timestamp;
                if (timestamp == null) return const SizedBox.shrink();
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
                      event.sceneName != null
                          ? '${event.sceneName}'
                          : (event.deviceName ?? ''),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      event.sceneName != null
                          ? 'Сцена выполнена'
                          : _eventLabel(eventType),
                      style: TextStyle(
                        color: _eventColor(eventType),
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      timeStr,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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