import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class PracticeHeader extends StatelessWidget implements PreferredSizeWidget {
  const PracticeHeader({
    super.key,
    this.onLongerDialogues,
    this.onSavePractice,
    this.onSavedPractice,
    this.onTranslationLanguage,
    this.showTranslationLanguage = false,
    this.isSaved = false,
    this.playbackSpeed = 1.0,
    this.onCycleSpeed,
  });
  final VoidCallback? onLongerDialogues;
  final VoidCallback? onSavePractice;
  final VoidCallback? onSavedPractice;
  final VoidCallback? onTranslationLanguage;

  /// Capability controls visibility; temporary busy states only disable it.
  final bool showTranslationLanguage;
  final bool isSaved;
  final double playbackSpeed;
  final VoidCallback? onCycleSpeed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    key: const ValueKey('practice-header-bar'),
    automaticallyImplyLeading: false,
    titleSpacing: 16,
    title: LayoutBuilder(
      builder: (context, constraints) {
        final l = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final speedLabel = playbackSpeed == playbackSpeed.roundToDouble()
            ? playbackSpeed.toInt().toString()
            : playbackSpeed.toString();
        const buttonSize = 48.0;
        final titleStyle =
            theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge;
        final title = Text(
          'Bantera App',
          key: const ValueKey('practice-title'),
          textAlign: TextAlign.center,
          style: titleStyle,
        );
        return SizedBox(
          height: buttonSize,
          child: Row(
            children: [
              const SizedBox(width: buttonSize * 2),
              Expanded(
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: title),
                ),
              ),
              SizedBox.square(
                dimension: buttonSize,
                child: TextButton(
                  key: const ValueKey('practice-playback-speed'),
                  onPressed: onCycleSpeed,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 48),
                  ),
                  child: Tooltip(
                    message: l.quickPlaybackSpeed(speedLabel),
                    child: Container(
                      width: 48,
                      height: 30,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: .06),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .35,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('$speedLabel×'),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: PopupMenuButton<String>(
                  key: const ValueKey('practice-more-menu'),
                  enabled:
                      onLongerDialogues != null ||
                      onSavedPractice != null ||
                      onTranslationLanguage != null,
                  tooltip: l.more,
                  icon: const Icon(Icons.more_horiz),
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'save':
                        onSavePractice?.call();
                      case 'saved':
                        onSavedPractice?.call();
                      case 'dialogues':
                        onLongerDialogues?.call();
                      case 'translation':
                        onTranslationLanguage?.call();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'save',
                      enabled: onSavePractice != null,
                      child: _menuLabel(
                        isSaved
                            ? Icons.bookmark_remove_outlined
                            : Icons.bookmark_add_outlined,
                        isSaved ? l.quickUnsave : l.quickSave,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'saved',
                      enabled: onSavedPractice != null,
                      child: _menuLabel(Icons.bookmarks_outlined, l.quickSaved),
                    ),
                    PopupMenuItem(
                      value: 'dialogues',
                      enabled: onLongerDialogues != null,
                      child: _menuLabel(
                        Icons.forum_outlined,
                        l.longerDialogues,
                      ),
                    ),
                    if (showTranslationLanguage ||
                        onTranslationLanguage != null)
                      PopupMenuItem(
                        value: 'translation',
                        enabled: onTranslationLanguage != null,
                        child: _menuLabel(
                          Icons.translate,
                          l.quickTranslationLanguageLabel,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget _menuLabel(IconData icon, String label) => Row(
    children: [
      Icon(icon, size: 22),
      const SizedBox(width: 12),
      Flexible(child: Text(label)),
    ],
  );
}
