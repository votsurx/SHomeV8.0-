/// Экран энергомониторинга (заготовка).
/// Отображает DPS-данные устройств: мощность, напряжение, ток, потребление.
/// Обновляется каждые 5 секунд.
/// В будущем будет заменён на графики из energy_log.
library;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/state/devices_provider.dart';
import '../../domain/models/device.dart';

class EnergyScreen extends ConsumerStatefulWidget {
  const EnergyScreen({super.key});

  @override
  ConsumerState<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends ConsumerState<EnergyScreen> {
  /// Таймер периодического опроса DPS
  Timer? _timer;
  /// Кэш DPS-данных по устройствам
  Map<String, Map<String, dynamic>> _deviceDps = {};

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Запускает периодический опрос DPS каждые 5 секунд.
  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _updateDps());
    _updateDps();
  }

  /// Запрашивает DPS для всех устройств.
  Future<void> _updateDps() async {
    final devices = ref.read(devicesProvider)
        .where((d) => d.type == DeviceType.sensor && d.properties['sensorType'] == 'power')
        .toList();
    for (final device in devices) {
      if (device.deviceId != null) {
        final dps = await ref.read(devicesProvider.notifier).getDeviceDps(device.id);
        if (dps != null && mounted) {
          setState(() => _deviceDps[device.id] = dps);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDevices = ref.watch(devicesProvider);
    final devices = allDevices
        .where((d) => d.type == DeviceType.sensor && d.properties['sensorType'] == 'power')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Энергомониторинг')),
      body: devices.isEmpty
          ? const Center(child: Text('Нет устройств'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          final dps = _deviceDps[device.id];
          return _buildEnergyCard(device, dps);
        },
      ),
    );
  }

  /// Карточка с энергоданными одного устройства.
  Widget _buildEnergyCard(Device device, Map<String, dynamic>? dps) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            if (dps != null) ...[
              _buildDpsRow('Мощность', '${dps['9'] ?? dps[9] ?? "—"} W'),
              _buildDpsRow('Напряжение', '${dps['10'] ?? dps[10] ?? "—"} V'),
              _buildDpsRow('Ток', '${dps['11'] ?? dps[11] ?? "—"} mA'),
              _buildDpsRow('Потреблено', '${dps['12'] ?? dps[12] ?? "—"} kWh'),
            ] else
              const Text('Нет данных DPS', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// Строка с одним показателем.
  Widget _buildDpsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}