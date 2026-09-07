import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../domain/models/device.dart';
import '../../widgets/myispy_camera_card.dart';

class DeviceCameraPreview extends StatelessWidget {
  final Device device;
  const DeviceCameraPreview({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final cameraType = device.properties['cameraType'] as String? ?? 'device';

    // MyiSpy AI камера
    if (cameraType == 'ispy') {
      return MyiSpyCameraCard(device: device);  // ← используй device (не camera!)
    }

    // MJPEG из Legion NVR
    if (cameraType == 'mjpeg') {
      return _MjpegPreview(device: device);
    }

    // RTSP (старый)
    if (cameraType == 'rtsp') {
      return _RtspPreview(device: device);
    }

    // Локальная камера планшета
    return GestureDetector(
      onTap: () => _openDeviceFullScreen(context),
      child: _MiniPreview(device: device),
    );
  }

  void _openDeviceFullScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _FullScreenCamera(device: device)));
  }
}

// ═══════════ MJPEG из Legion NVR ═══════════

class _MjpegPreview extends StatefulWidget {
  final Device device;
  const _MjpegPreview({required this.device});

  @override
  State<_MjpegPreview> createState() => _MjpegPreviewState();
}

class _MjpegPreviewState extends State<_MjpegPreview> {
  String get _mjpegUrl => widget.device.properties['mjpegUrl'] as String? ?? '';
  String get _legionUrl => widget.device.properties['legionUrl'] as String? ?? 'http://192.168.1.100:8080';
  String get _cameraName => widget.device.name;

  @override
  Widget build(BuildContext context) {
    if (_mjpegUrl.isEmpty) {
      return const Icon(Icons.videocam_off, size: 28, color: Colors.grey);
    }

    return GestureDetector(
      onTap: () {
        // Показать диалог: открыть в браузере
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('📷 $_cameraName'),
            content: const Text('Открыть полный интерфейс Legion NVR в браузере?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Открыть Legion'),
                onPressed: () {
                  Navigator.pop(ctx);
                  _openLegion(context);
                },
              ),
            ],
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // MJPEG-поток
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _mjpegUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black12,
                    child: const Center(
                      child: Icon(Icons.videocam_off, size: 28, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Название камеры
          Text(
            _cameraName,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _openLegion(BuildContext context) async {
    final url = Uri.parse(_legionUrl);
    try {
      // Пробуем url_launcher если есть
      // await launchUrl(url, mode: LaunchMode.externalApplication);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Открыть: $_legionUrl')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть браузер')),
      );
    }
  }
}

// ═══════════ RTSP через VLC (старый) ═══════════

class _RtspPreview extends StatefulWidget {
  final Device device;
  const _RtspPreview({required this.device});

  @override
  State<_RtspPreview> createState() => _RtspPreviewState();
}

class _RtspPreviewState extends State<_RtspPreview> {
  int _refreshKey = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _refreshKey++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _rtspUrl => widget.device.properties['rtspUrl'] as String? ?? '';

  @override
  Widget build(BuildContext context) {
    if (_rtspUrl.isEmpty) {
      return const Icon(Icons.videocam, size: 28, color: Colors.grey);
    }

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Полноэкранный просмотр будет позже')),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam, size: 28, color: Colors.blue),
          const SizedBox(height: 4),
          Text(_rtspUrl, style: const TextStyle(fontSize: 7), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Container(
            width: 60, height: 40,
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)),
            child: const Center(child: Icon(Icons.play_circle, color: Colors.blue, size: 20)),
          ),
        ],
      ),
    );
  }
}

// ═══════════ Локальная камера планшета ═══════════

class _MiniPreview extends StatefulWidget {
  final Device device;
  const _MiniPreview({required this.device});

  @override
  State<_MiniPreview> createState() => _MiniPreviewState();
}

class _MiniPreviewState extends State<_MiniPreview> {
  CameraController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final lens = widget.device.properties['cameraLens'] as int? ?? 0;
      _controller = CameraController(cameras[lens < cameras.length ? lens : 0], ResolutionPreset.low, enableAudio: false);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isReady = true);
    } catch (_) {}
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) return const Icon(Icons.videocam, size: 28, color: Colors.grey);
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: CameraPreview(_controller!));
  }
}

class _FullScreenCamera extends StatefulWidget {
  final Device device;
  const _FullScreenCamera({required this.device});

  @override
  State<_FullScreenCamera> createState() => _FullScreenCameraState();
}

class _FullScreenCameraState extends State<_FullScreenCamera> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _lensIndex = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _lensIndex = widget.device.properties['cameraLens'] as int? ?? 0;
    _init();
  }

  Future<void> _init() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;
    if (_lensIndex >= _cameras!.length) _lensIndex = 0;
    _controller = CameraController(_cameras![_lensIndex], ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isReady = true);
  }

  Future<void> _switch() async {
    if (_cameras == null || _cameras!.length < 2) return;
    _lensIndex = _lensIndex == 0 ? 1 : 0;
    await _controller?.dispose();
    _isReady = false;
    setState(() {});
    await _init();
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.device.name), backgroundColor: Colors.black, actions: [
        if (_cameras != null && _cameras!.length > 1)
          IconButton(icon: const Icon(Icons.flip_camera_android, color: Colors.white), onPressed: _switch),
      ]),
      body: _isReady && _controller != null ? Center(child: CameraPreview(_controller!)) : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}