import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_web_search.dart';
import 'package:app/infrastructure/ai/ai_video_search.dart';
import 'package:app/infrastructure/ai/ai_search_capabilities.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:app/presentation/chats/ai/ai_video_cards.dart';
import 'package:app/l10n/app_localizations.dart';

const link = 'https://www.youtube.com/watch?v=M7lc1UVf-VE';

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
  final result = Completer<Map>();
  @override
  void add(dynamic value) {
    if (value is String && !result.isCompleted) {
      result.complete(jsonDecode(value) as Map);
    }
  }

  @override
  Future<void> close([int? code, String? reason]) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('video search is distinct from optional word images', () {
    expect(AiSearchCapabilities.videoQuery(' VIDEOS: birds '), 'birds');
    expect(AiSearchCapabilities.videoQuery('videos:'), '');
    expect(AiSearchCapabilities.videoQuery('images: birds'), isNull);
    expect(AiSearchCapabilities.imageQuery('videos: birds'), isNull);
    expect(AiSearchCapabilities.context.length, lessThan(4000));
  });
  test(
    'only actual supported video URLs become cards; unsafe and lookalike hosts fail',
    () {
      for (final url in [
        link,
        'https://youtu.be/M7lc1UVf-VE',
        'https://m.youtube.com/shorts/M7lc1UVf-VE',
      ]) {
        final video = AiVideoAttachment.fromJson({
          'title': 'Video',
          'url': url,
        });
        expect(video?.youtubeId, 'M7lc1UVf-VE');
        expect(video?.url, link);
      }
      for (final url in [
        'https://youtube.com.evil.test/watch?v=M7lc1UVf-VE',
        'https://youtube.com@evil.test/watch?v=M7lc1UVf-VE',
        'http://www.youtube.com/watch?v=M7lc1UVf-VE',
        'https://localhost/video',
        'https://www.youtube.com/results?search_query=birds',
        'https://www.youtube.com/watch?v=bad',
        'https://www.youtube.com/embed/M7lc1UVf-VE/extra',
        'javascript:alert(1)',
        'https://www.example.com/not-a-video',
      ]) {
        expect(
          AiVideoAttachment.fromJson({'title': 'Video', 'url': url}),
          isNull,
          reason: url,
        );
      }
      expect(
        AiVideoAttachment.fromJson({
          'title': 'Film',
          'url': 'https://vimeo.com/12345',
        })?.youtubeId,
        isNull,
      );
    },
  );
  test(
    'history preserves video cards and marks unfinished searches unavailable',
    () {
      final message = AiMessage(
        role: 'model',
        videoSearchStatus: 'searching',
        videos: [const AiVideoAttachment(title: 'Demo', url: link)],
      );
      final restored = AiMessage.fromJson(message.toJson());
      expect(restored.videos.single.url, link);
      expect(restored.videoSearchStatus, 'unavailable');
      expect(
        AiHistoryStore.contextFor([restored]).single['text'],
        contains('contents not watched'),
      );
      expect(
        AiMessage.fromJson(AiMessage(role: 'model').toJson()).videos,
        isEmpty,
      );
    },
  );
  test(
    'embedded player has app identity, manual playback and no untrusted HTML',
    () {
      final html = youtubePlayerHtml(
        'M7lc1UVf-VE',
        'https://com.lisenhuang.bantera',
      );
      expect(html, contains('autoplay:0'));
      expect(html, contains('playsinline:1'));
      expect(html, contains('strict-origin-when-cross-origin'));
      expect(html, contains('onError'));
      expect(
        () => youtubePlayerHtml('bad<script>', 'https://app'),
        throwsArgumentError,
      );
      expect(
        () => youtubePlayerHtml('M7lc1UVf-VE', 'javascript:bad'),
        throwsArgumentError,
      );
    },
  );
  test(
    'Live video tool runs on device, returns bounded deduplicated links and persists bubble',
    () async {
      final dir = await Directory.systemTemp.createTemp('live-videos');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        AiChatController.audio,
        (call) async => call.method == 'storagePath' ? dir.path : null,
      );
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
                'id': 'v1',
                'name': 'search_web',
                'args': {'query': 'videos: how to make tea'},
              },
            ],
          }),
        );
        expect(search.query, 'how to make tea video');
        final bubble = controller.messages.single;
        expect(bubble.videoSearchStatus, 'searching');
        expect(bubble.images, isEmpty);
        search.result.complete({
          'provider': 'Bing',
          'results': [
            {'title': 'Tea lesson', 'url': link},
            {'title': 'Same video', 'url': 'https://youtu.be/M7lc1UVf-VE'},
            {'title': 'Other film', 'url': 'https://vimeo.com/12345'},
            {'title': 'Article', 'url': 'https://www.example.com/tea'},
          ],
        });
        final frame = await socket.result.future.timeout(
          const Duration(seconds: 3),
        );
        final result = frame['responses'][0]['response']['result'];
        expect(result['delivered'], true);
        expect(result['metadataOnly'], true);
        expect(result['videos'], hasLength(2));
        expect(bubble.videos, hasLength(2));
        await controller.receiveCallEventForTesting(
          jsonEncode({
            'type': 'transcript',
            'role': 'model',
            'text': 'I found two videos.',
          }),
        );
        await controller.receiveCallEventForTesting(
          jsonEncode({'type': 'turnComplete'}),
        );
        final loaded = AiHistoryStore('test');
        await loaded.load();
        expect(loaded.messages.last.videos, hasLength(2));
      } finally {
        controller.dispose();
        await Future<void>.delayed(const Duration(milliseconds: 40));
        messenger.setMockMethodCallHandler(AiChatController.audio, null);
        messenger.setMockMethodCallHandler(record, null);
        await dir.delete(recursive: true);
      }
    },
  );
  for (final width in [180.0, 280.0]) {
    testWidgets('video card fits $width and loads nothing before a tap', (
      tester,
    ) async {
      final message = AiMessage(
        role: 'model',
        videos: [
          const AiVideoAttachment(
            title: 'A long descriptive video title about birds',
            url: link,
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: AiVideoCards(
                message: message,
                enabled: false,
                beforePlay: () async {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('Play video'), findsOneWidget);
      expect(find.text('Open in browser'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
