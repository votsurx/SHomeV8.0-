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
import '../../l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final existingDevices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        // сканировать
        title: Text('🔍 ${l10n.scanTuyaTitle}'),
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
                  // 'Поиск устройств Tuya'
                  Text(
                    l10n.tuyaSearchTitle,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // 'Сканируем порты 6666-6668-7000 в локальной сети',
                  Text(
                    l10n.scanPortsHint,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  if (_scanning) ...[
                    LinearProgressIndicator(
                      value: _total > 0 ? _progress / _total : 0,
                    ),
                    const SizedBox(height: 8),
                    // 'Проверено:
                    Text(l10n.scanProgress(_progress, _total)),
                    const SizedBox(height: 16),
                  ],

                  if (_foundDevices.isNotEmpty) ...[
                    // 'Найдено:
                    Text(
                      l10n.foundDevices(_foundDevices.length),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                            // 'Добавлено'
                            subtitle: Text(l10n.deviceAddedStatus),
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
                          // 'Порт:
                          subtitle: Text(l10n.portNumber(device.port)),
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
                          // 'Нажмите "Сканировать"'
                          Text(
                            l10n.tapToScan,
                            style: const TextStyle(fontSize: 16),
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
                // 'Сканирование...' : 'Сканировать'
                label: Text(
                  _scanning ? l10n.scanning : l10n.scan,
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
                  // 'Продолжить'
                  child: Text(
                    l10n.continueButton,
                    style: const TextStyle(fontSize: 18),
                  ),
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
    final l10n = AppLocalizations.of(context);
    // Устройство
    final nameController = TextEditingController(text: l10n.defaultDeviceName(device.ip),);
    final localKeyController = TextEditingController();
    final deviceIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          // 'Добавить устройство'
          title: Text(l10n.addDeviceTitle),
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
                      // IP:
                      Text(
                        '📍 ${l10n.ipAddress(device.ip)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      // 🔌 Порт:
                      Text(
                        '🔌 ${l10n.portNumber(device.port)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  // 'Название'
                  decoration: InputDecoration(labelText: l10n.deviceName) ),
                const SizedBox(height: 8),
                DropdownButtonFormField<DeviceType>(
                  initialValue: _selectedType,
                  // 'Тип устройства'
                  decoration: InputDecoration(
                    labelText: l10n.deviceType,
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: DeviceType.outlet,
                      child: Text(l10n.outlet),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.switch1,
                      child: Text(l10n.switchOne),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.switch2,
                      child: Text(l10n.switchTwo),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.switch3,
                      child: Text(l10n.switchThree),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.sensor,
                      child: Text(l10n.sensor),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.light,
                      child: Text(l10n.light),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.curtain,
                      child: Text(l10n.curtain),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.hvac,
                      child: Text('❄️ ${l10n.airConditioner}'),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.compound,
                      child: Text('🦾 ${l10n.universalDevice}'),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => _selectedType = value ?? DeviceType.outlet),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: deviceIdController,
                  // 'Device ID'
                  decoration: InputDecoration(labelText: l10n.deviceId),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: localKeyController,
                  // 'Local Key'
                  decoration: InputDecoration(labelText: l10n.localKey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              // 'Отмена'
              child: Text(l10n.cancel),
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
                    // добавлено!'
                    SnackBar(content: Text(l10n.deviceAddedMessage(nameController.text)),
                    ),
                  );
                }
              },
              //'Добавить'
              child: Text(l10n.add),
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
          // 'Не удалось определить локальную сеть'
          SnackBar(
            content: Text(AppLocalizations.of(context).localNetworkNotFound),
          ),
        );
      }
      return;
    }

    final scanner = PortScanner(
      getIt<Talker>(),
          (device) {
        if (mounted) {
          setState(() => _foundDevices.add(device));
        }
      },
          (progress, total) {
        if (mounted) {
          setState(() {
            _progress = progress;
            _total = total;
          });
        }
      },
    );

    await scanner.scanSubnet(subnet);
    if (mounted) setState(() => _scanning = false);
  }

  Map<String, dynamic> _getDefaultProperties(DeviceType type) {
    return DevicesNotifier.defaultProperties(type);
  }
}