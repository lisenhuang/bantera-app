import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/activity/word_activity.dart';
import '../domain/activity/daily_word_goal.dart';
import '../infrastructure/auth_api_client.dart';
import 'app_resume_notifier.dart';
import 'auth_session_notifier.dart';
import 'goal_reminder_service.dart';
import 'user_profile_notifier.dart';
import 'settings_notifier.dart';

class WordActivityNotifier extends ChangeNotifier {
  WordActivityNotifier._()
    : _session = (() => AuthSessionNotifier.instance.session),
      _apiClient = AuthApiClient.instance,
      _testFile = null {
    AuthSessionNotifier.instance.addListener(_accountChanged);
    AppResumeNotifier.instance.addListener(_resumed);
    UserProfileNotifier.instance.addListener(_updateReminders);
    SettingsNotifier.instance.addListener(_updateReminders);
    unawaited(sync());
  }

  @visibleForTesting
  WordActivityNotifier.forTesting({
    required AuthSession? Function() session,
    required Future<File> Function(String userId) file,
    required AuthApiClient apiClient,
  }) : _session = session,
       _testFile = file,
       _apiClient = apiClient;

  final AuthSession? Function() _session;
  final Future<File> Function(String)? _testFile;
  final AuthApiClient _apiClient;

  static final instance = WordActivityNotifier._();
  WordActivityLedger? _ledger;
  String? _loadedUserId;
  final Set<String> _deletedUserIds = {};
  Future<void> _queue = Future.value();
  bool _syncing = false;
  bool _disposed = false;
  Timer? _timer;
  int _activeScreens = 0;

  @override
  void notifyListeners() {
    super.notifyListeners();
    _updateReminders();
  }

  void _updateReminders() {
    if (_disposed || _testFile != null) return;
    final language = UserProfileNotifier.instance.learningLanguage;
    unawaited(
      GoalReminderService.instance.update(
        ownerId: _deletedUserIds.contains(_userId) ? null : _userId,
        language: language,
        goal: dailyGoal,
        today: summaryFor(language).today,
      ),
    );
  }

