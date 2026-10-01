import 'package:flutter/services.dart';

/// Explicit per-weight families keep test and device typography identical.
Future<void> loadShareCardFonts() async {
  for (final family in ['Latin', 'SC', 'TC', 'JP', 'KR', 'Thai']) {
    for (final weight in family == 'Latin' ? [600, 700, 900] : [600, 900]) {
      await (FontLoader('BanteraShare$family$weight')..addFont(
            rootBundle.load(
              'assets/fonts/share_card/BanteraShare$family-$weight.ttf',
            ),
          ))
          .load();
    }
  }
}
