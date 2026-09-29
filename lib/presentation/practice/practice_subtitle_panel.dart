import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'subtitle_word_tokens.dart';

/// Fits the complete cue (and optional translation) into the media viewport.
class PracticeSubtitlePanel extends StatelessWidget {
  const PracticeSubtitlePanel({
    super.key,
    required this.originalText,
    required this.hasPlayableMedia,
    this.translatedText,
    this.highlightCharStarts,
    this.onWordTap,
  });

  final String originalText;
  final String? translatedText;
  final bool hasPlayableMedia;
  final Set<int>? highlightCharStarts;
  final void Function(int charStart)? onWordTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final showsTranslation = translatedText != null;
    final originalStyle = theme.textTheme.displayLarge?.copyWith(
      height: showsTranslation ? 1.28 : 1.3,
      color: hasPlayableMedia ? Colors.white : colors.onSurface,
      fontWeight: FontWeight.w700,
    );
    final translatedStyle = theme.textTheme.titleLarge?.copyWith(
      height: 1.28,
      color: hasPlayableMedia ? Colors.white : colors.primary,
      fontWeight: FontWeight.w700,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final preferredHeight = hasPlayableMedia
            ? (constraints.maxHeight * (showsTranslation ? 0.82 : 0.42)).clamp(
                156.0,
                showsTranslation ? 500.0 : 280.0,
              )
            : (showsTranslation ? 300.0 : 220.0);
        // The media area can be shorter than the preferred panel on a phone.
        final panelHeight = math.min(constraints.maxHeight, preferredHeight);
        return Align(
          alignment: hasPlayableMedia
              ? Alignment.bottomCenter
              : Alignment.center,
          child: SizedBox(
            width: double.infinity,
            height: panelHeight,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasPlayableMedia
                    ? Colors.black.withValues(alpha: 0.58)
                    : colors.surfaceContainerHighest.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(18),
              ),
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final original = _AdaptiveSubtitleText(
                    text: originalText,
                    textAlign: TextAlign.center,
                    style: originalStyle,
                    maxFontSize: hasPlayableMedia
                        ? (showsTranslation ? 28 : 30)
                        : 34,
                    highlightCharStarts: highlightCharStarts,
                    onWordTap: onWordTap,
                  );
                  if (!showsTranslation) return original;

                  final gap = math.min(
                    hasPlayableMedia ? 12.0 : 16.0,
                    contentConstraints.maxHeight * 0.1,
                  );
                  final availableHeight = contentConstraints.maxHeight - gap;
                  final originalNeed = _textHeight(
                    context,
                    originalText,
                    originalStyle,
                    hasPlayableMedia ? 28 : 34,
                    contentConstraints.maxWidth,
                  );
                  final translatedNeed = _textHeight(
                    context,
                    translatedText!,
                    translatedStyle,
                    hasPlayableMedia ? 24 : 28,
                    contentConstraints.maxWidth,
                  );
                  final originalFraction =
                      (originalNeed /
                              math.max(1.0, originalNeed + translatedNeed))
                          .clamp(0.2, 0.8);
                  final originalHeight = availableHeight * originalFraction;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: originalHeight, child: original),
                      SizedBox(height: gap),
                      SizedBox(
                        height: availableHeight - originalHeight,
                        child: _AdaptiveSubtitleText(
                          text: translatedText!,
                          textAlign: TextAlign.center,
                          style: translatedStyle,
                          maxFontSize: hasPlayableMedia ? 24 : 28,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  double _textHeight(
    BuildContext context,
    String text,
    TextStyle? style,
    double fontSize,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(
          context,
        ).style.merge(style).copyWith(fontSize: fontSize),
      ),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      textHeightBehavior: DefaultTextStyle.of(context).textHeightBehavior,
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }
}

class _AdaptiveSubtitleText extends StatefulWidget {
  const _AdaptiveSubtitleText({
    required this.text,
    required this.textAlign,
    required this.style,
    required this.maxFontSize,
    this.highlightCharStarts,
    this.onWordTap,
  });

  final String text;
  final TextAlign textAlign;
  final TextStyle? style;
  final double maxFontSize;
  final Set<int>? highlightCharStarts;
  final void Function(int charStart)? onWordTap;

  @override
  State<_AdaptiveSubtitleText> createState() => _AdaptiveSubtitleTextState();
}

class _AdaptiveSubtitleTextState extends State<_AdaptiveSubtitleText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Measure with the same inherited style, locale and scaling used to render.
    final baseStyle = DefaultTextStyle.of(context).style.merge(widget.style);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _bestFontSize(context, baseStyle, constraints);
        final effective = baseStyle.copyWith(fontSize: fontSize);
        final charStarts = widget.highlightCharStarts;
        final useRich =
            ((charStarts != null && charStarts.isNotEmpty) ||
                widget.onWordTap != null) &&
            kSubtitleWordRe.hasMatch(widget.text);

        return Align(
          alignment: Alignment.topCenter,
          child: useRich
              ? _richText(context, effective, charStarts ?? const <int>{})
              : Text(
                  widget.text,
                  textAlign: widget.textAlign,
                  style: effective,
                  softWrap: true,
                ),
        );
      },
    );
  }

  Widget _richText(BuildContext context, TextStyle base, Set<int> charStarts) {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final children = <InlineSpan>[];
    final highlightRanges = <TextRange>[];
    var last = 0;
    for (final m in subtitleWordTokens(widget.text)) {
      if (m.start > last) {
        children.add(TextSpan(text: widget.text.substring(last, m.start)));
      }
      final slice = widget.text.substring(m.start, m.end);
      final highlighted = charStarts.contains(m.start);
      if (highlighted) {
        // Touching tokens (characters of one Chinese word) share one highlight.
        if (highlightRanges.isNotEmpty && highlightRanges.last.end == m.start) {
          final previous = highlightRanges.removeLast();
          highlightRanges.add(TextRange(start: previous.start, end: m.end));
        } else {
          highlightRanges.add(TextRange(start: m.start, end: m.end));
        }
        TapGestureRecognizer? recognizer;
        if (widget.onWordTap != null) {
          final charStart = m.start;
          recognizer = TapGestureRecognizer()
            ..onTap = () {
              final line =
                  '[Bantera][WordTap] token tap gesture: '
                  'charStart=$charStart word="$slice" textLen=${widget.text.length}';
              debugPrint(line);
              developer.log(line, name: 'Bantera.WordTap');
              widget.onWordTap!(charStart);
            };
          _recognizers.add(recognizer);
        }
        children.add(TextSpan(text: slice, recognizer: recognizer));
      } else {
        TapGestureRecognizer? recognizer;
        if (widget.onWordTap != null) {
          final charStart = m.start;
          recognizer = TapGestureRecognizer()
            ..onTap = () {
              final line =
                  '[Bantera][WordTap] token tap gesture: '
                  'charStart=$charStart word="$slice" textLen=${widget.text.length}';
              debugPrint(line);
              developer.log(line, name: 'Bantera.WordTap');
              widget.onWordTap!(charStart);
            };
          _recognizers.add(recognizer);
        }
        children.add(TextSpan(text: slice, recognizer: recognizer));
      }
      last = m.end;
    }
    if (last < widget.text.length) {
      children.add(TextSpan(text: widget.text.substring(last)));
    }
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final span = TextSpan(style: base, children: children);
    return CustomPaint(
      painter: _RoundedHighlightPainter(
        text: widget.text,
        textSpan: span,
        textAlign: widget.textAlign,
        textDirection: textDirection,
        textScaler: textScaler,
        highlightRanges: highlightRanges,
        color: Theme.of(context).colorScheme.primary,
        cornerRadius: (base.fontSize ?? widget.maxFontSize) * 0.20,
      ),
      child: Text.rich(
        span,
        textAlign: widget.textAlign,
        textDirection: textDirection,
        textScaler: textScaler,
      ),
    );
  }

  double _bestFontSize(
    BuildContext context,
    TextStyle baseStyle,
    BoxConstraints constraints,
  ) {
    final painter = TextPainter(
      textAlign: widget.textAlign,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      textHeightBehavior: DefaultTextStyle.of(context).textHeightBehavior,
    );
    // Leave a little room for glyphs extending beyond their line metrics.
    final availableHeight = math.max(0.0, constraints.maxHeight - 4);
    bool fits(double fontSize) {
      painter.text = TextSpan(
        text: widget.text,
        style: baseStyle.copyWith(fontSize: fontSize),
      );
      painter.layout(maxWidth: constraints.maxWidth);
      return painter.height <= availableHeight &&
          painter.computeLineMetrics().every(
            (line) => line.width <= constraints.maxWidth,
          );
    }

    try {
      if (fits(widget.maxFontSize)) return widget.maxFontSize;
      // A fixed minimum can still clip long cues on small phones. Search the
      // entire range so every line fits without requiring scrolling.
      var low = 0.0;
      var high = widget.maxFontSize;
      for (var i = 0; i < 16; i++) {
        final mid = (low + high) / 2;
        if (fits(mid)) {
          low = mid;
        } else {
          high = mid;
        }
      }
      return low;
    } finally {
      painter.dispose();
    }
  }
}