  void retain() {
    if (_activeScreens++ > 0) return;
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      notifyListeners(); // Recompute calendar periods after midnight.
      unawaited(sync(fetchIfClean: false));
    });
  }

  void release() {
    if (_activeScreens > 0) _activeScreens--;
    if (_activeScreens == 0) {
      _timer?.cancel();
      _timer = null;
    }
  }

  String? get _userId => _session()?.userId;

  DailyWordGoal? get dailyGoal =>
      _loadedUserId == _userId ? _ledger?.dailyGoal : null;

  String? get accountId => _userId;

  Future<bool> setDailyGoal(DailyWordGoal? goal, {String? ownerId}) async {
    final userId = _userId;
    if (userId == null ||
        (ownerId != null && ownerId != userId) ||
        (goal != null && !goal.isValid)) {
      return false;
    }
    var saved = false;
    await _serial(() async {
      if (_userId != userId || _deletedUserIds.contains(userId)) return;
      await _load(userId);
      if (_userId != userId || _ledger == null) return;
      final ledger = _ledger!;
      final previous = ledger.dailyGoal;
      ledger.dailyGoal = goal;
      try {
        await _save(userId, ledger);
        saved = true;
      } catch (_) {
        ledger.dailyGoal = previous;
      }
      notifyListeners();
    });
    return saved;
  }

  ({WordTotals today, WordTotals week, WordTotals total}) get summary =>
      _loadedUserId == _userId && _ledger != null
      ? _ledger!.summary(DateTime.now())
      : (
          today: const WordTotals(),
          week: const WordTotals(),
          total: const WordTotals(),
        );

  ({WordTotals today, WordTotals week, WordTotals total}) summaryFor(
    String? language,
  ) =>
      _loadedUserId == _userId &&
          _ledger != null &&
          language != null &&
          language.trim().isNotEmpty
      ? _ledger!.summary(DateTime.now(), language: language)
      : (
          today: const WordTotals(),
          week: const WordTotals(),
          total: const WordTotals(),
        );

  WordTotals get legacyTotal => _loadedUserId == _userId && _ledger != null
      ? _ledger!.summary(DateTime.now(), language: '').total
      : const WordTotals();

  Map<String, WordTotals> historyFor(String? language) =>
      _loadedUserId == _userId &&
          _ledger != null &&
          language != null &&
          language.trim().isNotEmpty
      ? _ledger!.historyFor(language)
      : const {};

  Future<void> _serial(Future<void> Function() action) {
    final result = _queue.then(
      (_) => _disposed ? Future<void>.value() : action(),
    );
    _queue = result.catchError((Object error) {
      debugPrint('[WordActivity] Local save deferred: ${error.runtimeType}');
    });
    return _queue;
  }

  Future<File> _file(String userId) async {
    if (_testFile != null) return _testFile(userId);
    final dir = await getApplicationSupportDirectory();
    // The ID comes from the authenticated JWT, but still restrict filename chars.
    final safeId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '_');
    return File('${dir.path}/word_activity_$safeId.json');
  }

  Future<void> _load(String? userId) async {
    if (_deletedUserIds.contains(userId)) userId = null;
    if (_loadedUserId == userId && (userId == null || _ledger != null)) return;
    _loadedUserId = userId;
    _ledger = null;
    if (userId != null) {
      try {
        final file = await _file(userId);
        if (await file.exists()) {
          _ledger = WordActivityLedger.fromJson(
            jsonDecode(await file.readAsString()) as Map<String, dynamic>,
          );
        }
      } catch (_) {}
      _ledger ??= WordActivityLedger(deviceId: const Uuid().v4());
    }
    notifyListeners();
  }

  Future<void> _save(String userId, WordActivityLedger ledger) async {
    final file = await _file(userId);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(ledger.toJson()), flush: true);
    await temp.rename(file.path);
  }

  Future<void> record({
    int listened = 0,
    int spoken = 0,
    String? ownerId,
    DateTime? at,
    String? language,
    String? speechEventId,
  }) {
    final userId = ownerId ?? _userId;
    final date = at ?? DateTime.now();
    if (userId == null ||
        _deletedUserIds.contains(userId) ||
        userId != _userId ||
        (listened <= 0 && spoken <= 0)) {
      return Future.value();
    }
    return _serial(() async {
      if (_userId != userId || _deletedUserIds.contains(userId)) return;
      await _load(userId);
      if (_userId != userId) return;
      if (speechEventId != null &&
          _ledger!.recordedSpeechEvents.contains(speechEventId)) {
        return;
      }
      final before = _ledger!.toJson();
      if (speechEventId != null) {
        _ledger!.recordedSpeechEvents.add(speechEventId);
      }
      _ledger!.record(
        date,
        WordTotals(
          listened: listened.clamp(0, 10000000),
          spoken: spoken.clamp(0, 10000000),
        ),
        language: language,
      );
      try {
        await _save(userId, _ledger!);
      } catch (_) {
        _ledger = WordActivityLedger.fromJson(before);
        rethrow;
      }
      notifyListeners();
    });
  }

  void _accountChanged() {
    if (_loadedUserId == _userId) return;
    // Getters hide the previous account immediately, before asynchronous I/O.
    notifyListeners();
    unawaited(sync());
  }

  void _resumed() {
    notifyListeners();
    unawaited(sync());
  }

  Future<void> sync({bool fetchIfClean = true}) async {
    if (_disposed || _syncing) return;
    _syncing = true;
    String? userId;
    try {
      userId = _userId;
      await _serial(() => _load(userId));
      final ledger = _ledger;
      final session = _session();
      if (userId == null ||
          _deletedUserIds.contains(userId) ||
          ledger == null ||
          session?.userId != userId) {
        return;
      }
      final pending = ledger.pendingSnapshots;
      if (!fetchIfClean && pending.isEmpty) return;
      // Bounded batches, cumulative values safe to retry in any order.
      final entries = pending.entries.toList();
      for (var i = 0; i < entries.length; i += 31) {
        if (_userId != userId) return;
        final batch = Map<String, WordTotals>.fromEntries(
          entries.skip(i).take(31),
        );
        await _apiClient.saveWordActivity(
          accessToken: session!.accessToken,
          deviceId: ledger.deviceId,
          days: batch,
        );
      }
      if (_userId != userId) return;
      final remote = await _apiClient.fetchWordActivity(
        accessToken: session!.accessToken,
      );
      await _serial(() async {
        if (_userId != userId ||
            _ledger != ledger ||
            _deletedUserIds.contains(userId)) {
          return;
        }
        ledger.accept(pending, remote);
        notifyListeners();
        await _save(userId!, ledger);
      });
    } catch (_) {
      // Offline or backend not upgraded: keep all local counts for the next retry.
    } finally {
      _syncing = false;
      _updateReminders();
      if (!_disposed && userId != _userId) unawaited(sync());
    }
  }

  Future<void> removeUser(String userId) {
    _deletedUserIds.add(userId);
    return _serial(() async {
      if (_loadedUserId == userId) {
        _ledger = null;
        _loadedUserId = null;
        notifyListeners();
      }
      final file = await _file(userId);
      if (await file.exists()) await file.delete();
      final temp = File('${file.path}.tmp');
      if (await temp.exists()) await temp.delete();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    if (_testFile == null) {
      AuthSessionNotifier.instance.removeListener(_accountChanged);
      AppResumeNotifier.instance.removeListener(_resumed);
      UserProfileNotifier.instance.removeListener(_updateReminders);
      SettingsNotifier.instance.removeListener(_updateReminders);
    }
    super.dispose();
  }
}
