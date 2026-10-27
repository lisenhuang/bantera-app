import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/activity/word_activity.dart';
import '../infrastructure/last_snapshot_cache.dart';
import '../l10n/app_localizations.dart';
import 'app_locale.dart';
import 'settings_notifier.dart';

/// Shares aggregate progress and translated labels, never credentials or chats.
class PracticeWidgetService {
  PracticeWidgetService._()
    : _send = _sendNative,
      _supported = Platform.isIOS,
      _restoreFromCache = true;

  @visibleForTesting
  PracticeWidgetService.forTesting({
    required Future<void> Function(Map<String, Object>) send,
  }) : _send = send,
       _supported = true,
       _restoreFromCache = false;

  static final instance = PracticeWidgetService._();
  static const channel = MethodChannel('bantera/practice_widget');
  final Future<void> Function(Map<String, Object>) _send;
  final bool _supported;
  final bool _restoreFromCache;
  final chatRequested = ValueNotifier(false);
  Future<void> _queue = Future.value();
  String? _lastSignature;
  bool _initialized = false;
  String? _owner, _language, _level, _rankingDate;
  int? _rank;
  bool _rankKnown = false;
  int _scopeGeneration = 0;
  WordTotals _today = const WordTotals();
  AppLocalizations? _localizations;

  void setProgress({
    required String owner,
    required String language,
    required String? level,
  }) {
    if (!_supported ||
        owner != _owner ||
        language != _language ||
        !const ['A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'].contains(level)) {
      return;
    }
    _level = level;
    _republish();
  }

  void setLeaderboard({
    required String owner,
    required Map<String, dynamic> report,
  }) {
    if (!_supported || owner != _owner) return;
    final you = report['you'];
    _rank = you is Map && you['rank'] is num && (you['rank'] as num) > 0
        ? (you['rank'] as num).toInt()
        : null;
    _rankingDate = report['throughDate'] as String?;
    _rankKnown = true;
    _republish();
  }

  void _republish() {
    unawaited(
      update(
        signedIn: _owner != null,
        owner: _owner,
        learningLanguage: _language,
        today: _today,
        localizations: _localizations,
      ),
    );
  }

  Future<void> _restoreDetails(
    String owner,
    String? language,
    int generation,
  ) async {
    final practice = language == null
        ? null
        : await LastSnapshotCache.practice.read(jsonEncode([owner, language]));
    final ranking = await LastSnapshotCache.leaderboard.read(owner);
    if (_owner != owner ||
        _language != language ||
        generation != _scopeGeneration) {
      return;
    }
    if (_level == null && practice?['currentLevel'] is String) {
      setProgress(
        owner: owner,
        language: language!,
        level: practice!['currentLevel'] as String,
      );
    }
    if (!_rankKnown && ranking != null) {
      setLeaderboard(owner: owner, report: ranking);
    }
  }

  Future<void> initialize() async {
    if (!_supported || _initialized) return;
    _initialized = true;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'openChat') await _takePendingOpen();
    });
    await _takePendingOpen();
  }

  Future<void> _takePendingOpen() async {
    try {
      if (await channel.invokeMethod<bool>('takePendingOpen') == true) {
        chatRequested.value = true;
      }
    } on PlatformException catch (_) {
      // A widget is optional and must not block app startup.
    } on MissingPluginException catch (_) {}
  }

  static Future<void> _sendNative(Map<String, Object> data) =>
      channel.invokeMethod<void>('update', data);

  Future<void> update({
    required bool signedIn,
    required WordTotals today,
    String? owner,
    String? learningLanguage,
    DateTime? now,
    AppLocalizations? localizations,
  }) {
    if (!_supported) return Future.value();
    final date = now ?? DateTime.now();
    final nextOwner = signedIn ? owner : null;
    final nextLanguage = signedIn ? learningLanguage : null;
    final scopeChanged = nextOwner != _owner || nextLanguage != _language;
    if (nextOwner != _owner || !signedIn) {
      _rank = null;
      _rankingDate = null;
      _rankKnown = false;
    }
    if (scopeChanged || !signedIn) _level = null;
    _owner = nextOwner;
    _language = nextLanguage;
    _today = today;
    _localizations = localizations;
    if (scopeChanged) {
      final generation = ++_scopeGeneration;
      if (_restoreFromCache && nextOwner != null) {
        unawaited(_restoreDetails(nextOwner, nextLanguage, generation));
      }
    }
    // Capture the details with this write so later account changes cannot leak
    // another learner's progress into an older queued snapshot.
    final level = signedIn ? _level : null;
    final rankingDate = signedIn ? _rankingDate : null;
    final rank = signedIn && rankingDate == wordActivityDateKey(date.toUtc())
        ? _rank
        : null;
    final locale = localizations != null
        ? null
        : resolveAppLocale(
            preference: SettingsNotifier.instance.appLocalePreference,
            platformLocale: PlatformDispatcher.instance.locale,
          );
    // Queue all writes, including account clears, so an older asynchronous update
    // cannot overwrite a newer account's snapshot.
    _queue = _queue
        .then((_) async {
          final l =
              localizations ?? await AppLocalizations.delegate.load(locale!);
          final data = <String, Object>{
            'dateKey': wordActivityDateKey(date),
            'signedIn': signedIn,
            'spoken': signedIn ? today.spoken : 0,
            'listened': signedIn ? today.listened : 0,
            'locale': l.localeName,
            'learningLanguage': ?nextLanguage,
            'level': ?level,
            'rank': ?rank,
            'rankingDate': ?rankingDate,
            'labels': {
              'today': l.wordActivityToday,
              'spoken': l.wordActivitySpeaking,
              'listened': l.wordActivityListening,
              'words': l.wordActivityWords,
              'chat': 'Bantera AI',
              'signIn': l.authSignIn,
              'level': l.audioLevelSection,
              'language': l.editProfileLearningLanguage,
              'position': l.leaderboardYourPosition,
              'period': l.leaderboardScope,
            },
          };
          final signature = jsonEncode(data);
          if (signature == _lastSignature) return;
          await _send(data);
          _lastSignature = signature;
        })
        .catchError((Object error) {
          debugPrint('[PracticeWidget] Update deferred: ${error.runtimeType}');
        });
    return _queue;
  }
}
