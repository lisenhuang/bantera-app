import 'dart:convert';
import 'dart:io';

import 'package:app/infrastructure/chat_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> message(String media) => {
  'messageId': 'message',
  'threadId': 'thread',
  'threadType': 'group',
  'senderUser': {'userId': 'sender', 'displayName': 'Alex'},
  'createdAt': '2026-09-30T00:00:00Z',
  'audioUrl': 'https://api.bantera.app/api/v2/chat/messages/message/$media',
};

void main() {
  test(
    'old server fallback preserves pagination and audio; new image URL is recognized',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final paths = <String>[];
      var oldServer = true;
      server.listen((request) async {
        paths.add(request.uri.path);
        expect(request.uri.queryParameters, {'limit': '25', 'offset': '4'});
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer test-token',
        );
        if (oldServer && request.uri.path.startsWith('/api/v2')) {
          request.response.statusCode = 404;
          request.response.write('Not found');
        } else {
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode([message(oldServer ? 'audio' : 'image')]),
          );
        }
        await request.response.close();
      });
      final client = ChatApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final old = await client.fetchMessages(
        accessToken: 'test-token',
        threadId: 'thread',
        limit: 25,
        offset: 4,
      );
      expect(paths, [
        '/api/v2/chat/threads/thread/messages',
        '/api/chat/threads/thread/messages',
      ]);
      expect(old.single.isImage, isFalse);
      oldServer = false;
      final current = await client.fetchMessages(
        accessToken: 'test-token',
        threadId: 'thread',
        limit: 25,
        offset: 4,
      );
      expect(current.single.isImage, isTrue);
    },
  );
  for (final kind in ['native', 'learning']) {
    test('JPEG upload targets $kind group with expected language', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final dir = await Directory.systemTemp.createTemp(
        'bantera-image-api-test',
      );
      addTearDown(() async {
        await server.close(force: true);
        await dir.delete(recursive: true);
      });
      final file = await File(
        '${dir.path}/achievement.jpg',
      ).writeAsBytes([255, 216, 255, 217]);
      server.listen((request) async {
        expect(request.method, 'POST');
        expect(
          request.uri.path,
          '/api/v2/chat/threads/group/$kind/messages/image',
        );
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer test-token',
        );
        expect(request.headers.contentType!.mimeType, 'multipart/form-data');
        final body = latin1.decode(
          await request.fold<List<int>>([], (all, bytes) => all..addAll(bytes)),
        );
        expect(
          body,
          contains(
            'name="${kind == 'native' ? 'expectedNativeLanguage' : 'expectedLearningLanguage'}"\r\n\r\n${kind == 'native' ? 'zh-CN' : 'en-NZ'}',
          ),
        );
        expect(body, contains('Content-Type: image/jpeg'));
        expect(body, contains('filename="achievement.jpg"'));
        expect(body, isNot(contains('name="durationMs"')));
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(message('image')));
        await request.response.close();
      });
      final client = ChatApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final sent = await client.sendGroupImage(
        accessToken: 'test-token',
        imageFile: file,
        language: kind == 'native' ? 'zh-CN' : 'en-NZ',
        groupKind: kind,
      );
      expect(sent.isImage, isTrue);
    });
  }
}
