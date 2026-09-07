/// Полноэкранный просмотр камеры
library;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/models/device.dart';
import '../../data/services/mjpeg_stream_service.dart';

class FullscreenCameraScreen extends StatefulWidget {
  final Device device;
  final String mjpegUrl;

  const FullscreenCameraScreen({
    super.key,
    required this.device,
    required this.mjpegUrl,
  });

  @override
  State<FullscreenCameraScreen> createState() => _FullscreenCameraScreenState();
}

class _FullscreenCameraScreenState extends State<FullscreenCameraScreen> {
  MjpegStreamService? _mjpegService;
  Stream<Uint8List>? _stream;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void dispose() {
    _mjpegService?.dispose();
    super.dispose();
  }

  void _startStream() {
    _mjpegService = MjpegStreamService();
    _stream = _mjpegService!.subscribe(widget.mjpegUrl);

    _stream?.listen(
          (_) {
        if (_isLoading) {
          setState(() => _isLoading = false);
        }
      },
      onError: (_) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.device.name,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: _buildVideo(),
      ),
    );
  }

  Widget _buildVideo() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_hasError || _stream == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Нет сигнала',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<Uint8List>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onDoubleTap: _toggleFullscreen,
            child: Image(
              image: MemoryImage(snapshot.data!),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.grey, size: 64),
                );
              },
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text(
                  'Ошибка потока',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );
  }

  void _toggleFullscreen() {
    // Переключаем полноэкранный режим (скрываем/показываем статус бар)
    // TODO: реализовать настоящий полноэкранный режим
    // Пока просто выводим сообщение
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Двойной тап для полноэкранного режима'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}