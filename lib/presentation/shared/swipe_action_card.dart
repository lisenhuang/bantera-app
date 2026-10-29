import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'swipe_action_reveal.dart';

/// A physical right-to-left swipe reveals an action; swiping never deletes.
class SwipeActionCard extends StatelessWidget {
  const SwipeActionCard({super.key, required this.child, this.onRemove});

  final Widget child;
  final FutureOr<void> Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SwipeActionReveal(
        surfaceColor: colors.surfaceContainerLow,
        actions: [
          if (onRemove != null)
            SwipeRevealAction(
              label: l.deleteLabel,
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove!,
              backgroundColor: colors.errorContainer,
              foregroundColor: colors.onErrorContainer,
            ),
        ],
        child: child,
      ),
    );
  }
}
