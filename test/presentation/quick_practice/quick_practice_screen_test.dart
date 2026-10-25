import 'package:app/core/apple_system_version.dart';
import 'package:app/presentation/discover/discover_screen.dart';
import 'dart:io';
import 'package:app/core/practice_review_service.dart';
import 'package:app/core/theme.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/presentation/shared/goal_tab_icon.dart';
import 'package:app/presentation/shared/app_viewport.dart';
import 'package:app/presentation/shared/daily_goal_celebration_dialog.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/quick_practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const exercise = {
  'id': 'sample',
  'level': 'A1',
  'cue': 'Where is the station?',
  'cueAudioUrl': '',
  'translations': {
    'cue': '¿Dónde está la estación?',
    'option0': 'Está al lado del banco.',
    'option1': 'Abre a las nueve.',
  },
  'choices': [
    {'text': 'It’s next to the bank.', 'audioUrl': ''},
    {'text': 'It opens at nine.', 'audioUrl': ''},
  ],
};

// Match MainScaffold's route coverage: a dialog deactivates Practice until
// the parent rebuilds after didPopNext.
class RouteCoveredPractice extends StatefulWidget {
  const RouteCoveredPractice({super.key, required this.observer});
  final PracticeRouteObserver observer;

  @override
  State<RouteCoveredPractice> createState() => _RouteCoveredPracticeState();
}

class _RouteCoveredPracticeState extends State<RouteCoveredPractice>
    with RouteAware {
  bool covered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.observer.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPushNext() => setState(() => covered = true);

  @override
  void didPopNext() => setState(() => covered = false);

  @override
  void dispose() {
    widget.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: QuickPracticeScreen.preview(
      previewExercise: exercise,
      active: !covered,
    ),
  );
}

