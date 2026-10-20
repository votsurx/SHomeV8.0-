/// Роутер приложения на GoRouter.
library;
import 'package:go_router/go_router.dart';
import '../../presentation/screens/menu_screen.dart';
import '../../presentation/screens/device_list_screen.dart';
import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/onboarding/rooms_setup_screen.dart';
import '../../presentation/screens/energy_screen.dart';
import '../../presentation/screens/scenes_screen.dart';
import '../../presentation/screens/scan_devices_screen.dart';
import '../../presentation/screens/rooms_manage_screen.dart';
import '../../presentation/screens/events_screen.dart';
import '../../presentation/screens/timers_screen.dart';
import '../../presentation/screens/statistics_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/cloud_settings_screen.dart';
import '../../presentation/screens/notification_channels_screen.dart';
import '../../presentation/screens/presence_settings_screen.dart';
import '../../presentation/screens/mqtt_broker_settings_screen.dart';
import '../../presentation/screens/zigbee_scan_screen.dart';


final router = GoRouter(
  initialLocation: '/',
  routes: [
    // Главный экран
    GoRoute(
      path: '/',
      builder: (context, state) => const DeviceListScreen(),
    ),

    // Меню
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuScreen(),
    ),

    GoRoute(
      path: '/presence',
      builder: (context, state) => const PresenceSettingsScreen(),
    ),

    // Настройки
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // Облако
    GoRoute(
      path: '/cloud',
      builder: (context, state) => const CloudSettingsScreen(),
    ),

    // Уведомления
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationChannelsScreen(),
    ),

    // Управление комнатами
    GoRoute(
      path: '/rooms',
      builder: (context, state) => const RoomsManageScreen(),
    ),

    // Zigbee сканер
    GoRoute(
      path: '/zigbee_scan',
      builder: (context, state) => const ZigbeeScanScreen(),
    ),

    GoRoute(
      path: '/mqtt_broker_settings',
      builder: (context, state) => const MqttBrokerSettingsScreen(),
    ),

    // Сцены
    GoRoute(
      path: '/scenes',
      builder: (context, state) => const ScenesScreen(),
    ),

    // Таймеры
    GoRoute(
      path: '/timers',
      builder: (context, state) => const TimersScreen(),
    ),

    // Статистика
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),

    // Энергия
    GoRoute(
      path: '/energy',
      builder: (context, state) => const EnergyScreen(),
    ),

    // События
    GoRoute(
      path: '/events',
      builder: (context, state) => const EventsScreen(),
    ),

    // Сканер Tuya
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanDevicesScreen(),
    ),

    // Онбординг
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const WelcomeScreen(),
      routes: [
        GoRoute(
          path: 'scan',
          builder: (context, state) => const ScanDevicesScreen(isOnboarding: true),
        ),
        GoRoute(
          path: 'rooms',
          builder: (context, state) => const RoomsSetupScreen(),
        ),
      ],
    ),
  ],
);