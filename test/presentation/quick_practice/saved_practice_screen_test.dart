import 'dart:convert';
import 'dart:io';
import 'package:app/core/ai_callback_notifier.dart';
import 'package:app/core/auth_session_notifier.dart';
import 'package:app/infrastructure/saved_practice_store.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/saved_practice_screen.dart';
import 'package:app/presentation/quick_practice/quick_practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryStore extends SavedPracticeStore {
  MemoryStore() : super(file: () async => throw UnimplementedError());
  final entries = <Map<String, dynamic>>[
    {
      'id': 'one',
      'locale': 'en-US',
      'level': 'A0',
      'cue': 'Hello',
      'cueAudioUrl': '',
      'choices': [
        {'text': 'Hi', 'audioUrl': ''},
        {'text': 'Bye', 'audioUrl': ''},
      ],
    },
    {
      'id': 'two',
      'locale': 'ja-JP',
      'level': 'A1',
      'cue': 'こんにちは',
      'cueAudioUrl': '',
      'choices': <dynamic>[],
    },
  ];
  @override
  Future<List<Map<String, dynamic>>> load(String owner) async => [...entries];
  @override
  Future<void> clear(String owner) async => entries.clear();
  @override
  Future<void> setSaved({
    required String owner,
    required Map<String, dynamic> exercise,
    required bool saved,
  }) async {
    entries.removeWhere((entry) => entry['id'] == exercise['id']);
  }
}

void main() {
  testWidgets(
    'saved practice opens in Practice, restores the prior exercise, removes and clears on sign out',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync(
        'saved-practice-ui-',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      final messenger = tester.binding.defaultBinaryMessenger;
      for (final channel in [
        'xyz.luan/audioplayers.global',
        'xyz.luan/audioplayers.global/events',
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
        accountLabel: 'test',
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
      final methods = <String>[];
      messenger.setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'),
        (call) async {
          methods.add(call.method);
          final id = (call.arguments as Map)['playerId'];
          if (call.method == 'create') {
            messenger.setMockMethodCallHandler(
              MethodChannel('xyz.luan/audioplayers/events/$id'),
              (_) async => null,
            );
          }
          if (call.method == 'setSourceUrl') {
            Future.microtask(
              () => messenger.handlePlatformMessage(
                'xyz.luan/audioplayers/events/$id',
                const StandardMethodCodec().encodeSuccessEnvelope({
                  'event': 'audio.onPrepared',
                  'value': true,
                }),
                (_) {},
              ),
            );
          }
          return null;
        },
      );
      final store = MemoryStore();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final requests = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: QuickPracticeScreen.preview(
            previewSavedStore: store,
            previewExercise: const {
              'id': 'current',
              'locale': 'en-US',
              'level': 'A1',
              'cue': 'Original practice',
              'cueAudioUrl': '',
              'choices': [
                {'text': 'Original answer', 'audioUrl': ''},
                {'text': 'Other answer', 'audioUrl': ''},
              ],
            },
            previewFeedback: const {'outcome': 'correct'},
            previewApi: (path, payload) async {
              requests.add(path);
              return {
                ...store.entries.first,
                'id': 'fresh-review',
                'currentLevel': 'A1',
                'reviewMode': true,
              };
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('practice-more-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved practice'));
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsNothing);
      expect(find.text('Delete'), findsNothing);
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();
      expect(requests, ['one/review']);
      expect(find.byType(SavedPracticeScreen), findsNothing);
      expect(find.byKey(const ValueKey('practice-play-cue')), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Original practice'), findsNothing);
      // Removing from the Practice menu also asks first.
      await tester.tap(find.byKey(const ValueKey('practice-more-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove from saved'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(store.entries.length, 2);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(store.entries.length, 2);
      // Next leaves review without skipping/completing the original exercise.
      await tester.ensureVisible(find.text('Next practice').last);
      await tester.tap(find.text('Next practice').last);
      await tester.pumpAndSettle();
      expect(find.text('Original practice'), findsOneWidget);
      expect(requests, ['one/review']);
      expect(
        find.byKey(const ValueKey('practice-pinned-next')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('practice-more-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved practice'));
      await tester.pumpAndSettle();
      await AiCallbackNotifier.instance.incoming({
        'callId': 'saved-test',
        'recipientUserId': session.userId,
        'expiresAt':
            DateTime.now()
                .add(const Duration(minutes: 1))
                .millisecondsSinceEpoch ~/
            1000,
      }, system: true);
      await tester.pump();
      expect(
        tester.widget<ListTile>(find.widgetWithText(ListTile, 'Hello')).onTap,
        isNull,
      );
      // Avoid sending a cancellation request; this test owns no backend callback.
      AiCallbackNotifier.instance.ringing = false;
      await AiCallbackNotifier.instance.close();
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const ValueKey('saved-practice-one')),
        const Offset(-350, 0),
      );
      await tester.pumpAndSettle();
      // Even a full swipe only reveals the explicit Delete action.
      expect(store.entries.length, 2);
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(store.entries.length, 2);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(store.entries.length, 2);
      await tester.drag(
        find.byKey(const ValueKey('saved-practice-one')),
        const Offset(-350, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('confirm-remove-saved-practice')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsNothing);
      expect(store.entries.length, 1);
      await tester.tap(find.byKey(const ValueKey('clear-all-saved-practice')));
      await tester.pumpAndSettle();
      expect(find.text('Clear all saved practice?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(store.entries.length, 1);
      await tester.tap(find.byKey(const ValueKey('clear-all-saved-practice')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('confirm-remove-saved-practice')),
      );
      await tester.pumpAndSettle();
      expect(store.entries, isEmpty);
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey('clear-all-saved-practice')),
            )
            .onPressed,
        isNull,
      );
      await tester.runAsync(AuthSessionNotifier.instance.signOut);
      await tester.pumpAndSettle();
      expect(find.text('こんにちは'), findsNothing);
      expect(find.textContaining('No saved practice yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
