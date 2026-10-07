import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../infrastructure/ai/ai_history_store.dart';
import '../../../infrastructure/ai/ai_web_search.dart';
import '../../../l10n/app_localizations.dart';

class AiSearchSources extends StatelessWidget {
  const AiSearchSources({super.key, required this.message});
  final AiMessage message;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final searching = message.webSearchStatus == 'searching';
    final unavailable = message.webSearchStatus == 'unavailable';
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (searching)
                const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  unavailable ? Icons.search_off : Icons.travel_explore,
                  size: 18,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  searching
                      ? l.aiWebSearching
                      : unavailable
                      ? l.aiWebUnavailable
                      : l.aiWebSources,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
          if (message.webSearchQuery?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                message.webSearchQuery!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          for (final source in message.sources)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final uri = AiWebSource.safeUrl(source.url);
                    if (uri == null) return;
                    try {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {
                      /* The source remains visible if the browser is unavailable. */
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                source.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge,
                              ),
                              Text(
                                Uri.parse(source.url).host,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.open_in_new, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (message.sources.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('DuckDuckGo', style: theme.textTheme.labelSmall),
            ),
        ],
      ),
    );
  }
}
