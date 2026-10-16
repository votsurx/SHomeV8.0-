/// Точка входа в приложение.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';
import 'data/services/heartbeat_server.dart';
import 'data/services/nvr_api_client.dart';
import 'di/injection.dart';
import 'domain/models/room.dart';
import 'domain/repositories/device_repository.dart';
import 'domain/repositories/room_repository.dart';
import 'data/services/automation_engine.dart';
import 'data/services/timer_engine.dart';
import 'data/services/config_service.dart';
import 'data/services/mailru_cloud_service.dart';
import 'app.dart';
import 'data/services/mqtt_bridge.dart';
import 'data/services/mqtt_service_impl.dart';
import 'data/services/nvr_sync_service.dart';
import 'application/state/theme_provider.dart';
import 'application/state/nvr_provider.dart';
import 'data/services/ispy_sync_service.dart';
import 'domain/services/mqtt_service_interface.dart';
import 'application/state/devices_provider.dart';
import 'data/services/vk_notification_service.dart';

/// Глобальный доступ к MQTT сервису
MqttService? globalMqttService;

final globalContainer = ProviderContainer();

void main() async  {
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
  Timer? _nvrSyncTimer;
  MqttBridge? _mqttBridge;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoThemeTimer();
    _initNvrServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeTimer?.cancel();
    _nvrSyncTimer?.cancel();
    _mqttBridge?.stop();
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

  void _initNvrServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectMqttAndStartBridge();
      _startNvrSync();
    });
  }

  Future<void> _connectMqttAndStartBridge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mqttHost = prefs.getString('mqtt_host') ?? 'localhost';
      final mqttPort = prefs.getInt('mqtt_port') ?? 1883;

      // Создаём и сохраняем MQTT сервис глобально
      final service = MqttServiceImpl(getIt<Talker>());
      globalMqttService = service;   // ← Сохраняем для доступа из любого места!
      await service.connect(mqttHost, port: mqttPort);

      _mqttBridge = MqttBridge(
        mqttService: service,
        talker: getIt<Talker>(),
      );
      await _mqttBridge!.start();

      // ============================================================
      // 🧠 MYISPY — СЕРВИС СИНХРОНИЗАЦИИ КАМЕР
      // ============================================================
      final ispySyncService = IspySyncService(
        deviceRepo: getIt<DeviceRepository>(),
        talker: getIt<Talker>(),
        devicesNotifier: globalContainer.read(devicesProvider.notifier),  // ← ПЕРЕДАЁМ!
      );
      ispySyncService.attachMqttBridge(_mqttBridge!);

      // ============================================================
      // 🔴 LEGION NVR — КОЛБЭКИ ДВИЖЕНИЯ
      // ============================================================
      _mqttBridge!.onMotionEvent = (event) async {
        debugPrint('🔴 LegionNVR Motion: ${event.cameraName} → ${event.event}');

        // Отправляем уведомление только при НАЧАЛЕ движения
        if (event.event != 'motion_start') return;

        try {
          final prefs = await SharedPreferences.getInstance();
          final enabled = prefs.getBool('notifications_enabled') ?? false;
          final notifyAlarms = prefs.getBool('notify_alarms') ?? true;
          final token = prefs.getString('vk_token') ?? '';
          final userId = prefs.getString('vk_user_id') ?? '';

          if (enabled && notifyAlarms && token.isNotEmpty && userId.isNotEmpty) {
            final vk = VkNotificationService();
            await vk.loadSettings();
            await vk.sendAlarm(
              cameraName: event.cameraName,
              label: 'motion',
              score: (event.percent ?? 90) / 100,
            );
            debugPrint('✅ VK: тревога отправлена');
          }
        } catch (e) {
          debugPrint('❌ Ошибка отправки VK-тревоги: $e');
        }
      };

      ///_mqttBridge!.onStatusEvent = (cameraId, isOnline) {
        ///debugPrint('📡 Camera $cameraId: ${isOnline ? "ONLINE" : "OFFLINE"}');
      ///};

      _mqttBridge!.onRecordingEvent = (cameraId, isRecording) {
        debugPrint('📼 Camera $cameraId recording: $isRecording');
      };

      debugPrint('✅ MQTT Bridge started (MyiSpy + LegionNVR)');
    } catch (e) {
      debugPrint('❌ MQTT init error: $e');
    }
  }

  void _startNvrSync() {
    // ✅ ТОЛЬКО ПРИ СТАРТЕ, БЕЗ ПЕРИОДИЧЕСКОЙ СИНХРОНИЗАЦИИ
    Future.delayed(const Duration(seconds: 2), _syncNvrCameras);
  }

  Future<void> _syncNvrCameras() async {
    try {
      final settings = await _getNvrSettings();
      if (settings.host.isEmpty) {
        return;
      }

      if (!mounted) return;

      final apiClient = NvrApiClient(
        host: settings.host,
        port: settings.port,
      );

      final syncService = NvrSyncService(
        deviceRepo: getIt<DeviceRepository>(),
        talker: getIt<Talker>(),
        apiClient: apiClient,
      );

      await syncService.sync();
    } catch (e) {
      debugPrint('❌ NVR sync error: $e');
    }
  }

  Future<NvrSettings> _getNvrSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHost = prefs.getString('nvr_host');
    final savedPort = prefs.getInt('nvr_port');


    return NvrSettings(
      host: savedHost ?? '',  // ✅ ПУСТОЙ ДЕФОЛТ!
      port: savedPort ?? 8080,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Бекапим только когда приложение реально свернули (не при звонке/диалоге)
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