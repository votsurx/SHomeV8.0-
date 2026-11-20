import 'package:flutter/material.dart';

/// Предупреждение перед запуском сценария «Никого нет дома».
class PresenceWarningBanner extends StatefulWidget {
  const PresenceWarningBanner({
    required this.sceneName,
    required this.unknownPhoneNames,
    required this.remainingSeconds,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.onCancel,
    super.key,
  });

  final String sceneName;
  final List<String> unknownPhoneNames;
  final int remainingSeconds;

  /// Например: «Внимание!!!»
  final String title;

  /// Локализованное предупреждение о предстоящем запуске.
  final String message;

  /// Локализованный текст кнопки отмены.
  final String cancelLabel;

  final VoidCallback onCancel;

  @override
  State<PresenceWarningBanner> createState() =>
      _PresenceWarningBannerState();
}

class _PresenceWarningBannerState extends State<PresenceWarningBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.55,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant PresenceWarningBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sceneName != widget.sceneName ||
        oldWidget.unknownPhoneNames.length !=
            widget.unknownPhoneNames.length) {
      // Сохраняем непрерывное мигание; состояние виджета не сбрасываем.
      _blinkController
        ..stop()
        ..repeat(reverse: true);
    }
  }

  String _formatCountdown(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phoneNames = widget.unknownPhoneNames
        .where((name) => name.trim().isNotEmpty)
        .toList(growable: false);

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.72),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: AnimatedBuilder(
                  animation: _blinkController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _blinkController.value,
                      child: child,
                    );
                  },
                  child: Card(
                    color: theme.colorScheme.errorContainer,
                    elevation: 16,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.sceneName,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (phoneNames.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              phoneNames.join(', '),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Semantics(
                            label: _formatCountdown(widget.remainingSeconds),
                            liveRegion: true,
                            child: Text(
                              _formatCountdown(widget.remainingSeconds),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: widget.onCancel,
                              icon: const Icon(Icons.cancel_outlined),
                              label: Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  widget.cancelLabel,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }
}