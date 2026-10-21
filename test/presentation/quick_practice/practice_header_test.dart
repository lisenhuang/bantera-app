import 'dart:io';
import 'package:flutter/services.dart';
import 'package:app/core/theme.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/practice_header.dart';
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
  Future<void> mount(
    WidgetTester tester, {
    bool dark = false,
    double width = 393,
    double scale = 1,
    Locale locale = const Locale('en'),
    VoidCallback? onDialogues,
    TargetPlatform platform = TargetPlatform.iOS,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 400));
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
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          appBar: PracticeHeader(
            onLongerDialogues: onDialogues ?? () {},
            onSavePractice: () {},
            onSavedPractice: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'title stays centred without a goal control and menu stays right',
    (tester) async {
      await mount(tester);
      final title = tester.getCenter(
        find.byKey(const ValueKey('practice-title')),
      );
      expect(title.dx, closeTo(393 / 2, .1));
      expect(find.text('Bantera App'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byKey(const ValueKey('practice-set-goal')), findsNothing);
      expect(find.byKey(const ValueKey('practice-goal-percent')), findsNothing);
      expect(
        tester.getCenter(find.byKey(const ValueKey('practice-more-menu'))).dx,
        greaterThan(title.dx),
      );
    },
  );
  testWidgets('localised header fits a small screen with large text', (
    tester,
  ) async {
    await mount(
      tester,
      width: 320,
      scale: 1.7,
      dark: true,
      locale: const Locale('de'),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getCenter(find.byKey(const ValueKey('practice-title'))).dx,
      closeTo(160, .1),
    );
  });
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final dark in [false, true]) {
      testWidgets('overflow menu fits $platform dark=$dark at large text', (
        tester,
      ) async {
        var opened = 0;
        await mount(
          tester,
          width: 320,
          scale: 2,
          dark: dark,
          platform: platform,
          onDialogues: () => opened++,
        );
        final menu = find.byKey(const ValueKey('practice-more-menu'));
        expect(tester.getSize(menu), const Size(48, 48));
        expect(tester.getCenter(menu).dx, greaterThan(160));
        expect(
          tester.getCenter(find.byKey(const ValueKey('practice-title'))).dx,
          closeTo(160, .1),
        );
        expect(
          tester
              .getSize(find.byKey(const ValueKey('practice-header-bar')))
              .height,
          kToolbarHeight,
        );
        expect(tester.widget<PopupMenuButton<String>>(menu).tooltip, 'More');
        await tester.tap(menu);
        await tester.pumpAndSettle();
        final item = find.byType(PopupMenuItem<String>);
        expect(item, findsNWidgets(3));
        expect(
          find.descendant(of: item, matching: find.byType(Icon)),
          findsNWidgets(3),
        );
        expect(find.text('Save practice'), findsOneWidget);
        expect(find.text('Saved practice'), findsOneWidget);
        expect(
          tester
              .widgetList<PopupMenuItem<String>>(item)
              .map((item) => item.value),
          ['save', 'saved', 'dialogues'],
        );
        expect(find.text('Longer dialogues'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Longer dialogues'));
        await tester.pumpAndSettle();
        expect(opened, 1);
      });
    }
  }

  testWidgets('Practice header light and dark design captures', (tester) async {
    for (final dark in [false, true]) {
      await mount(tester, dark: dark);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/practice-header-${dark ? "dark" : "light"}.png',
        ),
      );
    }
  });
}
