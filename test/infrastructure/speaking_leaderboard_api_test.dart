import 'dart:convert';
import 'dart:io';
import 'package:app/infrastructure/auth_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => HttpOverrides.global = null);
  test(
    'admin deletion accepts both existing video 200 and practice 204',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final requests = <String>[];
      server.listen((request) async {
        requests.add('${request.method} ${request.uri.path}');
        request.response.statusCode = request.uri.path.contains('/videos/')
            ? 200
            : 204;
        if (request.response.statusCode == 200) {
          request.response.headers.contentType = ContentType.json;
          request.response.write('{"deleted":true}');
        }
        await request.response.close();
      });
      final client = AuthApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      try {
        await client.deleteAdminContent(accessToken: 'test', videoId: 'video');
        await client.deleteAdminContent(
          accessToken: 'test',
          practiceExposureId: 'practice',
        );
        expect(requests, [
          'DELETE /api/admin/videos/video',
          'DELETE /api/admin/practice/exposures/practice',
        ]);
      } finally {
        await server.close(force: true);
      }
    },
  );
  test(
    'default stays public 30 days and admin periods preserve pagination',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final requests = <Uri>[];
      server.listen((request) async {
        requests.add(request.uri);
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'rows': [], 'you': {}}));
        await request.response.close();
      });
      final client = AuthApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      try {
        await client.speakingLeaderboard(accessToken: 'test');
        await client.speakingLeaderboard(
          accessToken: 'test',
          days: 7,
          offset: 100,
        );
        await client.speakingLeaderboard(
          accessToken: 'test',
          days: 1,
          offset: 200,
        );
        expect(requests.map((r) => r.path), [
          '/api/speaking-leaderboard',
          '/api/admin/speaking-leaderboard',
          '/api/admin/speaking-leaderboard',
        ]);
        expect(requests.map((r) => r.queryParameters['hours']), [
          '720',
          '168',
          '24',
        ]);
        expect(requests.map((r) => r.queryParameters['offset']), [
          '0',
          '100',
          '200',
        ]);
        await expectLater(
          client.speakingLeaderboard(accessToken: 'test', days: 2),
          throwsArgumentError,
        );
        expect(requests.length, 3);
      } finally {
        await server.close(force: true);
      }
    },
  );
}
