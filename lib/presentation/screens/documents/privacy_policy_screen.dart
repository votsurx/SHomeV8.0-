import 'package:flutter/material.dart';
import 'legal_documents.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Политика конфиденциальности'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          LegalDocuments.privacyPolicy,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}