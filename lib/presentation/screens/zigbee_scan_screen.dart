import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/state/devices_provider.dart';
import '../../application/state/rooms_provider.dart';
import '../../application/state/zigbee_provider.dart';
import '../../data/mappers/zigbee_dps_mapper.dart';
import '../../data/protocols/zigbee_protocol.dart';
import '../../di/injection.dart';
import '../../domain/models/device.dart';
import '../../domain/models/zigbee_device.dart';
import '../../l10n/generated/app_localizations.dart';

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

      if (!mounted) return;

      setState(() {
        _isPermitJoin = false;
        _countdown = 0;
      });
    } else {
      await protocol.permitJoin(true, time: 254);

      if (!mounted) return;

      setState(() {
        _isPermitJoin = true;
        _countdown = 254;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_countdown <= 1) {
          timer.cancel();
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

  Future<void> _addDevice(ZigbeeDevice zigbeeDevice) async {
    final l10n = AppLocalizations.of(context);
    final devicesNotifier = ref.read(devicesProvider.notifier);
    final rooms = ref.read(roomsProvider);
    final roomId = rooms.isNotEmpty ? rooms.first.id : 'other';

    final dpsMap = ZigbeeDpsMapper.toDpsMap(zigbeeDevice.exposes);

    final device = Device(
      id: 'zigbee_${zigbeeDevice.ieeeAddress}',
      name: zigbeeDevice.friendlyName.isNotEmpty
          ? zigbeeDevice.friendlyName
          : zigbeeDevice.model,
      type: DeviceType.compound,
      roomId: roomId,
      isOnline: zigbeeDevice.available,
      state: zigbeeDevice.available
          ? DeviceState.online
          : DeviceState.offline,
      deviceId: zigbeeDevice.ieeeAddress,
      mqttTopic: 'zigbee2mqtt/${zigbeeDevice.friendlyName}',
      properties: {
        'source': 'zigbee',
        'friendly_name': zigbeeDevice.friendlyName,
        'ieee_address': zigbeeDevice.ieeeAddress,
        'model': zigbeeDevice.model,
        'vendor': zigbeeDevice.vendor,
        'exposes':
        zigbeeDevice.exposes.map((expose) => expose.toJson()).toList(),
        'dps_map': dpsMap,
        'isOn': false,
      },
    );

    await devicesNotifier.addDevice(device);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.zigbeeDeviceAdded(device.name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final zigbeeDevices = ref.watch(zigbeeDevicesProvider);
    final appDevices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.zigbeeScanTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.zigbeeRefresh,
            onPressed: () {
              // Список bridge/devices обычно приходит из retained-сообщения.
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _togglePermitJoin,
                    icon: Icon(
                      _isPermitJoin ? Icons.stop : Icons.wifi_find,
                    ),
                    label: Text(
                      _isPermitJoin
                          ? l10n.zigbeeStopPairing(_countdown)
                          : l10n.zigbeeOpenPairing,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      _isPermitJoin ? Colors.orange : Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (_isPermitJoin) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _countdown / 254),
                  const SizedBox(height: 8),
                  Text(
                    l10n.zigbeePairingInstruction,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: zigbeeDevices.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.zigbeeNoDevices,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
                : ListView.builder(
              itemCount: zigbeeDevices.length,
              itemBuilder: (context, index) {
                final zigbeeDevice = zigbeeDevices[index];
                final isAdded = appDevices.any(
                      (device) =>
                  device.deviceId == zigbeeDevice.ieeeAddress,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(
                      zigbeeDevice.isRouter
                          ? Icons.router
                          : Icons.sensors,
                      color: zigbeeDevice.available
                          ? Colors.purple
                          : Colors.grey,
                    ),
                    title: Text(
                      zigbeeDevice.friendlyName.isNotEmpty
                          ? zigbeeDevice.friendlyName
                          : zigbeeDevice.model,
                    ),
                    // Vendor, model и тип — данные устройства,
                    // оставляем их без перевода.
                    subtitle: Text(
                      '${zigbeeDevice.vendor} • '
                          '${zigbeeDevice.model} • '
                          '${zigbeeDevice.type}',
                    ),
                    trailing: isAdded
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                        : IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.purple,
                      ),
                      onPressed: () =>
                          _addDevice(zigbeeDevice),
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