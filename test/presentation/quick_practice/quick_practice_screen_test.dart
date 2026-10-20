import 'dart:io';
import 'package:app/core/practice_review_service.dart';
import 'package:app/core/theme.dart';
import 'package:app/domain/activity/word_activity.dart';
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
    Map<String, dynamic>? feedback,
    Map<String, dynamic> material = exercise,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: QuickPracticeScreen.preview(
            previewExercise: material,
            previewFeedback: feedback,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.graphic_eq),
                label: 'Practice',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chat_bubble_2),
                activeIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
                label: 'Dialogues',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('choices prompt speech instead of accepting a tapped answer', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('Where is the station?'), findsOneWidget);
    expect(find.text('¿Dónde está la estación?'), findsNothing);
    expect(find.text('Está al lado del banco.'), findsNothing);
    expect(find.text('Abre a las nueve.'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('practice-show-translation')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('¿Dónde está la estación?'), findsNothing);
    expect(find.byType(AlertDialog), findsOneWidget);
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
    await tester.tap(find.text('It’s next to the bank.'));
    await tester.pump();
    expect(
      find.text('Tap the microphone and say one of the replies aloud.'),
      findsNWidgets(2),
    );
    expect(find.text('That reply fits. Nicely done.'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
  testWidgets(
    'resumed assisted exercise keeps translations and exclusion notice',
    (tester) async {
      await mount(tester, material: {...exercise, 'translationUsed': true});
      expect(find.text('¿Dónde está la estación?'), findsOneWidget);
      expect(
        find.text('Translation used · This exercise won’t change your level.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('practice-show-translation')),
        findsNothing,
      );
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
    expect(find.text('Practice'), findsNWidgets(2));
  });
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
    'level help opens from the bottom link and returns to the same exercise',
    (tester) async {
      await mount(tester);
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
    final link = find.byKey(const ValueKey('practice-level-help-link'));
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text(
        'After a level change, a new set of 12 begins. A1 is the lowest level and C2 the highest.',
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
  testWidgets('goal setup opens settings and returns to the same exercise', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byKey(const ValueKey('practice-set-goal')));
    await tester.pumpAndSettle();
    expect(find.text('Daily goal'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
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
