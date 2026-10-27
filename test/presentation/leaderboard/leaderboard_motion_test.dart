import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/leaderboard/speaking_leaderboard.dart';
import 'package:app/presentation/leaderboard/leaderboard_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> row(String id, int rank, int count) => {
  'key': id,
  'rank': rank,
  'name': id,
  'spokenWords': count,
  'learningLanguage': 'en-US',
  'isMe': false,
};
SpeakingReport report(List<Map<String, dynamic>> rows) => SpeakingReport({
  'rows': rows,
  'you': rows.first,
  'fromDate': '2026-09-28',
  'throughDate': '2026-10-27',
  'offset': 0,
  'limit': 100,
  'hasMore': false,
});
Widget app(Widget home, {bool reduce = false}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
    child: child!,
  ),
  home: home,
);
void main() {
  for (final reduce in [false, true]) {
    testWidgets(
      'refresh counts and reorders continuously, reduced motion=$reduce',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var current = report([
          row('Alice', 1, 3000),
          row('Bob', 2, 1050),
          row('Carol', 3, 1000),
        ]);
        late StateSetter update;
        await tester.pumpWidget(
          app(
            StatefulBuilder(
              builder: (_, setState) {
                update = setState;
                return SpeakingLeaderboardView(
                  report: current,
                  onRefresh: () async {},
                );
              },
            ),
            reduce: reduce,
          ),
        );
        await tester.pumpAndSettle();
        double y(String name) => tester
            .getCenter(find.byKey(ValueKey('leaderboard-avatar-$name')))
            .dy;
        int count(String name) {
          final text = tester.widget<Text>(
            find.descendant(
              of: find.byKey(ValueKey('leaderboard-total-$name')),
              matching: find.byType(Text),
            ),
          );
          return int.parse(text.data!.replaceAll(',', ''));
        }

        final beforeBob = y('Bob'), beforeCarol = y('Carol');
        expect(
          count('Carol'),
          1000,
        ); // First display does not count up from zero.
        update(
          () => current = report([
            row('Alice', 1, 3000),
            row('Carol', 2, 1100),
            row('Bob', 3, 1050),
          ]),
        );
        await tester.pump();
        if (reduce) {
          expect(y('Carol'), closeTo(beforeBob, 1));
          expect(count('Carol'), 1100);
        } else {
          expect(y('Carol'), closeTo(beforeCarol, 1));
          expect(count('Carol'), 1000);
          await tester.pump(const Duration(milliseconds: 250));
          expect(y('Carol'), inExclusiveRange(beforeBob, beforeCarol));
          expect(count('Carol'), inExclusiveRange(1000, 1100));
        }
        await tester.pumpAndSettle();
        expect(y('Carol'), closeTo(beforeBob, 1));
        expect(y('Bob'), closeTo(beforeCarol, 1));
        expect(count('Carol'), 1100);
        for (final name in ['Alice', 'Bob', 'Carol']) {
          expect(
            tester.getCenter(find.byKey(ValueKey('leaderboard-rank-$name'))).dy,
            closeTo(y(name), 1),
          );
          expect(
            tester
                .getCenter(find.byKey(ValueKey('leaderboard-total-$name')))
                .dy,
            closeTo(y(name), 1),
          );
        }
        expect(find.textContaining('Learning '), findsNothing);
        expect(find.text('English(en-us 🇺🇸)'), findsNWidgets(3));
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'a second update continues from the visible number, including decreases',
    (tester) async {
      var count = 1000;
      late StateSetter update;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return Scaffold(
                body: AnimatedSpokenCount(
                  value: count,
                  locale: 'en',
                  style: const TextStyle(),
                ),
              );
            },
          ),
        ),
      );
      update(() => count = 2000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final before = tester.widget<Text>(find.byType(Text)).data;
      update(() => count = 500);
      await tester.pump();
      expect(tester.widget<Text>(find.byType(Text)).data, before);
      await tester.pumpAndSettle();
      expect(find.text('500'), findsOneWidget);
    },
  );
}
