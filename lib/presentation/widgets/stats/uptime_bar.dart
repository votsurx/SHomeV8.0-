import 'package:flutter/material.dart';

/// Полоса uptime: зелёная > 95%, жёлтая 80–95%, красная < 80%.
class UptimeBar extends StatelessWidget {
  /// 0.0..1.0, или null — нет данных.
  final double? ratio;
  final double height;

  const UptimeBar({super.key, required this.ratio, this.height = 6});

  Color get _color {
    if (ratio == null) return Colors.grey;
    if (ratio! >= 0.95) return Colors.green;
    if (ratio! >= 0.80) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final v = ratio ?? 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: v,
        minHeight: height,
        backgroundColor: Colors.grey.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(_color),
      ),
    );
  }
}