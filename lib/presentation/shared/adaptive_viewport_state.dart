import 'package:flutter/material.dart';

/// Only the main tab shell consumes the system's side strip with its own rail.
/// Full-screen routes keep the usual edge protection; dialogs keep their own
/// SafeArea without shifting the page underneath them.
final adaptiveViewportState = AdaptiveViewportState();
final adaptiveViewportObserver = AdaptiveViewportObserver();

class AdaptiveViewportState extends ChangeNotifier {
  bool mainMounted = false;
  bool rootPageVisible = true;
  bool navigationVisible = true;
  bool get usesEdgeRail => mainMounted && rootPageVisible && navigationVisible;
  void update({bool? mounted, bool? rootVisible, bool? navigationVisible}) {
    this.navigationVisible = navigationVisible ?? this.navigationVisible;
    mainMounted = mounted ?? mainMounted;
    rootPageVisible = rootVisible ?? rootPageVisible;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }
}

class AdaptiveViewportObserver extends NavigatorObserver {
  final _pages = <Route<dynamic>>[];
  void _changed() =>
      adaptiveViewportState.update(rootVisible: _pages.length <= 1);
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) _pages.add(route);
    _changed();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pages.remove(route);
    _changed();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pages.remove(route);
    _changed();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _pages.indexOf(oldRoute);
    if (index >= 0) {
      if (newRoute is PageRoute) {
        _pages[index] = newRoute;
      } else {
        _pages.removeAt(index);
      }
    }
    _changed();
  }
}
