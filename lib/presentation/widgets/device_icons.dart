import 'package:flutter/material.dart';
import '../../domain/models/device.dart';

IconData getDeviceIcon(Device device) {
  switch (device.type) {
    case DeviceType.outlet: return Icons.power;
    case DeviceType.light: return Icons.lightbulb;
    case DeviceType.switch1:
    case DeviceType.switch2:
    case DeviceType.switch3: return Icons.toggle_on;
    case DeviceType.sensor:
      final st = device.properties['sensorType'] as String?;
      if (st == 'temperature') return Icons.thermostat;
      if (st == 'humidity') return Icons.water_drop;
      if (st == 'power') return Icons.bolt;
      return Icons.sensors;
    case DeviceType.curtain: return Icons.blinds;
    case DeviceType.hvac: return Icons.ac_unit;
    case DeviceType.camera: return Icons.videocam;
    case DeviceType.compound: return Icons.smart_toy;
    default: return Icons.devices;
  }
}