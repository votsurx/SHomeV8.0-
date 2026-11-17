import 'package:flutter/material.dart';

import '../../data/local/secure_storage/encrypted_keys.dart';
import '../../data/services/config_service.dart';
import '../../data/services/mailru_cloud_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/services/backup_key_qr_service.dart';
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
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      _showSnack('Введите логин и пароль');
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

        _showSnack('✅ Подключено к облаку');
      } else {
        _showSnack(
          '❌ Не удалось подключиться. Проверьте логин и пароль.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack('❌ Ошибка подключения: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _disconnect() async {
    await _keys.deleteCloudLogin();
    await _keys.deleteCloudPassword();
    await _keys.deleteCloudLastSync();

    if (!mounted) return;

    setState(() {
      _isConnected = false;
      _login = null;
      _lastSync = null;
    });

    _showSnack('🔌 Отключено от облака');
  }

  Future<void> _generateBackupKey() async {
    final alreadyExists = await ConfigService.hasBackupKey();

    if (!mounted) return;

    if (alreadyExists) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Сгенерировать новый ключ?'),
          content: const Text(
            'Новый ключ сделает все существующие резервные копии '
                'недоступными для восстановления.\n\n'
                'Продолжить?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Сгенерировать'),
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
      _showSnack('✅ Ключ резервного копирования создан');
    } catch (e) {
      if (mounted) {
        _showSnack('❌ Ошибка создания ключа: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingBackupKey = false);
      }
    }
  }

  Future<void> _uploadBackup() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final login = await _keys.getCloudLogin();
      final password = await _keys.getCloudPassword();

      if (login == null ||
          login.isEmpty ||
          password == null ||
          password.isEmpty) {
        _showSnack('❌ Нет данных для входа в облако');
        return;
      }

      final hasBackupKey = await ConfigService.hasBackupKey();

      if (!hasBackupKey) {
        _showSnack(
          '❌ Сначала сгенерируйте ключ резервного копирования',
        );
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
        _showSnack('✅ Бекап загружен в облако');
      } else {
        _showSnack('❌ Ошибка загрузки бекапа');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('❌ Ошибка загрузки: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _downloadBackup() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      final login = await _keys.getCloudLogin();
      final password = await _keys.getCloudPassword();

      if (login == null ||
          login.isEmpty ||
          password == null ||
          password.isEmpty) {
        _showSnack('❌ Нет данных для входа в облако');
        return;
      }

      final hasBackupKey = await ConfigService.hasBackupKey();

      if (!hasBackupKey) {
        _showSnack(
          '❌ Сначала сгенерируйте или импортируйте ключ '
              'резервного копирования',
        );
        return;
      }

      final service = MailruCloudService(
        login: login,
        password: password,
      );

      final backups = await service.listBackups();

      if (!mounted) return;

      if (backups.isEmpty) {
        _showSnack('ℹ️ В облаке нет бекапов');
        return;
      }

      final selected = await showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Выберите бекап'),
          children: backups
              .map(
                (backup) => SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(backup),
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
        _showSnack('❌ Ошибка скачивания бекапа');
        return;
      }

      final json = await ConfigService.decryptBackup(encrypted);

      await ConfigService.restoreFromJson(json);

      if (!mounted) return;

      _showSnack(
        '✅ Бекап "$selected" восстановлен. '
            'Перезапустите приложение.',
      );
    } catch (e) {
      if (mounted) {
        _showSnack('❌ Ошибка восстановления: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _showBackupKeyQr() async {
    final key = await ConfigService.getBackupKey();

    if (!mounted) return;

    if (key == null || key.isEmpty) {
      _showSnack(
        '❌ Сначала сгенерируйте ключ резервного копирования',
      );
      return;
    }

    final payload = _backupKeyQr.encode(key);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR-ключ резервного копирования'),
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
            const Text(
              'Отсканируйте этот QR-код на другом устройстве SHome.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBackupKeyQr() async {
    final scannedValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(
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
          builder: (ctx) => AlertDialog(
            title: const Text('Заменить ключ?'),
            content: const Text(
              'На устройстве уже есть ключ резервного копирования.\n\n'
                  'После замены старые бекапы, созданные текущим ключом, '
                  'станут недоступны.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Заменить'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      }

      await _keys.saveBackupEncryptionKey(normalizedKey);

      if (!mounted) return;

      setState(() => _hasBackupKey = true);

      _showSnack('✅ Ключ резервного копирования импортирован');
    } on BackupKeyQrException catch (e) {
      _showSnack('❌ ${e.message}');
    } catch (e) {
      _showSnack('❌ Ошибка импорта ключа: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('☁️ Облачное хранилище'),
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
                    'Статус: '
                        '${_isConnected ? "✅ Подключено" : "⚪ Не подключено"}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (_isConnected && _login != null) ...[
              const SizedBox(height: 8),
              Text('Логин: $_login'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔗 Подключение',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Логин',
                hintText: 'login@mail.ru',
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль приложения',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
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
              child: const Text(
                '💡 Как получить пароль приложения:\n'
                    '1. Mail.ru → Настройки → Безопасность\n'
                    '2. Пароли для приложений → Создать\n'
                    '3. Назовите «SHome» → скопируйте пароль',
                style: TextStyle(fontSize: 13),
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.link),
                label: Text(
                  _isConnecting ? 'Подключение...' : 'Подключить',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedControls() {
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
            title: const Text('Отключить'),
            subtitle: const Text(
              'Ключ резервного копирования останется на устройстве',
            ),
            onTap: _disconnect,
          ),
        ),
      ],
    );
  }

  Widget _buildBackupKeyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔐 Ключ резервного копирования',
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
                _hasBackupKey ? 'Ключ создан' : 'Ключ не создан',
              ),
              subtitle: Text(
                _hasBackupKey
                    ? 'AES-256-GCM готов к работе'
                    : 'Создайте или импортируйте ключ',
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
                label: const Text('Показать QR'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _scanBackupKeyQr,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Сканировать QR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupManagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 Управление бекапами',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.upload,
                color: Colors.blue,
              ),
              title: const Text('Загрузить в облако'),
              subtitle: Text(
                _hasBackupKey
                    ? 'Сохранить текущий бекап в облако'
                    : 'Сначала создайте ключ резервного копирования',
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
              title: const Text('Скачать из облака'),
              subtitle: Text(
                _hasBackupKey
                    ? 'Восстановить бекап из облака'
                    : 'Сначала создайте ключ резервного копирования',
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
                'Последняя синхронизация: $_lastSync',
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