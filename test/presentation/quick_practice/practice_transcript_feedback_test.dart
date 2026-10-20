import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/practice_transcript_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
