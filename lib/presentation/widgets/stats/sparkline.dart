import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Мини-график для карточки статистики.
class Sparkline extends StatelessWidget {
  /// Значения по дням (Y). X — 0..n-1.
  final List<double> values;
  final Color color;
  final double height;

  const Sparkline({
    super.key,
    required this.values,
    this.color = Colors.blue,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('нет данных', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ),
      );
    }
    final spots = List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));
    final maxY = values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble().clamp(1, double.infinity),
          minY: 0,
          maxY: maxY <= 0 ? 1 : maxY,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}