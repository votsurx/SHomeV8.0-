/// Экран журнала событий.
/// Показывает историю всех действий: вкл/выкл, сцены, ошибки, онлайн/оффлайн.
/// Каждый тип события имеет свой цвет и иконку.
/// Кнопки: обновить, очистить всё.
library;
import 'package:flutter/material.dart';
import '../../data/local/database.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<dynamic> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// Загружает последние 200 событий из БД.
  Future<void> _loadEvents() async {
    final events = await AppDatabase.getRecentEvents(limit: 200);
    setState(() {
      _events = events;
      _loading = false;
    });
  }

  /// Иконка для типа события.
  IconData _eventIcon(String event) {
    switch (event) {
      case 'turnOn': return Icons.power_settings_new;
      case 'turnOff': return Icons.power_off;
      case 'online': return Icons.wifi;
      case 'offline': return Icons.wifi_off;
      case 'error': return Icons.error;
      case 'scene': return Icons.movie;
      default: return Icons.circle;
    }
  }

  /// Цвет для типа события.
  Color _eventColor(String event) {
    switch (event) {
      case 'turnOn': return Colors.green;
      case 'turnOff': return Colors.red;
      case 'online': return Colors.blue;
      case 'offline': return Colors.grey;
      case 'error': return Colors.orange;
      case 'scene': return Colors.purple;
      default: return Colors.grey;
    }
  }

  /// Человекочитаемая метка события.
  String _eventLabel(String event) {
    switch (event) {
      case 'turnOn': return 'Включено';
      case 'turnOff': return 'Выключено';
      case 'online': return 'В сети';
      case 'offline': return 'Не в сети';
      case 'error': return 'Ошибка';
      case 'scene': return 'Сцена';
      default: return event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('События'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await AppDatabase.clearEvents();
              _loadEvents();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(child: Text('Нет событий'))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final timestamp = event.timestamp;
          if (timestamp == null) return const SizedBox.shrink();

          final time = DateTime.parse(timestamp);
          final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';

          return Card(
            child: ListTile(
              leading: Icon(_eventIcon(event.event ?? ''), color: _eventColor(event.event ?? '')),
              title: Text(
                event.sceneName != null ? '${event.sceneName}' : (event.deviceName ?? ''),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                event.sceneName != null ? 'Сцена выполнена' : _eventLabel(event.event ?? ''),
                style: TextStyle(color: _eventColor(event.event ?? ''), fontSize: 12),
              ),
              trailing: Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}