import 'package:flutter/material.dart';
import 'legal_documents.dart';
import 'eula_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

/// Экран юридических документов
class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Юридическая информация'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // Информация о приложении
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.home_work,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  LegalDocuments.appName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Разработчик: ${LegalDocuments.developer}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Собственник: ${LegalDocuments.owner}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Версия: ${LegalDocuments.fullVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Список документов
          _buildDocumentTile(
            context,
            icon: Icons.description,
            title: 'Лицензионное соглашение (EULA)',
            subtitle: 'Правила использования приложения',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EulaScreen()),
            ),
          ),
          _buildDocumentTile(
            context,
            icon: Icons.privacy_tip,
            title: 'Политика конфиденциальности',
            subtitle: 'Как мы обрабатываем ваши данные',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          _buildDocumentTile(
            context,
            icon: Icons.rule,
            title: 'Условия использования',
            subtitle: 'Правила и ограничения',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
          ),
          _buildDocumentTile(
            context,
            icon: Icons.copyright,
            title: 'Лицензии открытого ПО',
            subtitle: 'Сторонние библиотеки',
            onTap: () => showLicensePage(
              context: context,
              applicationName: LegalDocuments.appName,
              applicationVersion: LegalDocuments.fullVersion,
              applicationLegalese: LegalDocuments.copyright,
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              '${LegalDocuments.copyright}\n${LegalDocuments.developer}\nВерсия ${LegalDocuments.fullVersion}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}