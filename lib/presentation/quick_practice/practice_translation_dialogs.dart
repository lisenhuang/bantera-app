import 'package:flutter/material.dart';
import '../../infrastructure/translation_service.dart';
import '../../l10n/app_localizations.dart';
import '../shared/locale_flag.dart';

class PracticeTranslationLanguageSheet extends StatefulWidget {
  const PracticeTranslationLanguageSheet({
    super.key,
    required this.options,
    this.fallback = true,
    this.selectedLocale,
  });
  final List<TranslationLocaleOption> options;
  final bool fallback;
  final String? selectedLocale;
  @override
  State<PracticeTranslationLanguageSheet> createState() =>
      _LanguageSheetState();
}

class _LanguageSheetState extends State<PracticeTranslationLanguageSheet> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final matches = widget.options
        .where(
          (option) => '${option.displayName} ${option.identifier}'
              .toLowerCase()
              .contains(query),
        )
        .toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.practiceChooseTranslationLanguageTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: l.cancel,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    widget.fallback
                        ? l.quickTranslationFallbackBody
                        : l.quickTranslationLanguageBody,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l.practiceSearchLanguagesHint,
                    ),
                    onChanged: (value) =>
                        setState(() => query = value.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SliverList.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final option = matches[index];
                return ListTile(
                  selected: option.identifier == widget.selectedLocale,
                  key: ValueKey(
                    'practice-translation-language-${option.identifier}',
                  ),
                  leading: ExcludeSemantics(
                    child: Text(
                      _translationLanguageFlag(option.identifier),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  title: Text(option.displayName),
                  subtitle: Text(
                    option.isInstalled
                        ? l.practiceTranslationInstalled
                        : l.practiceTranslationDownload,
                  ),
                  trailing: Icon(
                    option.identifier == widget.selectedLocale
                        ? Icons.check
                        : option.isInstalled
                        ? Icons.check_circle_outline
                        : Icons.download_outlined,
                  ),
                  onTap: () => Navigator.pop(context, option),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Regional locales can use their own flag. Broad languages such as English,
// Arabic use a globe. Unregionalized Simplified Mandarin represents mainland
// Chinese in this picker, even when the OS returns zh or zh-Hans instead of zh-CN.
String _translationLanguageFlag(String identifier) {
  final parts = identifier.toLowerCase().split(RegExp(r'[-_]'));
  final hasRegion = parts
      .skip(1)
      .any((part) => RegExp(r'^[a-z]{2}$').hasMatch(part));
  if (!hasRegion && parts.first == 'zh' && !parts.contains('hant')) {
    return '🇨🇳';
  }
  const countryAssociatedLanguages = {
    'ja',
    'ko',
    'it',
    'pl',
    'th',
    'vi',
    'id',
    'tr',
    'uk',
    'sv',
    'nb',
    'da',
    'fi',
    'cs',
    'hu',
    'he',
    'sk',
    'hr',
    'bg',
  };
  if (hasRegion || countryAssociatedLanguages.contains(parts.first)) {
    return flagEmojiForLocale(identifier);
  }
  return '🌐';
}
