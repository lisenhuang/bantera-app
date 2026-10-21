import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class PracticeHeader extends StatelessWidget implements PreferredSizeWidget {
  const PracticeHeader({super.key, this.onLongerDialogues});
  final VoidCallback? onLongerDialogues;

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
              const SizedBox(width: buttonSize),
              Expanded(
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: title),
                ),
              ),
              SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: PopupMenuButton<String>(
                  key: const ValueKey('practice-more-menu'),
                  enabled: onLongerDialogues != null,
                  tooltip: l.more,
                  icon: const Icon(Icons.more_horiz),
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (_) => onLongerDialogues?.call(),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'dialogues',
                      child: Text(l.longerDialogues),
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
}
