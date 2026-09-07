/// Провайдер настроек подключения к LegionNVR
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/nvr_api_client.dart';

// ============================================================
// 📦 NVR SETTINGS
// ============================================================

class NvrSettings {
  final String host;
  final int port;
  final bool autoSync;
  final bool showMjpeg;

  const NvrSettings({
    this.host = '',  // ✅ ПУСТОЙ ДЕФОЛТ!
    this.port = 8080,
    this.autoSync = true,
    this.showMjpeg = true,
  });

  NvrSettings copyWith({
    String? host,
    int? port,
    bool? autoSync,
    bool? showMjpeg,
  }) {
    return NvrSettings(
      host: host ?? this.host,
      port: port ?? this.port,
      autoSync: autoSync ?? this.autoSync,
      showMjpeg: showMjpeg ?? this.showMjpeg,
    );
  }

  String get baseUrl => 'http://$host:$port';
}

// ============================================================
// 🔌 NVR SETTINGS NOTIFIER
// ============================================================

final nvrSettingsProvider = StateNotifierProvider<NvrSettingsNotifier, NvrSettings>(
      (ref) => NvrSettingsNotifier(),
);

class NvrSettingsNotifier extends StateNotifier<NvrSettings> {
  static const _hostKey = 'nvr_host';
  static const _portKey = 'nvr_port';
  static const _autoSyncKey = 'nvr_auto_sync';
  static const _showMjpegKey = 'nvr_show_mjpeg';

  NvrSettingsNotifier() : super(const NvrSettings()) {
    print('🔧 NvrSettingsNotifier создан');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHost = prefs.getString(_hostKey);
    final savedPort = prefs.getInt(_portKey);

    print('📡 Загружаем настройки NVR: host=$savedHost, port=$savedPort');

    state = NvrSettings(
      host: savedHost ?? '',
      port: savedPort ?? 8080,
      autoSync: prefs.getBool(_autoSyncKey) ?? state.autoSync,
      showMjpeg: prefs.getBool(_showMjpegKey) ?? state.showMjpeg,
    );

    print('📡 Состояние NVR: host=${state.host}, port=${state.port}');
  }

  Future<void> updateSettings({
    String? host,
    int? port,
    bool? autoSync,
    bool? showMjpeg,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (host != null) {
      await prefs.setString(_hostKey, host);
      print('💾 Сохранён host: $host');
    }
    if (port != null) {
      await prefs.setInt(_portKey, port);
      print('💾 Сохранён port: $port');
    }
    if (autoSync != null) {
      await prefs.setBool(_autoSyncKey, autoSync);
    }
    if (showMjpeg != null) {
      await prefs.setBool(_showMjpegKey, showMjpeg);
    }

    state = state.copyWith(
      host: host,
      port: port,
      autoSync: autoSync,
      showMjpeg: showMjpeg,
    );

    print('📡 Новое состояние NVR: host=${state.host}, port=${state.port}');
  }

  /// Создаёт клиент API с текущими настройками
  NvrApiClient get client => NvrApiClient(
    host: state.host,
    port: state.port,
  );
}

// ============================================================
// 🔄 NVR STATUS PROVIDER
// ============================================================

final nvrStatusProvider = FutureProvider<bool>((ref) async {
  final settings = ref.watch(nvrSettingsProvider);
  final client = NvrApiClient(
    host: settings.host,
    port: settings.port,
  );
  return await client.isAlive();
});