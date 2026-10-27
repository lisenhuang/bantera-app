import 'chat_pane_navigation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../shared/adaptive_layout.dart';
import 'ai/ai_chat_screen.dart';
import 'chats_screen.dart';

/// The detail navigator stays mounted when the list collapses. A window resize
/// must never dispose an in-flight recorder, AI session or message scroll view.
class AdaptiveChatsScreen extends StatefulWidget {
  const AdaptiveChatsScreen({
    super.key,
    required this.active,
    this.onDetailChanged,
  });
  final bool active;
  final ValueChanged<bool>? onDetailChanged;
  @override
  State<AdaptiveChatsScreen> createState() => _AdaptiveChatsScreenState();
}

class _AdaptiveChatsScreenState extends State<AdaptiveChatsScreen> {
  final _navigator = chatPaneNavigatorKey;
  final _routes = RouteObserver<ModalRoute<dynamic>>();
  late final _observer = ChatPaneNavigationObserver(_changed);
  bool _detail = false;
  void _changed(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (value != _detail) {
        setState(() => _detail = value);
        widget.onDetailChanged?.call(value);
      }
    });
  }

  void _open(WidgetBuilder builder) {
    _navigator.currentState?.push(MaterialPageRoute<void>(builder: builder));
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.active || !_detail,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && widget.active) _navigator.currentState?.maybePop();
    },
    child: AdaptiveColumns(
      fillHeight: true,
      minimumPaneWidth: 320,
      firstFraction: .38,
      gap: 1,
      singlePane: _detail ? 1 : 0,
      textScale: MediaQuery.textScalerOf(context).scale(1),
      regions: AdaptiveLayoutScope.of(context).regions,
      first: _PaneViewport(
        child: ChatsScreen(
          active: widget.active,
          onOpen: _open,
          onOpenAi: () {
            final navigator = _navigator.currentState;
            if (navigator != null) unawaited(openAiChatInNavigator(navigator));
          },
        ),
      ),
      second: _PaneViewport(
        child: ChatPaneRouteScope(
          observer: _routes,
          active: widget.active,
          child: Navigator(
            key: _navigator,
            observers: [_observer, _routes],
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.chatsTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PaneViewport extends StatelessWidget {
  const _PaneViewport({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: LayoutBuilder(
      builder: (context, constraints) => MediaQuery(
        data: MediaQuery.of(context).copyWith(size: constraints.biggest),
        child: child,
      ),
    ),
  );
}
