import 'dart:async';
import 'package:flutter/material.dart';

/// One conversation route, including taps arriving during push/pop animations.
class AiChatNavigation {
  PageRoute<void>? _route;

  Future<void> open(NavigatorState navigator, WidgetBuilder builder) async {
    // A notification or second tap must not change the stack mid-swipe.
    if (navigator.userGestureInProgress) {
      final ended = Completer<void>();
      final gestures = navigator.userGestureInProgressNotifier;
      void changed() {
        if (!gestures.value && !ended.isCompleted) ended.complete();
      }

      gestures.addListener(changed);
      try {
        await ended.future;
      } finally {
        gestures.removeListener(changed);
      }
    }
    if (!navigator.mounted) return;
    final existing = _route;
    if (existing != null) {
      // The old page is already popping, but still owns its transition. Wait
      // for removal before reopening instead of pushing onto that animation.
      if (!existing.isActive) {
        await existing.completed;
        if (navigator.mounted) await open(navigator, builder);
      } else if (existing.navigator == navigator && !existing.isCurrent) {
        navigator.popUntil(
          (route) => identical(route, existing) || route.isFirst,
        );
      }
      return;
    }
    final route = MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/ai-chat'),
      builder: builder,
    );
    // Reserve before push: the page's first build happens on a later frame.
    _route = route;
    try {
      navigator.push(route);
      await route.completed;
    } finally {
      if (identical(_route, route)) _route = null;
    }
  }
}
