import 'dart:async';

import 'package:flutter/material.dart';

import '../../infrastructure/saved_cue_repository.dart';
import '../../infrastructure/practice_progress_store.dart';
import '../../core/auth_session_notifier.dart';
import 'practice_history_screen.dart';
import 'profile_library_section.dart';
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
  bool _historyLoaded = false;

  Future<void> _loadHistory() async {
    try {
      await PracticeProgressStore.instance.load();
      if (mounted) setState(() => _historyLoaded = true);
    } catch (_) {
      // The history destination provides a retry if local storage is unavailable.
    }
  }

  @override
  void initState() {
    super.initState();
    WordActivityNotifier.instance.retain();
    unawaited(_loadHistory());
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
        PracticeProgressStore.instance,
        AuthSessionNotifier.instance,
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.navProfile),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.settingsTitle,
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
                ProfileLibrarySection(
                  savedCount: stats.savedCount,
                  cueCount: SavedCueRepository.instance.entries.length,
                  historyCount: _historyLoaded
                      ? PracticeProgressStore.instance.entries.length
                      : null,
                  recent: PracticeProgressStore.instance.entries.firstOrNull,
                  onSavedMedia: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedScreen()),
                  ),
                  onSavedCues: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedCuesScreen()),
                  ),
                  onHistory: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PracticeHistoryScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
}
