import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../shared/goal_confetti.dart';

class PracticeLevelPromotion {
  static const levels = ['A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  static bool earned(String? before, String? after) =>
      levels.contains(before) &&
      levels.contains(after) &&
      levels.indexOf(after!) > levels.indexOf(before!);
}

Future<void> showPracticeLevelCelebration(
  BuildContext context, {
  required String before,
  required String after,
}) => showDialog<void>(
  context: context,
  useRootNavigator: true,
  useSafeArea: false,
  builder: (context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context), c = theme.colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Dialog(
          key: const ValueKey('practice-level-celebration'),
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [c.primaryContainer, c.secondaryContainer],
                        ),
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: 64,
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l.quickLevelUpTitle(after),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.quickLevelUpBody,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              before,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: c.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: c.primary,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              after,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: c.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const ValueKey(
                          'practice-level-celebration-continue',
                        ),
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
        ),
        const Positioned.fill(child: GoalConfetti()),
      ],
    );
  },
);
