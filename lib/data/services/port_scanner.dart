/// Асинхронный сканер Tuya-устройств в локальной сети.
/// Проверяет все IP в подсети на портах 6666, 6667, 6668, 7000.
/// Использует пул из 50 параллельных соединений для скорости.
/// Вызывает колбэки при обнаружении устройства и для отчёта о прогрессе.
library;
import 'dart:async';
import 'dart:io';
import 'package:talker/talker.dart';

/// Информация об обнаруженном устройстве.
class DiscoveredDevice {
  /// IP-адрес устройства
  final String ip;
  /// Порт, на котором устройство ответило
  final int port;

  DiscoveredDevice({required this.ip, required this.port});
}

class PortScanner {
  final Talker _talker;
  /// Колбэк при обнаружении устройства
  final void Function(DiscoveredDevice device) _onDeviceFound;
  /// Колбэк для отчёта о прогрессе (completed, total)
  final void Function(int progress, int total) _onProgress;

  PortScanner(this._talker, this._onDeviceFound, this._onProgress);

  /// Порты Tuya для сканирования
  static const List<int> tuyaPorts = [6668, 6667, 6666, 7000];
  /// Таймаут соединения
  static const Duration timeout = Duration(milliseconds: 500);
  /// Максимальное количество параллельных проверок
  static const int maxParallel = 50;

  /// Сканирует подсеть (например, "192.168.1.") на наличие Tuya-устройств.
  /// Проверяет все 254 IP, для каждого IP перебирает порты до первого успеха.
  Future<void> scanSubnet(String subnet) async {
    _talker.info('Scanning subnet: ${subnet}0/24');

    final ips = List.generate(254, (i) => '$subnet${i + 1}');
    var completed = 0;
    final totalChecks = ips.length;
    final foundIps = <String>{};

    // Разбиваем на батчи для параллельного выполнения
    for (var i = 0; i < ips.length; i += maxParallel) {
      final batch = ips.skip(i).take(maxParallel).toList();

      await Future.wait(batch.map((ip) async {
        // Проверяем порты по очереди
        for (final port in tuyaPorts) {
          try {
            final socket = await Socket.connect(ip, port, timeout: timeout);
            socket.destroy();

            if (!foundIps.contains(ip)) {
              foundIps.add(ip);
              _talker.info('Found device: $ip (port $port)');
              _onDeviceFound(DiscoveredDevice(ip: ip, port: port));
            }
            break; // Нашли устройство — не проверяем остальные порты
          } catch (e) {
            // Порт закрыт — пробуем следующий
          }
        }
        completed++;
        // Отчитываемся о прогрессе каждые 10 IP или в конце
        if (completed % 10 == 0 || completed == totalChecks) {
          _onProgress(completed, totalChecks);
        }
      }));
    }

    _talker.info('Scan complete. Found ${foundIps.length} devices');
    _onProgress(totalChecks, totalChecks);
  }

  /// Определяет локальную подсеть устройства.
  /// Возвращает строку вида "192.168.1." или null при ошибке.
  static Future<String?> getLocalSubnet() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.address.startsWith('127.')) {
            final parts = addr.address.split('.');
            return '${parts[0]}.${parts[1]}.${parts[2]}.';
          }
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
}