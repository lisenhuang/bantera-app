import 'dart:io';
import 'package:app/core/theme.dart';
import 'package:flutter/services.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/practice_transcript_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (font.existsSync()) {
      await (FontLoader('Roboto')..addFont(
            Future.value(ByteData.sublistView(await font.readAsBytes())),
          ))
          .load();
    }
  });
  for (final dark in [false, true]) {
    testWidgets('recording replay card ${dark ? 'dark' : 'light'} layout', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(393, 330));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: PracticeTranscriptFeedback(
                transcript:
                    'You could ask at the ticket desk whether they can change it.',
                choices: const [
                  'You could ask at the ticket desk whether they can change it.',
                  'The bus leaves at three.',
                ],
                locale: 'en-NZ',
                onReplay: () {},
                replaying: dark,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/practice-replay-${dark ? 'dark' : 'light'}.png',
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'recording replay sits beside transcript, toggles and disables safely',
    (tester) async {
      var taps = 0;
      Future<void> show({
        bool playing = false,
        bool enabled = true,
        bool available = true,
        bool loading = false,
        String transcript = '我想喺屋企睇書',
      }) async {
        await tester.binding.setSurfaceSize(const Size(320, 800));
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: PracticeTranscriptFeedback(
                  transcript: transcript,
                  choices: const ['我想喺屋企睇書', '我鍾意睇書'],
                  locale: 'zh-HK',
                  onReplay: available ? () => taps++ : null,
                  replaying: playing,
                  replayEnabled: enabled,
                  replayLoading: loading,
                ),
              ),
            ),
          ),
        );
      }

      addTearDown(() => tester.binding.setSurfaceSize(null));
      final button = find.byKey(const ValueKey('practice-replay-recording'));
      await show();
      expect(
        tester.getTopLeft(button).dx,
        greaterThan(
          tester
              .getTopLeft(find.byKey(const ValueKey('practice-heard-text')))
              .dx,
        ),
      );
      expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
      expect(find.byTooltip('Play Attempt'), findsOneWidget);
      await tester.tap(button);
      expect(taps, 1);
      await show(playing: true);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      await tester.tap(button);
      expect(taps, 2);
      await show(enabled: false);
      await tester.tap(button);
      expect(taps, 2);
      await show(loading: true);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await show(transcript: '');
      expect(button, findsOneWidget);
      await show(available: false);
      expect(button, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final row in [
    ('ar-SA', 'اسمي علي', ['اسمي سام', 'أنا من مصر'], TextDirection.rtl),
    ('zh-CN', '我想喝茶', ['我不想喝茶', '明天见'], TextDirection.ltr),
    ('th-TH', 'ฉันชื่อแซม', ['ฉันชื่อแซม', 'พรุ่งนี้'], TextDirection.ltr),
  ]) {
    testWidgets('preserves raw transcript and direction for ${row.$1}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PracticeTranscriptFeedback(
                  transcript: row.$2,
                  choices: row.$3,
                  locale: row.$1,
                  choice: 0,
                ),
              ),
            ),
          ),
        ),
      );
      final text = tester.widget<Text>(
        find.byKey(const ValueKey('practice-heard-text')),
      );
      expect(text.textSpan!.toPlainText(), row.$2);
      expect(text.textDirection, row.$4);
      expect(tester.takeException(), isNull);
    });
  }
}
