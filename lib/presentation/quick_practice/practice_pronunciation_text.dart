import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'practice_pronunciation_alignment.dart';
import '../practice/subtitle_word_tokens.dart';
import 'practice_word_text.dart';
import 'practice_word_boundaries.dart';

/// Aligned ruby-like readings. Original sentence offsets still drive word taps.
class PracticePronunciationText extends StatefulWidget {
  const PracticePronunciationText(
    this.text, {
    super.key,
    required this.segments,
    this.locale = '',
    this.style,
    this.textDirection,
    this.selectedWord,
    required this.onSelect,
    required this.onWord,
  });
  final String text;
  final String locale;
  final List<dynamic> segments;
  final TextStyle? style;
  final TextDirection? textDirection;
  final SubtitleWordToken? selectedWord;
  final ValueChanged<SubtitleWordToken> onSelect, onWord;
  @override
  State<PracticePronunciationText> createState() =>
      _PracticePronunciationTextState();
}

class _PracticePronunciationTextState extends State<PracticePronunciationText> {
  List<SubtitleWordToken> _tokens = [];
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(PracticePronunciationText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.locale != widget.locale) {
      _resolve();
    }
  }

  void _resolve() {
    final generation = ++_generation;
    _tokens = practiceWordFallback(widget.text);
    PracticeWordBoundaries.resolve(widget.text, widget.locale).then((tokens) {
      if (!mounted || generation != _generation) return;
      setState(() => _tokens = tokens);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final segments = widget.segments;
    final style = widget.style;
    final textDirection = widget.textDirection;
    final onSelect = widget.onSelect;
    final onWord = widget.onWord;
    // A user may tap before native boundaries arrive. Expand that selection
    // to the containing word so the next tap still confirms the same word.
    final original = widget.selectedWord;
    final selectedWord = original == null
        ? null
        : _tokens
              .where((t) => t.start <= original.start && t.end > original.start)
              .firstOrNull;
    final valid = PracticePronunciationAlignment.valid(
      segments,
      text,
      widget.locale,
    );
    if (!valid) {
      return PracticeWordText(
        text,
        style: style,
        textDirection: textDirection,
        selectedWord: selectedWord,
        words: _tokens,
        onSelect: onSelect,
        onWord: onWord,
      );
    }
    final tokens = _tokens;
    final direction = textDirection ?? Directionality.of(context);
    final sourceStyle = DefaultTextStyle.of(context).style.merge(style);
    final readingStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: Theme.of(context).colorScheme.primary,
      height: 1.2,
    );
    final scaler = MediaQuery.textScalerOf(context);
    double width(String value, TextStyle style, TextDirection direction) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: style),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      final result = painter.width;
      painter.dispose();
      return result;
    }

    // Punctuation belongs to its neighbouring unit, never a separate wrap item.
    // Each unit retains its own original offsets for independent word selection.
    final groups = <List<({String source, String reading, int start})>>[];
    var prefix = <({String source, String reading, int start})>[];
    var offset = 0;
    for (final p in segments) {
      final source = p['text'] as String, reading = p['reading'] as String;
      final unit = (source: source, reading: reading, start: offset);
      offset += source.length;
      if (reading.isEmpty) {
        if (source.contains('\n')) {
          if (prefix.isNotEmpty) {
            groups.add(prefix);
            prefix = [];
          }
          groups.add([unit]);
        } else if (RegExp(r'^[\s]*[（(「『【“‘]').hasMatch(source) ||
            groups.isEmpty ||
            groups.last.first.source.contains('\n')) {
          prefix.add(unit);
        } else {
          groups.last.add(unit);
        }
      } else {
        groups.add([...prefix, unit]);
        prefix = [];
      }
    }
    if (prefix.isNotEmpty) {
      if (groups.isEmpty) {
        groups.add(prefix);
      } else {
        groups.last.addAll(prefix);
      }
    }
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onLongPressStart: (details) async {
        final overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final position = overlay.globalToLocal(details.globalPosition);
        final copy = await showMenu<bool>(
          context: context,
          position: RelativeRect.fromSize(
            Rect.fromLTWH(position.dx, position.dy, 0, 0),
            overlay.size,
          ),
          items: [
            PopupMenuItem(
              value: true,
              child: Text(MaterialLocalizations.of(context).copyButtonLabel),
            ),
          ],
        );
        if (copy == true) await Clipboard.setData(ClipboardData(text: text));
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final children = <Widget>[];
          for (final group in groups) {
            if (group.length == 1 && group.first.source.contains('\n')) {
              children.add(
                SizedBox(
                  width: constraints.maxWidth,
                  height: sourceStyle.fontSize ?? 16,
                ),
              );
              continue;
            }
            final units = <Widget>[];
            var totalWidth = 0.0;
            for (final unit in group) {
              final source = unit.source,
                  reading = unit.reading,
                  start = unit.start;
              final end = start + source.length;
              final selected = selectedWord;
              final selectionOverlaps =
                  selected != null &&
                  selected.start < end &&
                  selected.end > start;
              // Reserve enough width for the selected bold source without
              // shifting its reading onto the next unit or clipping glyphs.
              final naturalWidth = width(
                source,
                selectionOverlaps
                    ? sourceStyle.copyWith(fontWeight: FontWeight.w700)
                    : sourceStyle,
                direction,
              );
              final readingWidth = width(
                reading,
                readingStyle,
                TextDirection.ltr,
              );
              final unitWidth =
                  (naturalWidth > readingWidth ? naturalWidth : readingWidth) +
                  (reading.isEmpty ? 0 : 2);
              totalWidth += unitWidth;
              SubtitleWordToken whole(SubtitleWordToken part) =>
                  tokens.firstWhere(
                    (t) =>
                        t.start <= start + part.start &&
                        t.end > start + part.start,
                    orElse: () => SubtitleWordToken(
                      start + part.start,
                      start + part.end,
                      part.text,
                    ),
                  );
              final a = selected == null
                  ? 0
                  : (selected.start - start).clamp(0, source.length);
              final b = selected == null
                  ? 0
                  : (selected.end - start).clamp(0, source.length);
              final localSelected = a < b
                  ? SubtitleWordToken(a, b, source.substring(a, b))
                  : null;
              units.add(
                SizedBox(
                  width: unitWidth,
                  child: Semantics(
                    container: true,
                    explicitChildNodes: true,
                    sortKey: OrdinalSortKey(start.toDouble()),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ExcludeSemantics(
                          child: Text(
                            reading.isEmpty ? ' ' : reading,
                            softWrap: false,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: readingStyle,
                          ),
                        ),
                        Center(
                          child: PracticeWordText(
                            source,
                            style: sourceStyle,
                            textDirection: direction,
                            selectedWord: localSelected,
                            softWrap: false,
                            words: tokens
                                .where((t) => t.start < end && t.end > start)
                                .map((t) {
                                  final a = (t.start - start).clamp(
                                    0,
                                    source.length,
                                  );
                                  final b = (t.end - start).clamp(
                                    0,
                                    source.length,
                                  );
                                  return SubtitleWordToken(
                                    a,
                                    b,
                                    source.substring(a, b),
                                  );
                                })
                                .toList(),
                            onSelect: (t) => onSelect(whole(t)),
                            onWord: (t) => onWord(whole(t)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final row = Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: direction,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: units,
            );
            // A long word remains one mapping. Scroll it at the user's text size
            // instead of shrinking, clipping or wrapping the two lines separately.
            children.add(
              totalWidth > constraints.maxWidth
                  ? SizedBox(
                      width: constraints.maxWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: direction == TextDirection.rtl,
                        child: row,
                      ),
                    )
                  : row,
            );
          }
          return Wrap(
            textDirection: direction,
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: 6,
            children: children,
          );
        },
      ),
    );
  }
}
