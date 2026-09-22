import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/models/presence_settings.dart';
import '../../application/state/presence_provider.dart';
import '../../application/state/presence_detector_provider.dart';
import '../../data/services/presence_detector.dart';
import 'package:geolocator/geolocator.dart';

class PresenceSettingsScreen extends ConsumerWidget {
  const PresenceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(presenceSettingsProvider);
    final notifier = ref.read(presenceSettingsProvider.notifier);
    final detector = ref.watch(presenceDetectorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Присутствие')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Включение ───
          SwitchListTile(
            title: const Text('Включить отслеживание'),
            subtitle: const Text('Определять, кто дома'),
            value: settings.enabled,
            onChanged: (val) async {
              await notifier.update(settings.copyWith(enabled: val));
            },
          ),
          const Divider(height: 32),

          // ─── Телефоны ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  'Телефоны',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showPhoneDialog(context, ref, null),
              ),
            ],
          ),
          if (settings.phones.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Нет добавленных телефонов'),
            )
          else
            ...settings.phones.map((phone) {
              final presence = detector.phones[phone.phoneId];
              return _buildPhoneCard(context, ref, notifier, phone, presence);
            }),
          const Divider(height: 32),

          // ─── Домашняя зона ───
          _buildCard(
            context: context,
            ref: ref,
            icon: Icons.my_location,
            color: Colors.blue,
            title: 'Домашняя зона',
            subtitle: settings.homeLat == 0 && settings.homeLng == 0
                ? 'Не настроено'
                : '${settings.homeLat.toStringAsFixed(4)}, ${settings.homeLng.toStringAsFixed(4)}',
            onTap: () => _showHomeZoneDialog(context, ref, settings),
          ),

          // ─── Радиус ───
          _buildCard(
            context: context,
            ref: ref,
            icon: Icons.circle_outlined,
            color: Colors.orange,
            title: 'Радиус',
            subtitle: '${settings.homeRadius} м',
            onTap: () => _showRadiusDialog(context, ref, settings),
          ),

          // ─── Таймаут "ушёл" ───
          _buildCard(
            context: context,
            ref: ref,
            icon: Icons.timer,
            color: Colors.red,
            title: 'Таймаут "ушёл"',
            subtitle: '${settings.awayTimeoutMin} мин',
            onTap: () => _showTimeoutDialog(context, ref, settings),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── Карточка телефона ───
  Widget _buildPhoneCard(
      BuildContext context,
      WidgetRef ref,
      PresenceSettingsNotifier notifier,
      PresencePhone phone,
      PhonePresence? presence,
      ) {
    final status = presence?.status ?? PhonePresenceStatus.unknown;
    final icon = status == PhonePresenceStatus.home
        ? Icons.home
        : status == PhonePresenceStatus.away
        ? Icons.directions_walk
        : Icons.help_outline;
    final color = status == PhonePresenceStatus.home
        ? Colors.green
        : status == PhonePresenceStatus.away
        ? Colors.orange
        : Colors.grey;
    final statusText = status == PhonePresenceStatus.home
        ? 'Дома${presence?.viaWifi == true ? " (Wi-Fi)" : " (GPS)"}'
        : status == PhonePresenceStatus.away
        ? 'Ушёл'
        : 'Неизвестно';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
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
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${phone.phoneId}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (phone.ip.isNotEmpty)
                      Text(
                        'IP: ${phone.ip}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              Switch(
                value: phone.enabled,
                onChanged: (val) {
                  notifier.updatePhone(
                    phone.phoneId,
                    phone.copyWith(enabled: val),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Карточка настройки ───
  Widget _buildCard({
    required BuildContext context,
    required WidgetRef ref,
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

  // ─── ДИАЛОГИ ───

  void _showPhoneDialog(
      BuildContext context, WidgetRef ref, PresencePhone? existingPhone) {
    final isEditing = existingPhone != null;
    final nameController =
    TextEditingController(text: existingPhone?.phoneName ?? '');
    final idController =
    TextEditingController(text: existingPhone?.phoneId ?? '');
    final ipController =
    TextEditingController(text: existingPhone?.ip ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Редактировать телефон' : 'Добавить телефон'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Мой телефон',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: idController,
                enabled: !isEditing,
                decoration: const InputDecoration(
                  labelText: 'Phone ID',
                  hintText: 'phone_1',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(
                  labelText: 'IP (необязательно)',
                  hintText: '192.168.1.50',
                ),
                keyboardType: TextInputType.number,
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
                Navigator.pop(ctx);
              },
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || idController.text.isEmpty) {
                return;
              }

              final newPhone = PresencePhone(
                phoneId: idController.text.trim(),
                phoneName: nameController.text.trim(),
                ip: ipController.text.trim(),
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
              Navigator.pop(ctx);
            },
            child: Text(isEditing ? 'Сохранить' : 'Добавить'),
          ),
        ],
      ),
    );
  }

  void _showHomeZoneDialog(
      BuildContext context, WidgetRef ref, PresenceSettings settings) {
    final latController =
    TextEditingController(text: settings.homeLat.toStringAsFixed(6));
    final lngController =
    TextEditingController(text: settings.homeLng.toStringAsFixed(6));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Домашняя зона'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'Широта',
                  hintText: '55.7558',
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(
                  labelText: 'Долгота',
                  hintText: '37.6173',
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    LocationPermission permission =
                    await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                    }
                    if (permission == LocationPermission.deniedForever) {
                      return;
                    }

                    final pos = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                      timeLimit: const Duration(seconds: 15),
                    );

                    latController.text = pos.latitude.toStringAsFixed(6);
                    lngController.text = pos.longitude.toStringAsFixed(6);
                  } catch (e) {
                    debugPrint('❌ Ошибка GPS: $e');
                  }
                },
                icon: const Icon(Icons.my_location),
                label: const Text('Определить мои координаты'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);
              if (lat != null && lng != null) {
                ref.read(presenceSettingsProvider.notifier).update(
                  settings.copyWith(homeLat: lat, homeLng: lng),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showRadiusDialog(
      BuildContext context, WidgetRef ref, PresenceSettings settings) {
    final ctrl =
    TextEditingController(text: settings.homeRadius.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Радиус'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Метры',
            hintText: '100',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final r = int.tryParse(ctrl.text);
              if (r != null && r > 0) {
                ref.read(presenceSettingsProvider.notifier).update(
                  settings.copyWith(homeRadius: r),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog(
      BuildContext context, WidgetRef ref, PresenceSettings settings) {
    final ctrl =
    TextEditingController(text: settings.awayTimeoutMin.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Таймаут "ушёл"'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Минуты',
            hintText: '5',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = int.tryParse(ctrl.text);
              if (t != null && t > 0) {
                ref.read(presenceSettingsProvider.notifier).update(
                  settings.copyWith(awayTimeoutMin: t),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}