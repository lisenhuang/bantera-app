import 'dart:convert';
import 'dart:io';
import 'package:app/core/apple_system_version.dart';
import 'package:app/core/auth_session_notifier.dart';
import 'package:app/core/practice_review_service.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/quick_practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'saved_practice_screen_test.dart' show MemoryStore;

class CoveredPractice extends StatefulWidget {
  const CoveredPractice(this.observer, {super.key});
  final PracticeRouteObserver observer;
  @override
  State<CoveredPractice> createState() => _CoveredPracticeState();
}

class _CoveredPracticeState extends State<CoveredPractice> with RouteAware {
  bool covered = false;
  final store = MemoryStore();
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
  Widget build(BuildContext context) => QuickPracticeScreen.preview(
    previewSavedStore: store,
    active: !covered,
    previewExercise: const {
      'id': 'test',
      'locale': 'en-US',
      'level': 'A1',
      'cue': 'Hello',
      'cueAudioUrl': '',
      'choices': [
        {'text': 'Hi', 'audioUrl': ''},
        {'text': 'Bye', 'audioUrl': ''},
      ],
    },
  );
}

void main() {
  testWidgets(
    'translation picker opens after menu route coverage and cancellation is safe',
    (tester) async {
      final dir = Directory.systemTemp.createTempSync('translation-menu-');
      translationCapabilityForTesting = true;
      addTearDown(() {
        translationCapabilityForTesting = null;
        dir.deleteSync(recursive: true);
      });
      final messenger = tester.binding.defaultBinaryMessenger;
      for (final name in [
        'xyz.luan/audioplayers.global',
        'xyz.luan/audioplayers.global/events',
        'bantera/media_audio',
        'bantera/callkit',
        'com.llfbandit.record/messages',
        'FlutterWebRTC.Event',
        'FlutterWebRTC/Texture1',
      ]) {
        messenger.setMockMethodCallHandler(
          MethodChannel(name),
          (_) async => null,
        );
      }
      messenger.setMockMethodCallHandler(
        const MethodChannel('FlutterWebRTC.Method'),
        (call) async =>
            call.method == 'createVideoRenderer' ? {'textureId': 1} : null,
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => dir.path,
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'),
        (call) async {
          if (call.method == 'create') {
            final id = (call.arguments as Map)['playerId'];
            messenger.setMockMethodCallHandler(
              MethodChannel('xyz.luan/audioplayers/events/$id'),
              (_) async => null,
            );
          }
          return null;
        },
      );
      final calls = <String>[];
      messenger.setMockMethodCallHandler(
        const MethodChannel('bantera/translation'),
        (call) async {
          calls.add(call.method);
          return [
            {'identifier': 'fr', 'displayName': 'French', 'isInstalled': true},
          ];
        },
      );
      final session = AuthSession(
        provider: AuthProviderType.email,
        accountLabel: 'translation-test',
        accessToken: 'test',
        tokenType: 'Bearer',
        expiresIn: 86400,
        refreshToken: '',
        issuedAt: DateTime.now(),
      );
      File(
        '${dir.path}/auth_session.json',
      ).writeAsStringSync(jsonEncode(session.toJson()));
      await tester.runAsync(AuthSessionNotifier.instance.initialize);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final observer = PracticeRouteObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CoveredPractice(observer),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('practice-more-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Translation language'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(
        find.byKey(const ValueKey('practice-translation-language-fr')),
      );
      expect(
        find.byKey(const ValueKey('practice-translation-language-fr')),
        findsOneWidget,
      );
      expect(calls, ['getSupportedTranslationLocales']);
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('practice-translation-language-fr')),
        findsNothing,
      );
      expect(calls, ['getSupportedTranslationLocales']);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