class _RoundedHighlightPainter extends CustomPainter {
  _RoundedHighlightPainter({
    required this.text,
    required this.textSpan,
    required this.textAlign,
    required this.textDirection,
    required this.textScaler,
    required this.highlightRanges,
    required this.color,
    required this.cornerRadius,
  });

  final String text;
  final TextSpan textSpan;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final List<TextRange> highlightRanges;
  final Color color;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (highlightRanges.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    final painter = TextPainter(
      text: textSpan,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout(maxWidth: size.width);

    final paint = Paint()..color = color;
    final radius = Radius.circular(cornerRadius);
    for (final range in highlightRanges) {
      if (range.start < 0 ||
          range.end <= range.start ||
          range.end > text.length) {
        continue;
      }
      final boxes = painter.getBoxesForSelection(
        TextSelection(baseOffset: range.start, extentOffset: range.end),
      );
      for (final box in boxes) {
        canvas.drawRRect(RRect.fromRectAndRadius(box.toRect(), radius), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoundedHighlightPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.textSpan != textSpan ||
        oldDelegate.textAlign != textAlign ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.textScaler != textScaler ||
        oldDelegate.color != color ||
        oldDelegate.cornerRadius != cornerRadius ||
        !_sameRanges(oldDelegate.highlightRanges, highlightRanges);
  }

  bool _sameRanges(List<TextRange> left, List<TextRange> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i].start != right[i].start || left[i].end != right[i].end) {
        return false;
      }
    }
    return true;
  }
}
