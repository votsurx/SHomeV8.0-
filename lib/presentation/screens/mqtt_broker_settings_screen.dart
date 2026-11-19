import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import '../../data/local/secure_storage/encrypted_keys.dart';
import '../../data/services/mqtt_service_impl.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';

class MqttBrokerSettingsScreen extends StatefulWidget {
  const MqttBrokerSettingsScreen({super.key});

  @override
  State<MqttBrokerSettingsScreen> createState() =>
      _MqttBrokerSettingsScreenState();
}

class _MqttBrokerSettingsScreenState
    extends State<MqttBrokerSettingsScreen> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController =
  TextEditingController(text: '1883');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

    // Порт может храниться как int или String.
    final portRaw = prefs.get('mqtt_port');
    final port = portRaw is int
        ? portRaw
        : int.tryParse(portRaw?.toString() ?? '') ?? 1883;

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
    final l10n = AppLocalizations.of(context);
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 1883;

    if (host.isEmpty) {
      setState(() => _errorMessage = l10n.mqttHostRequired);
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _isConnected = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mqtt_host', host);
      await prefs.setInt('mqtt_port', port);

      final keys = EncryptedKeys();
      await keys.saveMqttUsername(_usernameController.text.trim());
      await keys.saveMqttPassword(_passwordController.text);

      final service = MqttServiceImpl(getIt<Talker>());
      await service.connect(host, port: port);

      if (!mounted) {
        await service.disconnect();
        return;
      }

      final connected = service.isConnected;

      setState(() {
        _isConnected = connected;
        if (!connected) {
          _errorMessage = l10n.mqttConnectionFailed;
        }
      });

      await service.disconnect();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isConnected = false;
        _errorMessage = l10n.mqttConnectionError(error.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mqttSettingsTitle),
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
                    l10n.mqttBrokerTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.mqttUsageHint,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _hostController,
                    decoration: InputDecoration(
                      labelText: l10n.mqttHostLabel,
                      hintText: l10n.mqttHostHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.dns),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.mqttPortLabel,
                      hintText: '1883',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.mqttUsernameLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.mqttPasswordLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
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
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isConnected!
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _isConnected!
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isConnected!
                                  ? l10n.mqttConnectionSuccess
                                  : l10n.mqttConnectionFailureStatus,
                              style: TextStyle(
                                color: _isConnected!
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.wifi),
                      label: Text(
                        _isConnecting
                            ? l10n.mqttConnecting
                            : l10n.mqttSaveAndConnect,
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