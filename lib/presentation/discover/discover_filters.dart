import 'package:flutter/material.dart';

import '../../infrastructure/transcription_locale_option.dart';
import '../shared/audio_level_selector.dart';
import '../shared/locale_flag.dart';

const _variantLanguageCodes = {'en', 'fr', 'de', 'it', 'pt', 'es'};

String? discoverVariantLanguageCode(String learningLanguage) {
  final primary = primaryLanguageCodeForLocaleIdentifier(learningLanguage);
  return _variantLanguageCodes.contains(primary) ? primary : null;
}

String discoverAccentLanguageCode(String learningLanguage, bool allAccents) =>
    allAccents
    ? discoverVariantLanguageCode(learningLanguage) ?? learningLanguage.trim()
    : learningLanguage.trim();

String discoverAccentLabel(String learningLanguage, bool allAccents) =>
    discoverAccentLanguageCode(learningLanguage, allAccents);

/// Accent and level share one row; only accents with alternatives are pickers.
class DiscoverFilters extends StatelessWidget {
  const DiscoverFilters({
    super.key,
    required this.learningLanguage,
    required this.allAccents,
    required this.onAccentChanged,
  });

  final String learningLanguage;
  final bool allAccents;
  final ValueChanged<bool> onAccentChanged;

  bool get _canSelectAccent =>
      discoverVariantLanguageCode(learningLanguage) != null;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _canSelectAccent
            ? OutlinedButton.icon(
                key: const Key('discover-accent-selector'),
                onPressed: () => _selectAccent(context),
                icon: Text(
                  allAccents ? '🌐' : flagEmojiForLocale(learningLanguage),
                  style: const TextStyle(fontSize: 18),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        discoverAccentLabel(learningLanguage, allAccents),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              )
            : Container(
                key: const Key('discover-accent-selector'),
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      flagEmojiForLocale(learningLanguage),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        discoverAccentLabel(learningLanguage, false),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
      ),
      const SizedBox(width: 8),
      const Expanded(child: AudioLevelSelector(allowAll: true)),
    ],
  );

  Future<void> _selectAccent(BuildContext context) async {
    if (!_canSelectAccent) return;
    final canSelectAll = discoverVariantLanguageCode(learningLanguage) != null;
    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Text(
                  flagEmojiForLocale(learningLanguage),
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(discoverAccentLabel(learningLanguage, false)),
                selected: !allAccents,
                trailing: !allAccents ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, false),
              ),
              if (canSelectAll)
                ListTile(
                  leading: const Text('🌐', style: TextStyle(fontSize: 22)),
                  title: Text(discoverAccentLabel(learningLanguage, true)),
                  selected: allAccents,
                  trailing: allAccents ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, true),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
    if (context.mounted && result != null && result != allAccents) {
      onAccentChanged(result);
    }
  }
}
