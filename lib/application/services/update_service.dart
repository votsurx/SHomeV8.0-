import 'dart:io';
import 'package:flutter/material.dart';
import 'package:github_release_apk_updater/github_release_apk_updater.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

      final supportedAbis = await _updater.getSupportedAbis() ?? ['arm64-v8a'];
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

  /// Прямое скачивание APK с GitHub Releases
  static Future<String?> _downloadApkDirect(
      String version,
      String abi,
      void Function(double progress) onProgress,
      ) async {
    try {
      // Определяем имя файла по ABI
      String fileName;
      if (abi.contains('arm64')) {
        fileName = 'app-arm64-v8a-release.apk';
      } else if (abi.contains('armeabi')) {
        fileName = 'app-armeabi-v7a-release.apk';
      } else if (abi.contains('x86_64')) {
        fileName = 'app-x86_64-release.apk';
      } else {
        fileName = 'app-arm64-v8a-release.apk';
      }

      // Прямой URL
      final url = Uri.parse(
        'https://github.com/votsurx/SHome-Releases/releases/download/v$version/$fileName',
      );

      debugPrint('📥 Прямое скачивание: $url');

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/SHome_update.apk';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      final client = http.Client();
      final request = http.Request('GET', url);
      final response = await client.send(request);

      if (response.statusCode != 200) {
        debugPrint('❌ Ошибка скачивания: ${response.statusCode}');
        client.close();
        return null;
      }

      final total = response.contentLength ?? 0;
      int received = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          onProgress(received / total);
        }
      }

      await sink.close();
      client.close();

      debugPrint('✅ APK скачан: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Ошибка скачивания: $e');
      return null;
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
              const Icon(Icons.system_update, color: Colors.green, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Обновление ${release.version}',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
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

                // Получаем ABI устройства
                final abis = await _updater.getSupportedAbis();
                final abi = (abis != null && abis.isNotEmpty) ? abis.first : 'arm64-v8a';

                // Прямое скачивание
                final filePath = await _downloadApkDirect(
                  release.version,
                  abi,
                      (progress) {
                    progressNotifier.value = progress;
                  },
                );

                if (filePath != null) {
                  debugPrint('✅ APK скачан: $filePath');

                  final result = await OpenFilex.open(filePath);
                  debugPrint('📦 Результат: ${result.type} — ${result.message}');

                  if (!dialogCtx.mounted) return;

                  if (result.type != ResultType.done) {
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      SnackBar(content: Text('Ошибка установки: ${result.message}')),
                    );
                  } else {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      const SnackBar(content: Text('После установки откройте SHome вручную')),
                    );
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