import 'package:flutter/material.dart';

import '../../data/services/screen_saver_settings.dart';
import '../../l10n/generated/app_localizations.dart';

class ScreenSettingsScreen extends StatefulWidget {
  const ScreenSettingsScreen({super.key});

  @override
  State<ScreenSettingsScreen> createState() => _ScreenSettingsScreenState();
}

class _ScreenSettingsScreenState extends State<ScreenSettingsScreen> {
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

  String _timeoutLabel(AppLocalizations l10n, int seconds) {
    switch (seconds) {
      case 30:
        return l10n.screenSaverTimeout30;
      case 60:
        return l10n.screenSaverTimeout60;
      case 120:
        return l10n.screenSaverTimeout120;
      case 300:
        return l10n.screenSaverTimeout300;
      case 600:
        return l10n.screenSaverTimeout600;
      default:
        return l10n.screenSaverTimeoutSeconds(seconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.screenSettings),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final timeoutOptions = <int>[
      30,
      60,
      120,
      300,
      600,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.animation,
                color: Colors.deepPurple,
              ),
              title: Text(l10n.screenSaverTitle),
              subtitle: Text(l10n.screenSaverSubtitle),
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
              title: Text(l10n.screenSaverMotionWakeTitle),
              subtitle: Text(l10n.screenSaverMotionWakeSubtitle),
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
                          l10n.screenSaverSensitivity(_motionSensitivity),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.screenSaverSensitivityLow),
                      Text(l10n.screenSaverSensitivityHigh),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.screenSaverSensitivityHint,
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
              title: Text(l10n.screenSaverTimeoutTitle),
              subtitle: Text(_timeoutLabel(l10n, _idleTimeoutSeconds)),
              enabled: _enabled,
              trailing: DropdownButton<int>(
                value: timeoutOptions.contains(_idleTimeoutSeconds)
                    ? _idleTimeoutSeconds
                    : null,
                hint: Text(l10n.screenSaverChoose),
                items: timeoutOptions
                    .map(
                      (seconds) => DropdownMenuItem<int>(
                    value: seconds,
                    child: Text(_timeoutLabel(l10n, seconds)),
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