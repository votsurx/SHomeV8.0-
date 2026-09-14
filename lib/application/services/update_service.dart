import 'package:flutter/material.dart';
import 'package:github_release_apk_updater/github_release_apk_updater.dart';

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

      final isNewer = VersionComparator().isNewerVersion(
        release.version,
        currentVersion,
      );
      print('🔔 Текущая версия: $currentVersion');
      print('🔔 Версия в GitHub: ${release.version}');
      print('🔔 Обновление доступно: ${isNewer}');

      if (!context.mounted) return;

      if (isNewer) {
        // Показать диалог обновления
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Доступно обновление'),
            content: Text('Новая версия: ${release.version}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Позже'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final downloader = ApkDownloaderService();
                  final filePath = await downloader.downloadAPK(
                    release.apkUrl,
                    null,
                        (received, total) {},
                  );
                  if (filePath != null) {
                    await _updater.installApk(filePath);
                  }
                },
                child: const Text('Обновить'),
              ),
            ],
          ),
        );
      } else {
        // Показать, что обновлений нет
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Обновлений нет'),
            content: const Text('У вас установлена последняя версия SHome.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Ошибка проверки обновлений: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }
}