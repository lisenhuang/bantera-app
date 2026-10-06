import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/core/auth_session_notifier.dart';
import 'package:app/core/word_activity_notifier.dart';
import 'package:app/infrastructure/auth_api_client.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:flutter_test/flutter_test.dart';

AuthSession sessionFor(String id) => AuthSession(
  provider: AuthProviderType.email,
  accountLabel: '$id@test.local',
  accessToken:
      'test.${base64Url.encode(utf8.encode(jsonEncode({'sub': id})))}.test',
  tokenType: 'Bearer',
  expiresIn: 3600,
  refreshToken: 'test',
  issuedAt: DateTime.now(),
);

void main() {
  late Directory dir;
  late HttpServer server;
  late AuthApiClient client;
  AuthSession? session;
  late WordActivityNotifier notifier;
  late bool offline;
  late bool expireFirstUserToken;
  late int requests;
  late int remoteListened;
  late int remoteSpoken;
  late Map<String, WordTotals> languageDays;
  Completer<void>? requestReached;
  Completer<void>? releaseRequest;
  final day = DateTime.now();
  final dateKey =
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('bantera-word-store-test');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    client = AuthApiClient.forTesting(
      baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
    );
    session = sessionFor('user-a');
    offline = true;
    expireFirstUserToken = false;
    requests = 0;
    remoteListened = 0;
    remoteSpoken = 0;
    languageDays = {};
    requestReached = null;
    releaseRequest = null;
    server.listen((request) async {
      requests++;
      expect(request.uri.path, '/api/v2/me/word-stats');
      final requestOwner = request.headers.value(
        HttpHeaders.authorizationHeader,
      );
      if (request.method == 'GET' && requestReached != null) {
        requestReached!.complete();
        await releaseRequest!.future;
      }
      request.response.headers.contentType = ContentType.json;
      if (expireFirstUserToken &&
          requestOwner?.contains(sessionFor('user-a').accessToken) == true) {
        request.response.statusCode = 401;
        request.response.write('{"code":"token_expired","message":""}');
      } else if (offline) {
        request.response.statusCode = 503;
        request.response.write(jsonEncode({'message': 'Offline'}));
      } else if (request.method == 'POST') {
        final payload =
            jsonDecode(await utf8.decoder.bind(request).join()) as Map;
        final days = payload['days'] as List;
        for (final item in days) {
          final language = item['language'] as String;
          final listened = item['listenedWords'] as int;
          final spoken = item['spokenWords'] as int;
          if (language.isNotEmpty) {
            final previous = languageDays[language] ?? const WordTotals();
            languageDays[language] = WordTotals(
              listened: listened > previous.listened
                  ? listened
                  : previous.listened,
              spoken: spoken > previous.spoken ? spoken : previous.spoken,
            );
            continue;
          }
          if (listened > remoteListened) remoteListened = listened;
          if (spoken > remoteSpoken) remoteSpoken = spoken;
        }
        request.response.write('{"saved":true}');
      } else {
        final isFirstUser =
            requestOwner?.contains(sessionFor('user-a').accessToken) == true;
        request.response.write(
          jsonEncode({
            'days': isFirstUser
                ? [
                    {
                      'date': dateKey,
                      'language': '',
                      'listenedWords': remoteListened,
                      'spokenWords': remoteSpoken,
                    },
                    for (final entry in languageDays.entries)
                      {
                        'date': dateKey,
                        'language': entry.key,
                        ...entry.value.toJson(),
                      },
                  ]
                : [],
          }),
        );
      }
      await request.response.close();
    });
    notifier = WordActivityNotifier.forTesting(
      session: () => session,
      file: (id) async => File('${dir.path}/$id.json'),
      apiClient: client,
    );
  });

  tearDown(() async {
    notifier.dispose();
    await server.close(force: true);
    await dir.delete(recursive: true);
  });

  test(
    'AI speech events count once across retries, restart and account switches',
    () async {
      await notifier.record(
        spoken: 7,
        language: 'en-NZ',
        speechEventId: 'ai-spoken:one',
        at: day,
      );
      await notifier.record(
        spoken: 7,
        language: 'en-NZ',
        speechEventId: 'ai-spoken:one',
        at: day,
      );
      expect(notifier.summaryFor('en').today.spoken, 7);
      notifier.dispose();
      notifier = WordActivityNotifier.forTesting(
        session: () => session,
        file: (id) async => File('${dir.path}/$id.json'),
        apiClient: client,
      );
      await notifier.record(
        spoken: 7,
        language: 'en-NZ',
        speechEventId: 'ai-spoken:one',
        at: day,
      );
      expect(notifier.summaryFor('en').today.spoken, 7);
      session = sessionFor('user-b');
      await notifier.record(
        spoken: 20,
        language: 'en-NZ',
        ownerId: 'user-a',
        speechEventId: 'ai-spoken:two',
        at: day,
      );
      expect(notifier.summaryFor('en').today.spoken, 0);
    },
  );

  test(
    'language snapshots survive offline restart and sync without mixing accents',
    () async {
      await notifier.record(
        listened: 12,
        spoken: 3,
        language: 'en-NZ',
        at: day,
      );
      await notifier.record(spoken: 4, language: 'en-US', at: day);
      await notifier.record(listened: 8, spoken: 2, language: 'ja-JP', at: day);
      await notifier.sync();
      expect(notifier.summaryFor('en-GB').today.spoken, 7);
      expect(notifier.summaryFor('ja-JP').today.spoken, 2);
      notifier.dispose();
      notifier = WordActivityNotifier.forTesting(
        session: () => session,
        file: (id) async => File('${dir.path}/$id.json'),
        apiClient: client,
      );
      await notifier.sync();
      expect(notifier.summaryFor('en').total.spoken, 7);
      offline = false;
      await notifier.sync();
      await notifier.sync();
      expect(languageDays['en']?.spoken, 7);
      expect(languageDays['ja']?.spoken, 2);
      expect(notifier.summaryFor('fr').total.spoken, 0);
      expect(notifier.summaryFor('en-US').total.spoken, 7);
      expect(notifier.summaryFor('').total.spoken, 0);
    },
  );

  test('offline counts survive restart and repeated synchronization', () async {
    await notifier.record(listened: 12, spoken: 3, at: day);
    await notifier.sync(); // server unavailable
    expect(notifier.summary.today.listened, 12);
    expect(notifier.summaryFor(null).today.listened, 0);
    expect(notifier.summaryFor('').today.listened, 0);
    expect(notifier.legacyTotal.listened, 12);
    notifier.dispose();
    notifier = WordActivityNotifier.forTesting(
      session: () => session,
      file: (id) async => File('${dir.path}/$id.json'),
      apiClient: client,
    );
    await notifier.sync();
    expect(notifier.summary.today.spoken, 3);
    offline = false;
    await notifier.sync();
    await notifier.sync();
    expect(remoteListened, 12);
    expect(notifier.summary.total.listened, 12);
    await notifier.record(listened: 5, ownerId: 'user-a', at: day);
    await notifier.sync();
    expect(remoteListened, 17);
    expect(notifier.summary.total.listened, 17);
  });

  test('goals persist offline per account and deletion removes them', () async {
    expect(
      await notifier.setDailyGoal(
        const DailyWordGoal(listened: 0, spoken: 300),
      ),
      isTrue,
    );
    await notifier.record(listened: 15);
    notifier.dispose();
    notifier = WordActivityNotifier.forTesting(
      session: () => session,
      file: (id) async => File('${dir.path}/$id.json'),
      apiClient: client,
    );
    await notifier.sync();
    expect(notifier.dailyGoal?.listened, 0);
    expect(notifier.dailyGoal?.spoken, 300);
    expect(notifier.summary.today.listened, 15);
    session = sessionFor('user-b');
    expect(notifier.dailyGoal, isNull);
    expect(
      await notifier.setDailyGoal(
        DailyWordGoal.forMinutes(5),
        ownerId: 'user-a',
      ),
      isFalse,
    );
    expect(
      await notifier.setDailyGoal(const DailyWordGoal(listened: 0, spoken: 0)),
      isTrue,
    );
    expect(notifier.dailyGoal?.spoken, 0);
    session = sessionFor('user-a');
    await notifier.sync();
    expect(notifier.dailyGoal?.spoken, 300);
    await notifier.removeUser('user-a');
    expect(notifier.dailyGoal, isNull);
    expect(await File('${dir.path}/user-a.json').exists(), isFalse);
  });

  test(
    'a delayed response cannot overwrite another account or count old activity',
    () async {
      await notifier.record(listened: 12, at: day);
      offline = false;
      requestReached = Completer<void>();
      releaseRequest = Completer<void>();
      final sync = notifier.sync();
      await requestReached!.future.timeout(const Duration(seconds: 5));
      session = sessionFor('user-b');
      expect(notifier.summary.total.listened, 0);
      await notifier.record(listened: 90, ownerId: 'user-a');
      await notifier.record(spoken: 7, ownerId: 'user-b', at: day);
      requestReached = null;
      releaseRequest!.complete();
      await sync;
      expect(notifier.summary.total.listened, 0);
      expect(notifier.summary.today.spoken, 7);
      // The stale activity never lands in user B's local ledger.
      final saved =
          jsonDecode(await File('${dir.path}/user-b.json').readAsString())
              as Map;
      expect(saved['local'][dateKey]['listenedWords'], 0);
    },
  );

  test(
    'a token refresh cannot upload activity to a different account',
    () async {
      offline = false;
      expireFirstUserToken = true;
      client.setTokenRefresher(() async => sessionFor('user-b').accessToken);
      await expectLater(
        client.saveWordActivity(
          accessToken: session!.accessToken,
          deviceId: 'device',
          days: {dateKey: const WordTotals(listened: 12, spoken: 3)},
        ),
        throwsA(isA<SessionExpiredException>()),
      );
      expect(requests, 1);
      expect(remoteListened, 0);
    },
  );

  test(
    'account deletion removes local data and rejects late recordings',
    () async {
      await notifier.record(listened: 12, at: day);
      await notifier.removeUser('user-a');
      await notifier.record(spoken: 8, ownerId: 'user-a', at: day);
      expect(await File('${dir.path}/user-a.json').exists(), false);
      expect(notifier.summary.total.listened, 0);
      session = null;
      await notifier.sync();
      expect(notifier.summary.total.spoken, 0);
    },
  );
}
