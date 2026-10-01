import 'dart:async';

import 'package:flutter/material.dart';

import '../../infrastructure/saved_cue_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../core/profile_stats_notifier.dart';
import '../../core/word_activity_notifier.dart';
import '../../core/app_resume_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../shared/learning_language_label.dart';
import '../shared/profile_avatar.dart';
import 'edit_profile_screen.dart';
import 'saved_cues_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';
import 'word_activity_section.dart';
import 'daily_word_goal_section.dart';
import 'word_activity_share_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WordActivityNotifier.instance.retain();
    unawaited(ProfileStatsNotifier.instance.refresh());
    unawaited(SavedCueRepository.instance.load());
    unawaited(WordActivityNotifier.instance.sync());
  }

  @override
  void dispose() {
    WordActivityNotifier.instance.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        UserProfileNotifier.instance,
        ProfileStatsNotifier.instance,
        WordActivityNotifier.instance,
        AppResumeNotifier.instance,
        SavedCueRepository.instance,
      ]),
      builder: (context, _) {
        final profile = UserProfileNotifier.instance;
        final stats = ProfileStatsNotifier.instance;
        final language = learningLanguageLabel(profile.learningLanguage);
        final l10n = AppLocalizations.of(context)!;
        final activity = WordActivityNotifier.instance.summaryFor(
          profile.learningLanguage,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.navProfile),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Semantics(
                    button: true,
                    label: l10n.editProfile,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            ProfileAvatar(
                              radius: 32,
                              imageUrl: profile.avatarUrl,
                              imagePath: profile.avatarImagePath,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.displayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  if (language.name.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        text: l10n.wordActivityLearningLanguage(
                                          language.name,
                                        ),
                                        children: [
                                          const TextSpan(text: ' '),
                                          TextSpan(
                                            text: language.flag,
                                            style: const TextStyle(
                                              fontFamilyFallback: [
                                                'Apple Color Emoji',
                                                'Noto Color Emoji',
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                            wordSpacing: 0,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedScreen()),
                      ),
                      child: _buildStatColumn(
                        context,
                        l10n.savedTitle,
                        stats.savedCount != null ? '${stats.savedCount}' : '–',
                        tappable: true,
                      ),
                    ),
                    const SizedBox(width: 32),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedCuesScreen(),
                        ),
                      ),
                      child: _buildStatColumn(
                        context,
                        l10n.savedCuesTitle,
                        '${SavedCueRepository.instance.entries.length}',
                        tappable: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                DailyWordGoalSection(
                  goal: WordActivityNotifier.instance.dailyGoal,
                  today: activity.today,
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DailyWordGoalScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                WordActivitySection(
                  history: WordActivityNotifier.instance.historyFor(
                    profile.learningLanguage,
                  ),
                  today: activity.today,
                  week: activity.week,
                  total: activity.total,
                  onShare: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WordActivityShareScreen(
                        name: profile.displayName,
                        learningLanguage: profile.learningLanguage,
                        avatarUrl: profile.avatarUrl,
                        avatarPath: profile.avatarImagePath,
                        today: activity.today,
                        week: activity.week,
                        total: activity.total,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value, {
    bool tappable = false,
  }) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            if (tappable) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
