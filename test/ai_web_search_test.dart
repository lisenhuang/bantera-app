import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_web_search.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';

class _Headers extends Fake implements HttpHeaders {
  @override
  ContentType? get contentType => ContentType.html;
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _Response extends Fake implements HttpClientResponse {
  _Response(this.body, [this.statusCode = 200]);
  final String body;
  @override
  final int statusCode;
  @override
  HttpHeaders get headers => _Headers();
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream.value(utf8.encode(body)).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}

class _Request extends Fake implements HttpClientRequest {
  _Request(this.response);
  final Future<HttpClientResponse> Function() response;
  @override
  HttpHeaders get headers => _Headers();
  @override
  set followRedirects(bool value) {}
  @override
  Future<HttpClientResponse> close() => response();
}

class _Client extends Fake implements HttpClient {
  _Client(this.fetch);
  final Future<HttpClientResponse> Function(Uri) fetch;
  bool closed = false;
  @override
  set connectionTimeout(Duration? value) {}
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _Request(() => fetch(url));
  @override
  void close({bool force = false}) {
    closed = true;
  }
}

const _bingResult =
    '<li class="b_algo"><h2><a href="https://www.newzealand.com/">New Zealand tourism</a></h2><div class="b_caption"><p>Official travel information.</p></div></li>';

void main() {
  test(
    'Bing sources unwrap safe redirects and reject challenges or private links',
    () {
      final encoded = base64Url.encode(utf8.encode('https://example.com/page'));
      final results = AiWebSearch.parseBingResults('''
      <li class="b_algo"><h2><a href="https://www.bing.com/ck/a?u=a1$encoded">Source</a></h2><p>Excerpt</p></li>
      <li class="b_algo"><h2><a href="https://example.com/page">Duplicate</a></h2></li>
      <li class="b_algo"><h2><a href="https://127.0.0.1/private">Private</a></h2></li>
      <li class="b_algo"><h2><a href="https://www.bing.com/ck/a?u=a1!">Invalid</a></h2></li>
      <li class="b_algo"><h2><a href="javascript:alert(1)">Script</a></h2></li>
    ''');
      expect(results.single.url, 'https://example.com/page');
      expect(results.single.excerpt, 'Excerpt');
      expect(
        AiWebSearch.parseBingResults('<div id="b_captcha"></div>$_bingResult'),
        isEmpty,
      );
    },
  );

  for (final failure in ['challenge', 'http', 'timeout', 'oversize', 'empty']) {
    test(
      'device fallback recovers from DuckDuckGo $failure and caches results',
      () async {
        final urls = <Uri>[];
        final clients = <_Client>[];
        final search = AiWebSearch(
          clientFactory: () {
            final client = _Client((uri) async {
              urls.add(uri);
              if (uri.host == 'www.bing.com') return _Response(_bingResult);
              return switch (failure) {
                'http' => _Response('', 429),
                'timeout' => throw TimeoutException('provider timeout'),
                'oversize' => _Response('x' * 768001),
                'empty' => _Response('<html></html>'),
                _ => _Response('<form id="challenge-form"></form>'),
              };
            });
            clients.add(client);
            return client;
          },
        );
        final result = await search.search('New Zealand tourism');
        expect(result['provider'], 'Bing');
        expect(result['unavailable'], isNull);
        expect(
          (result['results'] as List).single['url'],
          'https://www.newzealand.com/',
        );
        expect(urls.map((u) => u.host), [
          'html.duckduckgo.com',
          'www.bing.com',
        ]);
        expect(urls.every((u) => u.scheme == 'https'), isTrue);
        expect(clients.every((c) => c.closed), isTrue);
        expect(await search.search('New Zealand tourism'), same(result));
        expect(urls, hasLength(2));
      },
    );
  }

  test('ending a call cancels search without starting a fallback', () async {
    final page = Completer<HttpClientResponse>();
    var requests = 0;
    final search = AiWebSearch(
      clientFactory: () => _Client((_) {
        requests++;
        return page.future;
      }),
    );
    final pending = search.search('tourism');
    await Future<void>.delayed(Duration.zero);
    search.cancel();
    page.complete(_Response(''));
    expect((await pending)['reason'], 'cancelled');
    expect(requests, 1);
  });

  test(
    'both providers unavailable gives a bounded graceful tool result',
    () async {
      var requests = 0;
      final search = AiWebSearch(
        clientFactory: () => _Client((_) async {
          requests++;
          return _Response('', 503);
        }),
      );
      expect(
        (await search.search('tourism'))['reason'],
        'provider_unavailable',
      );
      expect(requests, 2);
    },
  );
  test(
    'extracts bounded sources and unwraps provider links without executing HTML',
    () {
      final sources = AiWebSearch.parseResults('''
      <div class="result"><a class="result__a" href="//duckduckgo.com/l/?uddg=https%3A%2F%2Fexample.com%2Fweather">Weather &amp; news</a><a class="result__snippet">A short forecast.</a></div>
      <div class="result"><a class="result__a" href="https://example.com/weather">Duplicate</a></div>
      <div class="result"><a class="result__a" href="javascript:alert(1)">Bad link</a></div>
      <div class="result"><a class="result__a" href="https://127.0.0.1/private">Private</a></div>
    ''');
      expect(sources, hasLength(1));
      expect(sources.single.title, 'Weather & news');
      expect(sources.single.url, 'https://example.com/weather');
      expect(sources.single.excerpt, 'A short forecast.');
      expect(
        AiWebSearch.parseResults('<form id="challenge-form"></form>'),
        isEmpty,
      );
    },
  );
  test(
    'sources survive local history and unfinished searches do not stay spinning',
    () {
      final message = AiMessage(
        role: 'model',
        webSearchStatus: 'searching',
        webSearchQuery: 'weather',
        sources: [
          const AiWebSource('Weather', 'https://example.com', 'Forecast'),
        ],
      );
      final restored = AiMessage.fromJson(message.toJson());
      expect(restored.webSearchStatus, 'unavailable');
      expect(restored.sources.single.url, 'https://example.com');
      expect(
        AiMessage.fromJson({
          'role': 'model',
          'createdAt': DateTime.now().toIso8601String(),
        }).sources,
        isEmpty,
      );
    },
  );
  test('invalid query never needs a provider request', () async {
    expect((await AiWebSearch().search(''))['unavailable'], true);
    expect((await AiWebSearch().search('a' * 241))['reason'], 'invalid_query');
  });
}
