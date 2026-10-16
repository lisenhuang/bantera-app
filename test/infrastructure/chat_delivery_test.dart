import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app/infrastructure/chat_audio_integrity.dart';
import 'package:app/infrastructure/chat_api_client.dart';
import 'package:app/infrastructure/auth_api_client.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final bytes = [1, 2, 3, 4, 5, 6, 7, 8];
  final digest = sha256.convert(bytes).toString();
  test(
    'receipt waits for committed metadata and read-back file integrity',
    () async {
      final dir = await Directory.systemTemp.createTemp('bantera-dm-');
      addTearDown(() => dir.delete(recursive: true));
      final file = await File(
        '${dir.path}/voice.m4a',
      ).writeAsBytes(bytes, flush: true);
      final committed = Completer<bool>();
      var acknowledgements = 0;
      final delivery = ChatAudioIntegrity.confirmSaved(
        file: file,
        expectedBytes: bytes.length,
        expectedSha256: digest,
        isCommitted: () => committed.future,
        acknowledge: () async {
          acknowledgements++;
        },
      );
      await Future<void>.delayed(Duration.zero);
      expect(acknowledgements, 0);
      committed.complete(true);
      await delivery;
      expect(acknowledgements, 1);
      for (final stored in [
        [1, 2],
        [8, 7, 6, 5, 4, 3, 2, 1],
        <int>[],
      ]) {
        await file.writeAsBytes(stored, flush: true);
        await expectLater(
          ChatAudioIntegrity.confirmSaved(
            file: file,
            expectedBytes: bytes.length,
            expectedSha256: digest,
            isCommitted: () async => true,
            acknowledge: () async {
              acknowledgements++;
            },
          ),
          throwsA(isA<AuthApiException>()),
        );
      }
      await file.writeAsBytes(bytes, flush: true);
      await expectLater(
        ChatAudioIntegrity.confirmSaved(
          file: file,
          expectedBytes: bytes.length,
          expectedSha256: digest,
          isCommitted: () async => false,
          acknowledge: () async {
            acknowledgements++;
          },
        ),
        throwsStateError,
      );
      expect(acknowledgements, 1);
    },
  );
  test(
    'HTTP download verifies size and SHA before a receipt can be sent',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      var corrupt = false;
      final receipts = <Map>[];
      server.listen((request) async {
        expect(request.headers.value('authorization'), 'Bearer test-token');
        if (request.method == 'GET') {
          request.response.headers.set('X-Bantera-Audio-Sha256', digest);
          request.response.contentLength = bytes.length;
          request.response.add(corrupt ? bytes.reversed.toList() : bytes);
        } else {
          receipts.add(
            jsonDecode(await utf8.decoder.bind(request).join()) as Map,
          );
          request.response.statusCode = 204;
        }
        await request.response.close();
      });
      final client = ChatApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final audio = await client.downloadMessageAudio(
        accessToken: 'test-token',
        messageId: 'message',
      );
      expect(audio.sha256, digest);
      expect(audio.byteCount, bytes.length);
      corrupt = true;
      await expectLater(
        client.downloadMessageAudio(
          accessToken: 'test-token',
          messageId: 'message',
        ),
        throwsA(isA<AuthApiException>()),
      );
      expect(receipts, isEmpty);
      await client.acknowledgeVerifiedMessage(
        accessToken: 'test-token',
        messageId: 'message',
        sha256: digest,
        byteCount: bytes.length,
      );
      expect(receipts.single, {'sha256': digest, 'byteCount': bytes.length});
    },
  );
  test(
    'cursor paging follows an opaque cursor while legacy fallback keeps offset',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      var legacy = false;
      final paths = <Uri>[];
      server.listen((request) async {
        paths.add(request.uri);
        if (legacy && request.uri.path.startsWith('/api/v3/')) {
          request.response.statusCode = 404;
        } else {
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode(
              legacy
                  ? []
                  : {
                      'messages': [],
                      'nextCursor':
                          request.uri.queryParameters['cursor'] == null
                          ? 'opaque+/cursor='
                          : null,
                    },
            ),
          );
        }
        await request.response.close();
      });
      final client = ChatApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final first = await client.fetchDirectMessagePage(
        accessToken: 'token',
        threadId: 'thread',
      );
      await client.fetchDirectMessagePage(
        accessToken: 'token',
        threadId: 'thread',
        cursor: first.nextCursor,
      );
      expect(paths.last.queryParameters['cursor'], 'opaque+/cursor=');
      expect(paths.last.queryParameters.containsKey('offset'), false);
      legacy = true;
      final old = await client.fetchDirectMessagePage(
        accessToken: 'token',
        threadId: 'thread',
        offset: 100,
      );
      expect(old.cursorBased, false);
      expect(paths.last.queryParameters['offset'], '100');
    },
  );
}
