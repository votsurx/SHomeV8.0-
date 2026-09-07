/// Экран настроек подключения к MQTT брокеру MyiSpy
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class MyiSpySettingsScreen extends StatefulWidget {
  const MyiSpySettingsScreen({super.key});

  @override
  State<MyiSpySettingsScreen> createState() => _MyiSpySettingsScreenState();
}

class _MyiSpySettingsScreenState extends State<MyiSpySettingsScreen> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  bool _isSaving = false;
  bool _isSyncing = false;

  Future<void> _syncNow() async {
    setState(() => _isSyncing = true);

    try {
      final mqtt = globalMqttService;
      print('🔍 MQTT service: $mqtt');
      print('🔍 MQTT isConnected: ${mqtt?.isConnected}');

      if (mqtt == null || !mqtt.isConnected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ MQTT не подключён (isConnected=${mqtt?.isConnected})')),
          );
        }
        return;
      }

      await mqtt.publish('ispy/command/sync', '{}');

      // Ждём пока придут конфиги
      await Future.delayed(const Duration(seconds: 2));

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
      if (mounted) setState(() => _isSyncing = false);
    }
  }

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

  // ============================================================
  // 📥 ЗАГРУЗКА НАСТРОЕК
  // ============================================================

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hostController.text = prefs.getString('mqtt_host') ?? '192.168.1.100';
      _portController.text = (prefs.getInt('mqtt_port') ?? 1883).toString();
    });
  }

  // ============================================================
  // 💾 СОХРАНЕНИЕ НАСТРОЕК
  // ============================================================

  Future<void> _saveSettings() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 1883;

    if (host.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите IP адрес MQTT брокера')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mqtt_host', host);
      await prefs.setInt('mqtt_port', port);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Настройки MyiSpy MQTT сохранены'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка сохранения: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ============================================================
  // 🎨 UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 MyiSpy MQTT'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================================
          // ℹ️ ИНФОРМАЦИЯ
          // ============================================================
          Card(
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Подключение к MyiSpy',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('• Укажите IP адрес компьютера где запущен MyiSpy'),
                  Text('• Порт MQTT брокера по умолчанию: 1883'),
                  Text('• MyiSpy публикует события YOLO-детекции'),
                  Text('• SHomeDART получает уведомления в реальном времени'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ============================================================
          // 🔧 НАСТРОЙКИ ПОДКЛЮЧЕНИЯ
          // ============================================================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MQTT Брокер',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'IP адрес',
                      hintText: '192.168.1.100',
                      prefixIcon: Icon(Icons.dns),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Порт',
                      hintText: '1883',
                      prefixIcon: Icon(Icons.settings_ethernet),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveSettings,
                      icon: _isSaving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Сохранение...' : 'Сохранить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ============================================================
          // 🔄 СИНХРОНИЗАЦИЯ
          // ============================================================
          Card(
            child: ListTile(
              leading: const Icon(Icons.sync, color: Colors.orange),
              title: const Text('Синхронизировать камеры'),
              subtitle: const Text('Получить список камер из MyiSpy'),
              trailing: _isSyncing
                  ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.chevron_right),
              onTap: _isSyncing ? null : _syncNow,
            ),
          ),

          // ============================================================
          // 📋 КАК ЭТО РАБОТАЕТ
          // ============================================================
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Как это работает',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. MyiSpy детектирует объекты через YOLO'),
                  Text('2. События публикуются в MQTT топики ispy/#'),
                  Text('3. SHomeDART подписывается и получает уведомления'),
                  Text('4. Карточки камер обновляются в реальном времени'),
                  SizedBox(height: 8),
                  Text(
                    'Топики MyiSpy:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('• ispy/detect/{id} — детекция объектов'),
                  Text('• ispy/motion/{id} — движение'),
                  Text('• ispy/record/{id} — запись'),
                  Text('• ispy/status/{id} — статус камеры'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}