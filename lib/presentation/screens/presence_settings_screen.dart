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
          // Включение
          SwitchListTile(
            title: const Text('Отслеживать присутствие'),
            subtitle: const Text('Определять, кто дома'),
            value: settings.enabled,
            onChanged: (val) async {
              await notifier.update(settings.copyWith(enabled: val));
              // Провайдер сам запустит/остановит детектор
            },
          ),
          const Divider(height: 32),

          // Pair ID
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: TextEditingController(text: settings.pairId),
              decoration: const InputDecoration(
                labelText: 'Pair ID',
                hintText: 'ID связки из SHome-GEO',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                notifier.update(settings.copyWith(pairId: val.trim()));
              },
            ),
          ),
          const Divider(height: 32),

          // Телефоны
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Телефоны',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddPhoneDialog(context, ref),
              ),
            ],
          ),
          if (settings.phones.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Нет добавленных телефонов'),
            )
          else
            ...settings.phones.map((phone) => Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: Text(phone.phoneName),
                subtitle: Text(
                  'ID: ${phone.phoneId}${phone.ip.isNotEmpty ? "\nIP: ${phone.ip}" : ""}',
                ),
                isThreeLine: phone.ip.isNotEmpty,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: phone.enabled,
                      onChanged: (val) {
                        notifier.updatePhone(
                          phone.phoneId,
                          phone.copyWith(enabled: val),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        notifier.removePhone(phone.phoneId);
                      },
                    ),
                  ],
                ),
              ),
            )),
          const Divider(height: 32),

          // Домашняя зона
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Домашняя зона',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  label: 'Широта',
                  hint: '55.7558',
                  value: settings.homeLat.toStringAsFixed(6),
                  onChanged: (val) {
                    final lat = double.tryParse(val);
                    if (lat != null) {
                      notifier.update(settings.copyWith(homeLat: lat));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  label: 'Долгота',
                  hint: '37.6173',
                  value: settings.homeLng.toStringAsFixed(6),
                  onChanged: (val) {
                    final lng = double.tryParse(val);
                    if (lng != null) {
                      notifier.update(settings.copyWith(homeLng: lng));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
// ─── КНОПКА ОПРЕДЕЛИТЬ ───
          OutlinedButton.icon(
            onPressed: () async {
              try {
                // Запрашиваем разрешение
                LocationPermission permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                }
                if (permission == LocationPermission.deniedForever) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Разрешение на GPS запрещено')),
                  );
                  return;
                }

                // Получаем координаты
                final pos = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                  timeLimit: const Duration(seconds: 15),
                );

                // Сохраняем
                await notifier.update(settings.copyWith(
                  homeLat: pos.latitude,
                  homeLng: pos.longitude,
                ));

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✅ Координаты: ${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}',
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Ошибка: $e')),
                );
              }
            },
            icon: const Icon(Icons.my_location),
            label: const Text('Определить мои координаты'),
          ),
          _buildNumberField(
            label: 'Радиус (м)',
            hint: '100',
            value: settings.homeRadius.toString(),
            onChanged: (val) {
              final r = int.tryParse(val);
              if (r != null) {
                notifier.update(settings.copyWith(homeRadius: r));
              }
            },
          ),
          const SizedBox(height: 8),
          _buildNumberField(
            label: 'Таймаут "ушёл" (мин)',
            hint: '5',
            value: settings.awayTimeoutMin.toString(),
            onChanged: (val) {
              final t = int.tryParse(val);
              if (t != null) {
                notifier.update(settings.copyWith(awayTimeoutMin: t));
              }
            },
          ),
          const Divider(height: 32),

          // Статус
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Статус',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          ..._buildStatus(detector),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
      ),
    );
  }

  List<Widget> _buildStatus(PresenceDetector detector) {
    if (detector.phones.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Нет данных'),
        ),
      ];
    }

    return detector.phones.values.map((phone) {
      final icon = phone.status == PhonePresenceStatus.home
          ? Icons.home
          : phone.status == PhonePresenceStatus.away
          ? Icons.directions_walk
          : Icons.help_outline;
      final color = phone.status == PhonePresenceStatus.home
          ? Colors.green
          : phone.status == PhonePresenceStatus.away
          ? Colors.orange
          : Colors.grey;
      final status = phone.status == PhonePresenceStatus.home
          ? 'Дома${phone.viaWifi ? " (Wi-Fi)" : " (GPS)"}'
          : phone.status == PhonePresenceStatus.away
          ? 'Ушёл'
          : 'Неизвестно';

      return Card(
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(phone.phoneName),
          subtitle: Text(status),
          trailing: phone.battery != null
              ? Text('${phone.battery}%', style: const TextStyle(fontSize: 12))
              : null,
        ),
      );
    }).toList();
  }

  void _showAddPhoneDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final ipController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить телефон'),
        content: Column(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || idController.text.isEmpty) {
                return;
              }
              ref.read(presenceSettingsProvider.notifier).addPhone(
                PresencePhone(
                  phoneId: idController.text.trim(),
                  phoneName: nameController.text.trim(),
                  ip: ipController.text.trim(),
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}