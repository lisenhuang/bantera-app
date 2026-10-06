import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/core/theme.dart';
import 'package:app/infrastructure/practice_progress_store.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/profile_library_section.dart';
import 'package:app/presentation/profile/practice_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infrastructure/practice_progress_store_test.dart'
    show historyMedia;

void main() {
  setUpAll(() async {
    final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (await font.exists()) {
      await (FontLoader(
        'ProfileTestFont',
      )..addFont(font.readAsBytes().then(ByteData.sublistView))).load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  Widget app(
    Widget home, {
    Locale locale = const Locale('en'),
    bool dark = false,
    double scale = 1,
  }) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: (dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme).copyWith(
      textTheme: (dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme)
          .textTheme
          .apply(fontFamily: 'ProfileTestFont'),
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: home,
  );
  final recent = PracticeHistoryEntry(
    mediaItem: historyMedia('lesson'),
    cueIndex: 1,
    cueStartMs: 2000,
    cueMode: 'long',
    completedCueKeys: {'0:0:2000'},
    lastPracticedAt: DateTime(2026, 10, 6, 10, 30),
  );
  Widget library({
    VoidCallback? onMedia,
    VoidCallback? onCues,
    VoidCallback? onHistory,
  }) => ProfileLibrarySection(
    savedCount: 12,
    cueCount: 28,
    historyCount: 6,
    recent: recent,
    onSavedMedia: onMedia ?? () {},
    onSavedCues: onCues ?? () {},
    onHistory: onHistory ?? () {},
  );

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('library fits narrow screen with large text: $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          Scaffold(body: SingleChildScrollView(child: library())),
          locale: locale,
          scale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(InkWell), findsNWidgets(3));
    });
  }

  testWidgets('each library card opens its own destination', (tester) async {
    final taps = <String>[];
    await tester.pumpWidget(
      app(
        Scaffold(
          body: SingleChildScrollView(
            child: library(
              onMedia: () => taps.add('media'),
              onCues: () => taps.add('cues'),
              onHistory: () => taps.add('history'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Practice History'));
    await tester.tap(find.text('Saved Media'));
    await tester.tap(find.text('Saved Cues'));
    expect(taps, ['history', 'media', 'cues']);
  });

  testWidgets('remove requires confirmation and clears persisted progress', (
    tester,
  ) async {
    final dir = Directory.systemTemp.createTempSync('history-screen-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final store = PracticeProgressStore(
      file: () async => File('${dir.path}/progress.json'),
      owner: () => 'test',
    );
    await tester.runAsync(
      () => store.record(
        mediaItem: historyMedia('lesson'),
        cueIndex: 1,
        cueStartMs: 2000,
        cueMode: 'long',
        owner: 'test',
        completedCueKeys: {'0:0:2000'},
      ),
    );
    await tester.pumpWidget(app(PracticeHistoryScreen(store: store)));
    for (var i = 0; i < 10; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
    }
    await tester.pumpAndSettle();
    expect(find.text('1/2 cues heard'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove from list'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.entries, hasLength(1));
    await tester.tap(find.byTooltip('Remove from list'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from list'));
    for (var i = 0; i < 10; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
    }
    await tester.pumpAndSettle();
    expect(store.entries, isEmpty);
    expect(find.text('Your next practice starts here'), findsOneWidget);
    expect(await tester.runAsync(() => store.getCueIndex('lesson')), 0);
  });

  testWidgets('preview library in light and dark themes', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final dark in [false, true]) {
      final capture = GlobalKey();
      await tester.pumpWidget(
        app(
          RepaintBoundary(
            key: capture,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Profile'),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      leading: CircleAvatar(radius: 26, child: Text('A')),
                      title: Text('Alex'),
                      subtitle: Text('Learning English'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    library(),
                  ],
                ),
              ),
            ),
          ),
          dark: dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (Platform.environment['BANTERA_PROFILE_PREVIEW'] == '1') {
        await tester.runAsync(() async {
          final boundary =
              capture.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/bantera-profile-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
  });
}
