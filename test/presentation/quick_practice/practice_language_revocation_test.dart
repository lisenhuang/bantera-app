import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/core/auth_session_notifier.dart';
import 'package:app/infrastructure/language_availability_service.dart';
import 'package:app/infrastructure/saved_practice_store.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/quick_practice_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _maori = <String, dynamic>{
  'id': 'saved-maori',
  'locale': 'mi-NZ',
  'level': 'A1',
  'cue': 'Kei hea?',
  'cueAudioUrl': 'asset:///cue.mp3',
  'choices': [
    {'text': 'Kei konei.', 'audioUrl': ''},
    {'text': 'Āpōpō.', 'audioUrl': ''},
  ],
  'translations': {'cue': 'Where?', 'option0': 'Here.', 'option1': 'Tomorrow.'},
};

class _Store extends SavedPracticeStore {
  _Store() : super(file: () async => throw UnimplementedError());
  final entries = <Map<String, dynamic>>[_maori];
  @override
  Future<List<Map<String, dynamic>>> load(String owner) async => [...entries];
}

class _Player extends Fake implements AudioPlayer {
  int stops = 0;
  @override
  PlayerState state = PlayerState.stopped;
  @override
  Stream<Duration> get onDurationChanged => const Stream.empty();
  @override
  Stream<Duration> get onPositionChanged => const Stream.empty();
  @override
  Stream<void> get onPlayerComplete => const Stream.empty();
  @override
  Future<void> stop() async {
    stops++;
    state = PlayerState.stopped;
  }

  @override
  Future<void> dispose() async {}
  @override
  Future<void> setSource(Source source) async {}
  @override
  Future<void> setPlaybackRate(double rate) async {}
  @override
  Future<void> resume() async => state = PlayerState.playing;
}

void main() {
  testWidgets(
    'revoking public Māori closes saved review, stops audio and rejects late responses',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync('practice-access-');
      addTearDown(() => directory.deleteSync(recursive: true));
      final messenger = tester.binding.defaultBinaryMessenger;
      for (final channel in [
        'bantera/media_audio',
        'bantera/callkit',
        'com.llfbandit.record/messages',
        'FlutterWebRTC.Event',
        'FlutterWebRTC/Texture1',
      ]) {
        messenger.setMockMethodCallHandler(
          MethodChannel(channel),
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
        (_) async => directory.path,
      );
      final session = AuthSession(
        provider: AuthProviderType.email,
        accountLabel: 'visibility-test',
        accessToken: 'test',
        tokenType: 'Bearer',
        expiresIn: 86400,
        refreshToken: '',
        issuedAt: DateTime.now(),
      );
      File(
        '${directory.path}/auth_session.json',
      ).writeAsStringSync(jsonEncode(session.toJson()));
      await tester.runAsync(AuthSessionNotifier.instance.initialize);
      var public = false;
      final availability = LanguageAvailabilityService.forTesting(
        lookup: () async => public,
      );
      final player = _Player();
      final store = _Store();
      final requests = <String>[];
      final review = Completer<Map<String, dynamic>>();
      final english = Completer<Map<String, dynamic>>();
      var reviews = 0;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.binding.setSurfaceSize(const Size(393, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: QuickPracticeScreen.preview(
            previewLanguageAvailability: availability,
            previewPlayer: player,
            previewSavedStore: store,
            previewExercise: const {
              'id': 'current',
              'locale': 'en-NZ',
              'level': 'A1',
              'cue': 'Original English practice',
              'cueAudioUrl': '',
              'choices': [
                {'text': 'Yes.', 'audioUrl': ''},
                {'text': 'No.', 'audioUrl': ''},
              ],
            },
            previewApi: (path, payload) {
              requests.add(path);
              if (path == 'saved-maori/review') {
                return ++reviews == 1
                    ? review.future
                    : Future.value({..._maori, 'reviewMode': true});
              }
              expect(path, 'saved-maori/english-translation');
              return english.future;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> openSaved({bool pending = false}) async {
        await tester.tap(find.byKey(const ValueKey('practice-more-menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Saved practice'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Kei hea?'));
        if (pending) {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        } else {
          await tester.pumpAndSettle();
        }
      }

      // Already-disabled access is rejected before any review request.
      await openSaved();
      expect(requests, isEmpty);
      expect(find.text('Original English practice'), findsOneWidget);
      expect(store.entries, hasLength(1));
      public = true;
      await availability.refresh();
      await tester.pumpAndSettle();
      await openSaved(pending: true);
      expect(requests, ['saved-maori/review']);
      // The response was permitted when requested, but arrives after revocation.
      public = false;
      await availability.refresh();
      review.complete({..._maori, 'reviewMode': true});
      await tester.pumpAndSettle();
      expect(find.text('Original English practice'), findsOneWidget);
      expect(find.text('Kei hea?'), findsNothing);
      public = true;
      await availability.refresh();
      await tester.pumpAndSettle();
      await openSaved();
      expect(find.text('Kei hea?'), findsOneWidget);
      expect(requests.last, 'saved-maori/english-translation');
      await tester.tap(find.byKey(const ValueKey('practice-play-cue')));
      await tester.pumpAndSettle();
      expect(player.state, PlayerState.playing);
      final priorStops = player.stops;
      public = false;
      await availability.refresh();
      await tester.pumpAndSettle();
      expect(player.stops, greaterThan(priorStops));
      expect(player.state, PlayerState.stopped);
      expect(find.text('Kei hea?'), findsNothing);
      english.complete({
        'status': 'ready',
        'translationAlignmentStatus': 'ready',
        'translations': {
          'cue': 'Late English',
          'option0': 'Here.',
          'option1': 'Tomorrow.',
        },
        'translationAlignments': <String, dynamic>{},
      });
      await tester.pumpAndSettle();
      expect(find.text('Late English'), findsNothing);
      expect(find.byKey(const ValueKey('practice-play-cue')), findsNothing);
      expect(store.entries, hasLength(1));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      availability.dispose();
      await tester.runAsync(AuthSessionNotifier.instance.signOut);
      expect(tester.takeException(), isNull);
    },
  );
}
