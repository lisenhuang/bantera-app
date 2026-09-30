import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path_provider/path_provider.dart';

import 'auth_session_notifier.dart';

final practiceReviewRouteObserver = RouteObserver<ModalRoute<dynamic>>();

/// Device-local, account-isolated lesson history. Only iOS requests StoreKit reviews.
class PracticeReviewService {
  PracticeReviewService({
    required this.enabled,
    required this.currentOwner,
    required Future<File> Function() file,
    required Future<bool> Function() isAvailable,
    required Future<void> Function() requestReview,
    DateTime Function()? now,
  }) : _file = file,
       _isAvailable = isAvailable,
       _requestReview = requestReview,
       _now = now ?? DateTime.now;

  static final instance = PracticeReviewService(
    enabled: Platform.isIOS,
    currentOwner: () => AuthSessionNotifier.instance.session?.cacheKey,
    file: () async => File(
      '${(await getApplicationSupportDirectory()).path}/practice_review.json',
    ),
    isAvailable: InAppReview.instance.isAvailable,
    requestReview: InAppReview.instance.requestReview,
  );

  final bool enabled;
  final String? Function() currentOwner;
  final Future<File> Function() _file;
  final Future<bool> Function() _isAvailable;
  final Future<void> Function() _requestReview;
  final DateTime Function() _now;
  Future<void> _queue = Future.value();
  Map<String, dynamic>? _data;
  String? _pendingOwner;
  bool _requesting = false;
  bool _requestedThisSession = false;

  Future<Map<String, dynamic>> _load() async {
    if (_data != null) return _data!;
    final file = await _file();
    try {
      _data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } on FileSystemException {
      _data = {};
    } on FormatException {
      _data = {};
    }
    return _data!;
  }

  Future<void> _save() async {
    final file = await _file();
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(_data), flush: true);
    await temp.rename(file.path);
  }

  Future<void> recordCompletedCues({
    required String? owner,
    required String lessonId,
    required Set<String> completedCueKeys,
    required Set<String> requiredCueKeys,
  }) {
    if (!enabled ||
        owner == null ||
        completedCueKeys.isEmpty ||
        requiredCueKeys.isEmpty ||
        lessonId.isEmpty) {
      return Future.value();
    }
    final completedAt = _now();
    _queue = _queue
        .then((_) async {
          final data = await _load();
          final accounts =
              data.putIfAbsent('accounts', () => <String, dynamic>{}) as Map;
          final account =
              accounts.putIfAbsent(owner, () => <String, dynamic>{}) as Map;
          final lessons =
              account.putIfAbsent('lessons', () => <String, dynamic>{}) as Map;
          final completions =
              account.putIfAbsent('completions', () => <String, dynamic>{})
                  as Map;
          final heard = Set<String>.from(lessons[lessonId] as List? ?? []);
          heard.addAll(completedCueKeys);
          lessons[lessonId] = heard.toList();
          if (heard.containsAll(requiredCueKeys) &&
              !completions.containsKey(lessonId)) {
            completions.putIfAbsent(
              lessonId,
              () =>
                  '${completedAt.year}-${completedAt.month}-${completedAt.day}',
            );
            _pendingOwner = owner;
          }
          await _save();
        })
        .catchError((Object _) {
          // Optional review bookkeeping must never interrupt practice.
          _pendingOwner = null;
        });
    return _queue;
  }

  Future<void> requestIfEligible({required bool Function() isSafe}) async {
    if (!enabled || _requesting || _requestedThisSession) return;
    _requesting = true;
    try {
      await _queue;
      final owner = currentOwner();
      if (owner == null || _pendingOwner != owner || !isSafe()) return;
      final data = await _load();
      final accounts = data['accounts'] as Map?;
      final account = accounts?[owner] as Map?;
      final completions = account?['completions'] as Map? ?? {};
      if (completions.length < 3 || completions.values.toSet().length < 2) {
        return;
      }
      final lastRequest = DateTime.tryParse(
        data['lastRequestAt'] as String? ?? '',
      );
      if (lastRequest != null &&
          _now().difference(lastRequest) < const Duration(days: 90)) {
        return;
      }
      if (!await _isAvailable() || !isSafe() || currentOwner() != owner) return;

      // StoreKit does not report whether it displayed the prompt or a rating was left.
      data['lastRequestAt'] = _now().toUtc().toIso8601String();
      await _save();
      if (!isSafe() || currentOwner() != owner) {
        if (lastRequest == null) {
          data.remove('lastRequestAt');
        } else {
          data['lastRequestAt'] = lastRequest.toIso8601String();
        }
        await _save();
        return;
      }
      _requestedThisSession = true;
      _pendingOwner = null;
      await _requestReview();
    } catch (_) {
      // Unavailable StoreKit or local storage should remain invisible to users.
    } finally {
      _requesting = false;
    }
  }
}
