import 'package:flutter/material.dart';
import '../../data/local/secure_storage/encrypted_keys.dart';
import '../../data/services/mailru_cloud_service.dart';
import '../../data/services/config_service.dart';

class CloudSettingsScreen extends StatefulWidget {
  const CloudSettingsScreen({super.key});

  @override
  State<CloudSettingsScreen> createState() => _CloudSettingsScreenState();
}

class _CloudSettingsScreenState extends State<CloudSettingsScreen> {
  final _keys = EncryptedKeys();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isUploading = false;
  bool _isDownloading = false;
  bool _autoSync = false;
  String? _login;
  String? _lastSync;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final login = await _keys.getCloudLogin();
    final password = await _keys.getCloudPassword();
    final autoSync = await _keys.getCloudAutoSync();

    if (login != null && password != null) {
      if (!mounted) return;
      setState(() {
        _isConnected = true;
        _login = login;
        _autoSync = autoSync ?? false;
      });
      _loadLastSync();
    }
  }

  Future<void> _loadLastSync() async {
    final lastSync = await _keys.getCloudLastSync();
    if (mounted) setState(() => _lastSync = lastSync);
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
      final service = MailruCloudService(login: login, password: password);
      final success = await service.testConnection();
      if (!mounted) return;

      if (success) {
        await _keys.saveCloudLogin(login);
        await _keys.saveCloudPassword(password);
        await _keys.saveCloudAutoSync(false);

        if (!mounted) return;
        setState(() {
          _isConnected = true;
          _login = login;
          _autoSync = false;
        });
        _showSnack('✅ Подключено к облаку');
      } else {
        _showSnack('❌ Не удалось подключиться. Проверьте логин и пароль.');
      }
    } catch (e) {
      if (mounted) _showSnack('❌ Ошибка: $e');
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnect() async {
    await _keys.deleteCloudLogin();
    await _keys.deleteCloudPassword();
    await _keys.deleteCloudAutoSync();
    await _keys.deleteCloudLastSync();

    if (!mounted) return;
    setState(() {
      _isConnected = false;
      _login = null;
      _autoSync = false;
      _lastSync = null;
    });
    _showSnack('🔌 Отключено от облака');
  }

  Future<void> _toggleAutoSync(bool value) async {
    await _keys.saveCloudAutoSync(value);
    setState(() => _autoSync = value);
  }

  Future<void> _uploadBackup() async {
    setState(() => _isUploading = true);

    try {
      final login = await _keys.getCloudLogin();
      final password = await _keys.getCloudPassword();
      if (login == null || password == null) {
        _showSnack('❌ Нет данных для входа');
        return;
      }

      final service = MailruCloudService(login: login, password: password);
      final json = await ConfigService.buildConfigJson();
      final encrypted = ConfigService.encrypt(json);
      final success = await service.uploadBackup(encrypted);
      if (!mounted) return;

      if (success) {
        final now = DateTime.now();
        final dateStr = '${now.day}.${now.month}.${now.year} ${now.hour}:${now.minute}';
        await _keys.saveCloudLastSync(dateStr);
        if (!mounted) return;
        setState(() => _lastSync = dateStr);
        _showSnack('✅ Бекап загружен в облако');
      } else {
        _showSnack('❌ Ошибка загрузки');
      }
    } catch (e) {
      if (mounted) _showSnack('❌ Ошибка: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _downloadBackup() async {
    setState(() => _isDownloading = true);

    try {
      final login = await _keys.getCloudLogin();
      final password = await _keys.getCloudPassword();
      if (login == null || password == null) {
        _showSnack('❌ Нет данных для входа');
        return;
      }

      final service = MailruCloudService(login: login, password: password);
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
          children: backups.map((b) => SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, b),
            child: Text(b),
          )).toList(),
        ),
      );

      if (selected == null) return;

      final encrypted = await service.downloadBackup(selected);
      if (!mounted) return;

      if (encrypted != null) {
        String json;
        try {
          json = ConfigService.decrypt(encrypted);
        } catch (_) {
          json = encrypted;
        }
        await ConfigService.restoreFromJson(json);
        if (!mounted) return;
        _showSnack('✅ Бекап "$selected" восстановлен. Перезапустите приложение.');
      } else {
        _showSnack('❌ Ошибка скачивания');
      }
    } catch (e) {
      if (mounted) _showSnack('❌ Ошибка: $e');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... UI остаётся как было
    return Scaffold(
      appBar: AppBar(
        title: const Text('☁️ Облачное хранилище'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
                      Text(
                        'Статус: ${_isConnected ? "✅ Подключено" : "⚪ Не подключено"}',
                        style: Theme.of(context).textTheme.titleMedium,
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
          ),
          const SizedBox(height: 12),
          if (!_isConnected) _buildLoginForm() else _buildConnectedControls(),
        ],
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
            Text('🔗 Подключение', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Логин',
                hintText: 'login@mail.ru',
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль приложения',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
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
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.link),
                label: Text(_isConnecting ? 'Подключение...' : 'Подключить'),
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
        Card(
          child: ListTile(
            leading: const Icon(Icons.link_off, color: Colors.red),
            title: const Text('Отключить'),
            onTap: _disconnect,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔄 Автосинхронизация', style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                SwitchListTile(
                  title: const Text('Автосинхронизация бекапов'),
                  subtitle: const Text('Загружать бекап в облако при сворачивании приложения'),
                  value: _autoSync,
                  onChanged: _toggleAutoSync,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📋 Управление бекапами', style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.upload, color: Colors.blue),
                  title: const Text('Загрузить в облако'),
                  subtitle: const Text('Сохранить текущий бекап в облако'),
                  trailing: _isUploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right),
                  onTap: _isUploading ? null : _uploadBackup,
                ),
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.green),
                  title: const Text('Скачать из облака'),
                  subtitle: const Text('Восстановить бекап из облака'),
                  trailing: _isDownloading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right),
                  onTap: _isDownloading ? null : _downloadBackup,
                ),
                if (_lastSync != null) ...[
                  const Divider(),
                  Text(
                    'Последняя синхронизация: $_lastSync',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}