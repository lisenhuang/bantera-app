import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_vocabulary.dart';
import 'package:app/presentation/chats/ai/ai_vocabulary_screen.dart';
import 'package:app/l10n/app_localizations.dart';

Future<void> settle(WidgetTester tester) async {
  await Future<void>.delayed(const Duration(milliseconds: 80));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final icons = File(
      '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts/MaterialIcons-Regular.otf',
    );
    if (icons.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
      await loader.load();
    }
    final file = File(
      '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts/Roboto-Regular.ttf',
    );
    if (file.existsSync()) {
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      await loader.load();
    }
  });
  late Directory root;
  late AiVocabulary store;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('vocab-screen');
    store = AiVocabulary(
      'preview',
      storagePath: () async => root.path,
      isActive: () => true,
      now: () => DateTime.now().subtract(const Duration(days: 3)),
      timeZone: () async => 'Pacific/Auckland',
      language: () => 'en-NZ',
    );
    await store.execute({
      'action': 'add',
      'word': 'skewer',
      'meaning': 'A thin stick used to hold pieces of food while cooking.',
      'example': 'We grilled lamb skewers for lunch.',
    });
    await store.execute({
      'action': 'add',
      'word': 'broth',
      'meaning': 'A thin soup made by cooking meat or vegetables in water.',
    });
  });
  tearDown(() async => root.delete(recursive: true));
  Widget page({
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
  }) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(
      colorSchemeSeed: Colors.deepPurple,
      brightness: brightness,
    ),
    home: AiVocabularyScreen(repository: store),
  );
  testWidgets('vocabulary can be edited, reviewed and removed from its page', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(page());
      await settle(tester);
      expect(find.text('skewer'), findsOneWidget);
      await tester.ensureVisible(find.text('skewer'));
      await tester.tap(find.text('skewer'));
      await settle(tester);
      await tester.tap(find.text('Edit word'));
      await settle(tester);
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'A stick for grilling small pieces of food.',
      );
      await tester.tap(find.text('Save'));
      await settle(tester);
      expect(
        (await store.words()).firstWhere((w) => w.word == 'skewer').meaning,
        startsWith('A stick'),
      );
      await tester.ensureVisible(find.text('skewer'));
      await tester.tap(find.text('skewer'));
      await settle(tester);
      await tester.tap(find.text('Mark as reviewed'));
      await settle(tester);
      expect(
        (await store.words()).firstWhere((w) => w.word == 'skewer').reviews,
        1,
      );
      ScaffoldMessenger.of(
        tester.element(find.byType(AiVocabularyScreen)),
      ).clearSnackBars();
      await tester.pump(const Duration(seconds: 5));
      await tester.ensureVisible(find.text('skewer'));
      await tester.tap(find.text('skewer'));
      await settle(tester);
      await tester.tap(find.text('Delete'));
      await settle(tester);
      expect(find.text('Remove this word?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await settle(tester);
      expect((await store.words()).length, 1);
      expect(tester.takeException(), isNull);
    });
  });
  testWidgets('phone layout supports all locales and light/dark themes', (
    tester,
  ) async {
    await tester.runAsync(() async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final locale in AppLocalizations.supportedLocales) {
        await tester.pumpWidget(page(locale: locale));
        await settle(tester);
        expect(tester.takeException(), isNull, reason: locale.toString());
      }
      await tester.pumpWidget(page());
      await settle(tester);
    });
    await tester.runAsync(() async {
      await tester.pumpWidget(page(brightness: Brightness.dark));
      await settle(tester);
    });
    await tester.runAsync(() async {
      expect(tester.takeException(), isNull);
    });
  });
}
