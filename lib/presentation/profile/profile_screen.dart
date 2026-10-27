import '../shared/adaptive_layout.dart';
import 'goal_motion.dart';
import '../widgets/widget_discovery.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../infrastructure/video_processing_service.dart';
import '../../core/word_activity_notifier.dart';
import '../../core/app_resume_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../shared/learning_language_label.dart';
import '../shared/profile_avatar.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import '../leaderboard/speaking_leaderboard.dart';
import 'word_activity_section.dart';
import 'daily_word_goal_section.dart';
import 'word_activity_share_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.active = true, this.refreshTick = 0});
  final bool active;
  final int refreshTick;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _checkedLanguage;
  bool? _speechSupported;

  void _refreshSpeechSupport() {
    final language = UserProfileNotifier.instance.learningLanguage;
    if (_checkedLanguage == language) return;
    _checkedLanguage = language;
    if (language == null || language.isEmpty) {
      _speechSupported = null;
      return;
    }
    _speechSupported = isMaoriLanguage(language) ? false : null;
    unawaited(() async {
      final supported = await VideoProcessingService.instance
          .supportsPracticeTranscription(language);
      if (mounted && _checkedLanguage == language) {
        setState(() => _speechSupported = supported);
      }
    }());
  }

  @override
  void initState() {
    super.initState();
    WordActivityNotifier.instance.retain();
    UserProfileNotifier.instance.addListener(_refreshSpeechSupport);
    _refreshSpeechSupport();
    unawaited(WordActivityNotifier.instance.sync());
  }

  @override
  void dispose() {
    UserProfileNotifier.instance.removeListener(_refreshSpeechSupport);
    WordActivityNotifier.instance.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        UserProfileNotifier.instance,
        WordActivityNotifier.instance,
        AppResumeNotifier.instance,
      ]),
      builder: (context, _) {
        final profile = UserProfileNotifier.instance;
        final language = goalLearningLanguageLabel(profile.learningLanguage);
        final showSpeaking =
            !isMaoriLanguage(profile.learningLanguage) &&
            _speechSupported != false;
        final l10n = AppLocalizations.of(context)!;
        final activity = WordActivityNotifier.instance.summaryFor(
          profile.learningLanguage,
        );

        return GoalMotion(
          active: widget.active,
          replayTick: widget.refreshTick,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Bantera App'),
              ),
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
                                    if (language.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.wordActivityLearningLanguage(
                                          language,
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
                  const WidgetSuggestion(),
                  const SizedBox(height: 24),
                  AdaptiveColumns(
                    textScale: MediaQuery.textScalerOf(context).scale(1),
                    regions: AdaptiveLayoutScope.of(context).regions,
                    gap: 0,
                    first: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SpeakingLeaderboardCard(
                            active: widget.active,
                            refreshTick: widget.refreshTick,
                          ),
                        ),
                        const SizedBox(height: 24),
                        DailyWordGoalSection(
                          showSpeaking: showSpeaking,
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
                      ],
                    ),
                    second: WordActivitySection(
                      showSpeaking: showSpeaking,
                      history: WordActivityNotifier.instance.historyFor(
                        profile.learningLanguage,
                      ),
                      today: activity.today,
                      week: activity.week,
                      total: activity.total,
                      onShare: !showSpeaking
                          ? null
                          : () => Navigator.push(
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
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