void main() {
  setUp(() => translationCapabilityForTesting = true);
  tearDown(() => translationCapabilityForTesting = null);
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await (FontLoader('packages/cupertino_icons/CupertinoIcons')..addFont(
          rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'),
        ))
        .load();
    // Local design captures use readable system typography, without adding fonts to the app.
    final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (font.existsSync()) {
      await (FontLoader('Roboto')..addFont(
            Future.value(ByteData.sublistView(await font.readAsBytes())),
          ))
          .load();
    }
  });
  Future<void> mount(
    WidgetTester tester, {
    bool dark = false,
    double width = 393,
    double scale = 1,
    double height = 852,
    EdgeInsets sideInsets = EdgeInsets.zero,
    Locale locale = const Locale('en'),
    TargetPlatform platform = TargetPlatform.iOS,
    Map<String, dynamic>? feedback,
    Map<String, dynamic> material = exercise,
  }) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.binding.setSurfaceSize(Size(width, height));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: (dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme)
            .copyWith(platform: platform),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale), padding: sideInsets),
          child: AppViewport(child: child!),
        ),
        home: Scaffold(
          body: QuickPracticeScreen.preview(
            previewExercise: material,
            previewFeedback: feedback,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            unselectedItemColor:
                (dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme)
                    .colorScheme
                    .onSurfaceVariant,
            items: const [
              BottomNavigationBarItem(
                icon: SizedBox.square(
                  dimension: 36,
                  child: Center(child: Icon(CupertinoIcons.waveform, size: 28)),
                ),
                label: 'Practice',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.square(
                  dimension: 36,
                  child: Center(
                    child: Icon(CupertinoIcons.chat_bubble_text, size: 28),
                  ),
                ),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: GoalTabIcon(
                  goal: DailyWordGoal(listened: 600, spoken: 400),
                  today: WordTotals(listened: 300, spoken: 200),
                ),
                label: 'Goal',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('practice survives Duo folding, rotation and narrow windows', (
    tester,
  ) async {
    for (final size in [
      const Size(402, 874),
      const Size(744, 1133),
      const Size(1133, 744),
      const Size(320, 600),
    ]) {
      await mount(
        tester,
        width: size.width,
        height: size.height,
        sideInsets: const EdgeInsets.only(right: 64),
        feedback: {
          'outcome': 'correct',
          'transcript': 'It’s next to the bank.',
        },
      );
      expect(tester.takeException(), isNull);
      final next = find.byKey(const ValueKey('practice-pinned-next'));
      expect(next, findsOneWidget);
      final rect = tester.getRect(next);
      expect(rect.right, lessThanOrEqualTo(size.width - 64));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(find.text('Bantera App'), findsOneWidget);
      expect(find.byType(GoalTabIcon), findsOneWidget);
    }
  });

  for (final major in [15, 16, 17]) {
    testWidgets(
      'A0 shows meanings before answering and a visible beginner level',
      (tester) async {
        await mount(
          tester,
          material: {...exercise, 'level': 'A0', 'currentLevel': 'A0'},
        );
        expect(find.text('A0'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('practice-translation-cue')),
          findsOneWidget,
        );
        expect(find.text('¿Dónde está la estación?'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('practice-show-translation')),
          findsNothing,
        );
        expect(
          find.textContaining('A0 includes learning support'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('practice-level-menu')));
        await tester.pumpAndSettle();
        expect(find.text('Starting from zero'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'A0 keeps audio practice available without built-in translation',
      (tester) async {
        translationCapabilityForTesting = false;
        await mount(
          tester,
          material: {...exercise, 'level': 'A0', 'currentLevel': 'A0'},
        );
        expect(find.text('A0'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('practice-translation-cue')),
          findsNothing,
        );
        expect(
          find.textContaining('A0 includes learning support'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'iOS $major hides translation including a previously assisted exercise',
      (tester) async {
        translationCapabilityForTesting = translationSupportedOn(
          isIOS: true,
          isAndroid: false,
          realMajor: major,
        );
        final assisted = {...exercise, 'translationUsed': true};
        await mount(tester, material: assisted, width: 320);
        expect(
          find.byKey(const ValueKey('practice-show-translation')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('practice-translation-scoring')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('practice-translation-cue')),
          findsNothing,
        );
        expect(find.text('Where is the station?'), findsOneWidget);
        expect(assisted['translationUsed'], isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'dialogues and its library return to the same answered translated practice',
    (tester) async {
      await mount(
        tester,
        material: {...exercise, 'translationUsed': true},
        feedback: {
          'outcome': 'correct',
          'choice': 0,
          'transcript': 'It’s next to the bank.',
        },
      );
      final practiceState = tester.state(find.byType(QuickPracticeScreen));
      expect(find.text('¿Dónde está la estación?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('practice-more-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Longer dialogues'));
      await tester.pumpAndSettle();
      expect(find.byType(DiscoverScreen), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('dialogues-library-menu')));
      await tester.pumpAndSettle();
      expect(find.text('Practice History'), findsOneWidget);
      expect(find.text('Saved Media'), findsOneWidget);
      expect(find.text('Saved Cues'), findsOneWidget);
      // Close the library menu, then use the standard page back button.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(
        tester.state(find.byType(QuickPracticeScreen)),
        same(practiceState),
      );
      expect(find.text('Where is the station?'), findsOneWidget);
      expect(find.text('¿Dónde está la estación?'), findsOneWidget);
      expect(
        find.text('Translation used · This exercise won’t change your level.'),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('practice-pinned-next')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'audio buttons lead the waveform and replies without A/B labels',
    (tester) async {
      await mount(tester, width: 320, scale: 1.7);
      final cuePlay = find.byKey(const ValueKey('practice-play-cue'));
      final cueText = find.text('Where is the station?');
      expect(
        tester.getTopLeft(cuePlay).dy,
        greaterThan(tester.getBottomLeft(cueText).dy),
      );
      for (var i = 0; i < 2; i++) {
        final play = find.byKey(ValueKey('practice-play-option$i'));
        final text = find.text(
          (exercise['choices'] as List)[i]['text'] as String,
        );
        expect(tester.getCenter(play).dx, lessThan(tester.getTopLeft(text).dx));
        expect(tester.getSize(play).width, greaterThanOrEqualTo(48));
      }
      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'word selection underlines first and opens explanation on the second tap',
    (tester) async {
      await mount(tester);
      expect(find.text('Where is the station?'), findsOneWidget);
      expect(
        find.text(
          'Showing translation excludes this exercise from level changes.',
        ),
        findsNothing,
      );
      expect(find.text('¿Dónde está la estación?'), findsNothing);
      expect(find.text('Está al lado del banco.'), findsNothing);
      expect(find.text('Abre a las nueve.'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('practice-show-translation')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('¿Dónde está la estación?'), findsNothing);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text(
          'Showing translation excludes this exercise from level changes.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('¿Dónde está la estación?'), findsNothing);
      expect(
        find.text('Translation used · This exercise won’t change your level.'),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('practice-show-translation')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(
        find.byKey(const ValueKey('practice-confirm-translation')),
      );
      await tester.pumpAndSettle();
      expect(find.text('¿Dónde está la estación?'), findsOneWidget);
      expect(find.text('Está al lado del banco.'), findsOneWidget);
      expect(find.text('Abre a las nueve.'), findsOneWidget);
      await tester.tapOnText(find.textRange.ofSubstring('station'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tapOnText(find.textRange.ofSubstring('next'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      final selected = tester
          .widgetList<Text>(find.byType(Text))
          .expand((text) {
            final span = text.textSpan;
            return span is TextSpan
                ? (span.children ?? []).whereType<TextSpan>()
                : <TextSpan>[];
          })
          .where((span) => span.style?.decoration == TextDecoration.underline);
      expect(selected.map((span) => span.text), ['next']);
      await tester.tapOnText(find.textRange.ofSubstring('next'));
      await tester.pumpAndSettle();
      expect(find.text('Explain “next” with Bantera AI?'), findsOneWidget);
      expect(find.textContaining('“next”'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Tap to start and tap again to check, or hold while speaking and release to check.',
        ),
        findsOneWidget,
      );
      expect(find.text('That reply fits. Nicely done.'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle(const Duration(seconds: 4));
    },
  );
  testWidgets(
    'resumed assisted exercise keeps translations without inline explanation',
    (tester) async {
      await mount(tester, material: {...exercise, 'translationUsed': true});
      expect(find.text('¿Dónde está la estación?'), findsOneWidget);
      expect(
        find.text('Translation used · This exercise won’t change your level.'),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('practice-show-translation')),
        findsNothing,
      );
    },
  );
  for (final outcome in [null, 'correct', 'incorrect', 'unclear']) {
    testWidgets(
      'microphone stays directly below choices with $outcome feedback',
      (tester) async {
        await mount(
          tester,
          feedback: outcome == null
              ? null
              : {
                  'outcome': outcome,
                  'choice': 0,
                  'transcript': 'It’s next to the bank.',
                  'explanation': List.filled(
                    20,
                    'Long feedback should stay below recording.',
                  ).join(' '),
                },
        );
        final mic = find.byKey(const ValueKey('practice-record-button'));
        final lastChoice = find.text('It opens at nine.');
        expect(
          tester.getTopLeft(mic).dy,
          greaterThan(tester.getBottomLeft(lastChoice).dy),
        );
        expect(
          tester.getTopLeft(mic).dy - tester.getBottomLeft(lastChoice).dy,
          lessThan(100),
        );
        if (outcome != null) {
          expect(
            tester
                .getTopLeft(find.byKey(const ValueKey('practice-feedback')))
                .dy,
            greaterThan(tester.getBottomLeft(mic).dy),
          );
        }
        await Scrollable.ensureVisible(tester.element(mic), alignment: 1);
        await tester.pumpAndSettle();
        expect(mic.hitTestable(), findsOneWidget);
        expect(lastChoice.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'level sheet shows all levels and locked selection only explains',
    (tester) async {
      await mount(
        tester,
        material: {...exercise, 'level': 'B1', 'currentLevel': 'B1'},
      );
      await tester.tap(find.byKey(const ValueKey('practice-level-menu')));
      await tester.pumpAndSettle();
      for (final level in ['A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
        expect(
          find.byKey(ValueKey('practice-level-option-$level')),
          findsOneWidget,
        );
      }
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Current level: B1'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(3));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/practice-level-menu.png'),
      );
      await tester.tap(find.byKey(const ValueKey('practice-level-option-C1')));
      await tester.pumpAndSettle();
      expect(find.text('Level not reached yet'), findsOneWidget);
      expect(
        find.text(
          'Reach C1 through practice to unlock it. Your current level is B1.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('B1'), findsOneWidget);
      expect(find.text('Where is the station?'), findsOneWidget);
    },
  );
  testWidgets(
    'lower level confirmation preserves earned level and allows returning',
    (tester) async {
      await mount(
        tester,
        material: {...exercise, 'level': 'B1', 'currentLevel': 'B1'},
      );
      Future<void> choose(String level) async {
        await tester.tap(find.byKey(const ValueKey('practice-level-menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('practice-level-option-$level')));
        await tester.pumpAndSettle();
      }

      await choose('A1');
      expect(find.text('Practise at A1?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('B1'), findsOneWidget);
      await choose('A1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Review · Current level: B1'), findsOneWidget);
      expect(find.text('A1'), findsOneWidget);
      await choose('B1');
      expect(
        find.text(
          'Continue at your current level. Answers without translation will count towards level changes again.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Review · Current level: B1'), findsNothing);
      expect(find.text('B1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'retired saved language asks for another language without preparing material',
    (tester) async {
      await mount(tester, material: {...exercise, 'locale': 'mi-NZ'});
      expect(
        find.text('Choose a learning language in Settings.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('practice-record-button')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(QuickPracticeScreen),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Practice toolbar stays fixed while the exercise scrolls', (
    tester,
  ) async {
    await mount(tester);
    final header = find.byKey(const ValueKey('practice-header-bar'));
    final position = tester.getTopLeft(header);
    expect(tester.getSize(header).height, kToolbarHeight);
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(header), position);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Bantera App'), findsOneWidget);
  });
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final dark in [false, true]) {
      testWidgets(
        'level sheet preserves answer on dismissal: $platform dark=$dark',
        (tester) async {
          await mount(
            tester,
            width: 320,
            height: 568,
            scale: 2,
            dark: dark,
            platform: platform,
            locale: const Locale('zh'),
            material: {
              ...exercise,
              'level': 'B1',
              'currentLevel': 'B1',
              'translationUsed': true,
            },
            feedback: {
              'outcome': 'correct',
              'transcript': 'It’s next to the bank.',
            },
          );
          final screen = find.byType(QuickPracticeScreen);
          final state = tester.state(screen);
          final button = find.byKey(const ValueKey('practice-level-menu'));
          expect(find.text('先听，再说出你的回答。'), findsNothing);
          expect(tester.getTopLeft(button).dy, greaterThan(kToolbarHeight));
          expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
          expect(
            find.descendant(of: find.byType(AppBar), matching: button),
            findsNothing,
          );
          await tester.tap(button);
          await tester.pumpAndSettle();
          final sheet = find.byKey(const ValueKey('practice-level-sheet'));
          expect(sheet, findsOneWidget);
          final last = find.byKey(const ValueKey('practice-level-option-C2'));
          await tester.ensureVisible(last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final close = find.descendant(
            of: sheet,
            matching: find.byType(IconButton),
          );
          await tester.ensureVisible(close);
          await tester.tap(close);
          await tester.pumpAndSettle();
          expect(sheet, findsNothing);
          expect(identical(tester.state(screen), state), isTrue);
          expect(find.text('B1'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('practice-pinned-next')),
            findsOneWidget,
          );
          expect(find.text('¿Dónde está la estación?'), findsOneWidget);
        },
      );
    }
  }

  testWidgets('shows the exercise level and tolerates older API responses', (
    tester,
  ) async {
    await mount(tester, material: {...exercise, 'level': 'B2'});
    expect(find.text('B2'), findsOneWidget);
    expect(find.byKey(const ValueKey('practice-level')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await mount(tester, material: {...exercise}..remove('level'));
    expect(find.byKey(const ValueKey('practice-level')), findsNothing);
    expect(find.text('Where is the station?'), findsOneWidget);
  });
  testWidgets(
    'level help opens from the level sheet footer and returns to the same exercise',
    (tester) async {
      await mount(tester);
      expect(
        find.byKey(const ValueKey('practice-level-help-link')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('practice-level-menu')));
      await tester.pumpAndSettle();
      final link = find.byKey(const ValueKey('practice-level-help-link'));
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.text('10–12 correct: move up one level.'), findsOneWidget);
      expect(find.text('5–9 correct: stay at this level.'), findsOneWidget);
      expect(find.text('0–4 correct: move down one level.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/practice-level-help.png'),
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('10–12 correct: move up one level.'), findsNothing);
      expect(find.text('Where is the station?'), findsOneWidget);
    },
  );
  testWidgets('level help scrolls with large text on a small screen', (
    tester,
  ) async {
    await mount(tester, width: 320, scale: 1.7, dark: true);
    await tester.tap(find.byKey(const ValueKey('practice-level-menu')));
    await tester.pumpAndSettle();
    final link = find.byKey(const ValueKey('practice-level-help-link'));
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text(
        'After a level change, a new set of 12 begins. A0 is the lowest level and C2 the highest.',
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byTooltip('Close'));
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
  });
  for (final outcome in [null, 'incorrect', 'unclear']) {
    testWidgets('Next confirms $outcome and Cancel retains the exercise', (
      tester,
    ) async {
      await mount(
        tester,
        feedback: outcome == null
            ? null
            : {'outcome': outcome, 'transcript': ''},
      );
      expect(find.byKey(const ValueKey('practice-pinned-next')), findsNothing);
      await tester.ensureVisible(find.text('Next practice'));
      await tester.tap(find.text('Next practice'));
      await tester.pumpAndSettle();
      expect(find.text('Skip this practice?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Where is the station?'), findsOneWidget);
      await tester.tap(find.text('Next practice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip practice'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Where is the station?'), findsNothing);
      expect(
        find.text(
          "A short conversation is on its way. We'll prepare the next ones while you practise.",
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('Skip advances after route coverage clears on the next frame', (
    tester,
  ) async {
    final observer = PracticeRouteObserver();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RouteCoveredPractice(observer: observer),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Next practice'));
    await tester.tap(find.text('Next practice'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<QuickPracticeScreen>(find.byType(QuickPracticeScreen))
          .active,
      isFalse,
    );
    await tester.tap(find.text('Skip practice'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester
          .widget<QuickPracticeScreen>(find.byType(QuickPracticeScreen))
          .active,
      isTrue,
    );
    expect(find.text('Where is the station?'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('a correct reply advances without confirmation', (tester) async {
    await mount(
      tester,
      feedback: {'outcome': 'correct', 'choice': 0, 'transcript': ''},
    );
    // A successful reply can advance immediately without scrolling.
    expect(
      find.byKey(const ValueKey('practice-pinned-next')).hitTestable(),
      findsOneWidget,
    );
    expect(find.text('Next practice'), findsOneWidget);
    await tester.tap(find.text('Next practice'));
    await tester.pump();
    expect(find.byKey(const ValueKey('practice-pinned-next')), findsNothing);
    expect(find.text('Skip this practice?'), findsNothing);
    expect(find.text('Where is the station?'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'successful next stays above tabs while long feedback scrolls with large text',
    (tester) async {
      await mount(
        tester,
        width: 320,
        scale: 1.7,
        feedback: {
          'outcome': 'correct',
          'choice': 0,
          'transcript': 'It’s next to the bank.',
          'explanation': List.filled(
            20,
            'This reply tells you where the station is.',
          ).join(' '),
        },
      );
      final next = find.byKey(const ValueKey('practice-pinned-next'));
      final position = tester.getTopLeft(next);
      expect(next.hitTestable(), findsOneWidget);
      expect(
        tester.getBottomLeft(next).dy,
        lessThan(tester.getTopLeft(find.byType(BottomNavigationBar)).dy),
      );
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(next), position);
      expect(next.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(next);
      await tester.pump();
      expect(find.text('Skip this practice?'), findsNothing);
      expect(find.text('Where is the station?'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('Practice header has no duplicate goal control', (tester) async {
    await mount(tester);
    expect(find.byKey(const ValueKey('practice-set-goal')), findsNothing);
    expect(find.byKey(const ValueKey('practice-goal-ring')), findsNothing);
    expect(find.text('Where is the station?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('light practice layout', (tester) async {
    await mount(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/practice-light.png'),
    );
  });
  testWidgets('dark feedback layout', (tester) async {
    await mount(
      tester,
      dark: true,
      feedback: {
        'outcome': 'correct',
        'choice': 0,
        'transcript': 'It’s next to the bank.',
        'explanation': 'This reply tells you where the station is.',
      },
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/practice-dark.png'),
    );
  });
  testWidgets(
    'small screen and large text remain scrollable without overflow',
    (tester) async {
      await mount(tester, width: 320, scale: 1.7);
      await tester.ensureVisible(find.text('Next practice'));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('unclear feedback shows the exact transcript and differences', (
    tester,
  ) async {
    const raw = 'It’s next to the bark.';
    await mount(tester, feedback: {'outcome': 'unclear', 'transcript': raw});
    await tester.ensureVisible(
      find.byKey(const ValueKey('practice-heard-text')),
    );
    await tester.pumpAndSettle();
    final heard = tester.widget<Text>(
      find.byKey(const ValueKey('practice-heard-text')),
    );
    expect(heard.textSpan!.toPlainText(), raw);
    expect(find.text('What we heard'), findsOneWidget);
    expect(find.text('Compare with this reply'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/practice-transcript.png'),
    );
  });
  testWidgets('empty recognition gives an explicit empty state', (
    tester,
  ) async {
    await mount(tester, feedback: {'outcome': 'unclear', 'transcript': ''});
    expect(
      find.text(
        'No transcript could be generated for this attempt. Try again closer to the microphone.',
      ),
      findsOneWidget,
    );
    expect(find.text('Compare with this reply'), findsNothing);
  });
  testWidgets('transcript feedback remains usable with large text', (
    tester,
  ) async {
    await mount(
      tester,
      width: 320,
      scale: 1.7,
      feedback: {'outcome': 'unclear', 'transcript': 'It’s next to the bark.'},
    );
    await tester.ensureVisible(find.text('Next practice'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('goal celebration presents real totals in an accessible layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: BanteraTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: DailyGoalCelebrationDialog(
            totals: WordTotals(listened: 600, spoken: 300),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('600'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('Today’s goals reached'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/goal-complete.png'),
    );
  });
}
