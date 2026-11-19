/// Настройки устройства — bottom sheet с полным набором полей.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class DeviceSettings {
  // ===================================================================
  // ОСНОВНОЙ МЕТОД — открывает bottom sheet настроек устройства
  // ===================================================================

  static void show(BuildContext context, WidgetRef ref, Device device) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: device.name);
    final rooms = ref.watch(roomsProvider);
    String selectedRoomId = device.roomId;

    final roomIds = rooms.map((r) => r.id).toList();
    if (!roomIds.contains(selectedRoomId) && rooms.isNotEmpty) {
      selectedRoomId = rooms.first.id;
    }

    final localKeyController = TextEditingController(text: device.localKey ?? '');
    final addressController = TextEditingController(text: device.address ?? '');
    double selectedVersion = device.version ?? 3.3;

    final rtspUrlController = TextEditingController(text: device.properties['rtspUrl'] as String? ?? '');

    final channelCount = device.type == DeviceType.switch3 ? 3 : (device.type == DeviceType.switch2 ? 2 : 1);
    final dpsControllers = List.generate(
      channelCount,
          (i) => TextEditingController(text: '${(device.dpsIndex ?? 1) + i}'),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final latestDevice = ref.watch(devicesProvider).firstWhere(
                (d) => d.id == device.id,
            orElse: () => device,
          );

          final isZigbee = latestDevice.properties['source'] == 'zigbee';
          final isTuya = !isZigbee && latestDevice.type != DeviceType.camera;

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ╔══════════════════════════════════════════╗
                  // ║        НАЗВАНИЕ (для всех устройств)     ║
                  // ╚══════════════════════════════════════════╝
                  Text(latestDevice.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.deviceSettingsName,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ╔══════════════════════════════════════════╗
                  // ║        КОМНАТА (для всех устройств)      ║
                  // ╚══════════════════════════════════════════╝
                  DropdownButtonFormField<String>(
                    initialValue: selectedRoomId,
                    decoration: InputDecoration(
                      labelText: l10n.deviceSettingsRoom,
                      prefixIcon: const Icon(Icons.meeting_room),
                    ),
                    items: rooms
                        .map((r) => DropdownMenuItem(
                      value: r.id,
                      child: Text('${r.icon ?? "🏠"} ${r.name}'),
                    ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedRoomId = v);
                    },
                  ),

                  // ╔══════════════════════════════════════════╗
                  // ║    RTSP URL (только для RTSP камер)      ║
                  // ╚══════════════════════════════════════════╝
                  if (latestDevice.type == DeviceType.camera && latestDevice.properties['cameraType'] == 'rtsp') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: rtspUrlController,
                      decoration: const InputDecoration(labelText: 'RTSP URL', prefixIcon: Icon(Icons.link)),
                    ),
                  ],

                  // ╔══════════════════════════════════════════╗
                  // ║   ZIGBEE-ПОЛЯ (только для Zigbee)        ║
                  // ╚══════════════════════════════════════════╝
                  if (isZigbee) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.deviceSettingsZigbeeDevice,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),

                    TextField(
                      controller: TextEditingController(text: latestDevice.properties['ieee_address'] ?? ''),
                      decoration: const InputDecoration(
                        labelText: 'IEEE-адрес',
                        prefixIcon: Icon(Icons.fingerprint),
                      ),
                      readOnly: true,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: TextEditingController(
                        text: latestDevice.properties['model'] ?? '',
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.deviceSettingsModel,
                        prefixIcon: const Icon(Icons.devices),
                      ),
                      readOnly: true,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: TextEditingController(
                        text: latestDevice.properties['vendor'] ?? '',
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.deviceSettingsVendor,
                        prefixIcon: const Icon(Icons.business),
                      ),
                      readOnly: true,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (latestDevice.properties['battery'] != null) ...[
                      TextField(
                        controller: TextEditingController(
                          text: '${latestDevice.properties['battery']}%',
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.deviceSettingsBattery,
                          prefixIcon: const Icon(Icons.battery_full),
                        ),
                        readOnly: true,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (latestDevice.properties['linkquality'] != null) ...[
                      TextField(
                        controller: TextEditingController(
                          text: '${latestDevice.properties['linkquality']} lqi',
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.deviceSettingsLinkQuality,
                          prefixIcon: const Icon(Icons.signal_cellular_alt),
                        ),
                        readOnly: true,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // 🔔 Уведомления (для Zigbee-датчиков)
                    if (isZigbee && latestDevice.properties['exposes'] != null) ...[
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.notifications_active, color: Colors.orange),
                          title: Text(l10n.deviceSettingsNotifications),
                          subtitle: Text(
                            _getNotifySummary(latestDevice, l10n),
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(ctx);
                            context.push('/device_notifications?id=${latestDevice.id}');
                          },
                        ),
                      ),
                    ],
                  ],
                  // ╔══════════════════════════════════════════╗
                  // ║  🔔 УВЕДОМЛЕНИЯ (только для Tuya)        ║
                  // ╚══════════════════════════════════════════╝
                  if (isTuya) ...[
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.notifications_active,
                          color: Colors.orange,
                        ),
                        title: Text(l10n.deviceSettingsNotifications),
                        subtitle: Text(
                          _getNotifySummary(latestDevice, l10n),
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(ctx);
                          context.push(
                            '/device_notifications?id=${latestDevice.id}',
                          );
                        },
                      ),
                    ),
                  ],

                  // ╔══════════════════════════════════════════╗
                  // ║  СТАНДАРТНЫЕ ПОЛЯ TUYA (только для Tuya) ║
                  // ╚══════════════════════════════════════════╝
                  if (isTuya) ...[
                    const SizedBox(height: 8),

                    TextField(
                      controller: TextEditingController(text: latestDevice.deviceId ?? ''),
                      decoration: const InputDecoration(labelText: 'Device ID', prefixIcon: Icon(Icons.fingerprint)),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: l10n.deviceSettingsIpAddress,
                        prefixIcon: const Icon(Icons.wifi),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: localKeyController,
                      decoration: const InputDecoration(labelText: 'Local Key', prefixIcon: Icon(Icons.vpn_key)),
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<double>(
                      initialValue: selectedVersion,
                      decoration:
                    InputDecoration(
                    labelText: l10n.deviceSettingsProtocolVersion,
                    prefixIcon: const Icon(Icons.info_outline),
                    ),
                      items: const [
                        DropdownMenuItem(value: 3.1, child: Text('3.1')),
                        DropdownMenuItem(value: 3.3, child: Text('3.3')),
                        DropdownMenuItem(value: 3.4, child: Text('3.4')),
                        DropdownMenuItem(value: 3.5, child: Text('3.5')),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedVersion = v);
                      },
                    ),
                  ],

                  // ╔══════════════════════════════════════════╗
                  // ║  DPS ИНДЕКСЫ (только для Tuya, не Zigbee)║
                  // ╚══════════════════════════════════════════╝
                  if (isTuya && latestDevice.type != DeviceType.compound) ...[
                    const SizedBox(height: 8),
                    if (latestDevice.type == DeviceType.switch1 ||
                        latestDevice.type == DeviceType.switch2 ||
                        latestDevice.type == DeviceType.switch3) ...[
                      Text(
                        '${l10n.deviceSettingsChannels}:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ..._buildDpsMapEditor(latestDevice, setModalState, ctx, ref, l10n),
                    ] else ...[
                      TextField(
                        controller: dpsControllers.first,
                        decoration: InputDecoration(
                          labelText: l10n.deviceSettingsDpsIndex,
                          hintText: '1',
                          prefixIcon: const Icon(Icons.tune),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],

                  // ╔══════════════════════════════════════════╗
                  // ║ DPS КАРТА (только для Tuya compound/hvac)║
                  // ╚══════════════════════════════════════════╝
                  if (!isZigbee && (latestDevice.type == DeviceType.compound || latestDevice.type == DeviceType.hvac)) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.deviceSettingsDpsMap}:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._buildDpsMapEditor(latestDevice, setModalState, ctx, ref, l10n),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showDpsEditor(ctx, setModalState, latestDevice, null, ref, l10n,),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.deviceSettingsAddDps),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 36),
                      ),
                    ),
                  ],

                  // ╔══════════════════════════════════════════╗
                  // ║    ОТОБРАЖЕНИЕ НА КАРТОЧКЕ              ║
                  // ╚══════════════════════════════════════════╝
                  if (!isZigbee && (latestDevice.type == DeviceType.compound || latestDevice.type == DeviceType.hvac)) ...[
                    const SizedBox(height: 12),
                    _buildDisplaySettings(ref, latestDevice, () => setModalState(() {}), l10n),
                  ],

                  // ╔══════════════════════════════════════════╗
                  // ║      КНОПКИ: СОХРАНИТЬ / УДАЛИТЬ         ║
                  // ╚══════════════════════════════════════════╝
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Map<String, dynamic> newProperties = {...latestDevice.properties};

                          if (latestDevice.type == DeviceType.camera &&
                              latestDevice.properties['cameraType'] == 'rtsp') {
                            newProperties['rtspUrl'] = rtspUrlController.text;
                          }

                          final updated = latestDevice.copyWith(
                            name: nameController.text,
                            roomId: selectedRoomId,
                            address: isTuya && addressController.text.isNotEmpty
                                ? addressController.text
                                : latestDevice.address,
                            localKey: isTuya && localKeyController.text.isNotEmpty
                                ? localKeyController.text
                                : latestDevice.localKey,
                            dpsIndex: isTuya && latestDevice.type != DeviceType.compound
                                ? (int.tryParse(dpsControllers.first.text) ?? latestDevice.dpsIndex)
                                : latestDevice.dpsIndex,
                            version: isTuya ? selectedVersion : latestDevice.version,
                            properties: newProperties,
                          );
                          ref.read(devicesProvider.notifier).updateDevice(updated);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.save),
                        label: Text(l10n.deviceSettingsSave),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => showDialog(
                          context: ctx,
                          builder: (dCtx) => AlertDialog(
                            title: Text(l10n.deviceSettingsDeleteTitle),
                            content: Text(
                              l10n.deviceSettingsDeleteMessage(latestDevice.name),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Отмена')),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(devicesProvider.notifier).removeDevice(latestDevice.id);
                                  Navigator.pop(dCtx);
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                child: Text(l10n.deviceSettingsDelete),
                              ),
                            ],
                          ),
                        ),
                        icon: const Icon(Icons.delete),
                        label: Text(l10n.deviceSettingsDelete),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      ),
                    ),
                  ]),

                  // ╔══════════════════════════════════════════╗
                  // ║  СОЗДАТЬ ДАТЧИК (только для Tuya)        ║
                  // ╚══════════════════════════════════════════╝
                  if (isTuya &&
                      latestDevice.type != DeviceType.sensor &&
                      latestDevice.type != DeviceType.camera &&
                      latestDevice.type != DeviceType.compound) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCreateSensorDialog(context, ref, latestDevice, l10n);
                        },
                        icon: const Icon(Icons.add_chart, size: 18),
                        label: Text(l10n.deviceSettingsCreateSensor),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===================================================================
  // СВОДКА УВЕДОМЛЕНИЙ
  // ===================================================================

  static String _getNotifySummary(
      Device device,
      AppLocalizations l10n,
      ) {
    final condition =
        device.properties['notify_condition'] as String? ?? 'always';

    final conditionLabel = switch (condition) {
      'always' => l10n.deviceSettingsNotifyAlways,
      'away' => l10n.deviceSettingsNotifyAway,
      'night' => l10n.deviceSettingsNotifyNight,
      'away_or_night' => l10n.deviceSettingsNotifyAwayOrNight,
      _ => l10n.deviceSettingsNotifyAlways,
    };

    final typeCount =
        (device.properties['notify_types'] as List?)?.length ?? 5;

    return l10n.deviceSettingsNotifySummary(typeCount, conditionLabel);
  }

  // ===================================================================
  // DPS КАРТА — отображение списка DPS
  // ===================================================================

  static List<Widget> _buildDpsMapEditor(Device device,
      void Function(VoidCallback) setModalState,
      BuildContext ctx,
      WidgetRef ref,
      AppLocalizations l10n,
      ) {
    final dpsMap = Map<String, dynamic>.from(device.properties['dps_map'] as Map? ?? {});

    final sortedKeys = dpsMap.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    return sortedKeys.map((key) {
      final cfg = dpsMap[key] as Map<String, dynamic>;
      final label = cfg['label'] as String? ?? '';
      final role = cfg['role'] as String? ?? '';
      final iconName = cfg['icon'] as String? ?? '';

      final leading = role == 'channel'
          ? const Icon(Icons.tune, size: 16, color: Colors.blueGrey)
          : _dpsIcon(role, iconName);

      final titlePrefix = role == 'channel' ? 'Канал' : 'DPS';

      return ListTile(
        dense: true,
        leading: leading,
        title: Text('$titlePrefix $key: $label', style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.edit, size: 16),
        onTap: () {
          if (role == 'channel') {
            _showChannelEditor(ctx, setModalState, device, key, ref, l10n);
          } else {
            _showDpsEditor(ctx, setModalState, device, key, ref, l10n);
          }
        },
      );
    }).toList();
  }

  static Widget _dpsIcon(String role, String? iconName) {
    if (iconName != null && iconName.isNotEmpty) {
      return Text(_iconEmoji(iconName), style: const TextStyle(fontSize: 16));
    }
    return _dpsRoleIcon(role);
  }

  static Icon _dpsRoleIcon(String role) {
    switch (role) {
      case 'main':
        return const Icon(Icons.power_settings_new, size: 16, color: Colors.green);
      case 'action':
        return const Icon(Icons.play_circle, size: 16, color: Colors.blue);
      case 'toggle':
        return const Icon(Icons.toggle_on, size: 16, color: Colors.orange);
      case 'info':
        return const Icon(Icons.info_outline, size: 16, color: Colors.grey);
      case 'status':
        return const Icon(Icons.info, size: 16, color: Colors.teal);
      case 'slider':
        return const Icon(Icons.tune, size: 16, color: Colors.purple);
      case 'enum':
        return const Icon(Icons.list, size: 16, color: Colors.indigo);
      case 'channel':
        return const Icon(Icons.tune, size: 16, color: Colors.blueGrey);
      default:
        return const Icon(Icons.help_outline, size: 16);
    }
  }

  static String _iconEmoji(String key) {
    switch (key) {
      case 'battery': return '🔋';
      case 'timer': return '⏱';
      case 'area': return '📐';
      case 'water': return '💧';
      case 'fan': return '🌀';
      case 'temp': return '🌡';
      case 'home': return '🏠';
      case 'power': return '⚡';
      case 'mop': return '🧹';
      case 'ac': return '❄️';
      case 'heater': return '🔥';
      case 'air': return '🍃';
      case 'suction': return '🌪️';
      case 'wait': return '⏳';
      case 'sync': return '🔄';
      default: return '📌';
    }
  }

  // ===================================================================
  // РЕДАКТОР ОДНОГО DPS
  // ===================================================================

  static void _showDpsEditor(
      BuildContext context,
      void Function(VoidCallback) setModalState,
      Device device,
      String? dpsKey,
      WidgetRef ref,
      AppLocalizations l10n,
      ) {
    final isNew = dpsKey == null;
    final dpsMap = Map<String, dynamic>.from(device.properties['dps_map'] as Map? ?? {});

    final keyController = TextEditingController(text: dpsKey ?? '');
    final labelController = TextEditingController(text: isNew ? '' : dpsMap[dpsKey]?['label'] ?? '');
    String selectedType = isNew ? 'bool' : dpsMap[dpsKey]?['type'] ?? 'bool';
    const validTypes = ['bool', 'value', 'enum', 'slider'];
    if (!validTypes.contains(selectedType)) {
      selectedType = 'bool';
    }
    String selectedRole = isNew ? 'action' : dpsMap[dpsKey]?['role'] ?? 'action';
    const validRoles = ['main', 'action', 'toggle', 'info', 'status', 'enum', 'slider', 'channel'];
    if (!validRoles.contains(selectedRole)) {
      selectedRole = 'action';
    }
    String selectedIcon = isNew ? '' : dpsMap[dpsKey]?['icon'] ?? '';
    final enumValuesController = TextEditingController(
      text: isNew ? '' : (dpsMap[dpsKey]?['enum_values'] as List?)?.join(', ') ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            isNew
                ? l10n.deviceSettingsDpsAddTitle
                : l10n.deviceSettingsDpsEditTitle(dpsKey),
          ),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: keyController,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsDpsNumber,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsName,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Тип'),
                items: [
                  DropdownMenuItem(
                    value: 'bool',
                    child: Text('bool (${l10n.deviceSettingsTypeBool})'),
                  ),
                  DropdownMenuItem(
                    value: 'value',
                    child: Text('value (${l10n.deviceSettingsTypeValue})'),
                  ),
                  DropdownMenuItem(
                    value: 'enum',
                    child: Text('enum (${l10n.deviceSettingsTypeEnum})'),
                  ),
                  DropdownMenuItem(
                    value: 'slider',
                    child: Text('slider (${l10n.deviceSettingsTypeSlider})'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedType = v);
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsDpsRole,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'main',
                    child: Text('main (${l10n.deviceSettingsRoleMain})'),
                  ),
                  DropdownMenuItem(
                    value: 'action',
                    child: Text('action (${l10n.deviceSettingsRoleAction})'),
                  ),
                  DropdownMenuItem(
                    value: 'toggle',
                    child: Text('toggle (${l10n.deviceSettingsRoleToggle})'),
                  ),
                  DropdownMenuItem(
                    value: 'info',
                    child: Text('info (${l10n.deviceSettingsRoleInfo})'),
                  ),
                  DropdownMenuItem(
                    value: 'status',
                    child: Text('status (${l10n.deviceSettingsRoleStatus})'),
                  ),
                  DropdownMenuItem(
                    value: 'enum',
                    child: Text('enum (${l10n.deviceSettingsRoleEnum})'),
                  ),
                  DropdownMenuItem(
                    value: 'slider',
                    child: Text('slider (${l10n.deviceSettingsRoleSlider})'),
                  ),
                  DropdownMenuItem(
                    value: 'channel',
                    child: Text('channel (${l10n.deviceSettingsRoleChannel})'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedRole = v);
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedIcon.isEmpty ? null : selectedIcon,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsDpsIcon,
                ),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(l10n.deviceSettingsIconNone),
                  ),
                  DropdownMenuItem(
                    value: 'play',
                    child: Text('▶/⏹ ${l10n.deviceSettingsIconPlayStop}'),
                  ),
                  DropdownMenuItem(
                    value: 'home',
                    child: Text('🏠 ${l10n.deviceSettingsIconHomeBase}'),
                  ),
                  DropdownMenuItem(
                    value: 'power',
                    child: Text('⚡ ${l10n.deviceSettingsIconPower}'),
                  ),
                  DropdownMenuItem(
                    value: 'water',
                    child: Text('💧 ${l10n.deviceSettingsIconWater}'),
                  ),
                  DropdownMenuItem(
                    value: 'mop',
                    child: Text('🧹 ${l10n.deviceSettingsIconMop}'),
                  ),
                  DropdownMenuItem(
                    value: 'do_not_disturb',
                    child: Text('🔕 ${l10n.deviceSettingsIconDoNotDisturb}'),
                  ),
                  DropdownMenuItem(
                    value: 'battery',
                    child: Text('🔋 ${l10n.deviceSettingsIconBattery}'),
                  ),
                  DropdownMenuItem(
                    value: 'timer',
                    child: Text('⏱ ${l10n.deviceSettingsIconTimer}'),
                  ),
                  DropdownMenuItem(
                    value: 'area',
                    child: Text('📐 ${l10n.deviceSettingsIconArea}'),
                  ),
                  DropdownMenuItem(
                    value: 'fan',
                    child: Text('🌀 ${l10n.deviceSettingsIconFan}'),
                  ),
                  DropdownMenuItem(
                    value: 'cool',
                    child: Text('❄️ ${l10n.deviceSettingsIconCooling}'),
                  ),
                  DropdownMenuItem(
                    value: 'heat',
                    child: Text('🔥 ${l10n.deviceSettingsIconHeating}'),
                  ),
                  DropdownMenuItem(
                    value: 'dry',
                    child: Text('💨 ${l10n.deviceSettingsIconDrying}'),
                  ),
                  DropdownMenuItem(
                    value: 'auto',
                    child: Text('🔄 ${l10n.deviceSettingsIconAuto}'),
                  ),
                  DropdownMenuItem(
                    value: 'sleep',
                    child: Text('😴 ${l10n.deviceSettingsIconSleep}'),
                  ),
                  DropdownMenuItem(
                    value: 'swing_vertical',
                    child: Text('↕️ ${l10n.deviceSettingsIconVerticalBlinds}'),
                  ),
                  DropdownMenuItem(
                    value: 'swing_horizontal',
                    child: Text('↔️ ${l10n.deviceSettingsIconHorizontalBlinds}'),
                  ),
                  DropdownMenuItem(
                    value: 'air_quality',
                    child: Text('🌬️ ${l10n.deviceSettingsIconAirQuality}'),
                  ),
                  DropdownMenuItem(
                    value: 'filter',
                    child: Text('🧹 ${l10n.deviceSettingsIconFilter}'),
                  ),
                  DropdownMenuItem(
                    value: 'temp',
                    child: Text('🌡 ${l10n.deviceSettingsIconTemperature}'),
                  ),
                  DropdownMenuItem(
                    value: 'ac',
                    child: Text('❄️ ${l10n.deviceSettingsIconAirConditioner}'),
                  ),
                  DropdownMenuItem(
                    value: 'heater',
                    child: Text('🔥 ${l10n.deviceSettingsIconHeater}'),
                  ),
                  DropdownMenuItem(
                    value: 'air',
                    child: Text('🍃 ${l10n.deviceSettingsIconAir}'),
                  ),
                  DropdownMenuItem(
                    value: 'suction',
                    child: Text('🌪️ ${l10n.deviceSettingsIconSuction}'),
                  ),
                  DropdownMenuItem(
                    value: 'wait',
                    child: Text('⏳ ${l10n.deviceSettingsIconWaiting}'),
                  ),
                  DropdownMenuItem(
                    value: 'sync',
                    child: Text('🔄 ${l10n.deviceSettingsIconSynchronization}'),
                  ),
                ],
                onChanged: (v) => setDialogState(() => selectedIcon = v ?? ''),
              ),
            ]),
          ),
          actions: [
            if (!isNew)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteDps(device, dpsKey, ref);
                },
                child: Text(
                  l10n.deviceSettingsDelete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.deviceSettingsCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newKey = keyController.text.trim();
                if (newKey.isEmpty || labelController.text.isEmpty) return;

                final newDpsMap = Map<String, dynamic>.from(dpsMap);

                if (!isNew && dpsKey != newKey) {
                  newDpsMap.remove(dpsKey);
                }

                newDpsMap[newKey] = {
                  'label': labelController.text,
                  'type': selectedType,
                  'role': selectedRole,
                  if (selectedIcon.isNotEmpty) 'icon': selectedIcon,
                  if (selectedType == 'enum' && enumValuesController.text.isNotEmpty)
                    'enum_values': enumValuesController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList(),
                };

                final latestDevice = ref.read(devicesProvider).firstWhere(
                      (d) => d.id == device.id,
                  orElse: () => device,
                );

                final updated = latestDevice.copyWith(
                  properties: {...latestDevice.properties, 'dps_map': newDpsMap},
                );
                await ref.read(devicesProvider.notifier).updateDevice(updated);
                if (ctx.mounted) Navigator.pop(ctx);
                setModalState(() {});
              },
              child: Text(
                isNew
                    ? l10n.deviceSettingsAdd
                    : l10n.deviceSettingsSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _deleteDps(Device device, String dpsKey, WidgetRef ref) {
    final dpsMap = Map<String, dynamic>.from(device.properties['dps_map'] as Map? ?? {});
    dpsMap.remove(dpsKey);

    final updated = device.copyWith(
      properties: {...device.properties, 'dps_map': dpsMap},
    );
    ref.read(devicesProvider.notifier).updateDevice(updated);
  }

  // ===================================================================
  // СОЗДАТЬ ДАТЧИК
  // ===================================================================

  static void _showCreateSensorDialog(BuildContext context,
      WidgetRef ref,
      Device device,
      AppLocalizations l10n,
      ) {
    SensorType selectedSensorType = SensorType.temperature;
    final dpsController = TextEditingController(text: '21');
    final dividerController = TextEditingController(text: '10');
    final nameController = TextEditingController(text: '${device.name} t°');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.deviceSettingsCreateSensor),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(l10n.deviceSettingsSensorFromDevice(device.name)),
              const SizedBox(height: 12),
              DropdownButtonFormField<SensorType>(
                initialValue: selectedSensorType,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsSensorType,
                ),
                items: [
                  DropdownMenuItem(
                    value: SensorType.temperature,
                    child: Text(l10n.deviceSettingsTemperature),
                  ),
                  DropdownMenuItem(
                    value: SensorType.humidity,
                    child: Text(l10n.deviceSettingsHumidity),
                  ),
                  DropdownMenuItem(
                    value: SensorType.power,
                    child: Text(l10n.deviceSettingsPower),
                  ),
                  DropdownMenuItem(
                    value: SensorType.current,
                    child: Text(l10n.deviceSettingsCurrent),
                  ),
                  DropdownMenuItem(
                    value: SensorType.voltage,
                    child: Text(l10n.deviceSettingsVoltage),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() {
                      selectedSensorType = v;
                      switch (v) {
                        case SensorType.temperature:
                          dpsController.text = '21';
                          dividerController.text = '10';
                          nameController.text = '${device.name} t°';
                          break;
                        case SensorType.humidity:
                          dpsController.text = '22';
                          dividerController.text = '10';
                          nameController.text = '${device.name} h%';
                          break;
                        case SensorType.power:
                          dpsController.text = '23';
                          dividerController.text = '10';
                          nameController.text = '${device.name} W';
                          break;
                        case SensorType.current:
                          dpsController.text = '21';
                          dividerController.text = '1';
                          nameController.text = '${device.name} mA';
                          break;
                        case SensorType.voltage:
                          dpsController.text = '22';
                          dividerController.text = '10';
                          nameController.text = '${device.name} V';
                          break;
                        default:
                          break;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsName,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dpsController,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsDpsIndex,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dividerController,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsDivider,
                ),
                keyboardType: TextInputType.number,
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.deviceSettingsCancel),
            ),
            ElevatedButton(
              onPressed: () {
                final dps = int.tryParse(dpsController.text) ?? 21;
                final div = double.tryParse(dividerController.text) ?? 10;
                ref.read(devicesProvider.notifier).addDevice(Device(
                  id: '${device.id}_sensor_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  type: DeviceType.sensor,
                  roomId: device.roomId,
                  isOnline: false,
                  state: DeviceState.offline,
                  deviceId: device.deviceId,
                  localKey: device.localKey,
                  address: device.address,
                  version: device.version,
                  dpsIndex: dps,
                  properties: {'sensorDps': dps, 'sensorDivider': div, 'sensorType': selectedSensorType.name},
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.deviceSettingsSensorCreated(nameController.text),
                    ),
                  ),
                );
              },
              child: Text(l10n.deviceSettingsCreate),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDisplaySettings(WidgetRef ref,
      Device device,
      VoidCallback setModalState,
      AppLocalizations l10n,
      ) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Consumer(
          builder: (context, ref, _) {
            final latestDevice = ref.watch(
              devicesProvider.select(
                    (list) => list.firstWhere((d) => d.id == device.id),
              ),
            );
            final dpsMap = Map<String, dynamic>.from(
              latestDevice.properties['dps_map'] as Map? ?? {},
            );

            final displayEntries = dpsMap.entries.where((e) {
              final role = (e.value as Map<String, dynamic>)['role'];
              return role == 'info' || role == 'status';
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Отображение на карточке',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.deviceSettingsDisplayHint,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                if (displayEntries.isEmpty)
                  Text(
                    l10n.deviceSettingsNoInfoParameters,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  )
                else
                  ...displayEntries.map((entry) {
                    final config = entry.value as Map<String, dynamic>;
                    final key = entry.key;
                    final label = config['label'] as String? ?? key;
                    final currentlyShown = config['show_on_card'] != false;

                    return SwitchListTile(
                      dense: true,
                      title: Text(label, style: TextStyle(fontSize: 13)),
                      value: currentlyShown,
                      onChanged: (val) {
                        final newDpsMap = Map<String, dynamic>.from(dpsMap);
                        final newConfig = Map<String, dynamic>.from(config)
                          ..['show_on_card'] = val;
                        newDpsMap[key] = newConfig;
                        final updatedProperties =
                        Map<String, dynamic>.from(latestDevice.properties)
                          ..['dps_map'] = newDpsMap;
                        ref
                            .read(devicesProvider.notifier)
                            .updateDeviceProperties(latestDevice.id, updatedProperties);
                        setModalState();
                      },
                      activeThumbColor: Colors.blue,
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }

  static void _showChannelEditor(
      BuildContext context,
      void Function(VoidCallback) setModalState,
      Device device,
      String channelKey,
      WidgetRef ref,
      AppLocalizations l10n,
      ) {
    final dpsMap = Map<String, dynamic>.from(device.properties['dps_map'] as Map? ?? {});
    final currentConfig = dpsMap[channelKey] as Map<String, dynamic>? ?? {};
    final keyController = TextEditingController(text: channelKey);
    final labelController = TextEditingController(
      text: currentConfig['label'] as String? ??
          l10n.deviceSettingsDefaultChannelLabel(channelKey),
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Канал'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsChannelNumber,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: l10n.deviceSettingsName,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.deviceSettingsCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newKey = keyController.text.trim();
                if (newKey.isEmpty || labelController.text.isEmpty) return;

                final newDpsMap = Map<String, dynamic>.from(dpsMap);

                if (channelKey != newKey) {
                  newDpsMap.remove(channelKey);
                }

                newDpsMap[newKey] = {
                  'label': labelController.text,
                  'type': 'bool',
                  'role': 'channel',
                };

                final latestDevice = ref.read(devicesProvider).firstWhere(
                      (d) => d.id == device.id,
                  orElse: () => device,
                );

                final updated = latestDevice.copyWith(
                  properties: {...latestDevice.properties, 'dps_map': newDpsMap},
                );
                await ref.read(devicesProvider.notifier).updateDevice(updated);
                if (ctx.mounted) Navigator.pop(ctx);
                setModalState(() {});
              },
              child: Text(l10n.deviceSettingsSave),
            ),
          ],
        ),
      ),
    );
  }
}