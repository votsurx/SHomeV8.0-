import 'package:flutter/material.dart';
import 'package:shome/l10n/generated/app_localizations.dart';

import 'legal_documents.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.legalTermsTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          LegalDocuments.termsOfServiceFor(locale),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}