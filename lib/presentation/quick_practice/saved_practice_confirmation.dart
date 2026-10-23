import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

Future<bool> confirmSavedPracticeRemoval(
  BuildContext context, {
  String? cue,
}) async {
  final l = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(cue == null ? l.quickClearSavedTitle : l.quickUnsave),
          content: SingleChildScrollView(
            child: Text(cue ?? l.quickClearSavedBody),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            TextButton(
              key: const ValueKey('confirm-remove-saved-practice'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.deleteLabel),
            ),
          ],
        ),
      ) ??
      false;
}
