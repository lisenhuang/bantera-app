import 'dart:convert';
import 'dart:io';

import 'package:app/core/theme.dart';
import 'package:app/core/widget_discovery_service.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/widgets/widget_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late WidgetDiscoveryService service;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('widget-suggestion-test');
    service = WidgetDiscoveryService(
      supported: true,
      detect: () async => false,
      preferenceFile: () async => File('${directory.path}/dismissed'),
    );
    await service.initialize();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(WidgetDiscoveryService.channel, (call) async {
          if (call.method == 'isPad') return true;
          if (call.method == 'preview') {
            return base64Decode(
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aK1cAAAAASUVORK5CYII=',
            );
          }
          return null;
        });
  });
  tearDown(() async {
    service.dispose();
    await directory.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(WidgetDiscoveryService.channel, null);
  });
  Widget app(
    Widget child, {
    double scale = 1,
    bool dark = false,
    Locale locale = const Locale('en'),
  }) => MaterialApp(
    theme: dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: child,
  );
  Widget entries() => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          WidgetSuggestion(service: service),
          WidgetSuggestion(settings: true, service: service),
        ],
      ),
    ),
  );

  testWidgets(
    'cancel preserves Goal; confirmed dismissal keeps Settings entry',
    (tester) async {
      await tester.pumpWidget(app(entries()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('Hide widget suggestion?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Keep your progress in sight'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Don’t show again'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 20 && service.showGoal; i++) {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pumpAndSettle();
      }
      expect(find.text('Keep your progress in sight'), findsNothing);
      expect(find.text('Add a widget'), findsOneWidget);
      expect(
        await tester.runAsync(
          () => File('${directory.path}/dismissed').exists(),
        ),
        true,
      );
    },
  );

  testWidgets('both entry points open the same guide', (tester) async {
    await tester.pumpWidget(app(entries()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How to add a widget'));
    await tester.pumpAndSettle();
    expect(find.byType(WidgetGuideScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a widget'));
    await tester.pumpAndSettle();
    expect(find.byType(WidgetGuideScreen), findsOneWidget);
  });

  testWidgets('suggestion controls have accessible labels and tap targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final dark in [false, true]) {
      await tester.pumpWidget(app(entries(), dark: dark));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
    semantics.dispose();
  });

  testWidgets(
    'installed widgets hide Goal but Settings opens the guide without dismissal',
    (tester) async {
      final installed = WidgetDiscoveryService(
        supported: true,
        detect: () async => true,
        preferenceFile: () async => File('${directory.path}/other'),
      );
      await tester.runAsync(installed.initialize);
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Column(
              children: [
                WidgetSuggestion(service: installed),
                WidgetSuggestion(settings: true, service: installed),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Keep your progress in sight'), findsNothing);
      expect(find.text('Not now'), findsNothing);
      expect(find.text('Don’t show again'), findsNothing);
      expect(find.text('Add a widget'), findsOneWidget);
      await tester.tap(find.text('Add a widget'));
      await tester.pumpAndSettle();
      expect(find.byType(WidgetGuideScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Add a widget'), findsOneWidget);
      expect(find.text('Not now'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      installed.dispose();
    },
  );

  testWidgets('unsupported platforms show neither widget entry', (
    tester,
  ) async {
    final unsupported = WidgetDiscoveryService(
      supported: false,
      detect: () async => throw StateError('must not query WidgetKit'),
      preferenceFile: () async => File('${directory.path}/unsupported'),
    );
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Column(
            children: [
              WidgetSuggestion(service: unsupported),
              WidgetSuggestion(settings: true, service: unsupported),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Keep your progress in sight'), findsNothing);
    expect(find.text('Add a widget'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    unsupported.dispose();
  });

  testWidgets(
    'unknown detection keeps Settings guide accessible, without Goal prompt',
    (tester) async {
      final unknown = WidgetDiscoveryService(
        supported: true,
        detect: () async => null,
        preferenceFile: () async => File('${directory.path}/unknown'),
        maxRetries: 0,
      );
      await tester.runAsync(unknown.initialize);
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Column(
              children: [
                WidgetSuggestion(service: unknown),
                WidgetSuggestion(settings: true, service: unknown),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Keep your progress in sight'), findsNothing);
      expect(find.text('Add a widget'), findsOneWidget);
      await tester.tap(find.text('Add a widget'));
      await tester.pumpAndSettle();
      expect(find.byType(WidgetGuideScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      unknown.dispose();
    },
  );

  testWidgets(
    'suggestions and guide fit phone and iPad with large localized text',
    (tester) async {
      for (final size in [const Size(320, 568), const Size(1024, 768)]) {
        await tester.binding.setSurfaceSize(size);
        for (final dark in [false, true]) {
          for (final locale in [
            const Locale('en'),
            const Locale('de'),
            const Locale('ja'),
            const Locale('zh', 'Hant'),
          ]) {
            await tester.pumpWidget(
              app(entries(), scale: 2.5, dark: dark, locale: locale),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(
              app(
                const WidgetGuideScreen(),
                scale: 2.5,
                dark: dark,
                locale: locale,
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.drag(
              find.byType(SingleChildScrollView),
              const Offset(0, -2000),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        }
      }
      await tester.binding.setSurfaceSize(null);
    },
  );
}
