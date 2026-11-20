import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/local/secure_storage/encrypted_keys.dart';
import '../../data/services/backup_key_qr_service.dart';
import '../../data/services/config_service.dart';
import '../../data/services/mailru_cloud_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'backup_key_scanner_screen.dart';

class CloudSettingsScreen extends StatefulWidget {
  const CloudSettingsScreen({super.key});

  @override
  State<CloudSettingsScreen> createState() => _CloudSettingsScreenState();
}

class _CloudSettingsScreenState extends State<CloudSettingsScreen> {
  final EncryptedKeys _keys = EncryptedKeys();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final BackupKeyQrService _backupKeyQr = const BackupKeyQrService();

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isUploading = false;
  bool _isDownloading = false;
  bool _isGeneratingBackupKey = false;
  bool _hasBackupKey = false;
  bool _obscurePassword = true;

  String? _login;
  String? _lastSync;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final login = await _keys.getCloudLogin();
    final password = await _keys.getCloudPassword();
    final lastSync = await _keys.getCloudLastSync();
    final hasBackupKey = await ConfigService.hasBackupKey();

    if (!mounted) return;

    setState(() {
      _isConnected = login != null &&
          login.isNotEmpty &&
          password != null &&
          password.isNotEmpty;
      _login = login;
      _lastSync = lastSync;
      _hasBackupKey = hasBackupKey;
    });
  }

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context);
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      _showSnack(l10n.cloudEnterCredentials);
      return;
    }

    setState(() => _isConnecting = true);

    try {
      final service = MailruCloudService(
        login: login,
        password: password,
      );

      final success = await service.testConnection();

      if (!mounted) return;

      if (success) {
        await _keys.saveCloudLogin(login);
        await _keys.saveCloudPassword(password);

        if (!mounted) return;

        setState(() {
          _isConnected = true;
          _login = login;
        });

        _loginController.clear();
        _passwordController.clear();

        _showSnack(l10n.cloudConnectedMessage);
      } else {
        _showSnack(l10n.cloudConnectFailed);
      }
    } catch (error) {
      if (mounted) {
        _showSnack(l10n.cloudConnectionError(error.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context);

    await _keys.deleteCloudLogin();
    await _keys.deleteCloudPassword();
    await _keys.deleteCloudLastSync();

    if (!mounted) return;

    setState(() {
      _isConnected = false;
      _login = null;
      _lastSync = null;
    });

    _showSnack(l10n.cloudDisconnectedMessage);
  }

  Future<void> _generateBackupKey() async {
    final l10n = AppLocalizations.of(context);
    final alreadyExists = await ConfigService.hasBackupKey();

    if (!mounted) return;

    if (alreadyExists) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.cloudGenerateNewKeyTitle),
          content: Text(l10n.cloudGenerateNewKeyWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.cloudGenerate),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    setState(() => _isGeneratingBackupKey = true);

    try {
      await ConfigService.generateBackupKey();

      if (!mounted) return;

      setState(() => _hasBackupKey = true);
      _showSnack(l10n.cloudKeyCreatedMessage);
    } catch (error) {
      if (mounted) {
        _showSnack(l10n.cloudKeyCreateError(error.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingBackupKey = false);
      }
    }
  }

  Future<void> _uploadBackup() async {
    if (_isUploading) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _isUploading = true);

    try {
      final login = await _keys.getCloudLogin();
      final password = await _keys.getCloudPassword();

      if (login == null ||
          login.isEmpty ||
          password == null ||
          password.isEmpty) {
        _showSnack(l10n.cloudNoLoginData);
        return;
      }

      final hasBackupKey = await ConfigService.hasBackupKey();

      if (!hasBackupKey) {
        _showSnack(l10n.cloudGenerateKeyFirst);
        return;
      }

      final service = MailruCloudService(
        login: login,
        password: password,
      );

      final json = await ConfigService.buildConfigJson();
      final encrypted = await ConfigService.encryptBackup(json);
      final success = await service.uploadBackup(encrypted);

      if (!mounted) return;

      if (success) {
        final now = DateTime.now();
        final dateStr =
            '${now.day.toString().padLeft(2, '0')}.'
            '${now.month.toString().padLeft(2, '0')}.'
            '${now.year} '
            '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}';

        await _keys.saveCloudLastSync(dateStr);

        if (!mounted) return;

        setState(() => _lastSync = dateStr);
        _showSnack(l10n.cloudBackupUploaded);
      } else {
        _showSnack(l10n.cloudBackupUploadFailed);
      }
    } catch (error) {
      if (mounted) {
        _showSnack(l10n.cloudBackupUploadError(error.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _downloadBackup() async {
    if (_isDownloading) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _isDownloading = true);

    try {
      final login = await _keys.getCloudLogin();
      final password = await _keys.getCloudPassword();

      if (login == null ||
          login.isEmpty ||
          password == null ||
          password.isEmpty) {
        _showSnack(l10n.cloudNoLoginData);
        return;
      }

      final hasBackupKey = await ConfigService.hasBackupKey();

      if (!hasBackupKey) {
        _showSnack(l10n.cloudImportKeyFirst);
        return;
      }

      final service = MailruCloudService(
        login: login,
        password: password,
      );

      final backups = await service.listBackups();

      if (!mounted) return;

      if (backups.isEmpty) {
        _showSnack(l10n.cloudNoBackups);
        return;
      }

      final selected = await showDialog<String>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: Text(l10n.cloudChooseBackup),
          children: backups
              .map(
                (backup) => SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(backup),
              child: Text(backup),
            ),
          )
              .toList(),
        ),
      );

      if (selected == null) return;

      final encrypted = await service.downloadBackup(selected);

      if (!mounted) return;

      if (encrypted == null || encrypted.isEmpty) {
        _showSnack(l10n.cloudBackupDownloadFailed);
        return;
      }

      final json = await ConfigService.decryptBackup(encrypted);
      await ConfigService.restoreFromJson(json);

      if (!mounted) return;

      _showSnack(l10n.cloudBackupRestoreSuccess(selected));
    } catch (error) {
      if (mounted) {
        _showSnack(l10n.cloudBackupRestoreError(error.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _showBackupKeyQr() async {
    final l10n = AppLocalizations.of(context);
    final key = await ConfigService.getBackupKey();

    if (!mounted) return;

    if (key == null || key.isEmpty) {
      _showSnack(l10n.cloudGenerateKeyFirst);
      return;
    }

    final payload = _backupKeyQr.encode(key);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cloudQrTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: payload,
              version: QrVersions.auto,
              size: 260,
              gapless: true,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.cloudQrHint,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cloudClose),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBackupKeyQr() async {
    final l10n = AppLocalizations.of(context);

    final scannedValue = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const BackupKeyScannerScreen(),
      ),
    );

    if (!mounted || scannedValue == null) return;

    try {
      final normalizedKey = _backupKeyQr.decode(scannedValue);
      final hasExistingKey = await ConfigService.hasBackupKey();

      if (!mounted) return;

      if (hasExistingKey) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.cloudReplaceKeyTitle),
            content: Text(l10n.cloudReplaceKeyWarning),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(true),
                child: Text(l10n.cloudReplace),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      }

      await _keys.saveBackupEncryptionKey(normalizedKey);

      if (!mounted) return;

      setState(() => _hasBackupKey = true);
      _showSnack(l10n.cloudKeyImported);
    } on BackupKeyQrException catch (error) {
      _showSnack(l10n.cloudKeyImportError(error.message));
    } catch (error) {
      _showSnack(l10n.cloudKeyImportError(error.toString()));
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cloudSettingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCloudStatusCard(),
          const SizedBox(height: 12),
          if (!_isConnected)
            _buildLoginForm()
          else
            _buildConnectedControls(),
        ],
      ),
    );
  }

  Widget _buildCloudStatusCard() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _isConnected ? Colors.green : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${l10n.cloudStatusLabel}: '
                        '${_isConnected ? l10n.cloudStatusConnected : l10n.cloudStatusDisconnected}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (_isConnected && _login != null) ...[
              const SizedBox(height: 8),
              Text(l10n.cloudLoginValue(_login!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cloudConnectSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),

            // Единственное поле логина
            TextField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: l10n.cloudLogin,
                hintText: l10n.cloudLoginHint,
                prefixIcon: const Icon(Icons.person),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // Единственное поле пароля; глазик встроен в его декорацию
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.cloudAppPassword,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  tooltip: _obscurePassword
                      ? l10n.cloudPasswordShow
                      : l10n.cloudPasswordHide,
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              keyboardType: TextInputType.visiblePassword,
              onSubmitted: (_) {
                if (!_isConnecting) {
                  _connect();
                }
              },
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.cloudPasswordHelp,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isConnecting ? null : _connect,
                icon: _isConnecting
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.link),
                label: Text(
                  _isConnecting
                      ? l10n.cloudConnecting
                      : l10n.cloudConnect,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedControls() {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _buildBackupKeyCard(),
        const SizedBox(height: 12),
        _buildBackupManagementCard(),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.link_off,
              color: Colors.red,
            ),
            title: Text(l10n.cloudDisconnect),
            subtitle: Text(l10n.cloudDisconnectSubtitle),
            onTap: _disconnect,
          ),
        ),
      ],
    );
  }

  Widget _buildBackupKeyCard() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cloudBackupKeyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _hasBackupKey ? Icons.key : Icons.key_off,
                color: _hasBackupKey ? Colors.green : Colors.orange,
              ),
              title: Text(
                _hasBackupKey
                    ? l10n.cloudKeyCreated
                    : l10n.cloudKeyMissing,
              ),
              subtitle: Text(
                _hasBackupKey
                    ? l10n.cloudKeyReadySubtitle
                    : l10n.cloudKeyMissingSubtitle,
              ),
              trailing: _isGeneratingBackupKey
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.chevron_right),
              onTap: _isGeneratingBackupKey
                  ? null
                  : _generateBackupKey,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _hasBackupKey ? _showBackupKeyQr : null,
                icon: const Icon(Icons.qr_code),
                label: Text(l10n.cloudShowQr),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _scanBackupKeyQr,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.cloudScanQr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupManagementCard() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cloudBackupManagementTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.upload,
                color: Colors.blue,
              ),
              title: Text(l10n.cloudUploadBackup),
              subtitle: Text(
                _hasBackupKey
                    ? l10n.cloudUploadBackupSubtitle
                    : l10n.cloudGenerateKeyFirst,
              ),
              trailing: _isUploading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.chevron_right),
              onTap: _isUploading ? null : _uploadBackup,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.download,
                color: Colors.green,
              ),
              title: Text(l10n.cloudDownloadBackup),
              subtitle: Text(
                _hasBackupKey
                    ? l10n.cloudDownloadBackupSubtitle
                    : l10n.cloudImportKeyFirst,
              ),
              trailing: _isDownloading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.chevron_right),
              onTap: _isDownloading ? null : _downloadBackup,
            ),
            if (_lastSync != null) ...[
              const Divider(),
              Text(
                l10n.cloudLastSync(_lastSync!),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}