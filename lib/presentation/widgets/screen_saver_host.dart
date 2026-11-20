import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Показывает самописную заставку после периода бездействия.
///
/// Если включён motionWakeEnabled, фронтальная камера работает только
/// пока заставка видна и приложение находится на переднем плане.
/// Анализируются только яркостные значения кадров в памяти:
/// кадры не сохраняются и не отправляются.
class ScreenSaverHost extends StatefulWidget {
  const ScreenSaverHost({
    required this.child,
    required this.screenSaverBuilder,
    this.enabled = true,
    this.suppressScreenSaver = false,
    this.motionWakeEnabled = false,
    this.motionSensitivity = 50,
    this.idleTimeout = const Duration(minutes: 2),
    this.iconSize = 104,
    this.backgroundColor = const Color(0xFF050505),
    this.onScreenSaverActiveChanged,
    super.key,
  });

  final Widget child;
  final WidgetBuilder screenSaverBuilder;

  /// Пользовательская настройка: разрешено ли показывать заставку.
  final bool enabled;

  /// Временное подавление заставки, например пока отображается
  /// критичное предупреждение. Настройку [enabled] не меняет.
  final bool suppressScreenSaver;

  final bool motionWakeEnabled;

  /// Диапазон 0–100: чем выше значение, тем чувствительнее детекция.
  final int motionSensitivity;

  final Duration idleTimeout;
  final double iconSize;
  final Color backgroundColor;

  /// Вызывается, когда заставка показывается или скрывается.
  final ValueChanged<bool>? onScreenSaverActiveChanged;

  @override
  State<ScreenSaverHost> createState() => _ScreenSaverHostState();
}

