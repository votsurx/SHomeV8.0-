import 'package:flutter_test/flutter_test.dart';
import 'package:shome/data/services/port_scanner.dart';
import 'package:talker/talker.dart';

void main() {
  group('PortScanner', () {
    late Talker talker;

    setUp(() {
      talker = Talker();
    });

    test('getLocalSubnet возвращает корректную подсеть', () async {
      final subnet = await PortScanner.getLocalSubnet();

      if (subnet != null) {
        expect(subnet, endsWith('.'));
        final parts = subnet.split('.');
        expect(parts.length, 4);
        expect(parts[3], '');
      }
    });

    test('Подсеть для локального хоста не возвращается', () async {
      final subnet = await PortScanner.getLocalSubnet();
      if (subnet != null) {
        expect(subnet, isNot(startsWith('127.')));
      }
    });

    test('DiscoveredDevice создаётся корректно', () {
      final device = DiscoveredDevice(ip: '192.168.1.100', port: 6668);
      expect(device.ip, '192.168.1.100');
      expect(device.port, 6668);
    });

    test('Сканирование с недоступной подсетью не падает', () async {
      final scanner = PortScanner(
        talker,
        (device) {},
        (progress, total) {},
      );
      await scanner.scanSubnet('192.168.255.');
    });

    test('Callback onProgress сообщает прогресс', () async {
      final progressValues = <int>[];

      final scanner = PortScanner(
        talker,
        (device) {},
        (progress, total) => progressValues.add(progress),
      );

      final subnet = await PortScanner.getLocalSubnet();
      if (subnet != null) {
        await scanner.scanSubnet(subnet);
        expect(progressValues.isNotEmpty, true);
        expect(progressValues.last, 254);
      }
    });
  });
}
