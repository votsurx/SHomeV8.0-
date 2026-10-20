/// Точка входа в приложение.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';
import 'data/services/heartbeat_server.dart';
import 'di/injection.dart';
import 'domain/models/room.dart';
import 'domain/repositories/room_repository.dart';
import 'data/services/automation_engine.dart';
import 'data/services/timer_engine.dart';
import 'data/services/config_service.dart';
import 'data/services/mailru_cloud_service.dart';
import 'app.dart';
import 'data/services/mqtt_service_impl.dart';
import 'application/state/theme_provider.dart';
import 'domain/services/mqtt_service_interface.dart';

/// Глобальный доступ к MQTT сервису (для Zigbee и Frigate)
MqttService? globalMqttService;

final globalContainer = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  ThemeNotifier.updateAutoCache();

  // Запускаем HTTP-сервер для heartbeat
  final serverStarted = await HeartbeatServer.start(port: 7777);
  if (serverStarted) {
    getIt<Talker>().info('📡 HeartbeatServer готов к приёму');
  }

  getIt<TimerEngine>().start();
  getIt<AutomationEngine>().start();

  _addDefaultRooms();

  runApp(
    UncontrolledProviderScope(
      container: globalContainer,
      child: SHomeAppObserver(child: SHomeApp()),
    ),
  );
}

class SHomeAppObserver extends StatefulWidget {
  final Widget child;
  const SHomeAppObserver({required this.child, super.key});

  @override
  State<SHomeAppObserver> createState() => _SHomeAppObserverState();
}

class _SHomeAppObserverState extends State<SHomeAppObserver> with WidgetsBindingObserver {
  Timer? _themeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoThemeTimer();
    _connectMqtt();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeTimer?.cancel();
    HeartbeatServer.stop();
    super.dispose();
  }

  void _startAutoThemeTimer() {
    _themeTimer = Timer.periodic(const Duration(minutes: 1), (_) => _checkAutoTheme());
    _checkAutoTheme();
  }

  void _checkAutoTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final auto = prefs.getBool('auto_theme') ?? false;
    if (!auto) return;

    final hour = DateTime.now().hour;
    final newMode = (hour >= 6 && hour < 18) ? 'light' : 'dark';

    final currentMode = prefs.getString('theme_mode') ?? 'dark';
    if (newMode != currentMode) {
      await prefs.setString('theme_mode', newMode);
      ThemeNotifier.updateAutoCache();
    }
  }

  /// Подключаемся к MQTT-брокеру (для Zigbee и Frigate)
  Future<void> _connectMqtt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mqttHost = prefs.getString('mqtt_host') ?? '';
      final mqttPortRaw = prefs.get('mqtt_port');
      final mqttPort = mqttPortRaw is int
          ? mqttPortRaw
          : int.tryParse(mqttPortRaw?.toString() ?? '') ?? 1883;

      if (mqttHost.isEmpty) {
        getIt<Talker>().info('⚠️ MQTT host не настроен — пропускаем подключение');
        return;
      }

      final service = MqttServiceImpl(getIt<Talker>());
      globalMqttService = service;
      await service.connect(mqttHost, port: mqttPort);
      getIt<Talker>().info('✅ MQTT подключён: $mqttHost:$mqttPort');
    } catch (e) {
      getIt<Talker>().error('❌ MQTT init error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Бекапим только когда приложение реально свернули
    if (state == AppLifecycleState.paused) {
      ConfigService.buildConfigJson().then((json) {
        MailruCloudService.autoSync(json);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void _addDefaultRooms() async {
  await Future.delayed(const Duration(milliseconds: 100));
  final roomRepo = getIt<RoomRepository>();
  final rooms = await roomRepo.getAllRooms();
  if (rooms.isEmpty) {
    await roomRepo.saveRoom(Room(id: 'living', name: 'Гостиная', icon: '🛋️', sortOrder: 0));
    await roomRepo.saveRoom(Room(id: 'bedroom', name: 'Спальня', icon: '🛏️', sortOrder: 1));
    await roomRepo.saveRoom(Room(id: 'kitchen', name: 'Кухня', icon: '🍳', sortOrder: 2));
    await roomRepo.saveRoom(Room(id: 'other', name: 'Техника', icon: '🔌', sortOrder: 3));
  }
}