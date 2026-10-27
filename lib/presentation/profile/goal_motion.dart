import 'package:flutter/material.dart';

/// One entrance sequence: counts/bars finish first, then completion badges.
class GoalMotion extends StatefulWidget {
  const GoalMotion({
    super.key,
    required this.active,
    required this.replayTick,
    required this.child,
  });
  final bool active;
  final int replayTick;
  final Widget child;
  static _GoalMotionScope? _scopeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GoalMotionScope>();
  static int revisionOf(BuildContext context) =>
      _scopeOf(context)?.revision ?? 0;
  @override
  State<GoalMotion> createState() => _GoalMotionState();
}

class _GoalMotionState extends State<GoalMotion>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
    value: 1,
  );
  bool _initialized = false, _reduce = false;
  int _revision = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _replay() {
    _revision++;
    if (_reduce || !widget.active) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (!_initialized || reduced != _reduce) {
      _initialized = true;
      _reduce = reduced;
      _replay();
    }
  }

  @override
  void didUpdateWidget(GoalMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active ||
        widget.replayTick != oldWidget.replayTick) {
      _replay();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.active) setState(_replay);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _GoalMotionScope(
    animation: _controller,
    revision: _revision,
    child: widget.child,
  );
}

class _GoalMotionScope extends InheritedWidget {
  const _GoalMotionScope({
    required this.animation,
    required this.revision,
    required super.child,
  });
  final Animation<double> animation;
  final int revision;
  @override
  bool updateShouldNotify(_GoalMotionScope oldWidget) =>
      revision != oldWidget.revision;
}

class GoalMotionBuilder extends StatelessWidget {
  const GoalMotionBuilder({super.key, required this.builder});
  final Widget Function(
    BuildContext context,
    double progress,
    double completion,
  )
  builder;
  @override
  Widget build(BuildContext context) {
    final scope = GoalMotion._scopeOf(context);
    if (scope == null) return builder(context, 1, 1);
    return AnimatedBuilder(
      animation: scope.animation,
      builder: (context, _) => builder(
        context,
        const Interval(
          0,
          .72,
          curve: Curves.easeOutCubic,
        ).transform(scope.animation.value),
        const Interval(
          .72,
          1,
          curve: Curves.easeOutCubic,
        ).transform(scope.animation.value),
      ),
    );
  }
}
