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
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    _active.add(client);
    try {
      final sources = await _fetch(
        client,
        query,
      ).timeout(const Duration(seconds: 8));
      final result = <String, dynamic>{
        'provider': 'DuckDuckGo',
        'query': query,
        'retrievedAt': now.toUtc().toIso8601String(),
        'results': sources.map((s) => s.toJson()).toList(),
        'untrusted': true,
        'excerptsOnly': true,
        if (sources.isEmpty) 'unavailable': true,
      };
      if (sources.isNotEmpty) {
        if (_cache.length >= 8) _cache.remove(_cache.keys.first);
        _cache[query] = (at: now, result: result);
      }
      return result;
    } catch (_) {
      return {
        'unavailable': true,
        'reason': 'provider_unavailable',
        'query': query,
      };
    } finally {
      _active.remove(client);
      client.close(force: true);
    }
  }

  Future<List<AiWebSource>> _fetch(HttpClient client, String query) async {
    final request = await client.getUrl(
      Uri.https('html.duckduckgo.com', '/html/', {'q': query}),
    );
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
    return parseResults(utf8.decode(bytes, allowMalformed: true));
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
    for (final client in _active.toList()) {
      client.close(force: true);
    }
    _active.clear();
  }
}
