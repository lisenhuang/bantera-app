import 'package:flutter/material.dart';

/// A mounted chat workspace can receive word explanations and reminder links
/// without opening a second AI session on a different navigator.
final chatPaneNavigatorKey = GlobalKey<NavigatorState>();
VoidCallback? activateChatPane;

class ChatPaneRouteScope extends InheritedWidget {
  const ChatPaneRouteScope({
    super.key,
    required this.observer,
    required this.active,
    required super.child,
  });
  final RouteObserver<ModalRoute<dynamic>> observer;
  final bool active;
  static bool isActive(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ChatPaneRouteScope>()
          ?.active ??
      true;
  static RouteObserver<ModalRoute<dynamic>>? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ChatPaneRouteScope>()
      ?.observer;
  @override
  bool updateShouldNotify(ChatPaneRouteScope oldWidget) =>
      observer != oldWidget.observer || active != oldWidget.active;
}

/// Dialogs do not turn the chat list into a conversation. Track page routes
/// separately so dismissal, replacement and deep links restore tabs correctly.
class ChatPaneNavigationObserver extends NavigatorObserver {
  ChatPaneNavigationObserver(this.onDetailChanged);
  final ValueChanged<bool> onDetailChanged;
  final _pages = <Route<dynamic>>[];
  void _notify() => onDetailChanged(_pages.length > 1);
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) _pages.add(route);
    _notify();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pages.remove(route);
    _notify();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pages.remove(route);
    _notify();
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
    _notify();
  }
}
