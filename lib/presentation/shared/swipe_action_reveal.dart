import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class SwipeRevealAction {
  const SwipeRevealAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });
  final String label;
  final Widget icon;
  final FutureOr<void> Function() onPressed;
  final Color backgroundColor, foregroundColor;
}

/// A right-to-left swipe reveals explicit actions; it never executes them.
/// All instances share one open row, including different kinds of cards.
class SwipeActionReveal extends StatefulWidget {
  const SwipeActionReveal({
    super.key,
    required this.child,
    required this.actions,
    this.surfaceColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });
  final Widget child;
  final List<SwipeRevealAction> actions;
  final Color? surfaceColor;
  final BorderRadius borderRadius;
  @override
  State<SwipeActionReveal> createState() => _SwipeActionRevealState();
}

class _SwipeActionRevealState extends State<SwipeActionReveal> {
  // Covers message bubbles and other lists; released on close/disposal.
  static _SwipeActionRevealState? _active;
  static const _buttonSize = 52.0;
  static const _slotWidth = 64.0;
  static const _edgePadding = 8.0;
  bool _open = false, _busy = false;
  double? _drag;
  double _actionTop = 0;
  bool get _enabled => widget.actions.isNotEmpty && !_busy;
  double get _actionWidth =>
      widget.actions.length * _slotWidth + _edgePadding * 2;
  double get _offset =>
      widget.actions.isEmpty ? 0 : _drag ?? (_open ? _actionWidth : 0);

  void _claim() {
    if (identical(_active, this)) return;
    _active?._close();
    _active = this;
  }

  void _close() {
    if (identical(_active, this)) _active = null;
    if (!mounted || (!_open && _drag == null)) return;
    setState(() {
      _open = false;
      _drag = null;
    });
  }

  Future<void> _run(SwipeRevealAction action) async {
    if (!_enabled) return;
    _close();
    setState(() => _busy = true);
    try {
      await action.onPressed();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void didUpdateWidget(SwipeActionReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.actions.isEmpty) {
      if (identical(_active, this)) _active = null;
      _open = false;
      _drag = null;
    } else if (_drag != null) {
      _drag = _drag!.clamp(0, _actionWidth);
    }
  }

  @override
  void dispose() {
    if (identical(_active, this)) _active = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final revealed = _offset > 0;
    return TapRegion(
      enabled: revealed,
      // Keep the outside gesture usable, including opening another row.
      onTapOutside: (_) => _close(),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          children: [
            if (revealed)
              Positioned(
                top: _actionTop,
                right: 0,
                width: _actionWidth,
                height: _buttonSize + 16,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _edgePadding),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      for (final action in widget.actions)
                        SizedBox(
                          width: _slotWidth,
                          child: Center(
                            child: IconButton.filled(
                              tooltip: action.label,
                              onPressed: _enabled ? () => _run(action) : null,
                              style: IconButton.styleFrom(
                                minimumSize: const Size.square(_buttonSize),
                                maximumSize: const Size.square(_buttonSize),
                                shape: const CircleBorder(),
                                backgroundColor: action.backgroundColor,
                                foregroundColor: action.foregroundColor,
                              ),
                              iconSize: 26,
                              icon: action.icon,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            GestureDetector(
              // The revealed buttons sit behind this translated child. Do not
              // intercept their exposed area with the original row bounds.
              behavior: revealed
                  ? HitTestBehavior.deferToChild
                  : HitTestBehavior.opaque,
              onTap: revealed ? _close : null,
              onHorizontalDragStart: !_enabled
                  ? null
                  : (details) {
                      _claim();
                      final height = context.size?.height ?? _buttonSize + 16;
                      setState(() {
                        _drag = _offset;
                        // Keep actions beside the swipe even when a long AI
                        // response extends well beyond the visible viewport.
                        _actionTop =
                            (details.localPosition.dy - (_buttonSize + 16) / 2)
                                .clamp(
                                  0,
                                  (height - _buttonSize - 16).clamp(
                                    0,
                                    double.infinity,
                                  ),
                                );
                      });
                    },
              onHorizontalDragUpdate: !_enabled
                  ? null
                  : (details) {
                      // A second pointer may already have opened another row.
                      if (!identical(_active, this)) return;
                      setState(
                        () => _drag = (_offset - details.delta.dx).clamp(
                          0,
                          _actionWidth,
                        ),
                      );
                    },
              onHorizontalDragEnd: !_enabled
                  ? null
                  : (details) {
                      if (!identical(_active, this)) return;
                      final velocity = details.primaryVelocity ?? 0;
                      final open =
                          velocity < -200 ||
                          (velocity <= 200 && _offset > _actionWidth / 2);
                      setState(() {
                        _open = open;
                        _drag = null;
                      });
                      if (!open) _active = null;
                    },
              onHorizontalDragCancel: () {
                if (!identical(_active, this)) return;
                setState(() => _drag = null);
                if (!_open) _active = null;
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: _drag == null ? 180 : 0),
                transform: Matrix4.translationValues(-_offset, 0, 0),
                color: widget.surfaceColor,
                constraints: widget.actions.isEmpty
                    ? null
                    : BoxConstraints(
                        minWidth: _actionWidth,
                        minHeight: _buttonSize + 16,
                      ),
                child: Semantics(
                  customSemanticsActions: !_enabled
                      ? null
                      : {
                          for (final action in widget.actions)
                            CustomSemanticsAction(label: action.label): () =>
                                _run(action),
                        },
                  // Shifted content closes first instead of following links,
                  // starting playback or navigating underneath the actions.
                  child: AbsorbPointer(
                    absorbing: revealed,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
