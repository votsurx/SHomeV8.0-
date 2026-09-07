/// Главный экран со списком устройств в виде адаптивной сетки.
/// Поддерживает фильтрацию по комнатам через RoomSelector.
/// AppBar: название слева, время + погода по центру, шестерёнка справа.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../widgets/device_card.dart';
import '../widgets/myispy_camera_card.dart';
import '../widgets/room_selector.dart';
import '../../data/services/adaptive_poller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';
import '../../di/injection.dart';
import '../../data/protocols/tuya_protocol.dart';
import 'dart:async';
import 'dart:convert';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../../application/onboarding_manager.dart';
import '../widgets/nvr_camera_card.dart';
import 'package:http/http.dart' as http;
class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key});

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
  String _selectedRoomId = 'all';
  DeviceType _selectedType = DeviceType.outlet;
  AdaptivePoller? _poller;

  @override
  void initState() {
    super.initState();
    _initPoller(); // ← добавить
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final isComplete = await OnboardingManager.isOnboardingComplete();
    if (!isComplete && mounted) {
      context.go('/onboarding');
    }
  }

  Future<void> _initPoller() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt('poll_interval') ?? 2;
    final interval = Duration(seconds: seconds);

    if (!mounted) return;

    setState(() {
      _poller = AdaptivePoller(
        getIt<TuyaProtocol>(),
        getIt<Talker>(),
            (deviceId, isOn) {
          if (mounted) ref.read(devicesProvider.notifier).updateDeviceState(deviceId, isOn);
        },
            (deviceId, isOnline) {
          if (mounted) ref.read(devicesProvider.notifier).updateOnlineState(deviceId, isOnline);
        },
            (deviceId, states) {
          if (mounted) ref.read(devicesProvider.notifier).updateDeviceStates(deviceId, states);
        },
        onSensorUpdate: (deviceId, properties) {
          if (mounted) ref.read(devicesProvider.notifier).updateDeviceProperties(deviceId, properties);
        },
        normalInterval: interval,
      );
      _poller!.start();
      ref.read(devicesProvider.notifier).onCommandSent = (deviceId) {
        _poller?.forceReset(deviceId);
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final allDevices = ref.watch(devicesProvider);
    _poller?.updateDevices(allDevices); // ← обновляем список устройств

    final devices = _selectedRoomId == 'all'
        ? allDevices
        : allDevices.where((d) => d.roomId == _selectedRoomId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('SHome', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Spacer(),
            _TimeWeatherWidget(),
            Spacer(),
            SizedBox(width: 48), // компенсация иконки справа для центрирования
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/menu'),
          ),
        ],
      ),
      body: Column(
        children: [
          RoomSelector(
            selectedRoomId: _selectedRoomId,
            onRoomSelected: (room) => setState(() => _selectedRoomId = room.id),
          ),
          const Divider(),
          Expanded(
            child: devices.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Нет устройств', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 900 ? 5 : (width > 600 ? 4 : (width > 400 ? 3 : 2));

                return ReorderableGridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  padding: const EdgeInsets.all(12),
                  children: devices.map((device) {
                    final cameraType = device.properties['cameraType'] as String? ?? '';

                    // MyiSpy камеры — своя карточка
                    if (device.type == DeviceType.camera && cameraType == 'ispy') {
                      return MyiSpyCameraCard(
                        key: ValueKey(device.id),
                        device: device,
                      );
                    }

                    // LegionNVR камеры — своя карточка
                    if (device.type == DeviceType.camera && cameraType == 'nvr') {
                      return NvrCameraCard(
                        key: ValueKey(device.id),
                        device: device,
                      );
                    }

                    // Остальные устройства
                    return DeviceCard(
                      key: ValueKey(device.id),
                      device: device,
                    );
                  }).toList(),
                  onReorder: (oldIndex, newIndex) {
                    ref.read(devicesProvider.notifier).reorderDevices(oldIndex, newIndex);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDeviceDialog() {
    final nameController = TextEditingController();
    final deviceIdController = TextEditingController();
    final addressController = TextEditingController();
    final localKeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить устройство'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название')),
                const SizedBox(height: 8),
                DropdownButtonFormField<DeviceType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: 'Тип устройства', prefixIcon: Icon(Icons.category)),
                  items: const [
                    DropdownMenuItem(value: DeviceType.outlet, child: Text('Розетка')),
                    DropdownMenuItem(value: DeviceType.switch1, child: Text('Выключатель (1 кл.)')),
                    DropdownMenuItem(value: DeviceType.switch2, child: Text('Выключатель (2 кл.)')),
                    DropdownMenuItem(value: DeviceType.switch3, child: Text('Выключатель (3 кл.)')),
                    DropdownMenuItem(value: DeviceType.sensor, child: Text('Датчик')),
                    DropdownMenuItem(value: DeviceType.light, child: Text('Лампа')),
                    DropdownMenuItem(value: DeviceType.curtain, child: Text('Шторы')),
                    DropdownMenuItem(value: DeviceType.compound, child: Text('Универсальное устройство')),
                  ],
                  onChanged: (value) => setDialogState(() => _selectedType = value ?? DeviceType.outlet),
                ),
                const SizedBox(height: 8),
                TextField(controller: deviceIdController, decoration: const InputDecoration(labelText: 'Device ID')),
                const SizedBox(height: 8),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'IP Адрес')),
                const SizedBox(height: 8),
                TextField(controller: localKeyController, decoration: const InputDecoration(labelText: 'Local Key')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && deviceIdController.text.isNotEmpty) {
                  final device = Device(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    type: _selectedType,
                    roomId: _selectedRoomId == 'all' ? 'living' : _selectedRoomId,
                    isOnline: false,
                    state: DeviceState.offline,
                    deviceId: deviceIdController.text,
                    localKey: localKeyController.text,
                    address: addressController.text,
                    version: 3.5,
                    properties: _getDefaultProperties(_selectedType),
                  );
                  ref.read(devicesProvider.notifier).addDevice(device);
                  Navigator.pop(context);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getDefaultProperties(DeviceType type) {
    return DevicesNotifier.defaultProperties(type);
  }
}

/// Виджет времени и погоды для AppBar.
/// Обновляет время каждую минуту, погоду — каждые 30 минут.
class _TimeWeatherWidget extends StatefulWidget {
  const _TimeWeatherWidget();

  @override
  State<_TimeWeatherWidget> createState() => _TimeWeatherWidgetState();
}

class _TimeWeatherWidgetState extends State<_TimeWeatherWidget> {
  late DateTime _now;
  String _temperature = '--°';
  String _weatherIcon = '☀️';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _updateTime();
    _fetchWeather();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (!mounted) return;
    setState(() => _now = DateTime.now());
    _timer = Timer(const Duration(minutes: 1), _updateTime);
  }

  Future<void> _fetchWeather() async {
    try {
      final url = Uri.parse('https://wttr.in/54.53,36.27?format=%t|%C&lang=en');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final parts = response.body.split('|');
        if (parts.length == 2) {
          final tempStr = parts[0].trim().replaceAll('+', '').replaceAll('°C', '');
          final emoji = _weatherEmoji(parts[1].trim());

          if (!mounted) return;
          setState(() {
            _temperature = '$tempStr°';
            _weatherIcon = emoji;
          });
        }
      }
    } catch (e) {
      debugPrint('Weather fetch error: $e');
    }

    if (mounted) {
      Future.delayed(const Duration(minutes: 30), _fetchWeather);
    }
  }

  String _weatherEmoji(String condition) {
    if (condition.contains('Sunny') || condition.contains('Clear')) return '☀️';
    if (condition.contains('cloud')) return '☁️';
    if (condition.contains('rain') || condition.contains('drizzle')) return '🌧️';
    if (condition.contains('snow')) return '❄️';
    if (condition.contains('thunder')) return '⛈️';
    if (condition.contains('fog') || condition.contains('mist')) return '🌫️';
    return '🌡️';
  }

  void _showForecast(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🌤️ Прогноз погоды'),
        content: FutureBuilder(
          future: _fetchForecast(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final days = snapshot.data as List<Map<String, String>>;
            return SizedBox(
              width: double.maxFinite,
              height: 250,  // фиксированная высота для скролла
              child: ListView.builder(
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  return ListTile(
                    leading: Text(day['icon']!, style: const TextStyle(fontSize: 24)),
                    title: Text(day['date']!),
                    trailing: Text(day['temp']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            );
          },
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  Future<List<Map<String, String>>> _fetchForecast() async {
    final url = Uri.parse('https://wttr.in/Kaluga,Russia?format=j1&lang=ru');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final days = <Map<String, String>>[];

      for (final day in data['weather'] ?? []) {
        final date = day['date'] as String;
        final maxTemp = day['maxtempC']?.toString() ?? '--';
        final minTemp = day['mintempC']?.toString() ?? '--';
        final emoji = _weatherEmoji(day['hourly']?[4]?['weatherDesc']?[0]?['value'] ?? '');

        days.add({
          'date': date,
          'temp': '$minTemp° / $maxTemp°',
          'icon': emoji,
        });
      }
      return days;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => _showForecast(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(timeStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(_weatherIcon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(_temperature, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}