import 'dart:math';
import '../local/database.dart';

/// Генерирует тестовые данные датчиков за последние 7 дней.
/// Запускается один раз для наполнения графиков.
class TestDataGenerator {
  static Future<void> generateSensorData() async {
    final now = DateTime.now();
    final random = Random();

    // Проверяем, есть ли уже данные
    final existing = await AppDatabase.getSensorData(days: 7);
    if (existing.isNotEmpty) {
      print('Test data already exists, skipping generation.');
      return;
    }

    print('Generating test sensor data for 7 days...');

    for (var daysAgo = 7; daysAgo >= 0; daysAgo--) {
      for (var hour = 0; hour < 24; hour++) {
        // 4 замера в час (каждые 15 минут)
        for (var minute = 0; minute < 60; minute += 15) {
          final timestamp = DateTime(
            now.year, now.month, now.day - daysAgo,
            hour, minute,
          );

          // Базовая температура 22°C + суточные колебания ±5°C + шум
          final temp = 22.0 +
              5.0 * sin((hour - 6) * 3.14159 / 12) +
              random.nextDouble() * 2 - 1;

          // Влажность 60% + суточные колебания ±10% + шум
          final hum = 60.0 +
              10.0 * cos((hour - 12) * 3.14159 / 12) +
              random.nextDouble() * 10 - 5;

          // Мощность: днём 100-500W, ночью 10-50W
          final power = hour > 6 && hour < 22
              ? 100.0 + random.nextDouble() * 400
              : 10.0 + random.nextDouble() * 40;

          await AppDatabase.insertSensorLog(
            deviceId: 'test_sensor_1',
            deviceName: 'Датчик температуры',
            timestamp: timestamp.toIso8601String(),
            temperature: double.parse(temp.toStringAsFixed(1)),
            humidity: double.parse(hum.toStringAsFixed(1)),
            power: double.parse(power.toStringAsFixed(1)),
          );
        }
      }
    }

    print('Test data generation complete! ${7 * 24 * 4} records created.');
  }
}