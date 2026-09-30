import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';
import '../shared/learning_language_label.dart';

/// Fixed logical canvas, exported at 2x for a 1080 × 1920 story.
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
  final String name;
  final WordTotals today;
  final WordTotals week;
  final WordTotals total;
  final ImageProvider? avatar;
  final String? learningLanguage;
  static const backgroundAsset = 'assets/word_activity/share-background.png';
  static const qrAsset = 'assets/word_activity/homepage-qr.png';
  static const _muted = Color(0xFFD1C5FF);

  Widget _fit(
    String text,
    double size, {
    Color color = Colors.white,
    FontWeight weight = FontWeight.w600,
  }) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.05,
      ),
    ),
  );

  BoxDecoration get _panel => BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: const LinearGradient(
      colors: [Color(0xB04D3C97), Color(0x85352877)],
    ),
    border: Border.all(color: const Color(0xFFA58BFF), width: 1),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF6B4EE6).withValues(alpha: .28),
        blurRadius: 16,
      ),
    ],
  );

  Widget _stat(IconData icon, String value, String label) => Container(
    decoration: _panel,
    padding: const EdgeInsets.all(24),
    child: Row(
      children: [
        Container(
          width: 94,
          height: 94,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x705D3DA9),
            border: Border.all(color: const Color(0xFFAE95FF)),
          ),
          child: Icon(icon, size: 64, color: const Color(0xFFF0E8FF)),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _fit(value, 76, weight: FontWeight.w800)),
              const SizedBox(height: 6),
              SizedBox(
                height: 26,
                child: _fit(
                  label,
                  27,
                  color: const Color(0xFFF0E8FF),
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final languageLabel = learningLanguageLabel(learningLanguage);
    final languageName = languageLabel.name;
    final languageFlag = languageLabel.flag;
    return SizedBox.fromSize(
      size: size,
      child: MediaQuery.withNoTextScaling(
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white, fontSize: 18),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(backgroundAsset, fit: BoxFit.cover),
              ),
              Positioned(
                top: 48,
                left: 36,
                right: 36,
                height: 84,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFF9470F5),
                      foregroundImage: avatar,
                      child: avatar == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 45,
                            )
                          : null,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: languageName.isEmpty ? 64 : 40,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 350,
                                ),
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (languageName.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 26,
                              child: Row(
                                children: [
                                  Text(
                                    languageFlag,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontFamilyFallback: [
                                        'Apple Color Emoji',
                                        'Noto Color Emoji',
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _fit(
                                      l10n.wordActivityLearningLanguage(
                                        languageName,
                                      ),
                                      18,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 145,
                left: 36,
                right: 36,
                height: 145,
                child: _fit(
                  l10n.wordActivityShareHeading,
                  76,
                  color: const Color(0xFF4EE8CD),
                  weight: FontWeight.w800,
                ),
              ),
              Positioned(
                top: 320,
                left: 32,
                right: 32,
                height: 148,
                child: _stat(
                  Icons.mic_none_outlined,
                  number.format(today.spoken),
                  l10n.wordActivitySpoken,
                ),
              ),
              Positioned(
                top: 484,
                left: 32,
                right: 32,
                height: 148,
                child: _stat(
                  Icons.headphones_outlined,
                  number.format(today.listened),
                  l10n.wordActivityListened,
                ),
              ),
              Positioned(
                top: 649,
                left: 32,
                right: 32,
                height: 123,
                child: Container(
                  decoration: _panel,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1.2),
                      2: FlexColumnWidth(1.2),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          const SizedBox(),
                          _fit(l10n.wordActivitySpoken, 16, color: _muted),
                          _fit(l10n.wordActivityListened, 16, color: _muted),
                        ],
                      ),
                      for (final row in [
                        (l10n.wordActivityThisWeek, week),
                        (l10n.wordActivityTotal, total),
                      ])
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _fit(row.$1, 21, color: _muted),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _fit(number.format(row.$2.spoken), 23),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _fit(number.format(row.$2.listened), 23),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 40,
                top: 841,
                right: 166,
                height: 72,
                child: Row(
                  children: [
                    Image.asset('assets/icon.png', width: 70, height: 70),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _fit('Bantera', 38, weight: FontWeight.w800),
                          const SizedBox(height: 4),
                          _fit(
                            'iOS/Android',
                            20,
                            color: _muted,
                            weight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 40,
                top: 784,
                width: 104,
                height: 22,
                child: _fit(l10n.wordActivityScanToJoin, 14),
              ),
              Positioned(
                right: 40,
                bottom: 40,
                width: 104,
                height: 104,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    qrAsset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
