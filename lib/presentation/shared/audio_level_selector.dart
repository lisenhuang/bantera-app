import 'package:flutter/material.dart';

import '../../core/settings_notifier.dart';
import '../../domain/audio_level.dart';
import '../../l10n/app_localizations.dart';

String audioLevelLabel(AppLocalizations l10n, AudioLevel level) =>
    switch (level) {
      AudioLevel.beginner => l10n.audioLevelBeginner,
      AudioLevel.intermediate => l10n.audioLevelIntermediate,
      AudioLevel.advanced => l10n.audioLevelAdvanced,
    };

/// Three ascending bars, with one/two/three filled for the chosen level.
/// Drawn natively so the approved design stays crisp at every display scale.
class AudioLevelIcon extends StatelessWidget {
  const AudioLevelIcon({super.key, required this.level, this.size = 24});

  final AudioLevel level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            final filled = index <= level.index;
            return Container(
              width: size * .25,
              height: size * (.35 + index * .3),
              decoration: BoxDecoration(
                color: filled ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(size * .07),
                border: Border.all(
                  color: filled ? colors.primary : colors.outline,
                  width: 1.5,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class AudioLevelSelector extends StatelessWidget {
  const AudioLevelSelector({
    super.key,
    this.allowAll = false,
    this.showLeadingIcon = true,
  });

  final bool allowAll;
  final bool showLeadingIcon;

  @override
  Widget build(BuildContext context) {
    final settings = SettingsNotifier.instance;
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final level = settings.audioLevel;
        final label = level == null
            ? (allowAll ? l10n.audioLevelAll : l10n.audioLevelSelect)
            : audioLevelLabel(l10n, level);
        return OutlinedButton.icon(
          onPressed: () async {
            final result = await showModalBottomSheet<String>(
              context: context,
              showDragHandle: true,
              builder: (context) => SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          l10n.audioLevelSelect,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (allowAll)
                        ListTile(
                          leading: const Icon(Icons.layers_outlined),
                          title: Text(l10n.audioLevelAll),
                          selected: level == null,
                          trailing: level == null
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.pop(context, 'all'),
                        ),
                      for (final option in AudioLevel.values)
                        ListTile(
                          leading: AudioLevelIcon(level: option),
                          title: Text(audioLevelLabel(l10n, option)),
                          selected: level == option,
                          trailing: level == option
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.pop(context, option.name),
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
            // Dismissing the sheet must preserve the current selection.
            if (result != null) {
              await settings.setAudioLevel(AudioLevel.fromStorage(result));
            }
          },
          icon: !showLeadingIcon
              ? null
              : level == null
              ? const Icon(Icons.layers_outlined, size: 22)
              : AudioLevelIcon(level: level, size: 22),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(label)),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        );
      },
    );
  }
}

/// Direct choices for generation, sharing the saved level with Discover.
class AudioLevelButtons extends StatelessWidget {
  const AudioLevelButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsNotifier.instance;
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final option in AudioLevel.values) ...[
              if (option != AudioLevel.values.first) const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  key: ValueKey('audio-level-choice-${option.name}'),
                  selected: settings.audioLevel == option,
                  child: OutlinedButton(
                    onPressed: () => settings.setAudioLevel(option),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.transparent,
                      foregroundColor: colors.onSurface,
                      side: BorderSide(
                        width: settings.audioLevel == option ? 2 : 1,
                        color: settings.audioLevel == option
                            ? colors.primary
                            : colors.outline,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AudioLevelIcon(level: option),
                        const SizedBox(height: 8),
                        Text(
                          audioLevelLabel(l10n, option),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
