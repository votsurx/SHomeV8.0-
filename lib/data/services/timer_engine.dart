/// Движок таймеров — выполняет отложенные команды вкл/выкл.
/// Каждые 10 секунд проверяет таблицу timers в БД.
/// Если время выполнения наступило — отправляет команду и помечает таймер выполненным.
library;
import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/repositories/device_repository.dart';
import '../local/database.dart';

class TimerEngine {
  final DeviceRepository _deviceRepository;
  final Talker _talker;
  /// Таймер проверки (каждые 10 секунд)
  Timer? _timer;

  TimerEngine(this._deviceRepository, this._talker);

  /// Запускает периодическую проверку таймеров.
  void start() {
    _talker.info('TimerEngine started');
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkTimers());
  }

  /// Проверяет все активные таймеры.
  /// Если время выполнения наступило — выполняет команду и помечает таймер выполненным.
  Future<void> _checkTimers() async {
    try {
      final timers = await AppDatabase.getActiveTimers();
      final now = DateTime.now();

      for (final timer in timers) {
        if (now.isAfter(timer.executeAt)) {
          _talker.info('Executing timer: ${timer.deviceName} -> ${timer.command}');

          if (timer.command == 'turnOn') {
            await _deviceRepository.turnOn(timer.deviceId);
          } else {
            await _deviceRepository.turnOff(timer.deviceId);
          }

          await AppDatabase.markTimerExecuted(timer.id);
        }
      }
    } catch (e, stackTrace) {
      _talker.error('TimerEngine error', e, stackTrace);
    }
  }

  /// Останавливает движок таймеров.
  void stop() {
    _timer?.cancel();
  }
}