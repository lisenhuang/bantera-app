import 'package:flutter/material.dart';

/// Chronological items laid out from the bottom, so the first rendered frame
/// already contains the latest message, including after a cached-history refresh.
class NewestMessageList extends StatefulWidget {
  const NewestMessageList({
    super.key,
    required this.newestMessageId,
    required this.newestIsMine,
    required this.messageIds,
    required this.itemBuilder,
    this.padding,
  });

  final String newestMessageId;
  final bool newestIsMine;
  final List<String> messageIds;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;

  @override
  State<NewestMessageList> createState() => _NewestMessageListState();
}

class _NewestMessageListState extends State<NewestMessageList> {
  final _scroll = ScrollController(keepScrollOffset: false);
  int _viewport = 0;

  @override
  void didUpdateWidget(NewestMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.newestMessageId == widget.newestMessageId) return;
    final atBottom = !_scroll.hasClients || _scroll.offset <= 80;
    if (atBottom || widget.newestIsMine) {
      // A fresh bottom-anchored viewport avoids lazy, variable-height children
      // correcting a post-frame jump back away from the newest message.
      _viewport++;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
    key: ValueKey(_viewport),
    controller: _scroll,
    reverse: true,
    padding: widget.padding,
    itemCount: widget.messageIds.length,
    findChildIndexCallback: (key) {
      if (key is! ValueKey<String>) return null;
      final index = widget.messageIds.indexOf(key.value);
      return index < 0 ? null : widget.messageIds.length - 1 - index;
    },
    itemBuilder: (context, index) {
      final chronologicalIndex = widget.messageIds.length - 1 - index;
      return KeyedSubtree(
        key: ValueKey(widget.messageIds[chronologicalIndex]),
        child: widget.itemBuilder(context, chronologicalIndex),
      );
    },
  );
}
