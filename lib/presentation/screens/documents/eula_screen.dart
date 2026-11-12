import 'package:flutter/material.dart';
import 'legal_documents.dart';

class EulaScreen extends StatelessWidget {
  const EulaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лицензионное соглашение'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          LegalDocuments.eula,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}