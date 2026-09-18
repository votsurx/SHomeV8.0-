import 'dart:io';
import 'package:flutter/material.dart';
import 'package:github_release_apk_updater/github_release_apk_updater.dart';
import 'package:open_filex/open_filex.dart';
import 'package:restart_app/restart_app.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateService {
  static final _updater = GithubReleaseApkUpdater();
  static final _apiService = GithubApiService();

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

  static void _showUpdateDialog(BuildContext context, GithubAPKRelease release) async {
    final releaseNotes = await _getReleaseNotes(release.version);
    final progressNotifier = ValueNotifier<double>(0);
    final isDownloading = ValueNotifier<bool>(false);

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.system_update, color: Colors.green),
              const SizedBox(width: 8),
              Text('Обновление ${release.version}'),
            ],
          ),
          content: SingleChildScrollView(
            child: isDownloading.value
                ? ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, progress, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Скачивание обновления...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
                  const Text('Что нового:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(releaseNotes, style: const TextStyle(fontSize: 13)),
                ] else
                  const Text('Доступна новая версия приложения.'),
              ],
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
                  debugPrint('✅ APK скачан: $filePath');

                  // Копируем в публичную папку Downloads
                  String publicPath = filePath;
                  try {
                    final downloadsDir = await getDownloadsDirectory() ?? Directory('/storage/emulated/0/Download');
                    if (!await downloadsDir.exists()) {
                      await downloadsDir.create(recursive: true);
                    }
                    publicPath = '${downloadsDir.path}/SHome_update.apk';
                    final publicFile = File(publicPath);
                    if (await publicFile.exists()) {
                      await publicFile.delete();
                    }
                    await File(filePath).copy(publicPath);
                    debugPrint('📂 APK скопирован в: $publicPath');
                  } catch (e) {
                    debugPrint('⚠️ Не удалось скопировать в Downloads: $e');
                    // Если не удалось, пробуем установить из исходного пути
                    publicPath = filePath;
                  }

                  // Открываем APK
                  final result = await OpenFilex.open(publicPath);
                  debugPrint('📦 Результат: ${result.type} — ${result.message}');

                  if (result.type == ResultType.done) {
                    await Future.delayed(const Duration(seconds: 2));
                    await Restart.restartApp();
                  } else {
                    if (dialogCtx.mounted) {
                      ScaffoldMessenger.of(dialogCtx).showSnackBar(
                        SnackBar(content: Text('Ошибка установки: ${result.message}')),
                      );
                    }
                  }
                } else {
                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      const SnackBar(content: Text('Ошибка скачивания')),
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