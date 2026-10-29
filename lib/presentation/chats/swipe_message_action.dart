import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../shared/swipe_action_reveal.dart';

/// Reveals explicit actions without dismissing a message or changing its style.
class SwipeMessageAction extends StatelessWidget {
  const SwipeMessageAction({
    super.key,
    required this.child,
    this.onDelete,
    this.onSave,
    this.isSaved = false,
    this.adminAction = false,
  });
  final Widget child;
  final Future<void> Function()? onDelete, onSave;
  final bool isSaved, adminAction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SwipeActionReveal(
        actions: [
          if (onSave != null)
            SwipeRevealAction(
              label: isSaved ? l.aiUnsaveDialogue : l.aiSaveDialogue,
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
              onPressed: onSave!,
              backgroundColor: c.primaryContainer,
              foregroundColor: c.onPrimaryContainer,
            ),
          if (onDelete != null)
            SwipeRevealAction(
              label: l.deleteLabel,
              icon: adminAction
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: Stack(
                        children: [
                          Center(child: Icon(Icons.delete_outline)),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Icon(Icons.delete_outline),
              onPressed: onDelete!,
              backgroundColor: c.errorContainer,
              foregroundColor: c.onErrorContainer,
            ),
        ],
        child: child,
      ),
    );
  }
}
