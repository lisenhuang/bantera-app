import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_web_search.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';

class _Search extends AiWebSearch {
  final result = Completer<Map<String, dynamic>>();
  String? query;
  @override
  Future<Map<String, dynamic>> search(String query) {
    this.query = query;
    return result.future;
  }
}

class _Socket extends Fake implements WebSocket {
  final sent = <dynamic>[];
  final toolResult = Completer<Map>();
  @override
  void add(dynamic value) {
    sent.add(value);
    if (value is String && !toolResult.isCompleted) {
      toolResult.complete(jsonDecode(value) as Map);
    }
  }

  @override
  Future<void> close([int? code, String? reason]) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'live call keeps audio flowing during device search and returns source result',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'bantera-live-search',
      );
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final audioMethods = <String>[];
      messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
        audioMethods.add(call.method);
        return call.method == 'storagePath' ? directory.path : null;
      });
      const record = MethodChannel('com.llfbandit.record/messages');
      messenger.setMockMethodCallHandler(record, (_) async => null);
      final store = AiHistoryStore('test');
      await store.load();
      store.hasMetBanteraAi = true;
      final search = _Search();
      final socket = _Socket();
      final controller = AiChatController.forTesting(store, webSearch: search)
        ..loaded = true
        ..calling = true
        ..connected = true;
      try {
        controller.microphoneForTesting(Uint8List(640), socket);
        await controller.receiveCallEventForTesting(
          jsonEncode({
            'type': 'toolCall',
            'calls': [
              {
                'id': 'search-1',
                'name': 'search_web',
                'args': {'query': 'New Zealand tourism'},
              },
            ],
          }),
        );
        expect(search.query, 'New Zealand tourism');
        final bubble = controller.messages.single;
        expect(bubble.webSearchStatus, 'searching');
        controller.microphoneForTesting(Uint8List(640), socket);
        await controller.receiveCallEventForTesting(Uint8List(24000));
        expect(socket.sent.whereType<Uint8List>(), hasLength(2));
        expect(audioMethods, contains('feed'));
        expect(socket.toolResult.isCompleted, isFalse);
        search.result.complete({
          'provider': 'Bing',
          'results': [
            {
              'title': 'Tourism New Zealand',
              'url': 'https://www.newzealand.com/',
              'excerpt': 'Official travel information',
            },
          ],
          'untrusted': true,
        });
        final frame = await socket.toolResult.future.timeout(
          const Duration(seconds: 3),
        );
        expect(frame['type'], 'toolResponse');
        final response = (frame['responses'] as List).single as Map;
        expect(response['id'], 'search-1');
        expect(response['response']['result']['provider'], 'Bing');
        expect(bubble.sources.single.url, 'https://www.newzealand.com/');
        await controller.receiveCallEventForTesting(
          jsonEncode({
            'type': 'transcript',
            'role': 'model',
            'text': 'Tourism New Zealand is the official site.',
          }),
        );
        await controller.receiveCallEventForTesting(
          jsonEncode({'type': 'turnComplete'}),
        );
        final restored = AiHistoryStore('test');
        await restored.load();
        expect(
          restored.messages.single.sources.single.url,
          'https://www.newzealand.com/',
        );
        expect(restored.messages.single.text, contains('official site'));
      } finally {
        controller.calling = false;
        controller.dispose();
        await directory.delete(recursive: true);
        messenger.setMockMethodCallHandler(AiChatController.audio, null);
        messenger.setMockMethodCallHandler(record, null);
      }
    },
  );
}
