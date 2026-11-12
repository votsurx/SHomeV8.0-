/// Экран сканирования устройств Tuya.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:talker/talker.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/device.dart';
import '../../application/state/devices_provider.dart';
import '../../di/injection.dart';
import '../../data/services/port_scanner.dart';

class ScanDevicesScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;
  const ScanDevicesScreen({super.key, this.isOnboarding = false});

  @override
  ConsumerState<ScanDevicesScreen> createState() => _ScanDevicesScreenState();
}

class _ScanDevicesScreenState extends ConsumerState<ScanDevicesScreen> {
  bool _scanning = false;
  int _progress = 0;
  int _total = 254;
  final List<DiscoveredDevice> _foundDevices = [];
  final Set<String> _addedIps = {};
  DeviceType _selectedType = DeviceType.outlet;

  @override
  Widget build(BuildContext context) {
    final existingDevices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Сканировать Tuya'),
        leading: widget.isOnboarding
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Поиск устройств Tuya',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сканируем порты 6666-6668-7000 в локальной сети',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  if (_scanning) ...[
                    LinearProgressIndicator(
                      value: _total > 0 ? _progress / _total : 0,
                    ),
                    const SizedBox(height: 8),
                    Text('Проверено: $_progress / $_total'),
                    const SizedBox(height: 16),
                  ],

                  if (_foundDevices.isNotEmpty) ...[
                    Text(
                      'Найдено: ${_foundDevices.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ..._foundDevices.map((device) {
                      final isAlreadyAdded = existingDevices.any(
                            (d) => d.address == device.ip,
                      );
                      final isJustAdded = _addedIps.contains(device.ip);

                      if (isAlreadyAdded || isJustAdded) {
                        return Card(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: ListTile(
                            leading: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
                            ),
                            title: Text(
                              device.ip,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: const Text('Добавлено'),
                          ),
                        );
                      }

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.devices, color: Colors.blue, size: 24),
                          ),
                          title: Text(
                            device.ip,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text('Порт: ${device.port}'),
                          trailing: IconButton(
                            icon: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.blue, size: 20),
                            ),
                            onPressed: () => _showAddDialog(device),
                          ),
                        ),
                      );
                    }),
                  ],

                  if (!_scanning && _foundDevices.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'Нажмите "Сканировать"',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _scanning ? null : _startScan,
                icon: const Icon(Icons.search),
                label: Text(
                  _scanning ? 'Сканирование...' : 'Сканировать',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),

          if (widget.isOnboarding)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/onboarding/rooms'),
                  child: const Text('Продолжить', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD DIALOG
  // ============================================================

  void _showAddDialog(DiscoveredDevice device) {
    final nameController = TextEditingController(text: 'Устройство ${device.ip}');
    final localKeyController = TextEditingController();
    final deviceIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить устройство'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📍 IP: ${device.ip}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '🔌 Порт: ${device.port}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<DeviceType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Тип устройства',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(value: DeviceType.outlet, child: Text('Розетка')),
                    DropdownMenuItem(value: DeviceType.switch1, child: Text('Выключатель (1 кл.)')),
                    DropdownMenuItem(value: DeviceType.switch2, child: Text('Выключатель (2 кл.)')),
                    DropdownMenuItem(value: DeviceType.switch3, child: Text('Выключатель (3 кл.)')),
                    DropdownMenuItem(value: DeviceType.sensor, child: Text('Датчик')),
                    DropdownMenuItem(value: DeviceType.light, child: Text('Лампа')),
                    DropdownMenuItem(value: DeviceType.curtain, child: Text('Шторы')),
                    DropdownMenuItem(value: DeviceType.hvac, child: Text('❄️ Кондиционер')),
                    DropdownMenuItem(value: DeviceType.compound, child: Text('🦾 Универсальное устройство')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => _selectedType = value ?? DeviceType.outlet),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: deviceIdController,
                  decoration: const InputDecoration(labelText: 'Device ID'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: localKeyController,
                  decoration: const InputDecoration(labelText: 'Local Key'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (localKeyController.text.isNotEmpty) {
                  final newDevice = Device(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    type: _selectedType,
                    roomId: 'living',
                    isOnline: true,
                    state: DeviceState.online,
                    deviceId: deviceIdController.text.isNotEmpty
                        ? deviceIdController.text
                        : 'device_${device.ip.replaceAll('.', '_')}',
                    localKey: localKeyController.text,
                    address: device.ip,
                    version: 3.5,
                    properties: _getDefaultProperties(_selectedType),
                  );
                  ref.read(devicesProvider.notifier).addDevice(newDevice);
                  setState(() => _addedIps.add(device.ip));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${nameController.text} добавлено!')),
                  );
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SCAN
  // ============================================================

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _progress = 0;
      _total = 254;
      _foundDevices.clear();
    });

    final subnet = await PortScanner.getLocalSubnet();
    if (subnet == null) {
      setState(() => _scanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось определить локальную сеть')),
        );
      }
      return;
    }

    final scanner = PortScanner(
      getIt<Talker>(),
          (device) {
        if (mounted) setState(() => _foundDevices.add(device));
      },
          (progress, total) {
        if (mounted) setState(() {
          _progress = progress;
          _total = total;
        });
      },
    );

    await scanner.scanSubnet(subnet);
    if (mounted) setState(() => _scanning = false);
  }

  Map<String, dynamic> _getDefaultProperties(DeviceType type) {
    return DevicesNotifier.defaultProperties(type);
  }
}