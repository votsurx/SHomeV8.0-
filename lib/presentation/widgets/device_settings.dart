/// Настройки устройства — bottom sheet с полным набором полей.
///
/// Поддерживает все типы устройств:
/// - Обычные (outlet, light) — стандартные поля Tuya + DPS индекс
/// - Выключатели (switch1/2/3) — DPS для каждого канала
/// - Камеры (camera) — без Tuya-полей, для RTSP — поле URL
/// - Датчики (sensor) — без кнопки «Создать датчик»
/// - Универсальное устройство — dps_map редактор, без DPS индекса
///
/// dps_map позволяет гибко настраивать составные устройства:
/// каждый DPS имеет номер, название, тип, роль и иконку.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';

class DeviceSettings {
  // ===================================================================
  // ОСНОВНОЙ МЕТОД — открывает bottom sheet настроек устройства
  // ===================================================================

  static void show(BuildContext context, WidgetRef ref, Device device) {
    // ──────────────────────────────────────────────────────────
    // КОНТРОЛЛЕРЫ
    // ──────────────────────────────────────────────────────────
    final nameController = TextEditingController(text: device.name);
    final rooms = ref.watch(roomsProvider);
    String selectedRoomId = device.roomId;

    // Проверяем что комната существует в списке
    final roomIds = rooms.map((r) => r.id).toList();
    if (!roomIds.contains(selectedRoomId) && rooms.isNotEmpty) {
      selectedRoomId = rooms.first.id;
    }

    // Поля для устройств Tuya (кроме камер)
    final localKeyController = TextEditingController(text: device.localKey ?? '');
    final addressController = TextEditingController(text: device.address ?? '');
    double selectedVersion = device.version ?? 3.3;

    // Поля для RTSP камер
    final rtspUrlController = TextEditingController(text: device.properties['rtspUrl'] as String? ?? '');

    // DPS контроллеры для многоканальных выключателей
    final channelCount = device.type == DeviceType.switch3 ? 3 : (device.type == DeviceType.switch2 ? 2 : 1);
    final dpsControllers = List.generate(
      channelCount,
          (i) => TextEditingController(text: '${(device.dpsIndex ?? 1) + i}'),
    );

    // ──────────────────────────────────────────────────────────
    // BOTTOM SHEET
    // ──────────────────────────────────────────────────────────
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                Text(device.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название', prefixIcon: Icon(Icons.edit)),
                ),
                const SizedBox(height: 8),

                // ╔══════════════════════════════════════════╗
                // ║        КОМНАТА (для всех устройств)      ║
                // ╚══════════════════════════════════════════╝
                DropdownButtonFormField<String>(
                  initialValue: selectedRoomId,
                  decoration: const InputDecoration(labelText: 'Комната', prefixIcon: Icon(Icons.meeting_room)),
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
                if (device.type == DeviceType.camera && device.properties['cameraType'] == 'rtsp') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: rtspUrlController,
                    decoration: const InputDecoration(labelText: 'RTSP URL', prefixIcon: Icon(Icons.link)),
                  ),
                ],

                // ╔══════════════════════════════════════════╗
                // ║  СТАНДАРТНЫЕ ПОЛЯ TUYA (кроме камер)     ║
                // ╚══════════════════════════════════════════╝
                if (device.type != DeviceType.camera) ...[
                  const SizedBox(height: 8),

                  // Device ID (только чтение)
                  TextField(
                    controller: TextEditingController(text: device.deviceId ?? ''),
                    decoration: const InputDecoration(labelText: 'Device ID', prefixIcon: Icon(Icons.fingerprint)),
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // IP Адрес
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'IP Адрес', prefixIcon: Icon(Icons.wifi)),
                  ),
                  const SizedBox(height: 8),

                  // Local Key
                  TextField(
                    controller: localKeyController,
                    decoration: const InputDecoration(labelText: 'Local Key', prefixIcon: Icon(Icons.vpn_key)),
                  ),
                  const SizedBox(height: 8),

