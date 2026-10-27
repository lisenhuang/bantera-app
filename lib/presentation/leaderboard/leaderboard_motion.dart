import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

/// Counts enter from zero when requested; live updates start at the displayed value.
class AnimatedSpokenCount extends StatelessWidget {
  const AnimatedSpokenCount({
    super.key,
    required this.value,
    required this.locale,
    required this.style,
    this.fromZero = false,
  });
  final num value;
  final bool fromZero;
  final String locale;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.decimalPattern(locale);
    Widget text(num count) => Text(format.format(count.round()), style: style);
    if (MediaQuery.disableAnimationsOf(context)) return text(value);
    return Semantics(
      label: format.format(value),
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          begin: fromZero ? 0 : value.toDouble(),
          end: value.toDouble(),
        ),
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCubic,
        builder: (_, count, _) => text(count),
      ),
    );
  }
}

/// A lazily built row retains its identity while its layout index changes.
/// The paint transform starts at its previous on-screen position in the very
/// first frame, so updates do not flash at their destination before animating.
class LeaderboardMotionRow extends StatefulWidget {
  const LeaderboardMotionRow({
    super.key,
    required this.revision,
    required this.fromTop,
    required this.scrollOffset,
    required this.child,
  });
  final int revision;
  final double? fromTop;
  final double Function() scrollOffset;
  final Widget child;
  @override
  State<LeaderboardMotionRow> createState() => LeaderboardMotionRowState();
}

class LeaderboardMotionRowState extends State<LeaderboardMotionRow>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );
  final _anchor = GlobalKey();
  bool _reduceMotion = false;
  double? get visualTop {
    final render = _anchor.currentContext?.findRenderObject();
    if (render is! _RenderRowMove || !render.attached || !render.hasSize) {
      return null;
    }
    return render.localToGlobal(Offset.zero).dy +
        render.translation +
        widget.scrollOffset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) _controller.value = 1;
  }

  @override
  void didUpdateWidget(LeaderboardMotionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revision != oldWidget.revision) {
      if (_reduceMotion || widget.fromTop == null) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (_, child) => _RowMove(
      key: _anchor,
      fromTop: widget.fromTop,
      fraction: Curves.easeInOutCubic.transform(_controller.value),
      scrollOffset: widget.scrollOffset,
      child: child!,
    ),
  );
}

class _RowMove extends SingleChildRenderObjectWidget {
  const _RowMove({
    super.key,
    required this.fromTop,
    required this.fraction,
    required this.scrollOffset,
    required super.child,
  });
  final double? fromTop;
  final double fraction;
  final double Function() scrollOffset;
  @override
  _RenderRowMove createRenderObject(BuildContext context) =>
      _RenderRowMove(fromTop, fraction, scrollOffset);
  @override
  void updateRenderObject(BuildContext context, _RenderRowMove renderObject) {
    renderObject.update(fromTop, fraction, scrollOffset);
  }
}

class _RenderRowMove extends RenderProxyBox {
  _RenderRowMove(this.fromTop, this.fraction, this.scrollOffset);
  double? fromTop;
  double fraction, translation = 0;
  double Function() scrollOffset;
  void update(double? top, double progress, double Function() scroll) {
    fromTop = top;
    fraction = progress;
    scrollOffset = scroll;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    translation = fromTop == null || fraction >= 1
        ? 0
        : (fromTop! - localToGlobal(Offset.zero).dy - scrollOffset()) *
              (1 - fraction);
    if (child != null) {
      context.paintChild(child!, offset + Offset(0, translation));
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(0, translation, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      result.addWithPaintOffset(
        offset: Offset(0, translation),
        position: position,
        hitTest: (result, transformed) =>
            child?.hitTest(result, position: transformed) ?? false,
      );
}
