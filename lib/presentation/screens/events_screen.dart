/// Экран журнала событий.
/// Читает из StatsCache (последние 200) + БД (старые, пагинация).
/// Фильтры: категория (Все/Алерты/Действия/Ошибки/Присутствие),
/// устройство, период (пресеты + свой диапазон с датой и временем).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/state/devices_provider.dart';
import '../../data/local/database.dart';
import '../../data/services/stats_cache.dart';
import '../../l10n/generated/app_localizations.dart';

enum EventCategory { all, alerts, actions, errors, presence }

enum _PresenceVisualState {
  away,
  homeCloud,
  homeWifi,
  home,
  unknown,
}

/// Пресеты периода для фильтра по дате.
enum _DatePreset {
  all,
  today,
  yesterday,
  last7Days,
  last30Days,
  custom,
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

  // ─── Фильтр по периоду ───
  _DatePreset _datePreset = _DatePreset.all;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  bool get _hasDateFilter => _dateFrom != null || _dateTo != null;

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

          if (!actionEvents.contains(event)) {
            return false;
          }
          break;

        case EventCategory.errors:
          if (!{'offline', 'online', 'error'}.contains(event)) {
            return false;
          }
          break;

        case EventCategory.presence:
          if (!_isPresenceEvent(event)) {
            return false;
          }
          break;

        case EventCategory.all:
          break;
      }

      // ─── Фильтр по устройству ───
      if (_selectedDeviceId != null &&
          eventEntity.deviceId != _selectedDeviceId) {
        return false;
      }

      // ─── Фильтр по периоду ───
      if (_hasDateFilter) {
        final ts = DateTime.tryParse(
          eventEntity.timestamp?.toString() ?? '',
        );
        if (ts != null) {
          if (_dateFrom != null && ts.isBefore(_dateFrom!)) {
            return false;
          }
          if (_dateTo != null && ts.isAfter(_dateTo!)) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // ПЕРИОД: ПРЕСЕТЫ И СВОЙ ДИАПАЗОН
  // ═══════════════════════════════════════════════════════════════

  Future<void> _showDateFilterSheet() async {
    final l10n = AppLocalizations.of(context);

    final result = await showModalBottomSheet<_DateFilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _DateFilterSheet(
        initialPreset: _datePreset,
        initialFrom: _dateFrom,
        initialTo: _dateTo,
        l10n: l10n,
      ),
    );

    if (result == null) return;

    setState(() {
      _datePreset = result.preset;
      _dateFrom = result.from;
      _dateTo = result.to;
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // ПРИСУТСТВИЕ
  // ═══════════════════════════════════════════════════════════════

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
      case EventCategory.presence:
        return l10n.eventsFilterPresence;
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
          // 📅 Фильтр по периоду
          IconButton(
            tooltip: l10n.eventsFilterDate,
            onPressed: _showDateFilterSheet,
            icon: Badge(
              isLabelVisible: _hasDateFilter,
              child: const Icon(Icons.date_range),
            ),
          ),
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

// ═══════════════════════════════════════════════════════════════
// BOTTOM SHEET: ФИЛЬТР ПО ПЕРИОДУ
// ═══════════════════════════════════════════════════════════════

class _DateFilterResult {
  final _DatePreset preset;
  final DateTime? from;
  final DateTime? to;
  const _DateFilterResult({
    required this.preset,
    required this.from,
    required this.to,
  });
}

class _DateFilterSheet extends StatefulWidget {
  const _DateFilterSheet({
    required this.initialPreset,
    required this.initialFrom,
    required this.initialTo,
    required this.l10n,
  });

  final _DatePreset initialPreset;
  final DateTime? initialFrom;
  final DateTime? initialTo;
  final AppLocalizations l10n;

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  late _DatePreset _preset;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _preset = widget.initialPreset;
    _from = widget.initialFrom;
    _to = widget.initialTo;
  }

  DateTime _startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  void _selectPreset(_DatePreset preset) {
    final now = DateTime.now();

    setState(() {
      _preset = preset;
      switch (preset) {
        case _DatePreset.all:
          _from = null;
          _to = null;
          break;
        case _DatePreset.today:
          _from = _startOfDay(now);
          _to = _endOfDay(now);
          break;
        case _DatePreset.yesterday:
          final y = now.subtract(const Duration(days: 1));
          _from = _startOfDay(y);
          _to = _endOfDay(y);
          break;
        case _DatePreset.last7Days:
          _from = _startOfDay(now.subtract(const Duration(days: 6)));
          _to = _endOfDay(now);
          break;
        case _DatePreset.last30Days:
          _from = _startOfDay(now.subtract(const Duration(days: 29)));
          _to = _endOfDay(now);
          break;
        case _DatePreset.custom:
        // Оставляем текущие _from/_to, пользователь задаст вручную.
          if (_from == null && _to == null) {
            _from = _startOfDay(now);
            _to = _endOfDay(now);
          }
          break;
      }
    });
  }

  Future<void> _pickFromDate() async {
    final l10n = widget.l10n;
    final initial = _from ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: l10n.eventsFilterDateFrom,
    );
    if (picked == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_from ?? DateTime.now()),
      helpText: l10n.eventsFilterDateFrom,
    );
    if (time == null) return;

    setState(() {
      _from = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
      _preset = _DatePreset.custom;
    });
  }

  Future<void> _pickToDate() async {
    final l10n = widget.l10n;
    final initial = _to ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: l10n.eventsFilterDateTo,
    );
    if (picked == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_to ?? DateTime.now()),
      helpText: l10n.eventsFilterDateTo,
    );
    if (time == null) return;

    setState(() {
      _to = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
        59,
        999,
      );
      _preset = _DatePreset.custom;
    });
  }

  void _reset() {
    setState(() {
      _preset = _DatePreset.all;
      _from = null;
      _to = null;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      _DateFilterResult(preset: _preset, from: _from, to: _to),
    );
  }

  String _formatDateTime(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.eventsFilterDate,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _presetTile(_DatePreset.all, l10n.eventsFilterDateAll),
                    _presetTile(_DatePreset.today, l10n.eventsFilterDateToday),
                    _presetTile(
                        _DatePreset.yesterday, l10n.eventsFilterDateYesterday),
                    _presetTile(
                        _DatePreset.last7Days, l10n.eventsFilterDate7Days),
                    _presetTile(
                        _DatePreset.last30Days, l10n.eventsFilterDate30Days),
                    _presetTile(
                        _DatePreset.custom, l10n.eventsFilterDateCustom),
                    if (_preset == _DatePreset.custom) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickFromDate,
                              icon: const Icon(Icons.event),
                              label: Text(
                                '${l10n.eventsFilterDateFrom}: '
                                    '${_formatDateTime(_from)}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickToDate,
                              icon: const Icon(Icons.event),
                              label: Text(
                                '${l10n.eventsFilterDateTo}: '
                                    '${_formatDateTime(_to)}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: Text(l10n.eventsFilterDateReset),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
                    child: Text(l10n.eventsFilterDateApply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetTile(_DatePreset preset, String label) {
    return RadioListTile<_DatePreset>(
      value: preset,
      groupValue: _preset,
      onChanged: (v) {
        if (v != null) _selectPreset(v);
      },
      title: Text(label),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}