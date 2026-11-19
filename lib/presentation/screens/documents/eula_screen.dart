import 'package:flutter/material.dart';

import 'legal_documents.dart';
import 'package:shome/l10n/generated/app_localizations.dart';

class EulaScreen extends StatelessWidget {
  const EulaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eulaTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
            LegalDocuments.eulaFor(Localizations.localeOf(context)),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}