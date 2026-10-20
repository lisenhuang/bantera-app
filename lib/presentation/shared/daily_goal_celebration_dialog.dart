import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';
import 'goal_confetti.dart';

Future<void> showDailyGoalCelebration(
  BuildContext context, {
  required WordTotals totals,
}) => showDialog<void>(
  context: context,
  useRootNavigator: true,
  useSafeArea: false,
  builder: (_) => Stack(
    fit: StackFit.expand,
    children: [
      DailyGoalCelebrationDialog(totals: totals),
      const Positioned.fill(child: GoalConfetti()),
    ],
  ),
);

class DailyGoalCelebrationDialog extends StatelessWidget {
  const DailyGoalCelebrationDialog({super.key, required this.totals});
  final WordTotals totals;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!,
        theme = Theme.of(context),
        c = theme.colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: MediaQuery.of(context).disableAnimations ? 1 : 0,
                    end: 1,
                  ),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Transform.scale(
                    scale: .85 + .15 * value,
                    child: SizedBox(
                      width: 126,
                      height: 126,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              color: c.primary,
                              backgroundColor: c.primary.withValues(alpha: .1),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              color: c.secondary,
                              backgroundColor: c.secondary.withValues(
                                alpha: .1,
                              ),
                            ),
                          ),
                          Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: 56,
                            color: c.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l.dailyGoalReached,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l.goalCelebrationMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _metric(
                          context,
                          CupertinoIcons.headphones,
                          totals.listened,
                          l.wordActivityListened,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _metric(
                          context,
                          CupertinoIcons.mic_fill,
                          totals.spoken,
                          l.wordActivitySpoken,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Text(l.goalCelebrationContinue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    IconData icon,
    int value,
    String label,
  ) => Column(
    children: [
      Icon(icon, size: 23, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 8),
      Text(
        '$value',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}
