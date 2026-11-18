import 'package:flutter/material.dart';
import '../../data/services/stats_cache.dart';

/// Прозрачный «хвостик» справа по центру экрана.
/// Тап или свайп влево → открывает EndDrawer.
/// Бейдж: зелёный — аномалий нет, красный — есть.
class EdgeHandle extends StatefulWidget {
  final VoidCallback onOpen;
  const EdgeHandle({super.key, required this.onOpen});

  @override
  State<EdgeHandle> createState() => _EdgeHandleState();
}

class _EdgeHandleState extends State<EdgeHandle> {
  @override
  void initState() {
    super.initState();
    StatsCache.instance.addListener(_onCacheChanged);
  }

  @override
  void dispose() {
    StatsCache.instance.removeListener(_onCacheChanged);
    super.dispose();
  }

  void _onCacheChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    final color = Theme.of(context).colorScheme.primary;
    final hasAnomalies = StatsCache.instance.anomalyCount > 0;
    final badgeColor = hasAnomalies ? Colors.red : Colors.green;

    return Positioned(
      right: 0,
      top: MediaQuery.sizeOf(context).height * (isPhone ? 0.38 : 0.42),
      child: GestureDetector(
        onTap: widget.onOpen,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            widget.onOpen();
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isPhone ? 16 : 20,
              height: isPhone ? 48 : 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(10)),
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
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}