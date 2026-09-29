import 'dart:convert';
import 'dart:io';

import 'package:app/domain/audio_level.dart';
import 'package:app/domain/models/models.dart';
import 'package:app/infrastructure/auth_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> video({String? level, bool ai = true}) => {
  'id': 'lesson',
  'userId': 'owner',
  'originalFileName': 'Lesson.mp3',
  'transcriptText': 'Hello.',
  'transcriptLanguage': 'English',
  'transcriptLanguageCode': 'en-US',
  'isPublic': true,
  'isAiGenerated': ai,
  'durationMs': 1000,
  'fileSizeBytes': 100,
  'videoContentType': 'audio/mpeg',
  'createdAt': '2026-09-29T00:00:00Z',
  'level': ?level,
};

void main() {
  test(
    'Legacy AI defaults to Intermediate; uploads remain without a level',
    () {
      expect(
        AuthApiClient.uploadedVideoFromJsonPublic(video()).level,
        AudioLevel.intermediate,
      );
      expect(
        AuthApiClient.uploadedVideoFromJsonPublic(video(ai: false)).level,
        isNull,
      );
      expect(
        AuthApiClient.uploadedVideoFromJsonPublic(
          video(level: 'beginner'),
        ).level,
        AudioLevel.beginner,
      );
    },
  );

  test(
    'Discovery transmits level with existing pagination, language, and search',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final requests = <Uri>[];
      final serving = server.listen((request) async {
        requests.add(request.uri);
        request.response.headers.contentType = ContentType.json;
        request.response.write('[]');
        await request.response.close();
      });
      addTearDown(serving.cancel);
      final client = AuthApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      await client.fetchPublicVideos(
        languageCode: 'en-NZ',
        mediaType: 'audio',
        search: 'coffee',
        offset: 20,
        level: AudioLevel.beginner,
      );
      await client.fetchPublicVideos();
      expect(requests[0].queryParameters, containsPair('level', 'beginner'));
      expect(requests[0].queryParameters, containsPair('offset', '20'));
      expect(
        requests[0].queryParameters,
        containsPair('languageCode', 'en-NZ'),
      );
      expect(requests[0].queryParameters, containsPair('search', 'coffee'));
      expect(requests[0].queryParameters, containsPair('mediaType', 'audio'));
      expect(requests[1].queryParameters.containsKey('level'), isFalse);
    },
  );

  for (final useV3 in [false, true]) {
    test(
      'Generation ${useV3 ? 'v3' : 'v2'} sends selected level and parses response',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(() => server.close(force: true));
        Map? body;
        String? path;
        final serving = server.listen((request) async {
          path = request.uri.path;
          body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
          request.response.headers.contentType = ContentType(
            'text',
            'event-stream',
          );
          request.response.write(
            'data: ${jsonEncode({'step': 'done', 'video': video(level: 'advanced')})}\n\n',
          );
          await request.response.close();
        });
        addTearDown(serving.cancel);
        final client = AuthApiClient.forTesting(
          baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
        );
        final generate = useV3
            ? client.generateAiAudioStreamingV3
            : client.generateAiAudioStreamingV2;
        UploadedVideo? completed;
        await generate(
          accessToken: 'token',
          language: 'English',
          languageCode: 'en-US',
          scenario: 'coffee',
          durationSeconds: 60,
          level: AudioLevel.advanced,
          onDialogueDone: () {},
          onAudioGenerated: () {},
          onAligning: () {},
          onDone: (result, _) => completed = result,
        );
        expect(path, '/api/me/audio/generate/${useV3 ? 'v3' : 'v2'}');
        expect(body?['level'], 'advanced');
        expect(completed?.level, AudioLevel.advanced);
      },
    );
  }
}
