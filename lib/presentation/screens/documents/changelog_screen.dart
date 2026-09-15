import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История изменений'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('CHANGELOG.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Не удалось загрузить историю изменений'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              snapshot.data ?? '',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          );
        },
      ),
    );
  }
}