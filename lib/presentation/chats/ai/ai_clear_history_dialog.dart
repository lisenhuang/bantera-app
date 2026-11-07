import 'package:flutter/material.dart';
import '../../../infrastructure/ai/ai_history_store.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/storage_cache_screen.dart' show storageSize;

class AiHistoryClearChoice {
  const AiHistoryClearChoice(this.mode, this.keepSummary);
  final AiHistoryClearMode mode;
  final bool keepSummary;
}

class AiClearHistoryDialog extends StatefulWidget {
  const AiClearHistoryDialog({super.key, required this.usage});
  final Future<AiHistoryStorageUsage> usage;
  @override
  State<AiClearHistoryDialog> createState() => _AiClearHistoryDialogState();
}

class _AiClearHistoryDialogState extends State<AiClearHistoryDialog> {
  AiHistoryClearMode? _mode;
  bool _keepSummary = true;
  bool _confirming = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_confirming) {
      final audioOnly = _mode == AiHistoryClearMode.audioOnly;
      final confirmation = audioOnly
          ? l.aiClearConfirmAudioOnly
          : _keepSummary
          ? l.aiClearConfirmKeepSummary
          : l.aiClearConfirmRemoveSummary;
      return AlertDialog(
        title: Text(l.confirmDeletionTitle),
        scrollable: true,
        content: Text('$confirmation\n\n${l.aiClearNotice}'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _confirming = false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(
              context,
              AiHistoryClearChoice(_mode!, audioOnly || _keepSummary),
            ),
            child: Text(l.aiClearHistory),
          ),
        ],
      );
    }
    return FutureBuilder<AiHistoryStorageUsage>(
      future: widget.usage,
      builder: (context, snapshot) {
        final usage = snapshot.data;
        return AlertDialog(
          title: Text(l.aiClearHistory),
          scrollable: true,
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.aiClearNotice),
                const SizedBox(height: 12),
                if (snapshot.hasError) Text(l.onboardingLoadFailed),
                if (usage == null && !snapshot.hasError)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                RadioGroup<AiHistoryClearMode>(
                  groupValue: _mode,
                  onChanged: (value) => setState(() => _mode = value),
                  child: Column(
                    children: [
                      for (final mode in AiHistoryClearMode.values)
                        RadioListTile<AiHistoryClearMode>(
                          value: mode,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            mode == AiHistoryClearMode.audioOnly
                                ? l.aiClearAudioTitle
                                : l.aiClearAllTitle,
                          ),
                          subtitle: Text(
                            [
                              mode == AiHistoryClearMode.audioOnly
                                  ? l.aiClearAudioBody
                                  : l.aiClearAllBody,
                              if (usage != null)
                                l.aiClearFreed(
                                  storageSize(
                                    usage.reclaimable(
                                      mode,
                                      mode == AiHistoryClearMode.audioOnly ||
                                          _keepSummary,
                                    ),
                                  ),
                                ),
                            ].join('\n'),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_mode == AiHistoryClearMode.all) ...[
                  const Divider(),
                  CheckboxListTile(
                    value: usage?.hasSummary == true && _keepSummary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: usage?.hasSummary == true
                        ? (value) =>
                              setState(() => _keepSummary = value ?? false)
                        : null,
                    title: Text(l.aiKeepSummary),
                    subtitle: Text(
                      usage?.hasSummary == true
                          ? l.aiKeepSummaryBody
                          : l.aiNoSummary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: _mode == null || usage == null
                  ? null
                  : () => setState(() {
                      if (_mode == AiHistoryClearMode.all &&
                          !usage.hasSummary) {
                        _keepSummary = false;
                      }
                      _confirming = true;
                    }),
              child: Text(l.aiClearHistory),
            ),
          ],
        );
      },
    );
  }
}
