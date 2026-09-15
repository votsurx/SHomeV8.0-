import 'package:flutter/material.dart';
import 'package:github_release_apk_updater/github_release_apk_updater.dart';
import 'package:restart_app/restart_app.dart';
import 'package:disk_usage/disk_usage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateService {
  static final _updater = GithubReleaseApkUpdater();
  static final _apiService = GithubApiService();

  /// Получить release notes с GitHub
  static Future<String?> _getReleaseNotes(String version) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/votsurx/SHome-Releases/releases/tags/v$version'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['body'] as String?;
      }
    } catch (e) {
      debugPrint('❌ Ошибка получения release notes: $e');
    }
    return null;
  }

  /// Получить свободное место на устройстве (в байтах)
  static Future<int> _getFreeSpace() async {
    try {
      final freeSpace = await DiskUsage.freeSpace();
      return freeSpace ?? 0;
    } catch (e) {
      debugPrint('❌ Ошибка получения свободного места: $e');
      return 0;
    }
  }

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      if (!context.mounted) return;

      // 1. Проверяем свободное место
      final freeSpace = await _getFreeSpace();
      final freeSpaceMB = (freeSpace / 1024 / 1024).toStringAsFixed(0);
      debugPrint('💾 Свободно: $freeSpaceMB МБ');

      if (freeSpace < 200 * 1024 * 1024) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Мало свободного места ($freeSpaceMB МБ). Нужно хотя бы 200 МБ.'),
          ),
        );
        return;
      }

      // 2. Получаем ABI устройства
      final supportedAbis = await _updater.getSupportedAbis();
      debugPrint('📱 ABI устройства: $supportedAbis');

      // 3. Получаем последний релиз
      final release = await _apiService.getLatestGithubAPKRelease(
        ownerGithub: 'votsurx',
        repositoryGithub: 'SHome-Releases',
        apkKeyName: '',
        supportedAbis: supportedAbis,
      );

      if (release == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Не удалось проверить обновления')),
        );
        return;
      }

      // 4. Сравниваем версии
      final currentVersion = await _updater.getCurrentAppVersion();
      final isNewer = VersionComparator().isNewerVersion(release.version, currentVersion);

      debugPrint('🔔 Текущая версия: $currentVersion');
      debugPrint('🔔 Версия в GitHub: ${release.version}');
      debugPrint('🔔 Обновление доступно: $isNewer');

      if (!context.mounted) return;

      if (isNewer) {
        _showUpdateDialog(context, release);
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Обновлений нет'),
            content: const Text('У вас установлена последняя версия SHome.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Ошибка проверки обновлений: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e')),
      );
    }
  }

  static void _showUpdateDialog(BuildContext context, GithubAPKRelease release) async {
    final releaseNotes = await _getReleaseNotes(release.version);
    final progressNotifier = ValueNotifier<double>(0);
    final isDownloading = ValueNotifier<bool>(false);
    final downloadSpeed = ValueNotifier<String>('');

    if (!context.mounted) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.system_update, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Обновление ${release.version}',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: MediaQuery.of(dialogCtx).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: isDownloading.value
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: progressNotifier,
                    builder: (context, progress, _) => Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<String>(
                    valueListenable: downloadSpeed,
                    builder: (context, speed, _) => Text(
                      speed,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
                    const Text(
                      'Что нового:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      releaseNotes,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ] else
                    const Text('Доступна новая версия приложения.'),
                  const SizedBox(height: 12),
                  const Text(
                    'Размер: ~60 МБ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'После установки приложение перезапустится.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          actions: isDownloading.value
              ? null
              : [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Позже'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                isDownloading.value = true;
                setDialogState(() {});

                final downloader = ApkDownloaderService();
                final startTime = DateTime.now();
                int lastReceived = 0;

                final filePath = await downloader.downloadAPK(
                  release.apkUrl,
                  null,
                      (received, total) {
                    if (total > 0) {
                      progressNotifier.value = received / total;

                      final elapsed = DateTime.now()
                          .difference(startTime)
                          .inMilliseconds;
                      if (elapsed > 0) {
                        final speed = (received - lastReceived) /
                            (elapsed / 1000) /
                            1024 /
                            1024;
                        downloadSpeed.value =
                        '${speed.toStringAsFixed(2)} МБ/с';
                        lastReceived = received;
                      }
                    }
                  },
                );

                if (filePath != null) {
                  debugPrint('✅ APK скачан: $filePath');
                  await _updater.installApk(filePath);
                  await Restart.restartApp();
                } else {
                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      const SnackBar(content: Text('❌ Ошибка скачивания')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }
}