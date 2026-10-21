import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';

import 'auth_session_notifier.dart';

class PracticeRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  Route<dynamic>? top;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    top = route;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    top = previousRoute;
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (top == oldRoute) top = newRoute;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

final practiceReviewRouteObserver = PracticeRouteObserver();

/// Native iOS review requests happen only after a goal celebration is dismissed.
/// StoreKit controls visibility and frequency; a request is not a shown prompt.
class PracticeReviewService {
  PracticeReviewService({
    required this.enabled,
    required this.currentOwner,
    required Future<bool> Function() isAvailable,
    required Future<void> Function() requestReview,
    this.dismissalDelay = const Duration(milliseconds: 600),
  }) : _isAvailable = isAvailable,
       _requestReview = requestReview;

  static final instance = PracticeReviewService(
    enabled: Platform.isIOS,
    currentOwner: () => AuthSessionNotifier.instance.session?.cacheKey,
    isAvailable: InAppReview.instance.isAvailable,
    requestReview: InAppReview.instance.requestReview,
  );

  final bool enabled;
  final String? Function() currentOwner;
  final Future<bool> Function() _isAvailable;
  final Future<void> Function() _requestReview;
  final Duration dismissalDelay;
  bool _requesting = false;

  Future<void> requestAfterCelebration({
    required Future<void> dismissed,
    required bool Function() isSafe,
  }) async {
    final owner = currentOwner();
    try {
      // Await every dismissal path (Continue, tapping outside, or system back),
      // then let the closing animation finish before asking StoreKit.
      await dismissed;
      if (!enabled || owner == null) return;
      await Future<void>.delayed(dismissalDelay);
      if (_requesting || !isSafe() || currentOwner() != owner) return;
      _requesting = true;
      try {
        if (!await _isAvailable() || !isSafe() || currentOwner() != owner) {
          return;
        }
        await _requestReview();
      } finally {
        _requesting = false;
      }
    } catch (_) {
      // An unavailable native review must never interrupt the user.
    }
  }
}
