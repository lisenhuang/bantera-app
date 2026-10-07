import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_web_search.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';

void main() {
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
