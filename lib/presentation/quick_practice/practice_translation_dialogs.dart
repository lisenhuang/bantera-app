import 'package:flutter/material.dart';
import '../../infrastructure/translation_service.dart';
import '../../l10n/app_localizations.dart';

class PracticeTranslationLanguageSheet extends StatefulWidget {
  const PracticeTranslationLanguageSheet({super.key, required this.options});
  final List<TranslationLocaleOption> options;
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
                  Text(l.quickTranslationFallbackBody),
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
                  key: ValueKey(
                    'practice-translation-language-${option.identifier}',
                  ),
                  title: Text(option.displayName),
                  subtitle: Text(
                    option.isInstalled
                        ? l.practiceTranslationInstalled
                        : l.practiceTranslationDownload,
                  ),
                  trailing: Icon(
                    option.isInstalled
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
