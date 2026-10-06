import 'package:app/domain/audio_level.dart';
import 'package:app/presentation/shared/audio_level_selector.dart';
import 'package:app/domain/models/models.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/shared/lesson_details_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MediaItem lesson({bool empty = false}) => MediaItem(
  id: 'lesson',
  title: 'Ordering tea',
  description: '',
  creator: User(
    id: 'owner',
    displayName: 'Bantera AI',
    avatarUrl: '',
    firstLanguage: '',
    learningLanguage: '',
    level: '',
  ),
  coverUrl: '',
  spokenLanguage: 'English',
  accent: 'en-NZ',
  level: AudioLevel.beginner,
  durationMs: 125000,
  cues: empty
      ? []
      : [
          Cue(
            id: 'first',
            startTimeMs: 1000,
            endTimeMs: 5500,
            originalText: 'A cup of tea, please.',
            translatedText: '',
          ),
          Cue(
            id: 'second',
            startTimeMs: 61000,
            endTimeMs: 65000,
            originalText: 'Of course. Anything else?',
            translatedText: '',
          ),
        ],
  transcriptionSource: 'AI Generated',
  isAudioOnly: true,
);

Widget page(
  MediaItem media, {
  required VoidCallback onPractice,
  bool transcribing = false,
  bool isPrivate = false,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(
    body: LessonDetailsBody(
      mediaItem: media,
      creatorAvatar: const CircleAvatar(child: Icon(Icons.person)),
      onStartPractice: onPractice,
      isTranscribing: transcribing,
      isPrivate: isPrivate,
    ),
  ),
);

void main() {
  test('Saved lesson retains level and accent for practice', () {
    final restored = MediaItem.fromJson(lesson().toJson());
    expect(restored.level, AudioLevel.beginner);
    expect(restored.accent, 'en-NZ');
    final legacy = lesson().toJson()..remove('level');
    expect(MediaItem.fromJson(legacy).level, AudioLevel.intermediate);
    legacy['transcriptionSource'] = 'User Upload';
    expect(MediaItem.fromJson(legacy).level, isNull);
  });

  testWidgets(
    'Both detail views share duration, timed sentences, and practice action',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var practices = 0;
      await tester.pumpWidget(page(lesson(), onPractice: () => practices++));
      await tester.pumpAndSettle();

      expect(find.text('2:05'), findsOneWidget);
      expect(find.text('Words: 9'), findsOneWidget);
      expect(find.text('🇳🇿'), findsOneWidget);
      expect(find.byIcon(Icons.translate_outlined), findsNothing);
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.byType(AudioLevelIcon), findsOneWidget);
      expect(find.textContaining('EN-NZ'), findsNothing);
      expect(find.text('English'), findsNWidgets(2));
      expect(find.text('Public'), findsNothing);
      expect(find.text('AI Generated'), findsNothing);
      expect(find.byIcon(Icons.auto_awesome), findsNothing);
      expect(find.text('A cup of tea, please.'), findsNothing);
      await tester.tap(find.byType(FilledButton));
      expect(practices, 1);
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('1. 0:01 - 0:05'), findsOneWidget);
      expect(find.text('2. 1:01 - 1:05'), findsOneWidget);
      expect(find.text('A cup of tea, please.'), findsOneWidget);
      expect(find.text('Of course. Anything else?'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();
      expect(find.text('A cup of tea, please.'), findsNothing);
    },
  );

  testWidgets('Missing timing or active transcription disables practice', (
    tester,
  ) async {
    await tester.pumpWidget(page(lesson(empty: true), onPractice: () {}));
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.pumpWidget(
      page(lesson(), onPractice: () {}, transcribing: true),
    );
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
