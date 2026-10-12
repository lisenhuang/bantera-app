import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:html/parser.dart' as html;

class AiWebSource {
  const AiWebSource(this.title, this.url, this.excerpt);
  final String title, url, excerpt;
  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'excerpt': excerpt,
  };
  static AiWebSource? fromJson(dynamic value) {
    if (value is! Map || value['title'] is! String || value['url'] is! String) {
      return null;
    }
    final url = safeUrl(value['url'] as String);
    if (url == null) return null;
    return AiWebSource(
      short(value['title'] as String, 160),
      url.toString(),
      short(value['excerpt'] as String? ?? '', 500),
    );
  }

  static String short(String value, int max) => value
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .substring(
        0,
        value.replaceAll(RegExp(r'\s+'), ' ').trim().length.clamp(0, max),
      );
  static Uri? safeUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.host.isEmpty ||
        value.length > 2048) {
      return null;
    }
    final host = uri.host.toLowerCase();
    if (!host.contains('.') ||
        InternetAddress.tryParse(host) != null ||
        host == 'localhost' ||
        host.endsWith('.local') ||
        host.endsWith('.localhost') ||
        host.endsWith('.internal') ||
        (uri.hasPort && uri.port != 443)) {
      return null;
    }
    return uri;
  }
}

/// Runs on the phone, with no Bantera auth headers, search API secret or server
/// search proxy. Public HTML is best-effort: challenges are never bypassed.
class AiWebSearch {
  AiWebSearch({HttpClient Function()? clientFactory})
    : _clientFactory = clientFactory ?? HttpClient.new;
  final HttpClient Function() _clientFactory;
  int _generation = 0;
  final _active = <HttpClient>{};
  final _recent = <DateTime>[];
  final _cache = <String, ({DateTime at, Map<String, dynamic> result})>{};
  Future<Map<String, dynamic>> search(String query) async {
    query = query.trim();
    if (query.isEmpty ||
        query.length > 240 ||
        query.contains(RegExp(r'[\x00-\x1f]'))) {
      return {'unavailable': true, 'reason': 'invalid_query'};
    }
    final now = DateTime.now();
    final cached = _cache[query];
    if (cached != null && now.difference(cached.at).inMinutes < 5) {
      return cached.result;
    }
    _recent.removeWhere((t) => now.difference(t).inMinutes >= 1);
    if (_recent.length >= 4) {
      return {'unavailable': true, 'reason': 'rate_limited'};
    }
    _recent.add(now);
    final generation = _generation;
    // Both providers are contacted directly by the phone. Bound the combined
    // attempts below the voice-message relay's 12-second tool deadline.
    for (final provider in ['DuckDuckGo', 'Bing']) {
      if (generation != _generation) break;
      final client = _clientFactory()
        ..connectionTimeout = const Duration(seconds: 4);
      _active.add(client);
      try {
        final uri = provider == 'DuckDuckGo'
            ? Uri.https('html.duckduckgo.com', '/html/', {'q': query})
            : Uri.https('www.bing.com', '/search', {
                'q': query,
                'adlt': 'strict',
              });
        final markup = await _fetch(
          client,
          uri,
        ).timeout(const Duration(seconds: 5));
        if (generation != _generation) break;
        final sources = provider == 'DuckDuckGo'
            ? parseResults(markup)
            : parseBingResults(markup);
        if (sources.isEmpty) continue;
        final result = <String, dynamic>{
          'provider': provider,
          'query': query,
          'retrievedAt': DateTime.now().toUtc().toIso8601String(),
          'results': sources.map((s) => s.toJson()).toList(),
          'untrusted': true,
          'excerptsOnly': true,
        };
        if (_cache.length >= 8) _cache.remove(_cache.keys.first);
        _cache[query] = (at: now, result: result);
        return result;
      } catch (_) {
        // A provider challenge, timeout or changed page is not a call failure.
        // Try the independent provider; never execute or bypass challenges.
      } finally {
        _active.remove(client);
        client.close(force: true);
      }
    }
    return {
      'unavailable': true,
      'reason': generation == _generation
          ? 'provider_unavailable'
          : 'cancelled',
      'query': query,
    };
  }

  Future<String> _fetch(HttpClient client, Uri uri) async {
    final request = await client.getUrl(uri);
    request.followRedirects = false;
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'Bantera/2.4 (mobile language learning)',
    );
    request.headers.set(HttpHeaders.acceptHeader, 'text/html');
    final response = await request.close();
    if (response.statusCode != 200 ||
        response.headers.contentType?.mimeType != 'text/html') {
      throw StateError('Search unavailable');
    }
    final bytes = <int>[];
    await for (final chunk in response) {
      if (bytes.length + chunk.length > 768000) {
        throw StateError('Search too large');
      }
      bytes.addAll(chunk);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  static List<AiWebSource> parseBingResults(String markup) {
    final doc = html.parse(markup);
    if (doc.querySelector('#b_captcha, #challenge-form, #anomaly-modal') !=
        null) {
      return [];
    }
    final result = <AiWebSource>[];
    final seen = <String>{};
    for (final row in doc.querySelectorAll('li.b_algo')) {
      final link = row.querySelector('h2 a');
      var href = link?.attributes['href'];
      if (href == null) continue;
      try {
        final redirect = Uri.tryParse(href);
        if (redirect?.host == 'www.bing.com' && redirect?.path == '/ck/a') {
          final encoded = redirect!.queryParameters['u'];
          if (encoded == null || !encoded.startsWith('a1')) continue;
          href = utf8.decode(
            base64Url.decode(base64Url.normalize(encoded.substring(2))),
          );
        }
        final source = AiWebSource.fromJson({
          'title': link!.text,
          'url': href,
          'excerpt': row.querySelector('.b_caption p, p')?.text ?? '',
        });
        if (source == null || source.title.isEmpty || !seen.add(source.url)) {
          continue;
        }
        result.add(source);
        if (result.length == 5) break;
      } catch (_) {
        // Invalid redirect encoding is not a usable source.
      }
    }
    return result;
  }

  static List<AiWebSource> parseResults(String markup) {
    final doc = html.parse(markup);
    if (doc.querySelector('#challenge-form, #anomaly-modal') != null) return [];
    final result = <AiWebSource>[];
    final seen = <String>{};
    for (final row in doc.querySelectorAll('.result')) {
      final link = row.querySelector('.result__a');
      var href = link?.attributes['href'];
      if (href == null) continue;
      final redirect = Uri.tryParse(
        href.startsWith('//') ? 'https:$href' : href,
      );
      if (redirect != null &&
          (redirect.host == 'duckduckgo.com' ||
              redirect.host == 'html.duckduckgo.com') &&
          redirect.path == '/l/') {
        href = redirect.queryParameters['uddg'];
      }
      final source = AiWebSource.fromJson({
        'title': link!.text,
        'url': href,
        'excerpt': row.querySelector('.result__snippet')?.text ?? '',
      });
      if (source == null || source.title.isEmpty || !seen.add(source.url)) {
        continue;
      }
      result.add(source);
      if (result.length == 5) break;
    }
    return result;
  }

  void cancel() {
    _generation++;
    for (final client in _active.toList()) {
      client.close(force: true);
    }
    _active.clear();
  }
}
