import 'package:app_updater/app_updater.dart';
import 'package:flutter/cupertino.dart';

class UpdateService {
  static late AppUpdater _updater;

  static void initialize() {
    _updater = AppUpdater.configure(
      githubOwner: 'votsurx',
      githubRepo: 'SHome-Releases',
      checkFrequency: const Duration(days: 1),
    );
  }

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      print('🔔 Проверка обновлений...');
      if (!context.mounted) return;
      await _updater.checkAndShowUpdateDialog(context);
      print('🔔 Проверка завершена');
    } catch (e) {
      print('❌ Ошибка проверки обновлений: $e');
    }
  }
}