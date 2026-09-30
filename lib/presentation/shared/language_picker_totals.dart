import 'package:flutter/material.dart';

import '../../infrastructure/audio_language_groups.dart';
import '../../infrastructure/transcription_locale_option.dart';
import '../../l10n/app_localizations.dart';

class LanguagePickerTotals extends StatelessWidget {
  const LanguagePickerTotals({super.key, required this.identifiers});

  final Iterable<String> identifiers;

  @override
  Widget build(BuildContext context) {
    final accents = identifiers
        .map(normalizeLocaleIdentifierForLookup)
        .where((code) => code.isNotEmpty)
        .toSet();
    final languages = accents.map((code) {
      final group = audioLanguageGroupCode(code);
      // Mainland and Taiwan are accents of Mandarin; Cantonese stays distinct.
      return group == 'zh-tw' ? 'zh-cn' : group;
    }).toSet();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            AppLocalizations.of(
              context,
            )!.languagePickerTotals(languages.length, accents.length),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
