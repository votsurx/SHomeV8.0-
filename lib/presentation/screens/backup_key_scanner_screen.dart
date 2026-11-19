import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/generated/app_localizations.dart';

class BackupKeyScannerScreen extends StatefulWidget {
  const BackupKeyScannerScreen({super.key});

  @override
  State<BackupKeyScannerScreen> createState() =>
      _BackupKeyScannerScreenState();
}

class _BackupKeyScannerScreenState extends State<BackupKeyScannerScreen> {
  final MobileScannerController _scannerController =
  MobileScannerController();

  bool _handled = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;

      if (value == null || value.trim().isEmpty) {
        continue;
      }

      _handled = true;
      _scannerController.stop();

      if (mounted) {
        Navigator.of(context).pop(value.trim());
      }

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupKeyScanTitle),
        actions: [
          IconButton(
            tooltip: l10n.switchCameraTooltip,
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              _scannerController.switchCamera();
            },
          ),
          IconButton(
            tooltip: l10n.flashTooltip,
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              _scannerController.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Card(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.backupKeyScanHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}