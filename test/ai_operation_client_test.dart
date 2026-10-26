import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai_operation_client.dart';

void main() {
  test(
    'retries lost acceptance with the same ID and polls until complete',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final http = HttpClient();
      addTearDown(() async {
        http.close(force: true);
        await server.close(force: true);
      });
      var posts = 0, polls = 0;
      final ids = <String>[];
      server.listen((request) async {
        await request.drain<void>();
        if (request.method == 'POST') {
          posts++;
          ids.add(request.headers.value('Idempotency-Key')!);
          expect(request.headers.value('Prefer'), 'respond-async');
          request.response.statusCode = posts == 1 ? 503 : 202;
          request.response.write(jsonEncode({'jobId': 'same-job'}));
        } else {
          polls++;
          request.response.write(
            jsonEncode(
              polls == 1
                  ? {'status': 'running'}
                  : {
                      'status': 'done',
                      'result': {'summary': 'kept'},
                    },
            ),
          );
        }
        await request.response.close();
      });
      final client = AiOperationClient(
        http: http,
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
        token: (_) async => 'token',
        ensureActive: () async {},
        pollInterval: Duration.zero,
      );
      final result = await client.run('/summary', {
        'text': 'private',
      }, jobId: 'same-job');
      expect(result['summary'], 'kept');
      expect(ids, ['same-job', 'same-job']);
      expect(polls, 2);
    },
  );
  test('stops polling after account change or consent withdrawal', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final http = HttpClient();
    addTearDown(() async {
      http.close(force: true);
      await server.close(force: true);
    });
    var active = true;
    var requests = 0;
    server.listen((request) async {
      requests++;
      await request.drain<void>();
      active = false;
      request.response.statusCode = 202;
      request.response.write('{"jobId":"id"}');
      await request.response.close();
    });
    final client = AiOperationClient(
      http: http,
      baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      token: (_) async => 'token',
      ensureActive: () async {
        if (!active) throw StateError('account changed');
      },
      pollInterval: Duration.zero,
    );
    await expectLater(
      client.run('/summary', {}, jobId: 'id'),
      throwsStateError,
    );
    expect(requests, 1);
  });
  test('terminal failure does not trigger another generation', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final http = HttpClient();
    addTearDown(() async {
      http.close(force: true);
      await server.close(force: true);
    });
    var posts = 0;
    server.listen((request) async {
      await request.drain<void>();
      if (request.method == 'POST') {
        posts++;
        request.response.statusCode = 202;
        request.response.write('{}');
      } else {
        request.response.write(
          '{"status":"failed","statusCode":503,"result":{"message":"Interrupted"}}',
        );
      }
      await request.response.close();
    });
    final client = AiOperationClient(
      http: http,
      baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      token: (_) async => 'token',
      ensureActive: () async {},
      pollInterval: Duration.zero,
    );
    await expectLater(
      client.run('/summary', {}, jobId: 'id'),
      throwsA(isA<AiOperationException>()),
    );
    expect(posts, 1);
  });
}
