import 'dart:io';
import 'dart:typed_data';
import 'package:app/core/theme.dart';
import 'package:flutter/services.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/shared/ai_consent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    Future<ByteData> previewFont(String systemPath, String fallback) async {
      // Optional local previews can use complete system fonts. Normal tests
      // remain portable and use the repository's bundled font assets.
      if (const bool.fromEnvironment('CONSENT_PREVIEW')) {
        final file = File(systemPath);
        if (await file.exists())
          return ByteData.sublistView(await file.readAsBytes());
      }
      return rootBundle.load(fallback);
    }

    final latin = FontLoader('ConsentPreview')
      ..addFont(
        previewFont(
          '/System/Library/Fonts/SFNS.ttf',
          'assets/fonts/share_card/BanteraShareLatin-600.ttf',
        ),
      );
    final chinese = FontLoader('ConsentPreviewChinese')
      ..addFont(
        previewFont(
          '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
          'assets/fonts/share_card/BanteraShareSC-600.ttf',
        ),
      );
    await Future.wait([latin.load(), chinese.load()]);
  });
  for (final entry in [
    (
      name: 'phone',
      size: const Size(390, 844),
      scale: 1.0,
      locale: const Locale('en'),
    ),
    (
      name: 'large-text',
      size: const Size(320, 568),
      scale: 2.0,
      locale: const Locale('en'),
    ),
    (
      name: 'ipad',
      size: const Size(834, 1194),
      scale: 1.0,
      locale: const Locale('zh'),
    ),
  ]) {
    testWidgets('${entry.name}: disclosure scrolls and decline blocks action', (
      tester,
    ) async {
      tester.view.physicalSize = entry.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      bool? allowed;
      late AppLocalizations l;
      await tester.pumpWidget(
        MaterialApp(
          locale: entry.locale,
          debugShowCheckedModeBanner: false,
          theme: BanteraTheme.lightTheme.copyWith(
            textTheme: BanteraTheme.lightTheme.textTheme.apply(
              fontFamily: entry.locale.languageCode == 'zh'
                  ? 'ConsentPreviewChinese'
                  : 'ConsentPreview',
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(entry.scale)),
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              l = AppLocalizations.of(context)!;
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async {
                      allowed = await showAiConsentDialog(context);
                    },
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Cloudflare'), findsOneWidget);
      expect(find.text(l.aiConsentAgree), findsOneWidget);
      expect(allowed, isNull);
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('CONSENT_PREVIEW')) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('/tmp/bantera-consent-${entry.name}.png'),
        );
      }
      await tester.ensureVisible(find.text(l.aiConsentPolicy));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('CONSENT_PREVIEW')) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('/tmp/bantera-consent-${entry.name}-details.png'),
        );
      }
      await tester.tap(find.text(l.aiConsentDecline));
      await tester.pumpAndSettle();
      expect(allowed, false);
      expect(find.byType(AlertDialog), findsNothing);
    });
  }

  testWidgets('dismissal is not agreement; only agree returns true', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showAiConsentDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(result, false);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agree and continue'));
    await tester.pumpAndSettle();
    expect(result, true);
  });
}
