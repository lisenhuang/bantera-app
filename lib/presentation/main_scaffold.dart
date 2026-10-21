import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_resume_notifier.dart';
import '../core/ai_callback_notifier.dart';
import '../core/daily_goal_celebration.dart';
import '../core/word_activity_notifier.dart';
import '../core/user_profile_notifier.dart';
import 'shared/daily_goal_celebration_dialog.dart';
import '../core/practice_widget_service.dart';
import 'chats/ai/ai_chat_screen.dart';
import '../core/goal_reminder_service.dart';
import '../core/dm_call_notifier.dart';
import '../core/practice_review_service.dart';
import '../domain/models/chat_models.dart';
import '../infrastructure/app_update_service.dart';
import '../infrastructure/local_chat_repository.dart';
import '../l10n/app_localizations.dart';
import 'chats/chats_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/daily_word_goal_section.dart';
import 'quick_practice/quick_practice_screen.dart';
import 'shared/goal_tab_icon.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with RouteAware {
  final _goalTabAnchor = GlobalKey();
  ModalRoute<dynamic>? _reviewRoute;
  Timer? _reviewTimer;
  int _currentIndex = 0;
  int _tabSelection = 0;
  bool _goalSetupOpen = false;
  bool _covered = false;
  bool _checkingUpdate = false;
  bool _hasUnreadChats = false;
  StreamSubscription<List<ChatThreadSummary>>? _groupsSub;
  StreamSubscription<List<ChatThreadSummary>>? _dmsSub;
  List<ChatThreadSummary> _groups = [];
  List<ChatThreadSummary> _dms = [];

  @override
  void initState() {
    super.initState();
    WordActivityNotifier.instance.addListener(_schedulePracticeReview);
    WordActivityNotifier.instance.retain();
    practiceInteractionBusy.addListener(_schedulePracticeReview);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
    AppResumeNotifier.instance.addListener(_onResume);
    GoalReminderService.instance.profileRequested.addListener(_openGoalProfile);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openGoalProfile());
    PracticeWidgetService.instance.chatRequested.addListener(
      _scheduleWidgetChat,
    );
    _scheduleWidgetChat();
    _groupsSub = LocalChatRepository.instance.watchGroups().listen((groups) {
      _groups = groups;
      _updateUnread();
    });
    _dmsSub = LocalChatRepository.instance.watchDirectMessages().listen((dms) {
      _dms = dms;
      _updateUnread();
    });
  }

  void _scheduleWidgetChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !PracticeWidgetService.instance.chatRequested.value ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      PracticeWidgetService.instance.chatRequested.value = false;
      setState(() => _currentIndex = 1);
      openAiReminderChat();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _openGoalProfile() {
    final request = GoalReminderService.instance.profileRequested;
    if (!mounted || !request.value) return;
    request.value = false;
    setState(() => _currentIndex = 2);
  }

  void _selectTab(int index) {
    final selection = ++_tabSelection;
    setState(() => _currentIndex = index);
    _schedulePracticeReview();
    if (index == 2) unawaited(_openGoalSetupIfNeeded(selection));
  }

  Future<void> _openGoalSetupIfNeeded(int selection) async {
    final activity = WordActivityNotifier.instance;
    final owner = activity.accountId;
    await activity.ensureLoaded();
    if (!mounted ||
        selection != _tabSelection ||
        _currentIndex != 2 ||
        _covered ||
        _goalSetupOpen ||
        owner != activity.accountId ||
        activity.dailyGoal != null) {
      return;
    }
    _goalSetupOpen = true;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => const DailyWordGoalScreen()),
      );
    } finally {
      _goalSetupOpen = false;
    }
  }

  void _updateUnread() {
    final hasUnread =
        _groups.any((t) => t.unreadCount > 0) ||
        _dms.any((t) => t.unreadCount > 0);
    if (hasUnread != _hasUnreadChats) {
      setState(() => _hasUnreadChats = hasUnread);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _reviewRoute) {
      practiceReviewRouteObserver.unsubscribe(this);
      _reviewRoute = route;
      if (route != null) practiceReviewRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    setState(() => _covered = true);
    _schedulePracticeReview();
  }

  @override
  void didPopNext() {
    setState(() => _covered = false);
    _schedulePracticeReview();
  }

  bool get _canRequestReview =>
      mounted &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
      !DmCallNotifier.instance.isActive &&
      !AiCallbackNotifier.instance.aiActive &&
      !AiCallbackNotifier.instance.ringing &&
      !practiceInteractionBusy.value &&
      practiceReviewRouteObserver.top is PageRoute;

  void _schedulePracticeReview() {
    // Continuous word updates must not keep postponing an achieved goal.
    // The root dialog can appear over any pushed learning/settings page.
    if (_reviewTimer?.isActive ?? false) return;
    _reviewTimer = Timer(const Duration(milliseconds: 150), _celebrateGoal);
  }

  Future<void> _celebrateGoal() async {
    _reviewTimer = null;
    if (!mounted) return;
    final activity = WordActivityNotifier.instance;
    await activity.ensureLoaded();
    if (!mounted) return;
    final owner = activity.accountId;
    final language = UserProfileNotifier.instance.learningLanguage;
    final goal = activity.dailyGoal;
    final today = activity.summaryFor(language).today;
    final complete = DailyGoalCelebration.reached(goal, today);
    if (complete && !_canRequestReview) {
      _reviewTimer = Timer(const Duration(seconds: 2), _celebrateGoal);
    }
    bool current() =>
        mounted &&
        activity.accountId == owner &&
        UserProfileNotifier.instance.learningLanguage == language &&
        activity.dailyGoal?.listened == goal?.listened &&
        activity.dailyGoal?.spoken == goal?.spoken &&
        DailyGoalCelebration.reached(
              activity.dailyGoal,
              activity.summaryFor(language).today,
            ) ==
            complete;
    bool safe() => _canRequestReview && current();
    await DailyGoalCelebration.instance.presentIfEligible(
      owner: owner,
      goal: goal,
      language: language,
      totals: today,
      isCurrent: current,
      isSafe: safe,
      present: () => PracticeReviewService.instance.requestAfterCelebration(
        dismissed: showDailyGoalCelebration(context, totals: today),
        isSafe: safe,
      ),
    );
  }

  @override
  void dispose() {
    _reviewTimer?.cancel();
    WordActivityNotifier.instance.removeListener(_schedulePracticeReview);
    WordActivityNotifier.instance.release();
    practiceInteractionBusy.removeListener(_schedulePracticeReview);
    practiceReviewRouteObserver.unsubscribe(this);
    _groupsSub?.cancel();
    _dmsSub?.cancel();
    AppResumeNotifier.instance.removeListener(_onResume);
    PracticeWidgetService.instance.chatRequested.removeListener(
      _scheduleWidgetChat,
    );
    GoalReminderService.instance.profileRequested.removeListener(
      _openGoalProfile,
    );
    super.dispose();
  }

  void _onResume() {
    _schedulePracticeReview();
    _scheduleWidgetChat();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (_checkingUpdate) return;
    _checkingUpdate = true;
    try {
      final result = await AppUpdateService.checkForUpdate();
      if (!mounted) return;
      if (result != null && result.needsUpdate) {
        _showUpdateDialog(result.storeUrl);
      }
    } finally {
      _checkingUpdate = false;
    }
  }

  void _showUpdateDialog(String storeUrl) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateAlertTitle),
        content: Text(l10n.updateAlertMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.updateAlertLater),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await launchUrl(
                Uri.parse(storeUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            child: Text(l10n.updateAlertUpdate),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screens = <Widget>[
      QuickPracticeScreen(
        active: _currentIndex == 0 && !_covered,
        goalTabAnchor: _goalTabAnchor,
      ),
      ChatsScreen(active: _currentIndex == 1 && !_covered),
      const ProfileScreen(),
    ];
    final maxIndex = screens.length - 1;
    final stackIndex = _currentIndex.clamp(0, maxIndex);

    return Scaffold(
      body: IndexedStack(index: stackIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: stackIndex,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        onTap: _selectTab,
        items: [
          BottomNavigationBarItem(
            icon: const SizedBox.square(
              dimension: 36,
              child: Center(child: Icon(CupertinoIcons.waveform, size: 28)),
            ),
            label: l10n.navPractice,
          ),
          BottomNavigationBarItem(
            icon: SizedBox.square(
              dimension: 36,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      stackIndex == 1
                          ? CupertinoIcons.chat_bubble_text_fill
                          : CupertinoIcons.chat_bubble_text,
                      size: 28,
                    ),
                    if (_hasUnreadChats)
                      Positioned(
                        top: -2,
                        right: -4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            label: l10n.chatsTitle,
          ),
          BottomNavigationBarItem(
            icon: LiveGoalTabIcon(key: _goalTabAnchor),
            label: l10n.navGoal,
          ),
        ],
      ),
    );
  }
}
