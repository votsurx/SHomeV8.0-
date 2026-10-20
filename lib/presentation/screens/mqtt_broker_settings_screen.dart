import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';
import '../../di/injection.dart';
import '../../data/local/secure_storage/encrypted_keys.dart';
import '../../data/services/mqtt_service_impl.dart';

class MqttBrokerSettingsScreen extends StatefulWidget {
  const MqttBrokerSettingsScreen({super.key});

  @override
  State<MqttBrokerSettingsScreen> createState() => _MqttBrokerSettingsScreenState();
}

class _MqttBrokerSettingsScreenState extends State<MqttBrokerSettingsScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '1883');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = true;
  bool _isConnecting = false;
  bool? _isConnected;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = EncryptedKeys();

    final host = prefs.getString('mqtt_host') ?? '';
    final port = prefs.getInt('mqtt_port') ?? 1883;
    final username = await keys.getMqttUsername() ?? '';
    final password = await keys.getMqttPassword() ?? '';

    if (!mounted) return;
    setState(() {
      _hostController.text = host;
      _portController.text = port.toString();
      _usernameController.text = username;
      _passwordController.text = password;
      _isLoading = false;
    });
  }

  Future<void> _saveAndConnect() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 1883;

    if (host.isEmpty) {
      setState(() => _errorMessage = 'Укажите адрес брокера');
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _isConnected = null;
    });

    try {
      // Сохраняем настройки
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mqtt_host', host);
      await prefs.setInt('mqtt_port', port);

      final keys = EncryptedKeys();
      await keys.saveMqttUsername(_usernameController.text.trim());
      await keys.saveMqttPassword(_passwordController.text);

      // Пробуем подключиться
      final service = MqttServiceImpl(getIt<Talker>());
      await service.connect(host, port: port);

      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isConnected = service.isConnected;
        if (!service.isConnected) {
          _errorMessage = 'Не удалось подключиться к брокеру';
        }
      });

      await service.disconnect();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isConnected = false;
        _errorMessage = 'Ошибка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки MQTT')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Брокер MQTT',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Используется для Zigbee2MQTT и Frigate',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'Адрес (IP или hostname)',
                      hintText: '192.168.43.16',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.dns),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Порт',
                      hintText: '1883',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Логин (опционально)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль (опционально)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_isConnected != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isConnected!
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isConnected! ? Icons.check_circle : Icons.cancel,
                            color: _isConnected! ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isConnected!
                                ? 'Подключение успешно'
                                : 'Не удалось подключиться',
                            style: TextStyle(
                              color: _isConnected! ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isConnecting ? null : _saveAndConnect,
                      icon: _isConnecting
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.wifi),
                      label: Text(
                        _isConnecting
                            ? 'Подключение...'
                            : 'Сохранить и подключиться',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}