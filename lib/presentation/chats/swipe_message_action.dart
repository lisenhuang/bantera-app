import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../l10n/app_localizations.dart';

/// Reveals an explicit action without dismissing a message or changing its style.
class SwipeMessageAction extends StatefulWidget {
  const SwipeMessageAction({
    super.key,
    required this.child,
    this.onDelete,
    this.adminAction = false,
  });
  final Widget child;
  final Future<void> Function()? onDelete;
  final bool adminAction;
  @override
  State<SwipeMessageAction> createState() => _SwipeMessageActionState();
}

class _SwipeMessageActionState extends State<SwipeMessageAction> {
  static const width = 56.0;
  bool _open = false, _busy = false;
  double? _drag;
  bool get _enabled => widget.onDelete != null && !_busy;
  double get _offset =>
      widget.onDelete == null ? 0 : _drag ?? (_open ? width : 0);
  Future<void> _delete() async {
    if (!_enabled) return;
    setState(() {
      _busy = true;
      _open = false;
      _drag = null;
    });
    try {
      await widget.onDelete!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            if (_offset > 0)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: width,
                    height: 56,
                    child: Center(
                      child: IconButton(
                        tooltip: l.deleteLabel,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          maximumSize: const Size(48, 48),
                          backgroundColor: Colors.transparent,
                          foregroundColor: c.error,
                        ),
                        onPressed: _enabled ? _delete : null,
                        icon: widget.adminAction
                            ? const SizedBox(
                                width: 32,
                                height: 32,
                                child: Stack(
                                  children: [
                                    Center(child: Icon(Icons.delete_outline)),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Icon(
                                        Icons.admin_panel_settings_outlined,
                                        size: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
                ),
              ),
            GestureDetector(
              onHorizontalDragStart: !_enabled
                  ? null
                  : (_) => setState(() => _drag = _offset),
              onHorizontalDragUpdate: !_enabled
                  ? null
                  : (d) => setState(
                      () => _drag = (_offset - d.delta.dx).clamp(0, width),
                    ),
              onHorizontalDragEnd: !_enabled
                  ? null
                  : (d) => setState(() {
                      final velocity = d.primaryVelocity ?? 0;
                      _open =
                          velocity < -200 ||
                          (velocity <= 200 && _offset > width / 2);
                      _drag = null;
                    }),
              onHorizontalDragCancel: () => setState(() => _drag = null),
              child: AnimatedContainer(
                duration: Duration(milliseconds: _drag == null ? 180 : 0),
                transform: Matrix4.translationValues(-_offset, 0, 0),
                child: Semantics(
                  customSemanticsActions: !_enabled
                      ? null
                      : {CustomSemanticsAction(label: l.deleteLabel): _delete},
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
