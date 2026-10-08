import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_image_search.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_search_capabilities.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';

const picture = AiImageAttachment(
  title: 'Kiwi bird',
  url: 'https://thumb.wikimedia.org/wikipedia/commons/a/ab/Kiwi.jpg',
  sourceUrl: 'https://commons.wikimedia.org/wiki/File:Kiwi.jpg',
  author: 'Photographer',
  license: 'CC BY 4.0',
  mime: 'image/jpeg',
);

class _Search extends AiImageSearch {
  final result = Completer<List<AiDownloadedImage>>();
  String? receivedQuery;
  @override
  Future<List<AiDownloadedImage>> search(String query) {
    receivedQuery = query;
    return result.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'image commands use the existing search query without changing normal searches',
    () {
      expect(
        AiSearchCapabilities.imageQuery('  IMAGES: kiwi bird  '),
        'kiwi bird',
      );
      expect(AiSearchCapabilities.imageQuery('images:'), '');
      expect(AiSearchCapabilities.imageQuery('kiwi bird images'), isNull);
      expect(AiSearchCapabilities.imageQuery('weather in Auckland'), isNull);
    },
  );
  test(
    'capability context is transient and fits the existing history contract',
    () {
      final history = [
        {'role': 'model', 'text': 'Hello'},
        {'role': 'user', 'text': 'Show me a kiwi bird'},
      ];
      final original = jsonEncode(history);
      final sent = AiSearchCapabilities.withContext(history);
      expect(jsonEncode(history), original);
      expect(sent.take(history.length), history);
      expect(sent.last['role'], 'user');
      expect(sent.last['text'], contains('search_web'));
      expect(sent.last['text'], contains('images:'));
      expect(sent.last['text']!.length, lessThan(4000));
      expect(AiSearchCapabilities.withContext([]), hasLength(1));
    },
  );
  test(
    'only trusted image hosts, raster types and safe local filenames survive history',
    () {
      expect(AiImageAttachment.fromJson(picture.toJson()), isNotNull);
      for (final bad in [
        {...picture.toJson(), 'url': 'https://127.0.0.1/private.jpg'},
        {
          ...picture.toJson(),
          'url': 'https://thumb.wikimedia.org.evil.com/a.jpg',
        },
        {...picture.toJson(), 'url': 'https://user@thumb.wikimedia.org/a.jpg'},
        {...picture.toJson(), 'mime': 'image/svg+xml'},
        {...picture.toJson(), 'file': '../history.json'},
        {...picture.toJson(), 'sourceUrl': 'https://example.com/file'},
      ]) {
        expect(AiImageAttachment.fromJson(bad), isNull);
      }
      expect(
        picture.saved('image.jpg').toJson(local: false).containsKey('file'),
        false,
      );
    },
  );
  test(
    'provider results retain attribution, rank and reject malformed images',
    () {
      Map<String, dynamic> page(int index, String url) => {
        'index': index,
        'title': 'File:Bird $index.jpg',
        'imageinfo': [
          {
            'thumburl': url,
            'descriptionurl': picture.sourceUrl,
            'mime': picture.mime,
            'extmetadata': {
              'Artist': {
                'value': '<a href="https://example.com">Photographer</a>',
              },
              'LicenseShortName': {'value': 'CC BY 4.0'},
            },
          },
        ],
      };
      final results = AiImageSearch.parseResults({
        'query': {
          'pages': [
            page(2, 'https://private.local/a.jpg'),
            page(1, picture.url),
          ],
        },
      });
      expect(results.single.title, 'Bird 1.jpg');
      expect(results.single.author, 'Photographer');
      expect(results.single.license, 'CC BY 4.0');
      expect(AiImageSearch.parseResults({'error': 'unavailable'}), isEmpty);
    },
  );
  test('invalid queries and non-images fail safely', () async {
    expect(await AiImageSearch().search(''), isEmpty);
    expect(await AiImageSearch().search('x' * 241), isEmpty);
    await expectLater(
      AiImageSearch.validateImage(
        Uint8List.fromList(utf8.encode('<html>error</html>')),
      ),
      throwsA(anything),
    );
  });

  late Directory root;
  late AiHistoryStore store;
  late AiChatController controller;
  late _Search search;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('bantera-image-test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          AiChatController.audio,
          (call) async => call.method == 'storagePath' ? root.path : null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
    store = AiHistoryStore('test');
    await store.load();
    search = _Search();
    controller = AiChatController.forTesting(store, imageSearch: search)
      ..loaded = true
      ..calling = true;
  });
  tearDown(() async {
    controller.calling = false;
    controller.dispose();
    await root.delete(recursive: true);
  });
  Future<void> request() => controller.receiveCallEventForTesting(
    jsonEncode({
      'type': 'toolCall',
      'calls': [
        {
          'id': 'one',
          'name': 'search_web',
          'args': {'query': 'images: kiwi bird'},
        },
      ],
    }),
  );
  test(
    'image download finishing after an interrupted call turn stays in original bubble and persists',
    () async {
      await request();
      expect(search.receivedQuery, 'kiwi bird');
      final message = controller.messages.single;
      expect(message.imageSearchStatus, 'searching');
      await controller.receiveCallEventForTesting(
        jsonEncode({'type': 'interrupted'}),
      );
      final displayed = Completer<void>();
      controller.addListener(() {
        if (message.images.isNotEmpty && !displayed.isCompleted) {
          displayed.complete();
        }
      });
      search.result.complete([
        (image: picture, bytes: Uint8List.fromList([1, 2, 3])),
      ]);
      await displayed.future.timeout(const Duration(seconds: 3));
      await store.save();
      expect(controller.messages.single, same(message));
      final restored = AiHistoryStore('test');
      await restored.load();
      expect(restored.messages.single.images.single.title, 'Kiwi bird');
      final file = File(
        restored.path(restored.messages.single.images.single.file!),
      );
      expect(await file.readAsBytes(), [1, 2, 3]);
      expect(
        restored.context().single['text'],
        contains('Shared image: Kiwi bird'),
      );
      await restored.clear();
      expect(await file.exists(), false);
    },
  );
  test(
    'ended call cannot attach a late image or leave a local image file',
    () async {
      await request();
      controller.calling = false;
      search.result.complete([
        (image: picture, bytes: Uint8List.fromList([1])),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(controller.messages.single.images, isEmpty);
      expect(
        await root
            .list(recursive: true)
            .where((f) => f.path.endsWith('.jpg'))
            .length,
        0,
      );
    },
  );
  test(
    'older history loads without images and interrupted search does not spin forever',
    () {
      final old = AiMessage.fromJson({
        'role': 'model',
        'text': 'Hi',
        'createdAt': DateTime.now().toIso8601String(),
      });
      expect(old.images, isEmpty);
      final message = AiMessage(
        role: 'model',
        imageSearchStatus: 'searching',
        images: [picture.saved('image.jpg')],
      );
      expect(
        AiMessage.fromJson(message.toJson()).imageSearchStatus,
        'unavailable',
      );
    },
  );
}
