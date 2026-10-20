import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/state/frigate_provider.dart';
import '../../data/local/secure_storage/encrypted_keys.dart';
import '../../di/injection.dart';
import '../../data/services/frigate_service.dart';

class FrigateSettingsScreen extends ConsumerStatefulWidget {
  const FrigateSettingsScreen({super.key});

  @override
  ConsumerState<FrigateSettingsScreen> createState() => _FrigateSettingsScreenState();
}

class _FrigateSettingsScreenState extends ConsumerState<FrigateSettingsScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '5000');
  final _rtspPasswordController = TextEditingController();
  final _statsIntervalController = TextEditingController(text: '5');
  final Set<String> _notifyLabels = {'person', 'car'};

  bool _isLoading = true;
  bool _isSaving = false;
  bool? _isConnected;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _rtspPasswordController.dispose();
    _statsIntervalController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = EncryptedKeys();
    final mqttHost = prefs.getString('mqtt_host') ?? '';
    final host = prefs.getString('frigate_host') ?? mqttHost;
    final port = prefs.getInt('frigate_port') ?? 5000;
    final rtspPassword = await keys.getFrigateRtspPassword() ?? '';
    final statsInterval = prefs.getInt('frigate_stats_interval') ?? 5;
    final notifyRaw = prefs.getStringList('frigate_notify_labels') ?? ['person', 'car'];

    if (!mounted) return;
    setState(() {
      _hostController.text = host;
      _portController.text = port.toString();
      _rtspPasswordController.text = rtspPassword;
      _statsIntervalController.text = statsInterval.toString();
      _notifyLabels.clear();
      _notifyLabels.addAll(notifyRaw);
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 5000;
    final statsInterval = int.tryParse(_statsIntervalController.text.trim()) ?? 5;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('frigate_host', host);
    await prefs.setInt('frigate_port', port);
    await prefs.setInt('frigate_stats_interval', statsInterval);
    await prefs.setStringList('frigate_notify_labels', _notifyLabels.toList());

    final keys = EncryptedKeys();
    await keys.saveFrigateRtspPassword(_rtspPasswordController.text);

    final service = getIt<FrigateService>();
    service.configure(
      host: host,
      port: port,
      rtspPassword: _rtspPasswordController.text,
    );

    ref.read(frigateSettingsProvider.notifier).state = FrigateSettings(
      statsInterval: statsInterval,
      notifyLabels: _notifyLabels,
      rtspPassword: _rtspPasswordController.text,
    );

    await ref.read(frigateCamerasProvider.notifier).refresh();

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Настройки сохранены')),
    );
  }

  Future<void> _testConnection() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 5000;
    final service = getIt<FrigateService>();
    service.configure(host: host, port: port);
    final ok = await service.testConnection();
    if (!mounted) return;
    setState(() => _isConnected = ok);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки Frigate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Подключение', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'Host (IP)',
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
                      labelText: 'Port',
                      hintText: '5000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _rtspPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'RTSP-пароль',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _testConnection,
                        icon: const Icon(Icons.wifi),
                        label: const Text('Проверить'),
                      ),
                      if (_isConnected != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          _isConnected! ? Icons.check_circle : Icons.cancel,
                          color: _isConnected! ? Colors.green : Colors.red,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Настройки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _statsIntervalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Интервал статистики (сек)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Уведомления для:'),
                  ...['person', 'car', 'dog', 'cat', 'motion'].map((label) {
                    return CheckboxListTile(
                      title: Text(label),
                      value: _notifyLabels.contains(label),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _notifyLabels.add(label);
                          } else {
                            _notifyLabels.remove(label);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Сохранение...' : 'Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}