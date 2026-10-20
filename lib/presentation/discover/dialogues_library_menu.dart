import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../profile/practice_history_screen.dart';
import '../profile/saved_cues_screen.dart';
import '../profile/saved_screen.dart';

enum _LibraryDestination { history, media, cues }

class DialoguesLibraryMenu extends StatelessWidget {
  const DialoguesLibraryMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    PopupMenuItem<_LibraryDestination> item(
      _LibraryDestination destination,
      IconData icon,
      String label,
    ) => PopupMenuItem(
      value: destination,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Flexible(child: Text(label)),
        ],
      ),
    );

    return PopupMenuButton<_LibraryDestination>(
      key: const ValueKey('dialogues-library-menu'),
      icon: const Icon(Icons.more_horiz),
      tooltip: l.more,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      constraints: const BoxConstraints(minWidth: 224, maxWidth: 320),
      onOpened: () => FocusManager.instance.primaryFocus?.unfocus(),
      onSelected: (destination) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => switch (destination) {
            _LibraryDestination.history => const PracticeHistoryScreen(),
            _LibraryDestination.media => const SavedScreen(),
            _LibraryDestination.cues => const SavedCuesScreen(),
          },
        ),
      ),
      itemBuilder: (_) => [
        item(
          _LibraryDestination.history,
          Icons.history,
          l.practiceHistoryTitle,
        ),
        item(_LibraryDestination.media, Icons.bookmark_border, l.savedTitle),
        item(_LibraryDestination.cues, Icons.format_quote, l.savedCuesTitle),
      ],
    );
  }
}
