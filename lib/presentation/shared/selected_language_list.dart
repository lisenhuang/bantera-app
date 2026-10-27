import 'package:flutter/material.dart';

/// These short language catalogues are laid out together so the selected row
/// can be positioned accurately, including wrapped names and large text.
class SelectedLanguageList extends StatefulWidget {
  const SelectedLanguageList({
    super.key,
    required this.controller,
    required this.identifiers,
    required this.selectedIdentifier,
    required this.itemBuilder,
  });
  final ScrollController controller;
  final List<String> identifiers;
  final String? selectedIdentifier;
  final Widget Function(BuildContext, int) itemBuilder;
  @override
  State<SelectedLanguageList> createState() => _SelectedLanguageListState();
}

class _SelectedLanguageListState extends State<SelectedLanguageList> {
  final _selected = GlobalKey();
  String normalize(String? value) =>
      (value ?? '').trim().replaceAll('_', '-').toLowerCase();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selected.currentContext == null) return;
      Scrollable.ensureVisible(_selected.currentContext!, alignment: .35);
    });
  }

  @override
  void didUpdateWidget(SelectedLanguageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identifiers.join('|') != widget.identifiers.join('|')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.hasClients)
          widget.controller.jumpTo(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    controller: widget.controller,
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    child: Column(
      children: [
        for (var i = 0; i < widget.identifiers.length; i++)
          KeyedSubtree(
            key:
                normalize(widget.identifiers[i]) ==
                    normalize(widget.selectedIdentifier)
                ? _selected
                : null,
            child: widget.itemBuilder(context, i),
          ),
      ],
    ),
  );
}
