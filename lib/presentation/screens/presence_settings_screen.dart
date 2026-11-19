import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../application/models/presence_settings.dart';
import '../../application/state/presence_detector_provider.dart';
import '../../application/state/presence_provider.dart';
import '../../data/services/presence_detector.dart';
import '../../l10n/generated/app_localizations.dart';

class PresenceSettingsScreen extends ConsumerWidget {
  const PresenceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(presenceSettingsProvider);
    final notifier = ref.read(presenceSettingsProvider.notifier);
    final detector = ref.watch(presenceDetectorProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.presenceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(l10n.presenceTrackingEnable),
            subtitle: Text(l10n.presenceTrackingSubtitle),
            value: settings.enabled,
            onChanged: (value) async {
              await notifier.update(settings.copyWith(enabled: value));
            },
          ),
          const Divider(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  l10n.presencePhones,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showPhoneDialog(context, ref, null),
              ),
            ],
          ),

          if (settings.phones.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.presenceNoPhones),
            )
          else
            ...settings.phones.map((phone) {
              final presence = detector.phones[phone.phoneId];
              return _buildPhoneCard(
                context,
                ref,
                notifier,
                phone,
                presence,
                l10n,
              );
            }),

          const Divider(height: 32),

          _buildCard(
            context: context,
            icon: Icons.my_location,
            color: Colors.blue,
            title: l10n.presenceHomeZone,
            subtitle: settings.homeLat == 0 && settings.homeLng == 0
                ? l10n.presenceNotConfigured
                : '${settings.homeLat.toStringAsFixed(4)}, '
                '${settings.homeLng.toStringAsFixed(4)}',
            onTap: () => _showHomeZoneDialog(context, ref, settings),
          ),

          _buildCard(
            context: context,
            icon: Icons.circle_outlined,
            color: Colors.orange,
            title: l10n.presenceRadius,
            subtitle: '${settings.homeRadius} м',
            onTap: () => _showRadiusDialog(context, ref, settings),
          ),

          _buildCard(
            context: context,
            icon: Icons.timer,
            color: Colors.red,
            title: l10n.presenceAwayTimeout,
            subtitle: '${settings.awayTimeoutMin} мин',
            onTap: () => _showTimeoutDialog(context, ref, settings),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPhoneCard(
      BuildContext context,
      WidgetRef ref,
      PresenceSettingsNotifier notifier,
      PresencePhone phone,
      PhonePresence? presence,
      AppLocalizations l10n,
      ) {
    final status = presence?.status ?? PhonePresenceStatus.unknown;
    final source = presence?.source ?? PresenceSource.unknown;

    IconData icon;
    Color color;
    String statusText;
    String? subtitle;

    if (status == PhonePresenceStatus.home) {
      if (source == PresenceSource.heartbeat) {
        icon = Icons.wifi;
        color = Colors.green;
        statusText = l10n.presenceHomeWifi;
        subtitle = l10n.presenceHeartbeatActive;
      } else if (source == PresenceSource.cloud) {
        icon = Icons.cloud_done;
        color = Colors.lightGreen;
        statusText = l10n.presenceHomeCloud;

        final distance = presence?.distanceFromHome;
        subtitle = distance == null
            ? l10n.presenceWifiInactiveGpsUnavailable
            : l10n.presenceWifiInactiveDistance(
          _formatDistance(distance, l10n),
        );
      } else {
        icon = Icons.home;
        color = Colors.green;
        statusText = l10n.presenceHomeWifi;
        subtitle = null;
      }
    } else if (status == PhonePresenceStatus.away) {
      final distance = presence?.distanceFromHome;

      icon = Icons.directions_walk;
      color = Colors.orange;
      statusText = l10n.presenceAway;
      subtitle = distance == null
          ? null
          : l10n.presenceDistanceFromHome(
        _formatDistance(distance, l10n),
      );
    } else {
      icon = Icons.help_outline;
      color = Colors.grey;
      statusText = l10n.presenceUnknown;
      subtitle = null;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPhoneDialog(context, ref, phone),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            phone.phoneName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (presence?.battery != null)
                          Text(
                            '${presence!.battery}%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${phone.phoneId}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Switch(
                value: phone.enabled,
                onChanged: (value) {
                  notifier.updatePhone(
                    phone.phoneId,
                    phone.copyWith(enabled: value),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showPhoneDialog(
      BuildContext context,
      WidgetRef ref,
      PresencePhone? existingPhone,
      ) {
    final l10n = AppLocalizations.of(context);
    final isEditing = existingPhone != null;
    final nameController =
    TextEditingController(text: existingPhone?.phoneName ?? '');
    final idController =
    TextEditingController(text: existingPhone?.phoneId ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isEditing ? l10n.presenceEditPhone : l10n.presenceAddPhone,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.presenceName,
                  hintText: l10n.presenceNameHint,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: idController,
                enabled: !isEditing,
                decoration: InputDecoration(
                  labelText: l10n.presencePhoneId,
                  hintText: l10n.presencePhoneIdHint,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () {
                ref
                    .read(presenceSettingsProvider.notifier)
                    .removePhone(existingPhone.phoneId);
                Navigator.pop(dialogContext);
              },
              child: Text(
                l10n.presenceDelete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.presenceCancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  idController.text.isEmpty) {
                return;
              }

              final newPhone = PresencePhone(
                phoneId: idController.text.trim(),
                phoneName: nameController.text.trim(),
                enabled: existingPhone?.enabled ?? true,
              );

              if (isEditing) {
                ref.read(presenceSettingsProvider.notifier).updatePhone(
                  existingPhone.phoneId,
                  newPhone,
                );
              } else {
                ref
                    .read(presenceSettingsProvider.notifier)
                    .addPhone(newPhone);
              }

              Navigator.pop(dialogContext);
            },
            child: Text(
              isEditing ? l10n.presenceSave : l10n.presenceAdd,
            ),
          ),
        ],
      ),
    );
  }

  void _showHomeZoneDialog(
      BuildContext context,
      WidgetRef ref,
      PresenceSettings settings,
      ) {
    final l10n = AppLocalizations.of(context);

    final latController = TextEditingController(
      text: settings.homeLat == 0
          ? ''
          : settings.homeLat.toStringAsFixed(6),
    );
    final lngController = TextEditingController(
      text: settings.homeLng == 0
          ? ''
          : settings.homeLng.toStringAsFixed(6),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.presenceHomeZone),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                decoration: InputDecoration(
                  labelText: l10n.presenceLatitude,
                  hintText: '55.7558',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lngController,
                decoration: InputDecoration(
                  labelText: l10n.presenceLongitude,
                  hintText: '37.6173',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _getCurrentLocation(
                  context,
                  latController,
                  lngController,
                ),
                icon: const Icon(Icons.my_location),
                label: Text(l10n.presenceGetCurrentCoordinates),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.presenceCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final latitude = double.tryParse(latController.text);
              final longitude = double.tryParse(lngController.text);

              if (latitude != null && longitude != null) {
                ref.read(presenceSettingsProvider.notifier).update(
                  settings.copyWith(
                    homeLat: latitude,
                    homeLng: longitude,
                  ),
                );
              }

              Navigator.pop(dialogContext);
            },
            child: Text(l10n.presenceSave),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation(
      BuildContext context,
      TextEditingController latController,
      TextEditingController lngController,
      ) async {
    final l10n = AppLocalizations.of(context);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.presenceGpsDisabled)),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;

      final openSettings = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.presencePermissionTitle),
          content: Text(l10n.presencePermissionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.presenceCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.presenceOpenSettings),
            ),
          ],
        ),
      );

      if (openSettings == true) {
        await Geolocator.openAppSettings();
      }
      return;
    }

    if (permission == LocationPermission.denied) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.presencePermissionNotGranted)),
      );
      return;
    }

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(l10n.presenceGettingGps),
            ),
          ],
        ),
      ),
    );

    Position? position;

    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 60),
        ),
      );
    } catch (error) {
      debugPrint('⚠️ Fresh GPS timeout: $error');
    }

    if (position == null) {
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          debugPrint(
            '📍 Используем last known: '
                '${position.latitude}, ${position.longitude}',
          );
        }
      } catch (error) {
        debugPrint('❌ Last known error: $error');
      }
    }

    if (context.mounted) {
      Navigator.pop(context);
    }

    if (position != null) {
      final latitude = position.latitude.toStringAsFixed(6);
      final longitude = position.longitude.toStringAsFixed(6);

      latController.text = latitude;
      lngController.text = longitude;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.presenceCoordinatesReceived(latitude, longitude),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.presenceGpsFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRadiusDialog(
      BuildContext context,
      WidgetRef ref,
      PresenceSettings settings,
      ) {
    final l10n = AppLocalizations.of(context);
    final controller =
    TextEditingController(text: settings.homeRadius.toString());

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.presenceRadius),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.presenceMeters,
            hintText: l10n.presenceRadiusHint,
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.presenceCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final radius = int.tryParse(controller.text);
              if (radius != null && radius > 0) {
                ref.read(presenceSettingsProvider.notifier).update(
                  settings.copyWith(homeRadius: radius),
                );
              }
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.presenceSave),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog(
      BuildContext context,
      WidgetRef ref,
      PresenceSettings settings,
      ) {
    final l10n = AppLocalizations.of(context);
    final controller =
    TextEditingController(text: settings.awayTimeoutMin.toString());

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.presenceAwayTimeout),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.presenceMinutes,
            hintText: l10n.presenceTimeoutHint,
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.presenceCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final timeout = int.tryParse(controller.text);
              if (timeout != null && timeout > 0) {
                ref.read(presenceSettingsProvider.notifier).update(
                  settings.copyWith(awayTimeoutMin: timeout),
                );
              }
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.presenceSave),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters, AppLocalizations l10n) {
    if (meters < 1000) {
      return '${meters.round()} м';
    }

    return '${(meters / 1000).toStringAsFixed(1)} км';
  }
}