                  // Версия протокола Tuya
                  DropdownButtonFormField<double>(
                    initialValue: selectedVersion,
                    decoration:
                    const InputDecoration(labelText: 'Версия протокола', prefixIcon: Icon(Icons.info_outline)),
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
                // ║  DPS ИНДЕКСЫ (выключатели и обычные)     ║
                // ║  Скрыто: камеры, пылесосы (dps_map)      ║
                // ╚══════════════════════════════════════════╝
                if (device.type != DeviceType.camera && device.type != DeviceType.compound) ...[
                  const SizedBox(height: 8),
                  if (device.type == DeviceType.switch1 ||
                      device.type == DeviceType.switch2 ||
                      device.type == DeviceType.switch3) ...[
                    // Многоканальные — DPS для каждого канала
                    Text('DPS каналов:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13)),
                    const SizedBox(height: 4),
                    ...List.generate(channelCount, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: dpsControllers[i],
                        decoration: InputDecoration(
                            labelText: 'DPS канала ${i + 1}', prefixIcon: const Icon(Icons.tune)),
                        keyboardType: TextInputType.number,
                      ),
                    )),
                  ] else ...[
                    // Одноканальные — один DPS индекс
                    TextField(
                      controller: dpsControllers.first,
                      decoration: const InputDecoration(
                          labelText: 'DPS Индекс', hintText: '1', prefixIcon: Icon(Icons.tune)),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],

                // ╔══════════════════════════════════════════╗
                // ║ DPS КАРТА (для универсального устройства)║
                // ║   Редактор составных устройств           ║
                // ╚══════════════════════════════════════════╝
                if (device.type == DeviceType.compound) ...[
                  const SizedBox(height: 8),
                  Text('DPS карта:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 4),
                  ..._buildDpsMapEditor(device, setModalState, ctx, ref),
                  // Кнопка добавления нового DPS
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showDpsEditor(ctx, setModalState, device, null, ref),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Добавить DPS'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                    ),
                  ),
                ],

                // ╔══════════════════════════════════════════╗
                // ║    ОТОБРАЖЕНИЕ НА КАРТОЧКЕ              ║
                // ║   (только для устройств с dps_map)      ║
                // ╚══════════════════════════════════════════╝
                if (device.type == DeviceType.compound) ...[
                  const SizedBox(height: 12),
                  _buildDisplaySettings(ref, device),
                ],

                // ╔══════════════════════════════════════════╗
                // ║      КНОПКИ: СОХРАНИТЬ / УДАЛИТЬ         ║
                // ╚══════════════════════════════════════════╝
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Получаем актуальное состояние устройства из провайдера
                        final latestDevice = ref
                            .read(devicesProvider)
                            .firstWhere((d) => d.id == device.id, orElse: () => device);

                        Map<String, dynamic> newProperties = {...latestDevice.properties};

                        // Обновляем RTSP URL для камер
                        if (latestDevice.type == DeviceType.camera &&
                            latestDevice.properties['cameraType'] == 'rtsp') {
                          newProperties['rtspUrl'] = rtspUrlController.text;
                        }

                        final updated = latestDevice.copyWith(
                          name: nameController.text,
                          roomId: selectedRoomId,
                          address: latestDevice.type != DeviceType.camera && addressController.text.isNotEmpty
                              ? addressController.text
                              : latestDevice.address,
                          localKey: latestDevice.type != DeviceType.camera && localKeyController.text.isNotEmpty
                              ? localKeyController.text
                              : latestDevice.localKey,
                          dpsIndex: latestDevice.type != DeviceType.camera && latestDevice.type != DeviceType.compound
                              ? (int.tryParse(dpsControllers.first.text) ?? latestDevice.dpsIndex)
                              : latestDevice.dpsIndex,
                          version: latestDevice.type != DeviceType.camera ? selectedVersion : latestDevice.version,
                          properties: newProperties,
                        );
                        ref.read(devicesProvider.notifier).updateDevice(updated);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Сохранить'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Удалить?'),
                          content: Text('Удалить "${device.name}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Отмена')),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(devicesProvider.notifier).removeDevice(device.id);
                                Navigator.pop(dCtx);
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              child: const Text('Удалить'),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Удалить'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    ),
                  ),
                ]),

                // ╔══════════════════════════════════════════╗
                // ║  СОЗДАТЬ ДАТЧИК (не для камер/датчиков/  ║
                // ║  универсальных устройств                 ║
                // ╚══════════════════════════════════════════╝
                if (device.type != DeviceType.sensor &&
                    device.type != DeviceType.camera &&
                    device.type != DeviceType.compound) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCreateSensorDialog(context, ref, device);
                      },
                      icon: const Icon(Icons.add_chart, size: 18),
                      label: const Text('Создать датчик'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================================================
  // DPS КАРТА — отображение списка DPS
  // ===================================================================

  /// Отображает отсортированный список DPS из dps_map с иконками.
  /// Каждый элемент можно нажать для редактирования.
  static List<Widget> _buildDpsMapEditor(
      Device device,
      void Function(VoidCallback) setModalState,
      BuildContext ctx,
      WidgetRef ref,
      ) {
    final dpsMap = Map<String, dynamic>.from(device.properties['dps_map'] as Map? ?? {});

    // Сортируем ключи по числовому значению (1, 3, 4, 8...)
    final sortedKeys = dpsMap.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    return sortedKeys.map((key) {
      final cfg = dpsMap[key] as Map<String, dynamic>;
      final label = cfg['label'] as String? ?? '';
      final type = cfg['type'] as String? ?? '';
      final role = cfg['role'] as String? ?? '';
      final iconName = cfg['icon'] as String? ?? '';

      return ListTile(
        dense: true,
        leading: _dpsIcon(role, iconName),
        title: Text('DPS $key: $label', style: const TextStyle(fontSize: 12)),
        subtitle: Text('$type / $role', style: const TextStyle(fontSize: 10)),
        trailing: const Icon(Icons.edit, size: 16),
        onTap: () {
          Navigator.pop(ctx);
          _showDpsEditor(ctx, setModalState, device, key, ref);
        },
      );
    }).toList();
  }

  /// Возвращает иконку для DPS: сначала кастомная, затем по роли.
  static Widget _dpsIcon(String role, String? iconName) {
    // Если задана кастомная иконка — показываем эмодзи
    if (iconName != null && iconName.isNotEmpty) {
      return Text(_iconEmoji(iconName), style: const TextStyle(fontSize: 16));
    }
    // Иначе — иконка по роли
    return _dpsRoleIcon(role);
  }

  /// Возвращает Material иконку по роли DPS.
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
      default:
        return const Icon(Icons.help_outline, size: 16);
    }
  }



  /// Преобразует ключ иконки в эмодзи.
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
  // РЕДАКТОР ОДНОГО DPS (добавление / изменение)
  // ===================================================================

  /// Диалог добавления нового или редактирования существующего DPS.
  /// dpsKey == null → создание нового DPS.
  /// dpsKey != null → редактирование существующего.
  static void _showDpsEditor(
      BuildContext context,
      void Function(VoidCallback) setModalState,
      Device device,
      String? dpsKey,
      WidgetRef ref,
      ) {
    final isNew = dpsKey == null;
    final dpsMap = Map<String, dynamic>.from(device.properties['dps_map'] as Map? ?? {});

    // Контроллеры с текущими значениями
    final keyController = TextEditingController(text: dpsKey ?? '');
    final labelController = TextEditingController(text: isNew ? '' : dpsMap[dpsKey]?['label'] ?? '');
    String selectedType = isNew ? 'bool' : dpsMap[dpsKey]?['type'] ?? 'bool';
    String selectedRole = isNew ? 'action' : dpsMap[dpsKey]?['role'] ?? 'action';
    String selectedIcon = isNew ? '' : dpsMap[dpsKey]?['icon'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isNew ? 'Добавить DPS' : 'Редактировать DPS $dpsKey'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Номер DPS (всегда редактируемый)
              TextField(
                controller: keyController,
                decoration: const InputDecoration(labelText: 'Номер DPS'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),

              // Название
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 8),

              // Тип значения
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Тип'),
                items: const [
                  DropdownMenuItem(value: 'bool', child: Text('bool (вкл/выкл)')),
                  DropdownMenuItem(value: 'value', child: Text('value (число)')),
                  DropdownMenuItem(value: 'enum', child: Text('enum (текст)')),
                  DropdownMenuItem(value: 'slider', child: Text('slider (ползунок)')),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedType = v);
                },
              ),
              const SizedBox(height: 8),

              // Роль (определяет отображение в виджете)
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Роль'),
                items: const [
                  DropdownMenuItem(value: 'main', child: Text('main (главная кнопка)')),
                  DropdownMenuItem(value: 'action', child: Text('action (действие)')),
                  DropdownMenuItem(value: 'toggle', child: Text('toggle (переключатель)')),
                  DropdownMenuItem(value: 'info', child: Text('info (информация)')),
                  DropdownMenuItem(value: 'status', child: Text('status (статус)')),
                  DropdownMenuItem(value: 'slider', child: Text('slider (ползунок)')),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedRole = v);
                },
              ),
              const SizedBox(height: 8),

              // Иконка (эмодзи)
              DropdownButtonFormField<String>(
                initialValue: selectedIcon.isEmpty ? null : selectedIcon,
                decoration: const InputDecoration(labelText: 'Иконка'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('Без иконки')),
                  DropdownMenuItem(value: 'play', child: Text('▶/⏹ Пуск/Стоп')),
                  DropdownMenuItem(value: 'home', child: Text('🏠 Дом/База')),
                  DropdownMenuItem(value: 'power', child: Text('⚡ Питание')),
                  DropdownMenuItem(value: 'water', child: Text('💧 Вода')),
                  DropdownMenuItem(value: 'mop', child: Text('🧹 Мытьё')),
                  DropdownMenuItem(value: 'do_not_disturb', child: Text('🔕 Не беспокоить')),
                  DropdownMenuItem(value: 'battery', child: Text('🔋 Батарея')),
                  DropdownMenuItem(value: 'timer', child: Text('⏱ Таймер')),
                  DropdownMenuItem(value: 'area', child: Text('📐 Площадь')),
                  DropdownMenuItem(value: 'fan', child: Text('🌀 Вентилятор')),
                  DropdownMenuItem(value: 'temp', child: Text('🌡 Температура')),
                  DropdownMenuItem(value: 'ac', child: Text('❄️ Кондиционер')),
                  DropdownMenuItem(value: 'heater', child: Text('🔥 Обогреватель')),
                  DropdownMenuItem(value: 'air', child: Text('🍃 Воздух')),
                  DropdownMenuItem(value: 'suction', child: Text('🌪️ Всасывание')),
                  DropdownMenuItem(value: 'wait', child: Text('⏳ Ожидание')),
                  DropdownMenuItem(value: 'sync', child: Text('🔄 Синхронизация')),
                ],
                onChanged: (v) => setDialogState(() => selectedIcon = v ?? ''),
              ),
            ]),
          ),
          actions: [
            // Кнопка «Удалить» (только для существующих DPS)
            if (!isNew)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteDps(device, dpsKey, ref);
                },
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                final newKey = keyController.text.trim();
                if (newKey.isEmpty || labelController.text.isEmpty) return;

                final newDpsMap = Map<String, dynamic>.from(dpsMap);

                // Если ключ изменился — удаляем старый
                if (!isNew && dpsKey != newKey) {
                  newDpsMap.remove(dpsKey);
                }

                // Сохраняем конфигурацию DPS
                newDpsMap[newKey] = {
                  'label': labelController.text,
                  'type': selectedType,
                  'role': selectedRole,
                  if (selectedIcon.isNotEmpty) 'icon': selectedIcon,
                };

                final updated = device.copyWith(
                  properties: {...device.properties, 'dps_map': newDpsMap},
                );
                ref.read(devicesProvider.notifier).updateDevice(updated);
                Navigator.pop(ctx);

                // Переоткрываем настройки с обновлённым устройством
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  DeviceSettings.show(context, ref, updated);
                });
              },
              child: Text(isNew ? 'Добавить' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  /// Удаляет DPS из dps_map.
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

  /// Диалог создания датчика из текущего устройства.
  /// Копирует deviceId, localKey, address, version от родительского устройства.
  static void _showCreateSensorDialog(BuildContext context, WidgetRef ref, Device device) {
    SensorType selectedSensorType = SensorType.temperature;
    final dpsController = TextEditingController(text: '21');
    final dividerController = TextEditingController(text: '10');
    final nameController = TextEditingController(text: '${device.name} t°');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Создать датчик'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Из устройства: ${device.name}'),
              const SizedBox(height: 12),
              // Тип датчика
              DropdownButtonFormField<SensorType>(
                initialValue: selectedSensorType,
                decoration: const InputDecoration(labelText: 'Тип датчика'),
                items: const [
                  DropdownMenuItem(value: SensorType.temperature, child: Text('Температура')),
                  DropdownMenuItem(value: SensorType.humidity, child: Text('Влажность')),
                  DropdownMenuItem(value: SensorType.power, child: Text('Мощность')),
                  DropdownMenuItem(value: SensorType.current, child: Text('Ток')),
                  DropdownMenuItem(value: SensorType.voltage, child: Text('Напряжение')),
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
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название')),
              const SizedBox(height: 8),
              TextField(controller: dpsController, decoration: const InputDecoration(labelText: 'DPS индекс'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: dividerController, decoration: const InputDecoration(labelText: 'Делитель'), keyboardType: TextInputType.number),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
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
                  SnackBar(content: Text('✅ Датчик "${nameController.text}" создан!')),
                );
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDisplaySettings(WidgetRef ref, Device device) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Consumer(
          builder: (context, ref, _) {
            // Получаем актуальное состояние устройства из провайдера
            final latestDevice = ref.watch(
              devicesProvider.select(
                    (list) => list.firstWhere((d) => d.id == device.id),
              ),
            );
            final dpsMap = Map<String, dynamic>.from(
              latestDevice.properties['dps_map'] as Map? ?? {},
            );

            // Показываем только info и status DP
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
                  'Выберите, какие данные показывать на главном экране',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                if (displayEntries.isEmpty)
                  Text(
                    'Нет информационных параметров',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  )
                else
                  ...displayEntries.map((entry) {
                    final config = entry.value as Map<String, dynamic>;
                    final key = entry.key;
                    final label = config['label'] as String? ?? key;
                    final currentlyShown = config['show_on_card'] != false; // по умолчанию true

                    return SwitchListTile(
                      dense: true,
                      title: Text(label, style: TextStyle(fontSize: 13)),
                      value: currentlyShown,
                      onChanged: (val) {
                        // Клонируем dps_map и меняем show_on_card
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
                        // Интерфейс обновится автоматически благодаря ref.watch выше
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
}