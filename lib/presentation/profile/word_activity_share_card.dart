import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';
import '../shared/learning_language_label.dart';

/// Fixed logical canvas, exported at 2x for a 1080 × 1920 story.
/// Text is measured inside its own slot; artwork never contains baked-in copy.
class WordActivityShareCard extends StatelessWidget {
  const WordActivityShareCard({
    super.key,
    required this.name,
    required this.today,
    required this.week,
    required this.total,
    this.avatar,
    this.learningLanguage,
  });
  static const size = Size(540, 960);
  static const backgroundAsset =
      'assets/word_activity/share-editorial-background.png';
  static const qrAsset = 'assets/word_activity/homepage-qr.png';
  static const _ink = Color(0xFF142D27);
  static const _muted = Color(0xFF62716A);
  final String name;
  final WordTotals today;
  // Kept in the public contract for callers; this artwork celebrates today.
  final WordTotals week;
  final WordTotals total;
  final ImageProvider? avatar;
  final String? learningLanguage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final language = learningLanguageLabel(learningLanguage);
    final languageName = switch (language.name) {
      'English' => l10n.languageEnglish,
      'Japanese' => l10n.languageJapanese,
      'Korean' => l10n.languageKorean,
      _ => language.name,
    };
    return SizedBox.fromSize(
      size: size,
      child: MediaQuery.withNoTextScaling(
        child: ColoredBox(
          color: const Color(0xFFF7F5EC),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(backgroundAsset, fit: BoxFit.fill),
              ),
              Positioned(
                top: 52,
                left: 34,
                right: 160,
                height: 76,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 37,
                      backgroundColor: const Color(0xFFD9C9F7),
                      foregroundImage: avatar,
                      child: avatar == null
                          ? const Icon(Icons.person, color: _ink, size: 38)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _ArtworkText(
                              name,
                              fontSize: 27,
                              weight: FontWeight.w700,
                              maxLines: 2,
                            ),
                          ),
                          if (language.name.isNotEmpty)
                            SizedBox(
                              height: 30,
                              child: Row(
                                children: [
                                  Text(
                                    language.flag,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: _ink,
                                      decoration: TextDecoration.none,
                                      fontFamilyFallback: [
                                        'Apple Color Emoji',
                                        'Noto Color Emoji',
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _ArtworkText(
                                      languageName,
                                      fontSize: 17,
                                      maxLines: 2,
                                      color: _muted,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 68,
                right: 34,
                width: 96,
                height: 37,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: _ink, width: 1.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: _ArtworkText(
                    l10n.wordActivityShareToday,
                    fontSize: 16,
                    maxLines: 2,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              Positioned(
                top: 140,
                left: 34,
                right: 34,
                height: 190,
                child: _ArtworkText(
                  l10n.wordActivityShareHeading(
                    language.name.replaceAll(' ', '_').replaceAll('å', 'a'),
                  ),
                  fontSize: 94,
                  lineHeight: 1,
                  maxLines: 3,
                  weight: FontWeight.w900,
                  alignment: Alignment.topLeft,
                ),
              ),
              Positioned(
                top: 394,
                left: 98,
                right: 65,
                height: 43,
                child: _ArtworkText(
                  l10n.wordActivityShareSpokenToday,
                  fontSize: 30,
                  maxLines: 2,
                ),
              ),
              Positioned(
                top: 428,
                left: 94,
                right: 72,
                height: 145,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: SizedBox(
                        height: 145,
                        child: _ArtworkText(
                          number.format(today.spoken),
                          key: const ValueKey('share-spoken-number'),
                          fontSize: 180,
                          lineHeight: .9,
                          letterSpacing: -1.5,
                          weight: FontWeight.w900,
                          alignment: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 62,
                      height: 52,
                      child: _ArtworkText(
                        l10n.wordActivityShareWordUnit(today.spoken),
                        key: const ValueKey('share-spoken-unit'),
                        fontSize: 30,
                        maxLines: 1,
                        alignment: Alignment.bottomLeft,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 650,
                left: 50,
                right: 50,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.headphones_outlined,
                      size: 46,
                      color: _ink,
                    ),
                    const SizedBox(width: 17),
                    Flexible(
                      child: _ArtworkText(
                        l10n.wordActivityShareListened(today.listened),
                        key: const ValueKey('share-listened'),
                        fontSize: 28,
                        emphasizedText: number.format(today.listened),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 740,
                left: 34,
                right: 34,
                height: 58,
                child: _ArtworkText(
                  l10n.wordActivityShareEncouragement,
                  weight: FontWeight.w700,
                  fontSize: 29,
                  maxLines: 2,
                ),
              ),
              const Positioned(
                top: 809,
                left: 34,
                right: 34,
                height: 1,
                child: ColoredBox(color: Color(0xFFACB8AE)),
              ),
              Positioned(
                top: 840,
                left: 34,
                right: 158,
                height: 86,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Image.asset(
                        'assets/icon.png',
                        width: 75,
                        height: 75,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 42,
                            child: _ArtworkText(
                              'Bantera',
                              fontSize: 38,
                              weight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(
                            height: 26,
                            child: _ArtworkText(
                              l10n.wordActivityShareInvitation,
                              fontSize: 17,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                            child: _ArtworkText(
                              'bantera.app',
                              fontSize: 14,
                              color: _muted,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 825,
                right: 30,
                width: 116,
                height: 116,
                child: Column(
                  children: [
                    // Includes the original white quiet zone; no rounded mask.
                    Image.asset(
                      qrAsset,
                      // Keep the source quiet zone inside the reference-sized tile.
                      width: 96,
                      height: 96,
                      filterQuality: FilterQuality.none,
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: _ArtworkText(
                        l10n.wordActivityScanToJoin,
                        fontSize: 12,
                        maxLines: 2,
                        color: _muted,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Measures real localized glyphs, grouping separators and line breaks before
/// choosing a font size. Unlike scaling a whole row, the number cannot shrink
/// its unit, and translated labels cannot push neighbouring elements around.
class _ArtworkText extends StatelessWidget {
  const _ArtworkText(
    this.text, {
    super.key,
    required this.fontSize,
    this.maxLines = 1,
    this.weight = FontWeight.w500,
    this.color = WordActivityShareCard._ink,
    this.alignment = Alignment.centerLeft,
    this.lineHeight,
    this.letterSpacing = 0,
    this.emphasizedText,
  });
  final String text;
  final double fontSize;
  final int maxLines;
  final FontWeight weight;
  final Color color;
  final Alignment alignment;
  final double? lineHeight;
  final double letterSpacing;
  final String? emphasizedText;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final locale = Localizations.localeOf(context);
      final script = switch (locale.languageCode) {
        'zh' => locale.scriptCode == 'Hant' ? 'TC' : 'SC',
        'ja' => 'JP',
        'ko' => 'KR',
        'th' => 'Thai',
        _ => null,
      };
      final latinFamily =
          'BanteraShareLatin${weight.value >= FontWeight.w800.value
              ? 900
              : weight.value >= FontWeight.w700.value
              ? 700
              : 600}';
      final scriptFamily = script == null
          ? null
          : 'BanteraShare$script${weight.value >= FontWeight.w800.value ? 900 : 600}';
      final hasScriptText =
          script != null &&
          text.runes.any(
            (rune) => rune >= 0x2e80 || (rune >= 0x0e00 && rune <= 0x0e7f),
          );
      final base = Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontFamily: hasScriptText ? scriptFamily : latinFamily,
        fontFamilyFallback: [
          latinFamily,
          ?scriptFamily,
          ...?Theme.of(context).textTheme.bodyMedium!.fontFamilyFallback,
        ],
        color: color,
        fontWeight: weight,
        // Thai tone marks and vowels need more room between headline lines.
        height: locale.languageCode == 'th' ? 1.35 : (lineHeight ?? 1.15),
        letterSpacing: letterSpacing,
        fontSize: fontSize,
      );
      final direction = Directionality.of(context);
      final painter = TextPainter(
        textDirection: direction,
        locale: locale,
        maxLines: maxLines,
        textScaler: TextScaler.noScaling,
      );
      TextSpan span(double size) {
        final style = base.copyWith(fontSize: size);
        final emphasis = emphasizedText;
        final index = emphasis == null ? -1 : text.indexOf(emphasis);
        if (index < 0) return TextSpan(text: text, style: style);
        return TextSpan(
          style: style,
          children: [
            TextSpan(text: text.substring(0, index)),
            TextSpan(
              text: emphasis,
              style: style.copyWith(
                fontFamily: 'BanteraShareLatin900',
                fontWeight: FontWeight.w900,
                fontSize: size * 1.85,
                height: 1,
              ),
            ),
            TextSpan(text: text.substring(index + emphasis!.length)),
          ],
        );
      }

      bool fits(double size) {
        painter.text = span(size);
        painter.layout(maxWidth: constraints.maxWidth);
        return !painter.didExceedMaxLines &&
            painter.width <= constraints.maxWidth &&
            painter.height <= constraints.maxHeight;
      }

      var chosen = fontSize;
      if (!fits(chosen)) {
        var low = 1.0;
        var high = fontSize;
        for (var i = 0; i < 14; i++) {
          final mid = (low + high) / 2;
          if (fits(mid)) {
            low = mid;
          } else {
            high = mid;
          }
        }
        chosen = low;
      }
      painter.dispose();
      return Align(
        alignment: alignment,
        widthFactor: 1,
        heightFactor: 1,
        child: Text.rich(
          span(chosen),
          style: base.copyWith(fontSize: chosen),
          locale: locale,
          maxLines: maxLines,
          textScaler: TextScaler.noScaling,
          textAlign: alignment == Alignment.center
              ? TextAlign.center
              : TextAlign.start,
        ),
      );
    },
  );
}
