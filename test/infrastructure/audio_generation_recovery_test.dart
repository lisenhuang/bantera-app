import 'dart:convert';
import 'dart:io';

import 'package:app/domain/models/models.dart';
import 'package:app/infrastructure/auth_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> completedVideo(String id) => {
  'id': id,
  'userId': 'owner',
  'originalFileName': 'Audio.wav',
  'transcriptText': 'Hello.',
  'transcriptLanguage': 'English',
  'transcriptLanguageCode': 'en-AU',
  'isPublic': true,
  'durationMs': 2000,
  'fileSizeBytes': 1000,
  'videoContentType': 'audio/wav',
  'createdAt': '2026-09-27T00:00:00Z',
  'dialogueLines': ['Hello.'],
};

void main() {
  for (final useV3 in [false, true]) {
    for (final includeStarted in [false, true]) {
      test(
        'recovers ${useV3 ? 'v3' : 'v2'} after EOF, started=$includeStarted, without another POST',
        () async {
          final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
          addTearDown(() => server.close(force: true));
          final client = AuthApiClient.forTesting(
            baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
          );
          var posts = 0;
          var polls = 0;
          String? jobId;
          final serving = server.listen((request) async {
            request.response.headers.contentType = ContentType.json;
            if (request.method == 'POST') {
              posts++;
              final data =
                  jsonDecode(await utf8.decoder.bind(request).join()) as Map;
              jobId = data['clientJobId'] as String;
              request.response.headers.contentType = ContentType(
                'text',
                'event-stream',
              );
              if (includeStarted) {
                request.response.write(
                  'data: ${jsonEncode({'step': 'started', 'jobId': jobId})}\n\n',
                );
              }
              // An EOF can happen before any progress or after an intermediate step.
              request.response.write(
                'data: {"step":"dialogue","lines":["Hello."]}\n\n',
              );
            } else {
              expect(request.uri.path, '/api/me/audio/jobs/$jobId');
              polls++;
              request.response.write(
                jsonEncode(
                  polls == 1
                      ? {'status': 'processing'}
                      : {
                          'status': 'done',
                          'video': completedVideo('completed-audio'),
                        },
                ),
              );
            }
            await request.response.close();
          });
          addTearDown(serving.cancel);
          UploadedVideo? result;
          await client.generateAiAudioStreaming(
            accessToken: 'token',
            language: 'English',
            languageCode: 'en-AU',
            scenario: 'Coffee',
            durationSeconds: 60,
            useV2: !useV3,
            useV3: useV3,
            onDialogueDone: () {},
            onAudioDone: (v, lines) {
              result = v;
              expect(lines, ['Hello.']);
            },
          );
          expect(result?.id, 'completed-audio');
          expect(posts, 1);
          expect(polls, 2);
        },
      );
    }
  }

  test(
    'a real server generation failure is reported without retrying',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final client = AuthApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      var posts = 0;
      final serving = server.listen((request) async {
        if (request.method == 'POST') {
          posts++;
          await request.drain<void>();
        } else {
          request.response.write(
            jsonEncode({
              'status': 'failed',
              'errorMessage': 'Unable to generate this audio.',
            }),
          );
        }
        await request.response.close();
      });
      addTearDown(serving.cancel);
      await expectLater(
        client.generateAiAudioStreaming(
          accessToken: 'token',
          language: 'English',
          languageCode: 'en-AU',
          scenario: 'Coffee',
          durationSeconds: 60,
          useV2: true,
          onDialogueDone: () {},
          onAudioDone: (_, _) {
            fail('must not succeed');
          },
        ),
        throwsA(
          isA<AuthApiException>().having(
            (e) => e.code,
            'code',
            'generation_failed',
          ),
        ),
      );
      expect(posts, 1);
    },
  );

  test('done is final and requires no status poll', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final client = AuthApiClient.forTesting(
      baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
    );
    var requests = 0;
    var completions = 0;
    final serving = server.listen((request) async {
      requests++;
      await request.drain<void>();
      request.response.write(
        'data: ${jsonEncode({'step': 'done', 'video': completedVideo('finished')})}\n\n',
      );
      request.response.write(
        'data: {"step":"error","message":"late stream error"}\n\n',
      );
      await request.response.close();
    });
    addTearDown(serving.cancel);
    await client.generateAiAudioStreaming(
      accessToken: 'token',
      language: 'English',
      languageCode: 'en-AU',
      scenario: 'Coffee',
      durationSeconds: 60,
      useV2: true,
      onDialogueDone: () {},
      onAudioDone: (_, _) {
        completions++;
      },
    );
    expect(completions, 1);
    expect(requests, 1);
  });

  test(
    'recovers through proxy errors without resubmitting generation',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final client = AuthApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      var posts = 0;
      var polls = 0;
      final serving = server.listen((request) async {
        if (request.method == 'POST') {
          posts++;
          await request.drain<void>();
          request.response.statusCode = 504;
          request.response.write('<html>Gateway timeout</html>');
        } else if (++polls == 1) {
          request.response.statusCode = 502;
          request.response.write('<html>Bad gateway</html>');
        } else {
          request.response.write(
            jsonEncode({
              'status': 'done',
              'video': completedVideo('proxy-recovered'),
            }),
          );
        }
        await request.response.close();
      });
      addTearDown(serving.cancel);
      UploadedVideo? result;
      await client.generateAiAudioStreaming(
        accessToken: 'token',
        language: 'English',
        languageCode: 'en-AU',
        scenario: 'Coffee',
        durationSeconds: 60,
        useV2: true,
        onDialogueDone: () {},
        onAudioDone: (video, _) => result = video,
      );
      expect(result?.id, 'proxy-recovered');
      expect(posts, 1);
      expect(polls, 2);
    },
  );

  test('processing past recovery window stays pending', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final client = AuthApiClient.forTesting(
      baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      recoveryTimeout: const Duration(milliseconds: 60),
      recoveryPollInterval: const Duration(milliseconds: 10),
    );
    final serving = server.listen((request) async {
      if (request.method == 'POST') {
        await request.drain<void>();
      } else {
        request.response.write('{"status":"processing"}');
      }
      await request.response.close();
    });
    addTearDown(serving.cancel);
    await expectLater(
      client.generateAiAudioStreaming(
        accessToken: 'token',
        language: 'English',
        languageCode: 'en-AU',
        scenario: 'Coffee',
        durationSeconds: 60,
        useV2: true,
        onDialogueDone: () {},
        onAudioDone: (_, _) {
          fail('not done');
        },
      ),
      throwsA(
        isA<AuthApiException>().having(
          (e) => e.code,
          'code',
          'generation_pending',
        ),
      ),
    );
  });
}
