/// Экран меню с адаптивной сеткой плиток.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../application/state/theme_provider.dart';
import '../../application/state/nvr_provider.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final nvrSettings = ref.watch(nvrSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Меню'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width > 600 ? 4 : (width > 400 ? 3 : 2);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                // ============================================================
                // 📱 ОСНОВНЫЕ
                // ============================================================
                _buildTile(
                  icon: Icons.devices,
                  label: 'Устройства',
                  color: Colors.blue,
                  onTap: () => context.go('/'),
                ),
                _buildTile(
                  icon: Icons.bolt,
                  label: 'Энергия',
                  color: Colors.amber,
                  onTap: () => context.push('/energy'),
                ),
                _buildTile(
                  icon: Icons.movie,
                  label: 'Сцены',
                  color: Colors.purple,
                  onTap: () => context.push('/scenes'),
                ),

                // ============================================================
                // 🔍 СКАНЕР
                // ============================================================
                _buildTile(
                  icon: Icons.search,
                  label: 'Сканировать',
                  color: Colors.teal,
                  onTap: () => context.push('/scan'),
                ),

                // ============================================================
                // 🎨 ТЕМА
                // ============================================================
                _buildTile(
                  icon: themeNotifier.themeIcon,
                  label: 'Тема: ${themeNotifier.themeName}',
                  color: isDark ? Colors.indigo : Colors.orange,
                  onTap: () => themeNotifier.toggle(),
                ),

                // ============================================================
                // 🏠 УПРАВЛЕНИЕ
                // ============================================================
                _buildTile(
                  icon: Icons.meeting_room,
                  label: 'Комнаты',
                  color: Colors.brown,
                  onTap: () => context.push('/rooms'),
                ),
                _buildTile(
                  icon: Icons.bar_chart,
                  label: 'Статистика',
                  color: Colors.green,
                  onTap: () => context.push('/statistics'),
                ),
                _buildTile(
                  icon: Icons.timer,
                  label: 'Таймеры',
                  color: Colors.deepOrange,
                  onTap: () => context.push('/timers'),
                ),
                _buildTile(
                  icon: Icons.notifications,
                  label: 'События',
                  color: Colors.red,
                  onTap: () => context.push('/events'),
                ),

                // ============================================================
                // 🎥 ВИДЕО (НОВОЕ!)
                // ============================================================
                _buildTile(
                  icon: Icons.security,
                  label: 'Видео NVR',
                  color: Colors.red,
                  onTap: () async {
                    final url = 'http://${nvrSettings.host}:${nvrSettings.port}';
                    try {
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('❌ Не удалось открыть LegionNVR')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Ошибка: $e')),
                      );
                    }
                  },
                ),

                // ============================================================
                // ☁️ ОБЛАКО
                // ============================================================
                _buildTile(
                  icon: Icons.cloud,
                  label: 'Облако',
                  color: Colors.lightBlue,
                  onTap: () => context.push('/cloud'),
                ),

                // ============================================================
                // ⚙️ НАСТРОЙКИ
                // ============================================================
                _buildTile(
                  icon: Icons.settings,
                  label: 'Настройки',
                  color: Colors.grey,
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}