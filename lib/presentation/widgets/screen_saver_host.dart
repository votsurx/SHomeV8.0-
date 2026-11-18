import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Оборачивает приложение и показывает заставку после периода бездействия.
///
/// Любое касание закрывает заставку и перезапускает таймер бездействия.
/// Содержимое заставки передаётся через [screenSaverBuilder] — туда можно
/// подставить анимированную иконку из экрана первого запуска.
class ScreenSaverHost extends StatefulWidget {
  const ScreenSaverHost({
    required this.child,
    required this.screenSaverBuilder,
    this.enabled = true,
    this.idleTimeout = const Duration(minutes: 2),
    this.iconSize = 104,
    this.backgroundColor = const Color(0xFF050505),
    this.onScreenSaverActiveChanged,
    super.key,
  });

  final Widget child;
  final WidgetBuilder screenSaverBuilder;

  final bool enabled;
  final Duration idleTimeout;
  final double iconSize;
  final Color backgroundColor;

  /// Позже пригодится для камеры: включать её при true и выключать при false.
  /// true означает, что заставка видна и приложение на переднем плане.
  final ValueChanged<bool>? onScreenSaverActiveChanged;

  @override
  State<ScreenSaverHost> createState() => _ScreenSaverHostState();
}

class _ScreenSaverHostState extends State<ScreenSaverHost>
    with WidgetsBindingObserver {
  final math.Random _random = math.Random();

  Timer? _idleTimer;
  Timer? _movementTimer;

  bool _showingScreenSaver = false;
  bool _appResumed = true;

  // Положение иконки как доли доступной ширины и высоты.
  double _x = 0.5;
  double _y = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleIdleTimer();
  }

  @override
  void didUpdateWidget(covariant ScreenSaverHost oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled) {
      _hideScreenSaver();
      _idleTimer?.cancel();
    } else if (!oldWidget.enabled || oldWidget.idleTimeout != widget.idleTimeout) {
      _scheduleIdleTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;

    if (!_appResumed) {
      _idleTimer?.cancel();
      _movementTimer?.cancel();
      _notifyScreenSaverState();
      return;
    }

    if (_showingScreenSaver) {
      _startMovementTimer();
      _notifyScreenSaverState();
    } else {
      _scheduleIdleTimer();
    }
  }

  void _scheduleIdleTimer() {
    _idleTimer?.cancel();

    if (!widget.enabled || !_appResumed || _showingScreenSaver) {
      return;
    }

    _idleTimer = Timer(widget.idleTimeout, _showScreenSaver);
  }

  void _showScreenSaver() {
    if (!mounted || !widget.enabled || !_appResumed) {
      return;
    }

    setState(() {
      _showingScreenSaver = true;
      _x = 0.5;
      _y = 0.5;
    });

    _startMovementTimer();
    _notifyScreenSaverState();
  }

  void _hideScreenSaver() {
    _idleTimer?.cancel();
    _movementTimer?.cancel();

    if (_showingScreenSaver && mounted) {
      setState(() {
        _showingScreenSaver = false;
      });
      _notifyScreenSaverState();
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_showingScreenSaver) {
      _hideScreenSaver();
    } else {
      _scheduleIdleTimer();
    }
  }

  void _startMovementTimer() {
    _movementTimer?.cancel();

    if (!_showingScreenSaver || !_appResumed) {
      return;
    }

    _movementTimer = Timer.periodic(
      const Duration(seconds: 8),
          (_) {
        if (!mounted || !_showingScreenSaver || !_appResumed) {
          return;
        }

        setState(() {
          _x = 0.08 + _random.nextDouble() * 0.84;
          _y = 0.08 + _random.nextDouble() * 0.84;
        });
      },
    );
  }

  void _notifyScreenSaverState() {
    widget.onScreenSaverActiveChanged?.call(
      _showingScreenSaver && _appResumed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_showingScreenSaver)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxLeft = math.max(
                    0.0,
                    constraints.maxWidth - widget.iconSize,
                  );
                  final maxTop = math.max(
                    0.0,
                    constraints.maxHeight - widget.iconSize,
                  );

                  return Listener(
                    // Поглощает касание заставки: оно не попадёт в кнопки под ней.
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _onPointerDown,
                    child: ColoredBox(
                      color: widget.backgroundColor,
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(seconds: 7),
                            curve: Curves.easeInOut,
                            left: maxLeft * _x,
                            top: maxTop * _y,
                            width: widget.iconSize,
                            height: widget.iconSize,
                            child: widget.screenSaverBuilder(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    _movementTimer?.cancel();
    super.dispose();
  }
}