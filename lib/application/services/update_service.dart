import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:github_release_apk_updater/github_release_apk_updater.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/services/event_logger.dart';
import '../../l10n/generated/app_localizations.dart';
import 'dart:async';

class UpdateService {
  static final _updater = GithubReleaseApkUpdater();
  static final _apiService = GithubApiService();

  static Future<void> _logUpdateError(
      AppLocalizations l10n,
      String message,
      ) async {
    try {
      await EventLogger.log(
        event: 'error',
        deviceName: l10n.updateJournalSource,
        value: message,
      );
    } catch (error) {
      debugPrint('Failed to write update error to event log: $error');
    }
  }

  static Future<String?> _getReleaseNotes(String version) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/'
              'votsurx/SHome-Releases/releases/tags/v$version',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['body'] as String?;
      }
    } catch (error) {
      debugPrint('Failed to get release notes: $error');
    }

    return null;
  }

  static Future<void> checkForUpdates(BuildContext context) async {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);

    try {
      final supportedAbis =
          await _updater.getSupportedAbis() ?? ['arm64-v8a'];

      final release = await _apiService.getLatestGithubAPKRelease(
        ownerGithub: 'votsurx',
        repositoryGithub: 'SHome-Releases',
        apkKeyName: '',
        supportedAbis: supportedAbis,
      );

      if (release == null) {
        await _logUpdateError(l10n, l10n.updateCheckFailed);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updateCheckFailed)),
        );
        return;
      }

      final currentVersion = await _updater.getCurrentAppVersion();
      final isNewer = VersionComparator().isNewerVersion(
        release.version,
        currentVersion,
      );

      if (!context.mounted) return;

      if (isNewer) {
        await _showUpdateDialog(context, release, l10n);
      } else {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.updateNoUpdatesTitle),
            content: Text(l10n.updateNoUpdatesMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.updateOk),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      debugPrint('Update check failed: $error');
      await _logUpdateError(
        l10n,
        l10n.updateCheckError(error.toString()),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.updateCheckError(error.toString())),
        ),
      );
    }
  }

  /// Скачивает APK напрямую из GitHub Releases.
  static Future<String?> _downloadApkDirect(
      String version,
      String abi,
      void Function(double progress) onProgress, {
        required Future<void> abortTrigger,
      }) async {
    http.Client? client;
    IOSink? sink;
    File? file;

    try {
      final String fileName;

      if (abi.contains('arm64')) {
        fileName = 'app-arm64-v8a-release.apk';
      } else if (abi.contains('armeabi')) {
        fileName = 'app-armeabi-v7a-release.apk';
      } else if (abi.contains('x86_64')) {
        fileName = 'app-x86_64-release.apk';
      } else {
        fileName = 'app-arm64-v8a-release.apk';
      }

      final url = Uri.parse(
        'https://github.com/votsurx/SHome-Releases/'
            'releases/download/v$version/$fileName',
      );

      debugPrint('Скачивание обновления: $url');

      final directory = await getApplicationDocumentsDirectory();
      file = File('${directory.path}/SHome_update.apk');

      if (await file.exists()) {
        await file.delete();
      }

      client = http.Client();

      final request = http.AbortableRequest(
        'GET',
        url,
        abortTrigger: abortTrigger,
      );

      // Если сервер не отвечает, прерываем ожидание.
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != HttpStatus.ok) {
        debugPrint(
          'Не удалось скачать APK: HTTP ${response.statusCode}',
        );
        return null;
      }

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;

      sink = file.openWrite();

      // Если данные перестали поступать, завершаем загрузку ошибкой.
      await for (final chunk
      in response.stream.timeout(const Duration(seconds: 30))) {
        sink.add(chunk);
        receivedBytes += chunk.length;

        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;

      debugPrint('APK скачан: ${file.path}');
      return file.path;
    } catch (error) {
      debugPrint('Ошибка скачивания или отмена: $error');

      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {
          // Не заменяем исходную ошибку ошибкой закрытия файла.
        }
        sink = null;
      }

      // При ошибке или отмене удаляем частично скачанный APK.
      if (file != null) {
        try {
          if (await file.exists()) {
            await file.delete();
          }
        } catch (deleteError) {
          debugPrint('Не удалось удалить неполный APK: $deleteError');
        }
      }

      return null;
    } finally {
      // Закрывает клиент и прерывает незавершённый HTTP-запрос.
      client?.close();
    }
  }

  static Future<void> _showUpdateDialog(
      BuildContext context,
      GithubAPKRelease release,
      AppLocalizations l10n,
      ) async {
    final releaseNotes = await _getReleaseNotes(release.version);
    if (!context.mounted) return;

    final progressNotifier = ValueNotifier<double>(0);
    final isDownloading = ValueNotifier<bool>(false);
    final isCancelling = ValueNotifier<bool>(false);

    Completer<void>? activeDownloadAbort;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.system_update,
                  color: Colors.green,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.updateDialogTitle(release.version),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.updateDownloading,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (releaseNotes != null &&
                      releaseNotes.isNotEmpty) ...[
                    Text(
                      l10n.updateWhatsNew,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      releaseNotes,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ] else
                    Text(l10n.updateAvailable),
                ],
              ),
            ),
            actions: isDownloading.value
                ? [
              TextButton(
                onPressed: isCancelling.value ||
                    activeDownloadAbort == null
                    ? null
                    : () {
                  final abort = activeDownloadAbort;
                  if (abort == null || abort.isCompleted) return;

                  isCancelling.value = true;
                  setDialogState(() {});
                  abort.complete();
                },
                child: Text(
                  isCancelling.value
                      ? l10n.updateCancelling
                      : l10n.updateCancel,
                ),
              ),
            ]
                : [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.updateLater),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  isDownloading.value = true;
                  isCancelling.value = false;
                  progressNotifier.value = 0;
                  setDialogState(() {});

                  try {
                    final abis = await _updater.getSupportedAbis();
                    final abi = (abis != null && abis.isNotEmpty)
                        ? abis.first
                        : 'arm64-v8a';

                    if (!dialogContext.mounted) return;

                    final abort = Completer<void>();
                    activeDownloadAbort = abort;
                    setDialogState(() {});

                    final filePath = await _downloadApkDirect(
                      release.version,
                      abi,
                          (progress) {
                        progressNotifier.value = progress;
                      },
                      abortTrigger: abort.future,
                    );

                    activeDownloadAbort = null;

                    if (filePath == null) {
                      if (!dialogContext.mounted) return;

                      if (abort.isCompleted) {
                        final messenger =
                        ScaffoldMessenger.of(dialogContext);
                        Navigator.pop(dialogContext);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.updateDownloadCancelled),
                          ),
                        );
                        return;
                      }

                      await _logUpdateError(
                        l10n,
                        l10n.updateDownloadError(release.version),
                      );

                      if (!dialogContext.mounted) return;

                      final messenger =
                      ScaffoldMessenger.of(dialogContext);
                      Navigator.pop(dialogContext);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.updateDownloadFailed),
                        ),
                      );
                      return;
                    }

                    // Если отмена пришла одновременно с окончанием
                    // загрузки, не запускаем установщик.
                    if (abort.isCompleted) {
                      try {
                        final apkFile = File(filePath);
                        if (await apkFile.exists()) {
                          await apkFile.delete();
                        }
                      } catch (error) {
                        debugPrint(
                          'Could not delete cancelled update APK: $error',
                        );
                      }

                      if (!dialogContext.mounted) return;

                      final messenger =
                      ScaffoldMessenger.of(dialogContext);
                      Navigator.pop(dialogContext);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.updateDownloadCancelled),
                        ),
                      );
                      return;
                    }

                    // Загрузка завершена; теперь открывается установщик.
                    setDialogState(() {});

                    final result = await OpenFilex.open(filePath);

                    if (result.type != ResultType.done) {
                      await _logUpdateError(
                        l10n,
                        l10n.updateInstallError(
                          release.version,
                          result.message,
                        ),
                      );

                      if (!dialogContext.mounted) return;

                      isDownloading.value = false;
                      isCancelling.value = false;
                      setDialogState(() {});

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.updateInstallFailed(result.message),
                          ),
                        ),
                      );
                      return;
                    }

                    if (!dialogContext.mounted) return;

                    final messenger =
                    ScaffoldMessenger.of(dialogContext);
                    Navigator.pop(dialogContext);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.updateInstalledHint),
                      ),
                    );
                  } catch (error) {
                    activeDownloadAbort = null;

                    if (!dialogContext.mounted) return;

                    if (isCancelling.value) {
                      final messenger =
                      ScaffoldMessenger.of(dialogContext);
                      Navigator.pop(dialogContext);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.updateDownloadCancelled),
                        ),
                      );
                      return;
                    }

                    await _logUpdateError(
                      l10n,
                      l10n.updateInstallError(
                        release.version,
                        error.toString(),
                      ),
                    );

                    if (!dialogContext.mounted) return;

                    isDownloading.value = false;
                    isCancelling.value = false;
                    setDialogState(() {});

                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.updateInstallFailed(error.toString()),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.download),
                label: Text(l10n.updateButton),
              ),
            ],
          ),
        ),
      );
    } finally {
      progressNotifier.dispose();
      isDownloading.dispose();
      isCancelling.dispose();
    }
  }
}