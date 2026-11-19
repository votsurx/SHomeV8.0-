import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/services/language_preference.dart';
import '../../l10n/generated/app_localizations.dart';

class LanguageSelectorTile extends StatefulWidget {
  const LanguageSelectorTile({super.key});

  @override
  State<LanguageSelectorTile> createState() =>
      _LanguageSelectorTileState();
}

class _LanguageSelectorTileState extends State<LanguageSelectorTile> {
  @override
  void initState() {
    super.initState();
    unawaited(LanguagePreference.load());
  }

  String _languageLabel(
      AppLocalizations l10n,
      String languageCode,
      ) {
    switch (languageCode) {
      case LanguagePreference.russian:
        return l10n.languageRussian;
      case LanguagePreference.english:
        return l10n.languageEnglish;
      case LanguagePreference.system:
      default:
        return l10n.languageSystem;
    }
  }

  Future<void> _chooseLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext);

        return ValueListenableBuilder<String>(
          valueListenable: LanguagePreference.value,
          builder: (context, currentLanguage, _) {
            return SimpleDialog(
              title: Text(dialogL10n.languageTitle),
              children: [
                _languageOption(
                  dialogContext,
                  code: LanguagePreference.system,
                  currentLanguage: currentLanguage,
                  label: dialogL10n.languageSystem,
                ),
                _languageOption(
                  dialogContext,
                  code: LanguagePreference.russian,
                  currentLanguage: currentLanguage,
                  label: dialogL10n.languageRussian,
                ),
                _languageOption(
                  dialogContext,
                  code: LanguagePreference.english,
                  currentLanguage: currentLanguage,
                  label: dialogL10n.languageEnglish,
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || selected == null) return;

    await LanguagePreference.set(selected);

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.languageSelected(
            _languageLabel(l10n, selected),
          ),
        ),
      ),
    );
  }

  Widget _languageOption(
      BuildContext dialogContext, {
        required String code,
        required String currentLanguage,
        required String label,
      }) {
    final isSelected = currentLanguage == code;

    return SimpleDialogOption(
      onPressed: () => Navigator.of(dialogContext).pop(code),
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            size: 20,
            color: isSelected ? Colors.blue : null,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ValueListenableBuilder<String>(
        valueListenable: LanguagePreference.value,
        builder: (context, languageCode, _) {
          return ListTile(
            leading: const Icon(
              Icons.language,
              color: Colors.indigo,
            ),
            title: Text(l10n.languageTitle),
            subtitle: Text(
              l10n.languageSelected(
                _languageLabel(l10n, languageCode),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _chooseLanguage,
          );
        },
      ),
    );
  }
}