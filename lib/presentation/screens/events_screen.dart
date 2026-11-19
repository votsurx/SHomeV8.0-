/// Экран журнала событий.
/// Читает из StatsCache (последние 200) + БД (старые, пагинация).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/state/devices_provider.dart';
import '../../data/local/database.dart';
import '../../data/services/stats_cache.dart';
import '../../l10n/generated/app_localizations.dart';

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

  List<dynamic> _cacheEvents = [];
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
        .map(
          (event) =>
      '${event.timestamp}|${event.event}|${event.deviceId ?? ''}',
    )
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
        .map(
          (event) =>
      '${event.timestamp}|${event.event}|${event.deviceId ?? ''}',
    )
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

  String _presenceCurrentRaw(dynamic eventEntity) {
    final value = eventEntity.value?.toString().trim();

    if (value != null && value.isNotEmpty) {
      return value.split('→').last.trim();
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

  String _presenceLabel(
      dynamic eventEntity,
      AppLocalizations l10n,
      ) {
    switch (_presenceVisualState(eventEntity)) {
      case _PresenceVisualState.away:
        return l10n.eventsPresenceAway;
      case _PresenceVisualState.homeCloud:
        return l10n.eventsPresenceHomeCloud;
      case _PresenceVisualState.homeWifi:
        return l10n.eventsPresenceHomeWifi;
      case _PresenceVisualState.home:
        return l10n.eventsPresenceHome;
      case _PresenceVisualState.unknown:
        return l10n.eventsPresenceUnknown;
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

  String _eventLabel(String event, AppLocalizations l10n) {
    if (_isPresenceEvent(event)) return l10n.eventsPresence;

    switch (event) {
      case 'turnOn':
        return l10n.eventsTurnedOn;
      case 'turnOff':
        return l10n.eventsTurnedOff;
      case 'scene':
        return l10n.eventsScene;
      case 'roomAdded':
        return l10n.eventsRoomAdded;
      case 'roomRemoved':
        return l10n.eventsRoomRemoved;
      case 'timer':
        return l10n.eventsTimer;
      case 'deviceAdded':
        return l10n.eventsDeviceAdded;
      case 'deviceRemoved':
        return l10n.eventsDeviceRemoved;
      case 'sceneCreated':
        return l10n.eventsSceneCreated;
      case 'sceneDeleted':
        return l10n.eventsSceneDeleted;
      case 'online':
        return l10n.eventsOnline;
      case 'offline':
        return l10n.eventsOffline;
      case 'error':
        return l10n.eventsError;
      case 'alarm_water_leak':
        return l10n.eventsAlarmWaterLeak;
      case 'alarm_smoke':
        return l10n.eventsAlarmSmoke;
      case 'alarm_gas':
        return l10n.eventsAlarmGas;
      case 'alarm_motion':
        return l10n.eventsAlarmMotion;
      case 'alarm_contact_open':
        return l10n.eventsAlarmContactOpen;
      case 'alarm_contact_closed':
        return l10n.eventsAlarmContactClosed;
      case 'alarm_temperature_above':
        return l10n.eventsAlarmTemperatureAbove;
      case 'alarm_temperature_below':
        return l10n.eventsAlarmTemperatureBelow;
      case 'alarm_humidity_above':
        return l10n.eventsAlarmHumidityAbove;
      case 'alarm_humidity_below':
        return l10n.eventsAlarmHumidityBelow;
      case 'frigate_person':
        return l10n.eventsFrigatePerson;
      case 'frigate_car':
        return l10n.eventsFrigateCar;
      case 'frigate_dog':
        return l10n.eventsFrigateDog;
      case 'frigate_cat':
        return l10n.eventsFrigateCat;
      case 'frigate_bird':
        return l10n.eventsFrigateBird;
    }

    if (event.startsWith('frigate_')) {
      return l10n.eventsFrigateOther;
    }

    return event;
  }

  String _categoryLabel(
      EventCategory category,
      AppLocalizations l10n,
      ) {
    switch (category) {
      case EventCategory.all:
        return l10n.eventsFilterAll;
      case EventCategory.alerts:
        return l10n.eventsFilterAlerts;
      case EventCategory.actions:
        return l10n.eventsFilterActions;
      case EventCategory.errors:
        return l10n.eventsFilterErrors;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        title: Text(l10n.eventsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.eventsRefresh,
            onPressed: _loadInitial,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.eventsClearAll,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.eventsClearTitle),
                  content: Text(l10n.eventsClearWarning),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(l10n.eventsClearCancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(l10n.eventsClearConfirm),
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
                    children: EventCategory.values
                        .map(
                          (category) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _buildCategoryChip(
                          _categoryLabel(category, l10n),
                          category,
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: _selectedDeviceId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.eventsDeviceFilter,
                    prefixIcon: const Icon(Icons.devices),
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.eventsAllDevices),
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
                ? Center(
              child: Text(l10n.eventsEmptyFilter),
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
                        ? l10n.eventsSystemError
                        : isPresence
                        ? l10n.eventsPhone
                        : '');

                final details = eventEntity.value?.toString();
                final subtitle = isPresence
                    ? _presenceLabel(eventEntity, l10n)
                    : sceneName != null
                    ? l10n.eventsSceneCompleted
                    : eventType == 'error' &&
                    details != null &&
                    details.isNotEmpty
                    ? '${_eventLabel(eventType, l10n)}\n$details'
                    : _eventLabel(eventType, l10n);

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