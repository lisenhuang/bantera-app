import '../shared/language_code_label.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../shared/learning_language_label.dart';
import '../shared/locale_flag.dart';

class PracticeHeader extends StatelessWidget implements PreferredSizeWidget {
  const PracticeHeader({
    super.key,
    this.onLongerDialogues,
    this.showLongerDialogues = true,
    this.onSavePractice,
    this.onSavedPractice,
    this.onTranslationLanguage,
    this.showAdminDelete = false,
    this.onAdminDelete,
    this.showTranslationLanguage = false,
    this.isSaved = false,
    this.playbackSpeed = 1.0,
    this.onSpeedSelected,
    this.learningLocale,
    this.levelMenu,
  });
  final String? learningLocale;
  final Widget? levelMenu;
  final VoidCallback? onLongerDialogues;
  final bool showLongerDialogues;
  final VoidCallback? onSavePractice;
  final VoidCallback? onSavedPractice;
  final VoidCallback? onTranslationLanguage;
  final bool showAdminDelete;
  final VoidCallback? onAdminDelete;

  /// Capability controls visibility; temporary busy states only disable it.
  final bool showTranslationLanguage;
  final bool isSaved;
  static const speeds = [0.5, 0.75, 1.0, 1.25, 1.5];
  final double playbackSpeed;
  final ValueChanged<double>? onSpeedSelected;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final speedLabel = playbackSpeed == playbackSpeed.roundToDouble()
        ? playbackSpeed.toInt().toString()
        : playbackSpeed.toString();
    const buttonSize = 48.0;
    return AppBar(
      key: const ValueKey('practice-header-bar'),
      automaticallyImplyLeading: false,
      centerTitle: true,
      titleSpacing: 8,
      leadingWidth: levelMenu == null ? buttonSize * 2 : 144,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: levelMenu != null
            ? Align(alignment: Alignment.centerLeft, child: levelMenu)
            : learningLocale == null || learningLocale!.isEmpty
            ? null
            : Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message: learningLanguageLabel(learningLocale).name,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      key: const ValueKey('practice-language-label'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          flagEmojiForLocale(learningLocale!),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          languageCodeLabel(learningLocale!),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      title: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Bantera',
          key: ValueKey('practice-title'),
        ),
      ),
      actions: [
        SizedBox.square(
          dimension: buttonSize,
          child: MenuAnchor(
            consumeOutsideTap: true,
            style: MenuStyle(
              minimumSize: const WidgetStatePropertyAll(Size(150, 0)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            menuChildren: [
              for (final speed in speeds)
                Semantics(
                  selected: speed == playbackSpeed,
                  child: MenuItemButton(
                    key: ValueKey('practice-speed-$speed'),
                    onPressed: onSpeedSelected == null
                        ? null
                        : () => onSpeedSelected!(speed),
                    leadingIcon: speed == playbackSpeed
                        ? const Icon(
                            Icons.check,
                            key: ValueKey('practice-speed-selected'),
                          )
                        : const SizedBox(width: 24),
                    child: Text(
                      '${speed == speed.roundToDouble() ? speed.toInt() : speed}×',
                    ),
                  ),
                ),
            ],
            builder: (context, controller, child) => Tooltip(
              message: l.quickPlaybackSpeed(speedLabel),
              child: TextButton(
                key: const ValueKey('practice-playback-speed'),
                onPressed: onSpeedSelected == null
                    ? null
                    : () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                ),
                child: child!,
              ),
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .06),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: .35),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$speedLabel×',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: onSpeedSelected == null
                          ? theme.colorScheme.onSurface.withValues(alpha: .38)
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        PopupMenuButton<String>(
          key: const ValueKey('practice-more-menu'),
          enabled:
              onLongerDialogues != null ||
              onSavedPractice != null ||
              onTranslationLanguage != null ||
              showAdminDelete,
          tooltip: l.more,
          icon: const Icon(Icons.more_vert),
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
              case 'admin-delete':
                onAdminDelete?.call();
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
            if (showLongerDialogues)
              PopupMenuItem(
                value: 'dialogues',
                enabled: onLongerDialogues != null,
                child: _menuLabel(Icons.forum_outlined, l.longerDialogues),
              ),
            if (showAdminDelete)
              PopupMenuItem(
                value: 'admin-delete',
                enabled: onAdminDelete != null,
                child: _menuLabel(
                  Icons.admin_panel_settings_outlined,
                  l.adminDeletePractice,
                ),
              ),
            if (showTranslationLanguage || onTranslationLanguage != null)
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
      ],
    );
  }

  Widget _menuLabel(IconData icon, String label) => Row(
    children: [
      Icon(icon, size: 22),
      const SizedBox(width: 12),
      Flexible(child: Text(label)),
    ],
  );
}
