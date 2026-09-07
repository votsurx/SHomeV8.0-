/// Экран настроек подключения к LegionNVR
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/state/nvr_provider.dart';
import '../../data/services/nvr_api_client.dart';
import '../../data/services/nvr_sync_service.dart';
import '../../di/injection.dart';
import '../../domain/repositories/device_repository.dart';
import 'package:talker/talker.dart';

class NvrSettingsScreen extends ConsumerStatefulWidget {
  const NvrSettingsScreen({super.key});

  @override
  ConsumerState<NvrSettingsScreen> createState() => _NvrSettingsScreenState();
}

class _NvrSettingsScreenState extends ConsumerState<NvrSettingsScreen> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  bool _isTesting = false;
  bool _isConnected = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final settings = ref.read(nvrSettingsProvider);
    _hostController.text = settings.host;
    _portController.text = settings.port.toString();
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);

    try {
      final client = NvrApiClient(
        host: _hostController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 8080,
      );

      _isConnected = await client.isAlive();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isConnected ? '✅ Подключено к LegionNVR' : '❌ Не удалось подключиться',
            ),
            backgroundColor: _isConnected ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 8080;

    if (host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите IP адрес')),
      );
      return;
    }

    final notifier = ref.read(nvrSettingsProvider.notifier);
    await notifier.updateSettings(host: host, port: port);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Настройки сохранены')),
      );
    }
  }

  Future<void> _syncNow() async {
    setState(() => _isSyncing = true);

    try {
      final settings = ref.read(nvrSettingsProvider);
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Синхронизация выполнена')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🖥️ Видео NVR'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Подключение к LegionNVR',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'IP адрес',
                      hintText: '192.168.1.100',
                      prefixIcon: Icon(Icons.dns),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Порт',
                      hintText: '8080',
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isTesting ? null : _testConnection,
                          icon: _isTesting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Icon(Icons.wifi_find),
                          label: Text(_isTesting ? 'Проверка...' : 'Проверить'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveSettings,
                          icon: const Icon(Icons.save),
                          label: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),

                  if (_isConnected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('LegionNVR доступен'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.sync, color: Colors.blue),
              title: const Text('Синхронизировать камеры'),
              subtitle: const Text('Обновить список камер из NVR'),
              trailing: _isSyncing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.chevron_right),
              onTap: _isSyncing ? null : _syncNow,
            ),
          ),

          const SizedBox(height: 24),

          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Интеграция с LegionNVR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Камеры добавляются и настраиваются в LegionNVR'),
                  Text('• Изменения автоматически синхронизируются'),
                  Text('• Управляйте камерами прямо с главного экрана'),
                  Text('• Тревоги отображаются в журнале событий'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}