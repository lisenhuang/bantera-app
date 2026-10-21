import 'dart:convert';
import 'dart:io';
import 'package:app/core/ai_callback_notifier.dart';
import 'package:app/core/auth_session_notifier.dart';
import 'package:app/infrastructure/saved_practice_store.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/saved_practice_screen.dart';
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
      'cueAudioUrl': 'https://example.test/cue.wav',
      'choices': [
        {'text': 'Hi', 'audioUrl': 'https://example.test/reply.wav'},
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
    'saved practice expands, plays, stops for calls/background, removes and clears on sign out',
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
      final owner = AuthSessionNotifier.instance.session!.cacheKey;
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
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SavedPracticeScreen(owner: owner, store: store),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('こんにちは'), findsOneWidget);
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();
      expect(find.text('Hi'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.volume_up_outlined).first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(methods, contains('resume'));
      methods.clear();
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
      expect(methods, contains('stop'));
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.volume_up_outlined).first,
            )
            .onPressed,
        isNull,
      );
      // Avoid sending a cancellation request; this test owns no backend callback.
      AiCallbackNotifier.instance.ringing = false;
      await AiCallbackNotifier.instance.close();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.volume_up_outlined).first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      methods.clear();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(methods, contains('stop'));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.tap(find.text('Remove from saved'));
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsNothing);
      expect(store.entries.length, 1);
      await tester.runAsync(AuthSessionNotifier.instance.signOut);
      await tester.pumpAndSettle();
      expect(find.text('こんにちは'), findsNothing);
      expect(find.textContaining('No saved practice yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
