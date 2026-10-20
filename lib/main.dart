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
import 'application/state/theme_provider.dart';
import 'domain/services/mqtt_service_interface.dart';
import 'data/services/zigbee_bridge.dart';
import 'data/services/frigate_bridge.dart';
import 'data/services/frigate_service.dart';
import 'data/local/secure_storage/encrypted_keys.dart';
import 'application/state/devices_provider.dart';

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

class _SHomeAppObserverState extends State<SHomeAppObserver>
    with WidgetsBindingObserver {
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

  // ═══════════════════════════════════════════════════════════
  // АВТОТЕМА
  // ═══════════════════════════════════════════════════════════

  void _startAutoThemeTimer() {
    _themeTimer =
        Timer.periodic(const Duration(minutes: 1), (_) => _checkAutoTheme());
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

  // ═══════════════════════════════════════════════════════════
  // MQTT + ZIGBEE + FRIGATE
  // ═══════════════════════════════════════════════════════════

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

      // ✅ ОДИН экземпляр MqttService для всех
      final service = getIt<MqttService>();
      await service.connect(mqttHost, port: mqttPort);
      getIt<Talker>().info('✅ MQTT подключён: $mqttHost:$mqttPort');

      // ═══════════════════════════════════════════════════════════
      // 🐝 ZIGBEE
      // ═══════════════════════════════════════════════════════════
      final zigbeeBridge = getIt<ZigbeeBridge>();
      await zigbeeBridge.start();
      getIt<Talker>().info('🐝 ZigbeeBridge запущен');

      // Привязываем onState → devicesProvider
      zigbeeBridge.onState = (friendlyName, newState) {
        _updateZigbeeDeviceState(friendlyName, newState);
      };
      getIt<Talker>().info('🐝 onState привязан к devicesProvider');

      // ═══════════════════════════════════════════════════════════
      // 🎥 FRIGATE
      // ═══════════════════════════════════════════════════════════
      final frigateBridge = getIt<FrigateBridge>();
      await frigateBridge.start();
      getIt<Talker>().info('🎥 FrigateBridge запущен');

      // Настраиваем FrigateService
      final frigateHost = prefs.getString('frigate_host') ?? mqttHost;
      final frigatePort = prefs.getInt('frigate_port') ?? 5000;
      final rtspPassword =
          await EncryptedKeys().getFrigateRtspPassword() ?? '';

      final frigateService = getIt<FrigateService>();
      frigateService.configure(
        host: frigateHost,
        port: frigatePort,
        rtspPassword: rtspPassword,
      );
      getIt<Talker>()
          .info('🎥 FrigateService настроен: $frigateHost:$frigatePort');
    } catch (e) {
      getIt<Talker>().error('❌ MQTT init error: $e');
    }
  }

  /// Обновляет `properties` Zigbee-устройства в `devicesProvider`.
  ///
  /// Ищем `Device` по `friendly_name`, мержим `newState` в `properties`,
  /// и вызываем `updateDeviceLocal` — это триггерит перерисовку `DeviceCard`.
  void _updateZigbeeDeviceState(
      String friendlyName,
      Map<String, dynamic> newState,
      ) {
    try {
      final devicesNotifier =
      globalContainer.read(devicesProvider.notifier);
      final devices = globalContainer.read(devicesProvider);

      final device = devices.firstWhere(
            (d) =>
        d.properties['source'] == 'zigbee' &&
            d.properties['friendly_name'] == friendlyName,
      );

      // Мержим новые значения (battery, linkquality, water_leak...) в properties
      final updatedProperties = <String, dynamic>{
        ...device.properties,
        ...newState,
      };

      final updatedDevice = device.copyWith(properties: updatedProperties);
      devicesNotifier.updateDeviceLocal(updatedDevice);

      getIt<Talker>().debug(
        '🐝 onState: $friendlyName → ${newState.keys.join(", ")}',
      );
    } catch (_) {
      // Устройство ещё не добавлено в SHome — игнорируем
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ЖИЗНЕННЫЙ ЦИКЛ
  // ═══════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════
// КОМНАТЫ ПО УМОЛЧАНИЮ
// ═══════════════════════════════════════════════════════════

void _addDefaultRooms() async {
  await Future.delayed(const Duration(milliseconds: 100));
  final roomRepo = getIt<RoomRepository>();
  final rooms = await roomRepo.getAllRooms();
  if (rooms.isEmpty) {
    await roomRepo.saveRoom(
        Room(id: 'living', name: 'Гостиная', icon: '🛋️', sortOrder: 0));
    await roomRepo.saveRoom(
        Room(id: 'bedroom', name: 'Спальня', icon: '🛏️', sortOrder: 1));
    await roomRepo.saveRoom(
        Room(id: 'kitchen', name: 'Кухня', icon: '🍳', sortOrder: 2));
    await roomRepo.saveRoom(
        Room(id: 'other', name: 'Техника', icon: '🔌', sortOrder: 3));
  }
}