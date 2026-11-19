/// Экран юридических документов.
library;

import 'package:flutter/material.dart';

import 'package:shome/l10n/generated/app_localizations.dart';

import 'changelog_screen.dart';
import 'eula_screen.dart';
import 'legal_documents.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.legalInfoTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
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
                  l10n.legalDeveloperLabel(LegalDocuments.developer),
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  l10n.legalOwnerLabel(LegalDocuments.owner),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.legalVersionLabel(LegalDocuments.fullVersion),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          _buildDocumentTile(
            context,
            icon: Icons.description,
            title: l10n.legalEulaTitle,
            subtitle: l10n.legalEulaSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const EulaScreen(),
              ),
            ),
          ),
          _buildDocumentTile(
            context,
            icon: Icons.privacy_tip,
            title: l10n.legalPrivacyTitle,
            subtitle: l10n.legalPrivacySubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const PrivacyPolicyScreen(),
              ),
            ),
          ),
          _buildDocumentTile(
            context,
            icon: Icons.rule,
            title: l10n.legalTermsTitle,
            subtitle: l10n.legalTermsSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const TermsScreen(),
              ),
            ),
          ),
          _buildDocumentTile(
            context,
            icon: Icons.copyright,
            title: l10n.legalOpenSourceTitle,
            subtitle: l10n.legalOpenSourceSubtitle,
            onTap: () => showLicensePage(
              context: context,
              applicationName: LegalDocuments.appName,
              applicationVersion: LegalDocuments.fullVersion,
              applicationLegalese: LegalDocuments.copyright,
            ),
          ),
          _buildDocumentTile(
            context,
            icon: Icons.history,
            title: l10n.legalChangelogTitle,
            subtitle: l10n.legalChangelogSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ChangelogScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${LegalDocuments.copyright}\n'
                  '${LegalDocuments.developer}\n'
                  '${l10n.legalVersionFooter(LegalDocuments.fullVersion)}',
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
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}