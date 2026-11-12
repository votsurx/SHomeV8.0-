import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/state/zigbee_provider.dart';
import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';
import '../../domain/models/device.dart';
import '../../domain/models/zigbee_device.dart';
import '../../data/mappers/zigbee_dps_mapper.dart';
import '../../di/injection.dart';
import '../../data/protocols/zigbee_protocol.dart';

class ZigbeeScanScreen extends ConsumerStatefulWidget {
  const ZigbeeScanScreen({super.key});

  @override
  ConsumerState<ZigbeeScanScreen> createState() => _ZigbeeScanScreenState();
}

class _ZigbeeScanScreenState extends ConsumerState<ZigbeeScanScreen> {
  Timer? _timer;
  int _countdown = 0;
  bool _isPermitJoin = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _togglePermitJoin() async {
    final protocol = getIt<ZigbeeProtocol>();

    if (_isPermitJoin) {
      await protocol.permitJoin(false);
      _timer?.cancel();
      setState(() {
        _isPermitJoin = false;
        _countdown = 0;
      });
    } else {
      await protocol.permitJoin(true, time: 254);
      setState(() {
        _isPermitJoin = true;
        _countdown = 254;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_countdown <= 1) {
          t.cancel();
          setState(() {
            _isPermitJoin = false;
            _countdown = 0;
          });
        } else {
          setState(() => _countdown--);
        }
      });
    }
  }

  Future<void> _addDevice(ZigbeeDevice zb) async {
    final devicesNotifier = ref.read(devicesProvider.notifier);
    final rooms = ref.read(roomsProvider);
    final roomId = rooms.isNotEmpty ? rooms.first.id : 'other';

    final dpsMap = ZigbeeDpsMapper.toDpsMap(zb.exposes);

    final device = Device(
      id: 'zigbee_${zb.ieeeAddress}',
      name: zb.friendlyName.isNotEmpty ? zb.friendlyName : zb.model,
      type: DeviceType.compound,
      roomId: roomId,
      isOnline: zb.available,
      state: zb.available ? DeviceState.online : DeviceState.offline,
      deviceId: zb.ieeeAddress,
      mqttTopic: 'zigbee2mqtt/${zb.friendlyName}',
      properties: {
        'source': 'zigbee',
        'friendly_name': zb.friendlyName,
        'ieee_address': zb.ieeeAddress,
        'model': zb.model,
        'vendor': zb.vendor,
        'exposes': zb.exposes.map((e) => e.toJson()).toList(),
        'dps_map': dpsMap,
        'isOn': false,
      },
    );

    await devicesNotifier.addDevice(device);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ ${device.name} добавлено')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(zigbeeDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zigbee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Перезапрашиваем список (bridge/devices — retained)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Кнопка Permit join
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _togglePermitJoin,
                    icon: Icon(_isPermitJoin ? Icons.stop : Icons.wifi_find),
                    label: Text(
                      _isPermitJoin
                          ? 'Остановить сопряжение ($_countdown с)'
                          : 'Открыть сеть для сопряжения',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPermitJoin ? Colors.orange : Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (_isPermitJoin) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _countdown / 254),
                  const SizedBox(height: 8),
                  const Text(
                    'Зажмите кнопку на устройстве на 5 секунд',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          // Список устройств
          Expanded(
            child: devices.isEmpty
                ? const Center(
              child: Text(
                'Устройства не найдены.\nНажмите «Открыть сеть» и добавьте устройство.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final zb = devices[index];
                final isAdded = ref
                    .watch(devicesProvider)
                    .any((d) => d.deviceId == zb.ieeeAddress);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(
                      zb.isRouter ? Icons.router : Icons.sensors,
                      color: zb.available ? Colors.purple : Colors.grey,
                    ),
                    title: Text(zb.friendlyName.isNotEmpty ? zb.friendlyName : zb.model),
                    subtitle: Text('${zb.vendor} • ${zb.model} • ${zb.type}'),
                    trailing: isAdded
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.purple),
                      onPressed: () => _addDevice(zb),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}