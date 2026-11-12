import 'package:flutter/material.dart';
import 'legal_documents.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Условия использования'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          LegalDocuments.termsOfService,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}