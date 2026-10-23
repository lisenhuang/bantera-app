import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../l10n/app_localizations.dart';

/// A physical right-to-left swipe reveals an action; swiping never deletes.
class SavedPracticeTile extends StatefulWidget {
  const SavedPracticeTile({
    super.key,
    required this.cue,
    required this.subtitle,
    required this.revealed,
    required this.onReveal,
    this.onOpen,
    this.onRemove,
  });
  final String cue, subtitle;
  final bool revealed;
  final ValueChanged<bool> onReveal;
  final VoidCallback? onOpen, onRemove;
  @override
  State<SavedPracticeTile> createState() => _SavedPracticeTileState();
}

class _SavedPracticeTileState extends State<SavedPracticeTile> {
  static const _actionWidth = 96.0;
  double? _drag;
  double get _offset => _drag ?? (widget.revealed ? _actionWidth : 0);
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (_offset > 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: _actionWidth,
                  height: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      shape: const RoundedRectangleBorder(),
                    ),
                    onPressed: widget.onRemove,
                    child: Text(l.deleteLabel, textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          GestureDetector(
            onHorizontalDragStart: widget.onRemove == null
                ? null
                : (_) => setState(() => _drag = _offset),
            onHorizontalDragUpdate: widget.onRemove == null
                ? null
                : (details) => setState(
                    () => _drag = (_offset - details.delta.dx).clamp(
                      0,
                      _actionWidth,
                    ),
                  ),
            onHorizontalDragEnd: widget.onRemove == null
                ? null
                : (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    final open =
                        velocity < -200 ||
                        (velocity <= 200 && _offset > _actionWidth / 2);
                    setState(() => _drag = null);
                    widget.onReveal(open);
                  },
            onHorizontalDragCancel: () => setState(() => _drag = null),
            child: AnimatedContainer(
              duration: Duration(milliseconds: _drag == null ? 180 : 0),
              transform: Matrix4.translationValues(-_offset, 0, 0),
              color: colors.surfaceContainerLow,
              child: Semantics(
                customSemanticsActions: widget.onRemove == null
                    ? null
                    : {
                        CustomSemanticsAction(label: l.deleteLabel):
                            widget.onRemove!,
                      },
                child: ListTile(
                  title: Text(widget.cue),
                  subtitle: Text(widget.subtitle),
                  onTap: widget.revealed
                      ? () => widget.onReveal(false)
                      : widget.onOpen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
