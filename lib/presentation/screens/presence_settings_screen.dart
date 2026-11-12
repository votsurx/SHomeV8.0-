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
            icon: Icons.circle_outlined,
            color: Colors.orange,
            title: 'Радиус',
            subtitle: '${settings.homeRadius} м',
            onTap: () => _showRadiusDialog(context, ref, settings),
          ),

          // ─── Таймаут "ушёл" ───
          _buildCard(
            context: context,
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

  // ═══════════════════════════════════════════════════════════════
  // КАРТОЧКА ТЕЛЕФОНА
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPhoneCard(
      BuildContext context,
      WidgetRef ref,
      PresenceSettingsNotifier notifier,
      PresencePhone phone,
      PhonePresence? presence,
      ) {
    final status = presence?.status ?? PhonePresenceStatus.unknown;
    final source = presence?.source ?? PresenceSource.unknown;

    // ─── Определяем иконку, цвет, текст ───
    IconData icon;
    Color color;
    String statusText;
    String? subtitle;

    if (status == PhonePresenceStatus.home) {
      if (source == PresenceSource.heartbeat) {
        // 🟢 Дома по Wi-Fi — точно дома
        icon = Icons.wifi;
        color = Colors.green;
        statusText = 'Дома (Wi-Fi)';
        subtitle = 'Heartbeat активен';
      } else if (source == PresenceSource.cloud) {
        // 🟡 Дома по облаку — Companion сказал "home" без Wi-Fi
        icon = Icons.cloud_done;
        color = Colors.lightGreen;
        statusText = 'Дома (облако)';
        subtitle = 'Wi-Fi не активен, но Companion дома';
      } else {
        icon = Icons.home;
        color = Colors.green;
        statusText = 'Дома';
        subtitle = null;
      }
    } else if (status == PhonePresenceStatus.away) {
      final dist = presence?.distanceFromHome;
      icon = Icons.directions_walk;
      color = Colors.orange;
      statusText = 'Ушёл';
      subtitle = dist != null
          ? 'Расстояние: ${dist.round()} м'
          : null;
    } else {
      icon = Icons.help_outline;
      color = Colors.grey;
      statusText = 'Неизвестно';
      subtitle = null;
    }

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

  // ═══════════════════════════════════════════════════════════════
  // КАРТОЧКА НАСТРОЙКИ
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  // ДИАЛОГИ
  // ═══════════════════════════════════════════════════════════════

  void _showPhoneDialog(
      BuildContext context,
      WidgetRef ref,
      PresencePhone? existingPhone,
      ) {
    final isEditing = existingPhone != null;
    final nameController =
    TextEditingController(text: existingPhone?.phoneName ?? '');
    final idController =
    TextEditingController(text: existingPhone?.phoneId ?? '');

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
                  hintText: '89533309330',
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

  // ═══════════════════════════════════════════════════════════════
  // ДОМАШНЯЯ ЗОНА — с исправленным GPS
  // ═══════════════════════════════════════════════════════════════

  void _showHomeZoneDialog(
      BuildContext context,
      WidgetRef ref,
      PresenceSettings settings,
      ) {
    final latController = TextEditingController(
      text: settings.homeLat == 0 ? '' : settings.homeLat.toStringAsFixed(6),
    );
    final lngController = TextEditingController(
      text: settings.homeLng == 0 ? '' : settings.homeLng.toStringAsFixed(6),
    );

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
                onPressed: () => _getCurrentLocation(
                  context,
                  latController,
                  lngController,
                ),
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

  /// Получает GPS с увеличенным timeout + fallback.
  Future<void> _getCurrentLocation(
      BuildContext context,
      TextEditingController latController,
      TextEditingController lngController,
      ) async {
    // 1. Проверяем сервис GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ GPS выключен в системе. Включите в настройках.'),
        ),
      );
      return;
    }

    // 2. Проверяем/запрашиваем разрешение
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      // Предлагаем открыть настройки
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Нет разрешения'),
          content: const Text(
            'Разрешение на GPS отклонено навсегда.\n'
                'Откройте настройки и разрешите вручную.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Открыть настройки'),
            ),
          ],
        ),
      );
      if (open == true) {
        await Geolocator.openAppSettings();
      }
      return;
    }
    if (permission == LocationPermission.denied) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Разрешение на GPS не выдано')),
      );
      return;
    }

    // 3. Показываем диалог «Получаем GPS...»
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Получаем GPS...\n'
                    'Может занять до 60 секунд',
              ),
            ),
          ],
        ),
      ),
    );

    Position? position;

    // 4. Пытаемся получить свежие координаты (timeout 60 сек)
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 60),   // ← 60 сек!
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Fresh GPS timeout: $e');
    }

    // 5. Fallback на последнюю известную позицию
    if (position == null) {
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          debugPrint('📍 Используем last known: '
              '${position.latitude}, ${position.longitude}');
        }
      } catch (e) {
        debugPrint('❌ Last known error: $e');
      }
    }

    // 6. Закрываем прогресс-диалог
    if (context.mounted) Navigator.pop(context);

    // 7. Обновляем контроллеры
    if (position != null) {
      latController.text = position.latitude.toStringAsFixed(6);
      lngController.text = position.longitude.toStringAsFixed(6);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Координаты получены:\n'
                  '${position.latitude.toStringAsFixed(6)}, '
                  '${position.longitude.toStringAsFixed(6)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ Не удалось получить GPS.\n'
                  'Попробуйте выйти на открытое место.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // РАДИУС И ТАЙМАУТ
  // ═══════════════════════════════════════════════════════════════

  void _showRadiusDialog(
      BuildContext context,
      WidgetRef ref,
      PresenceSettings settings,
      ) {
    final ctrl = TextEditingController(text: settings.homeRadius.toString());

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
      BuildContext context,
      WidgetRef ref,
      PresenceSettings settings,
      ) {
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