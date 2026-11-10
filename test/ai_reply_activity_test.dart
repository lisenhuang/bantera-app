import 'package:flutter/services.dart';
import 'package:app/infrastructure/ai/ai_api_client.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_web_search.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_reply_activity.dart';
import 'package:app/infrastructure/ai/ai_voice_stream.dart';
import 'package:app/presentation/chats/ai/ai_reply_status.dart';
import 'package:app/l10n/app_localizations.dart';

class _Api extends AiApiClient {
  _Api(this.port);
  final int port;
  @override
  Future<WebSocket> voice(
    String owner,
    List<Map<String, String>> history,
    String requestId, {
    required bool hasMetBanteraAi,
    List<Map<String, String>> images = const [],
    bool textOnly = false,
  }) => WebSocket.connect('ws://127.0.0.1:$port');
}

class _Search extends AiWebSearch {
  final entered = Completer<void>();
  final result = Completer<Map<String, dynamic>>();
  @override
  Future<Map<String, dynamic>> search(String query) {
    entered.complete();
    return result.future;
  }
}

void main() {
  test(
    'tool completion restores current phase without overwriting newer work',
    () {
      final state = AiReplyActivity()..base = AiReplyPhase.waiting;
      expect(
        state.beginTool({
          'name': 'manage_vocabulary',
          'args': {'action': 'review_conversation'},
        }),
        isNull,
      );
      final vocabulary = state.beginTool({
        'name': 'manage_vocabulary',
        'args': {'action': 'list'},
      });
      expect(state.phase, AiReplyPhase.vocabulary);
      final image = state.beginTool({
        'name': 'search_web',
        'args': {'query': ' images: brownies'},
      });
      expect(state.phase, AiReplyPhase.images);
      state.endTool(vocabulary);
      expect(state.phase, AiReplyPhase.images);
      state.base = AiReplyPhase.replying;
      state.endTool(image);
      expect(state.phase, AiReplyPhase.replying);
      final other = AiReplyActivity();
      expect(other.phase, AiReplyPhase.sending);
      final video = other.beginTool({
        'name': 'search_web',
        'args': {'query': 'videos: recipes'},
      });
      expect(other.phase, AiReplyPhase.videos);
      other.endTool(video);
      final web = other.beginTool({
        'name': 'search_web',
        'args': {'query': 'recipes'},
      });
      expect(other.phase, AiReplyPhase.web);
      other.endTool(web);
      expect(other.phase, AiReplyPhase.sending);
    },
  );

  test(
    'commit changes sending to waiting before first AI output; retry resets wait',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final commit = Completer<void>();
      WebSocket? peer;
      server.listen((request) async {
        final socket = peer = await WebSocketTransformer.upgrade(request);
        socket.add(jsonEncode({'type': 'ready'}));
        socket.listen((frame) {
          if (frame is String && jsonDecode(frame)['type'] == 'commit')
            commit.complete();
        });
      });
      final phases = <AiReplyPhase>[];
      final audio = Completer<void>();
      final stream = AiVoiceStream(
        connect: () => WebSocket.connect('ws://127.0.0.1:${server.port}'),
        onAudio: (bytes) async {
          if (!audio.isCompleted) audio.complete();
        },
        onReset: () async {},
        onProgress: phases.add,
      );
      try {
        final response = stream.send({});
        await commit.future.timeout(const Duration(seconds: 3));
        expect(phases, [AiReplyPhase.waiting]);
        peer!.add(jsonEncode({'type': 'reset'}));
        peer!.add(Uint8List(4800));
        await audio.future.timeout(const Duration(seconds: 3));
        expect(phases, [
          AiReplyPhase.waiting,
          AiReplyPhase.waiting,
          AiReplyPhase.replying,
        ]);
        peer!.add(jsonEncode({'type': 'complete', 'outputText': 'Hello'}));
        await response;
      } finally {
        await stream.close();
        await peer?.close();
        await server.close(force: true);
      }
    },
  );

  test(
    'controller keeps search status until the asynchronous tool finishes',
    () async {
      final root = await Directory.systemTemp.createTemp('status-tool');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final committed = Completer<void>();
      WebSocket? peer;
      server.listen((request) async {
        final socket = peer = await WebSocketTransformer.upgrade(request);
        socket.add(jsonEncode({'type': 'ready', 'acceptText': true}));
        socket.listen((frame) {
          if (frame is! String) return;
          final data = jsonDecode(frame) as Map;
          if (data['type'] == 'commit') committed.complete();
          if (data['type'] == 'toolResponse') {
            socket.add(Uint8List(4800));
            socket.add(
              jsonEncode({
                'type': 'complete',
                'outputText': 'Here is what I found.',
              }),
            );
          }
        });
      });
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        AiChatController.audio,
        (call) async => call.method == 'storagePath' ? root.path : null,
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (_) async => null,
      );
      final search = _Search();
      final store = AiHistoryStore('test');
      await store.load();
      final chat = AiChatController.forTesting(
        store,
        api: _Api(server.port),
        webSearch: search,
        voiceMetadata: () async => {},
      )..loaded = true;
      try {
        final reply = chat.explainWord(
          text: 'brownie',
          prompt: 'Find brownie recipes on the web',
          language: 'en-NZ',
        );
        await committed.future.timeout(const Duration(seconds: 3));
        expect(chat.replyPhase, AiReplyPhase.waiting);
        peer!.add(
          jsonEncode({
            'type': 'toolCall',
            'calls': [
              {
                'id': 'search',
                'name': 'search_web',
                'args': {'query': 'brownie recipes'},
              },
            ],
          }),
        );
        await search.entered.future.timeout(const Duration(seconds: 3));
        await Future<void>.delayed(Duration.zero);
        expect(chat.replyPhase, AiReplyPhase.web);
        search.result.complete({'results': <dynamic>[], 'untrusted': true});
        await reply;
        expect(chat.replyPhase, isNull);
      } finally {
        chat.dispose();
        await peer?.close();
        await server.close(force: true);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        messenger.setMockMethodCallHandler(AiChatController.audio, null);
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          null,
        );
        await root.delete(recursive: true);
      }
    },
  );

  testWidgets(
    'single localized accessible status fits narrow large-text layouts',
    (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        for (final phase in AiReplyPhase.values) {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(brightness: Brightness.dark),
              home: Scaffold(
                body: MediaQuery(
                  data: const MediaQueryData(textScaler: TextScaler.linear(3)),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 260,
                      child: AiReplyStatus(phase: phase),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          final semantics = tester.widgetList<Semantics>(
            find.descendant(
              of: find.byType(AiReplyStatus),
              matching: find.byType(Semantics),
            ),
          );
          expect(semantics.any((s) => s.properties.liveRegion == true), true);
        }
      }
    },
  );
}
