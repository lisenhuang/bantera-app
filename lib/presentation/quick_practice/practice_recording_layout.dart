import '../shared/adaptive_layout.dart';
import 'package:flutter/material.dart';
import 'practice_record_control.dart';

/// Keep both the mic's offset and scroll extent stable during recording startup
/// and recording. Background readings/translations appear after release.
class PracticeRecordingLayout extends StatefulWidget {
  const PracticeRecordingLayout({
    super.key,
    required this.pinned,
    required this.children,
  });
  final bool pinned;
  final List<Widget> children;

  @override
  State<PracticeRecordingLayout> createState() =>
      _PracticeRecordingLayoutState();
}

class _PracticeRecordingLayoutState extends State<PracticeRecordingLayout> {
  List<Widget>? _before, _after;

  @override
  Widget build(BuildContext context) {
    final mic = widget.children.indexWhere(
      (child) => child is PracticeRecordControl || child is AdaptiveColumns,
    );
    if (mic < 0) {
      if (!widget.pinned || _before == null) _before = widget.children;
      _after = null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _before!,
      );
    }
    if (!widget.pinned || _before == null) {
      _before = widget.children.take(mic).toList();
      _after = widget.children.skip(mic + 1).toList();
    }
    Widget section(List<Widget> children) => IgnorePointer(
      ignoring: widget.pinned,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [section(_before!), widget.children[mic], section(_after!)],
    );
  }
}
