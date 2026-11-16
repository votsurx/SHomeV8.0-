import 'package:flutter/material.dart';

/// Прозрачный «хвостик» справа по центру экрана.
/// Тап или свайп влево → открывает EndDrawer.
class EdgeHandle extends StatelessWidget {
  final VoidCallback onOpen;

  const EdgeHandle({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Positioned(
      right: 0,
      top: MediaQuery.of(context).size.height * 0.42,
      child: GestureDetector(
        onTap: onOpen,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            onOpen();
          }
        },
        child: Container(
          width: 20,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.analytics_outlined,
            size: 14,
            color: color.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}