class _ScreenSaverHostState extends State<ScreenSaverHost>
    with WidgetsBindingObserver {
  static const _cameraWarmupDuration = Duration(seconds: 3);
  static const _sampleStep = 8;

  final math.Random _random = math.Random();

  Timer? _idleTimer;
  Timer? _movementTimer;

  CameraController? _motionCamera;
  bool _cameraStarting = false;
  bool _motionTriggered = false;

  DateTime? _ignoreMotionUntil;
  Uint8List? _previousSamples;
  int _consecutiveMotionFrames = 0;

  bool _showingScreenSaver = false;
  bool _appResumed = true;

  // Положение иконки — доли доступной ширины и высоты.
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

    if (!widget.enabled || widget.suppressScreenSaver) {
      _idleTimer?.cancel();
      _idleTimer = null;
      _hideScreenSaver(scheduleIdleTimer: false);
      return;
    }

    if (oldWidget.suppressScreenSaver && !widget.suppressScreenSaver) {
      _scheduleIdleTimer();
    } else if (!oldWidget.enabled ||
        oldWidget.idleTimeout != widget.idleTimeout) {
      _scheduleIdleTimer();
    }

    if (oldWidget.motionWakeEnabled != widget.motionWakeEnabled) {
      if (widget.motionWakeEnabled &&
          _showingScreenSaver &&
          _appResumed &&
          !widget.suppressScreenSaver) {
        unawaited(_startMotionCamera());
      } else {
        unawaited(_stopMotionCamera());
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;

    if (!_appResumed) {
      _idleTimer?.cancel();
      _idleTimer = null;
      _movementTimer?.cancel();
      unawaited(_stopMotionCamera());
      _notifyScreenSaverState();
      return;
    }

    if (widget.suppressScreenSaver || !widget.enabled) {
      _idleTimer?.cancel();
      _idleTimer = null;
      _movementTimer?.cancel();
      unawaited(_stopMotionCamera());

      if (_showingScreenSaver) {
        _hideScreenSaver(scheduleIdleTimer: false);
      }
      return;
    }

    if (_showingScreenSaver) {
      _startMovementTimer();
      _notifyScreenSaverState();

      if (widget.motionWakeEnabled) {
        unawaited(_startMotionCamera());
      }
    } else {
      _scheduleIdleTimer();
    }
  }

  void _scheduleIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;

    if (!widget.enabled ||
        widget.suppressScreenSaver ||
        !_appResumed ||
        _showingScreenSaver) {
      return;
    }

    _idleTimer = Timer(widget.idleTimeout, _showScreenSaver);
  }

  void _showScreenSaver() {
    if (!mounted ||
        !widget.enabled ||
        widget.suppressScreenSaver ||
        !_appResumed) {
      return;
    }

    setState(() {
      _showingScreenSaver = true;
      _x = 0.5;
      _y = 0.5;
    });

    _motionTriggered = false;
    _startMovementTimer();
    _notifyScreenSaverState();

    if (widget.motionWakeEnabled) {
      unawaited(_startMotionCamera());
    }
  }

  void _hideScreenSaver({
    bool scheduleIdleTimer = true,
  }) {
    _idleTimer?.cancel();
    _idleTimer = null;
    _movementTimer?.cancel();
    unawaited(_stopMotionCamera());

    if (!_showingScreenSaver || !mounted) {
      if (scheduleIdleTimer &&
          widget.enabled &&
          !widget.suppressScreenSaver) {
        _scheduleIdleTimer();
      }
      return;
    }

    setState(() {
      _showingScreenSaver = false;
    });

    _motionTriggered = false;
    _notifyScreenSaverState();

    if (scheduleIdleTimer &&
        widget.enabled &&
        !widget.suppressScreenSaver) {
      _scheduleIdleTimer();
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.suppressScreenSaver) return;

    if (_showingScreenSaver) {
      _hideScreenSaver();
    } else {
      _scheduleIdleTimer();
    }
  }

  void _startMovementTimer() {
    _movementTimer?.cancel();

    if (!_showingScreenSaver ||
        !_appResumed ||
        widget.suppressScreenSaver) {
      return;
    }

    _movementTimer = Timer.periodic(
      const Duration(seconds: 8),
          (_) {
        if (!mounted ||
            !_showingScreenSaver ||
            !_appResumed ||
            widget.suppressScreenSaver) {
          return;
        }

        setState(() {
          _x = 0.08 + _random.nextDouble() * 0.84;
          _y = 0.08 + _random.nextDouble() * 0.84;
        });
      },
    );
  }

  Future<void> _startMotionCamera() async {
    if (_cameraStarting ||
        _motionCamera != null ||
        !_canUseCamera) {
      return;
    }

    _cameraStarting = true;
    CameraController? controller;

    try {
      final cameras = await availableCameras();

      if (!_canUseCamera || cameras.isEmpty) {
        return;
      }

      final frontCameras = cameras.where(
            (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      final camera =
      frontCameras.isNotEmpty ? frontCameras.first : cameras.first;

      controller = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (!_canUseCamera) {
        await controller.dispose();
        return;
      }

      _motionCamera = controller;
      _previousSamples = null;
      _consecutiveMotionFrames = 0;

      // Даём камере время стабилизировать экспозицию и баланс белого.
      _ignoreMotionUntil = DateTime.now().add(_cameraWarmupDuration);

      await controller.startImageStream(_onCameraImage);

      if (!_canUseCamera) {
        await _stopMotionCamera();
      }
    } catch (_) {
      if (controller != null) {
        if (identical(_motionCamera, controller)) {
          _motionCamera = null;
        }

        try {
          await controller.dispose();
        } catch (_) {
          // Ошибка камеры не должна ломать интерфейс SHome.
        }
      }

      // Если камера недоступна или разрешение не выдано,
      // заставку всё равно можно закрыть касанием.
    } finally {
      _cameraStarting = false;
    }
  }

  bool get _canUseCamera =>
      mounted &&
          _showingScreenSaver &&
          _appResumed &&
          widget.enabled &&
          !widget.suppressScreenSaver &&
          widget.motionWakeEnabled &&
          !_motionTriggered;

  void _onCameraImage(CameraImage image) {
    if (!_canUseCamera ||
        image.planes.isEmpty ||
        image.format.group != ImageFormatGroup.yuv420) {
      return;
    }

    // Первая плоскость YUV420 содержит яркостный канал.
    // Учитываем stride для корректного чтения пикселей.
    final plane = image.planes.first;
    final bytes = plane.bytes;
    final pixelStride = plane.bytesPerPixel ?? 1;
    final samplesPerRow = (image.width + _sampleStep - 1) ~/ _sampleStep;
    final samplesPerColumn =
        (image.height + _sampleStep - 1) ~/ _sampleStep;

    if (samplesPerRow <= 0 ||
        samplesPerColumn <= 0 ||
        bytes.isEmpty) {
      return;
    }

    final samples = Uint8List(samplesPerRow * samplesPerColumn);
    var sampleIndex = 0;

    for (var y = 0; y < image.height; y += _sampleStep) {
      for (var x = 0; x < image.width; x += _sampleStep) {
        final byteIndex = y * plane.bytesPerRow + x * pixelStride;

        if (byteIndex >= bytes.length) continue;

        samples[sampleIndex++] = bytes[byteIndex];
      }
    }

    if (sampleIndex == 0) return;

    final currentSamples = sampleIndex == samples.length
        ? samples
        : Uint8List.fromList(samples.sublist(0, sampleIndex));

    final previous = _previousSamples;
    _previousSamples = currentSamples;

    // Первые секунды кадры обновляют опорное изображение,
    // движение в это время не определяется.
    final ignoreUntil = _ignoreMotionUntil;
    if (ignoreUntil != null && DateTime.now().isBefore(ignoreUntil)) {
      _consecutiveMotionFrames = 0;
      return;
    }

    if (previous == null || previous.length != currentSamples.length) {
      return;
    }

    final sensitivity = widget.motionSensitivity.clamp(0, 100);
    final pixelDeltaThreshold = (40 - sensitivity * 0.28).round();
    final changedRatioThreshold = 0.35 - sensitivity * 0.0029;

    var changedSamples = 0;

    for (var i = 0; i < currentSamples.length; i++) {
      final difference = (currentSamples[i] - previous[i]).abs();

      if (difference >= pixelDeltaThreshold) {
        changedSamples++;
      }
    }

    final changedRatio = changedSamples / currentSamples.length;

    // Три последовательных кадра уменьшают ложные срабатывания от шума.
    if (changedRatio >= changedRatioThreshold) {
      _consecutiveMotionFrames++;
    } else {
      _consecutiveMotionFrames = 0;
    }

    if (_consecutiveMotionFrames >= 3) {
      _motionTriggered = true;
      _hideScreenSaver();
    }
  }

  Future<void> _stopMotionCamera() async {
    final controller = _motionCamera;
    _motionCamera = null;

    _previousSamples = null;
    _consecutiveMotionFrames = 0;
    _ignoreMotionUntil = null;

    if (controller == null) return;

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {
      // Поток мог остановиться при смене состояния приложения.
    }

    try {
      await controller.dispose();
    } catch (_) {
      // Освобождение камеры не должно ломать интерфейс.
    }
  }

  void _notifyScreenSaverState() {
    widget.onScreenSaverActiveChanged?.call(
      _showingScreenSaver &&
          _appResumed &&
          !widget.suppressScreenSaver,
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
          if (_showingScreenSaver &&
              widget.enabled &&
              !widget.suppressScreenSaver)
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
    unawaited(_stopMotionCamera());
    super.dispose();
  }
}