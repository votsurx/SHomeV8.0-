import 'package:flutter/material.dart';

import '../../data/services/screen_saver_settings.dart';

class ScreenSettingsScreen extends StatefulWidget {
  const ScreenSettingsScreen({super.key});

  @override
  State<ScreenSettingsScreen> createState() =>
      _ScreenSettingsScreenState();
}

class _ScreenSettingsScreenState extends State<ScreenSettingsScreen> {
  static const _timeoutOptions = <int, String>{
    30: '30 секунд',
    60: '1 минута',
    120: '2 минуты',
    300: '5 минут',
    600: '10 минут',
  };

  bool _isLoading = true;
  bool _enabled = true;
  bool _motionWakeEnabled = false;
  int _idleTimeoutSeconds = 120;
  int _motionSensitivity = 50;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await ScreenSaverSettings.load();

    if (!mounted) return;

    final config = ScreenSaverSettings.value.value;

    setState(() {
      _enabled = config.enabled;
      _idleTimeoutSeconds = config.idleTimeoutSeconds;
      _motionWakeEnabled = config.motionWakeEnabled;
      _motionSensitivity = config.motionSensitivity;
      _isLoading = false;
    });
  }
  Future<void> _setMotionSensitivity(int sensitivity) async {
    setState(() => _motionSensitivity = sensitivity);
    await ScreenSaverSettings.setMotionSensitivity(sensitivity);
  }

  Future<void> _setMotionWakeEnabled(bool enabled) async {
    setState(() => _motionWakeEnabled = enabled);
    await ScreenSaverSettings.setMotionWakeEnabled(enabled);
  }

  Future<void> _setEnabled(bool enabled) async {
    setState(() => _enabled = enabled);
    await ScreenSaverSettings.setEnabled(enabled);
  }

  Future<void> _setIdleTimeout(int seconds) async {
    setState(() => _idleTimeoutSeconds = seconds);
    await ScreenSaverSettings.setIdleTimeout(seconds);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Настройки экрана'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки экрана')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.animation,
                color: Colors.deepPurple,
              ),
              title: const Text('Заставка'),
              subtitle: const Text(
                'Показывать анимированную заставку после бездействия',
              ),
              value: _enabled,
              onChanged: _setEnabled,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.directions_run,
                color: Colors.teal,
              ),
              title: const Text('Сбрасывать заставку по движению'),
              subtitle: const Text(
                'Использовать фронтальную камеру, пока показана заставка',
              ),
              value: _motionWakeEnabled,
              onChanged: _enabled ? _setMotionWakeEnabled : null,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Чувствительность: $_motionSensitivity%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _motionSensitivity.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '$_motionSensitivity%',
                    onChanged: !_enabled || !_motionWakeEnabled
                        ? null
                        : (value) {
                      setState(() {
                        _motionSensitivity = value.round();
                      });
                    },
                    onChangeEnd: !_enabled || !_motionWakeEnabled
                        ? null
                        : (value) {
                      _setMotionSensitivity(value.round());
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Низкая'),
                      Text('Высокая'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Если заставка срабатывает без движения, '
                        'уменьшите чувствительность.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Время до заставки'),
              subtitle: Text(
                _timeoutOptions[_idleTimeoutSeconds] ??
                    '$_idleTimeoutSeconds секунд',
              ),
              enabled: _enabled,
              trailing: DropdownButton<int>(
                value: _timeoutOptions.containsKey(_idleTimeoutSeconds)
                    ? _idleTimeoutSeconds
                    : null,
                hint: const Text('Выбрать'),
                items: _timeoutOptions.entries
                    .map(
                      (entry) => DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                    .toList(),
                onChanged: !_enabled
                    ? null
                    : (seconds) {
                  if (seconds != null) {
                    _setIdleTimeout(seconds);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}