import 'package:flutter/material.dart';
import 'package:github_release_apk_updater/github_release_apk_updater.dart';
import 'package:restart_app/restart_app.dart';

class UpdateService {
  static final _updater = GithubReleaseApkUpdater();
  static final _apiService = GithubApiService();

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      if (!context.mounted) return;

      final supportedAbis = await _updater.getSupportedAbis();
      final release = await _apiService.getLatestGithubAPKRelease(
        ownerGithub: 'votsurx',
        repositoryGithub: 'SHome-Releases',
        apkKeyName: '',
        supportedAbis: supportedAbis,
      );

      if (release == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось проверить обновления')),
        );
        return;
      }

      final currentVersion = await _updater.getCurrentAppVersion();
      final isNewer = VersionComparator().isNewerVersion(release.version, currentVersion);

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
    }
  }

  static void _showUpdateDialog(BuildContext context, GithubAPKRelease release) {
    // Контроллер для диалога прогресса
    final progressNotifier = ValueNotifier<double>(0);
    final isDownloading = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Доступно обновление'),
          content: isDownloading.value
              ? ValueListenableBuilder<double>(
            valueListenable: progressNotifier,
            builder: (context, progress, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 8),
                Text('${(progress * 100).toStringAsFixed(0)}%'),
              ],
            ),
          )
              : Text('Новая версия: ${release.version}'),
          actions: isDownloading.value
              ? null
              : [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Позже'),
            ),
            ElevatedButton(
              onPressed: () async {
                isDownloading.value = true;
                setDialogState(() {});

                final downloader = ApkDownloaderService();
                final filePath = await downloader.downloadAPK(
                  release.apkUrl,
                  null,
                      (received, total) {
                    if (total > 0) {
                      progressNotifier.value = received / total;
                    }
                  },
                );

                if (filePath != null) {
                  // Устанавливаем APK
                  await _updater.installApk(filePath);

                  // Перезапускаем приложение
                  await Restart.restartApp();
                } else {
                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      const SnackBar(content: Text('Ошибка скачивания')),
                    );
                  }
                }
              },
              child: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }
}