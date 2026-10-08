import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:html/parser.dart' as html;
import 'ai_web_search.dart';

class AiImageAttachment {
  const AiImageAttachment({
    required this.title,
    required this.url,
    required this.sourceUrl,
    required this.author,
    required this.license,
    required this.mime,
    this.licenseUrl = '',
    this.file,
  });
  final String title, url, sourceUrl, author, license, licenseUrl, mime;
  final String? file;
  AiImageAttachment saved(String name) => AiImageAttachment(
    title: title,
    url: url,
    sourceUrl: sourceUrl,
    author: author,
    license: license,
    licenseUrl: licenseUrl,
    mime: mime,
    file: name,
  );
  Map<String, dynamic> toJson({bool local = true}) => {
    'title': title,
    'url': url,
    'sourceUrl': sourceUrl,
    'author': author,
    'license': license,
    'licenseUrl': licenseUrl,
    'mime': mime,
    if (local && file != null) 'file': file,
  };
  static AiImageAttachment? fromJson(dynamic value) {
    if (value is! Map) return null;
    String field(String key) =>
        value[key] is String ? value[key] as String : '';
    final url = imageUrl(field('url'));
    final source = AiWebSource.safeUrl(field('sourceUrl'));
    final file = value['file'];
    if (url == null ||
        source?.host != 'commons.wikimedia.org' ||
        !source!.path.startsWith('/wiki/File:') ||
        !['image/jpeg', 'image/png', 'image/webp'].contains(field('mime')) ||
        field('title').isEmpty ||
        field('license').isEmpty ||
        (file != null &&
            (file is! String ||
                !RegExp(r'^[a-zA-Z0-9-]+\.(jpg|png|webp)$').hasMatch(file)))) {
      return null;
    }
    return AiImageAttachment(
      title: AiWebSource.short(field('title'), 180),
      url: url.toString(),
      sourceUrl: source.toString(),
      author: AiWebSource.short(field('author'), 300),
      license: AiWebSource.short(field('license'), 100),
      licenseUrl: AiWebSource.safeUrl(field('licenseUrl'))?.toString() ?? '',
      mime: field('mime'),
      file: file as String?,
    );
  }

  static Uri? imageUrl(String value) {
    final uri = AiWebSource.safeUrl(value);
    return uri != null &&
            const [
              'upload.wikimedia.org',
              'thumb.wikimedia.org',
            ].contains(uri.host) &&
            uri.path.startsWith('/wikipedia/commons/')
        ? uri
        : null;
  }
}

typedef AiDownloadedImage = ({AiImageAttachment image, Uint8List bytes});

/// Only Wikimedia's API and image host are contacted. Never follows redirects,
/// takes arbitrary download URLs from the model, or forwards app credentials.
class AiImageSearch {
  final _active = <HttpClient>{};
  final _recent = <DateTime>[];
  int _generation = 0;
  bool _busy = false;
  Future<List<AiDownloadedImage>> search(String query) async {
    query = query.trim();
    if (query.isEmpty ||
        query.length > 240 ||
        query.contains(RegExp(r'[\x00-\x1f]')) ||
        _busy) {
      return [];
    }
    final now = DateTime.now();
    _recent.removeWhere((t) => now.difference(t).inMinutes >= 1);
    if (_recent.length >= 4) return [];
    _recent.add(now);
    _busy = true;
    final generation = _generation;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    _active.add(client);
    try {
      return await _search(
        client,
        query,
        generation,
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      return [];
    } finally {
      client.close(force: true);
      _active.remove(client);
      _busy = false;
    }
  }

  Future<List<AiDownloadedImage>> _search(
    HttpClient client,
    String query,
    int generation,
  ) async {
    final json = await _get(
      client,
      Uri.https('commons.wikimedia.org', '/w/api.php', {
        'action': 'query',
        'format': 'json',
        'formatversion': '2',
        'generator': 'search',
        'gsrsearch': '$query filetype:bitmap',
        'gsrnamespace': '6',
        'gsrlimit': '6',
        'prop': 'imageinfo',
        'iiprop': 'url|mime|extmetadata',
        'iiurlwidth': '640',
        'iiurlheight': '640',
        'iiextmetadatafilter':
            'Artist|LicenseShortName|LicenseUrl|ImageDescription',
      }),
      512000,
      const ['application/json'],
    );
    final candidates = parseResults(jsonDecode(utf8.decode(json.bytes)));
    final downloaded = await Future.wait(
      candidates.take(2).map((candidate) async {
        try {
          final data = await _get(
            client,
            AiImageAttachment.imageUrl(candidate.url)!,
            3 * 1024 * 1024,
            [candidate.mime],
          );
          if (generation != _generation) return null;
          await validateImage(data.bytes);
          if (generation != _generation) return null;
          return (image: candidate, bytes: data.bytes);
        } catch (_) {
          return null;
        }
      }),
    );
    return generation == _generation
        ? downloaded.whereType<AiDownloadedImage>().toList()
        : [];
  }

  static Future<void> validateImage(Uint8List bytes) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    try {
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      try {
        if (descriptor.width <= 0 ||
            descriptor.height <= 0 ||
            descriptor.width > 4096 ||
            descriptor.height > 4096 ||
            descriptor.width * descriptor.height > 16000000) {
          throw const FormatException('Image dimensions');
        }
        final codec = await descriptor.instantiateCodec(
          targetWidth: descriptor.width.clamp(1, 800),
        );
        try {
          final frame = await codec.getNextFrame();
          frame.image.dispose();
        } finally {
          codec.dispose();
        }
      } finally {
        descriptor.dispose();
      }
    } finally {
      buffer.dispose();
    }
  }

  Future<({Uint8List bytes, String mime})> _get(
    HttpClient client,
    Uri uri,
    int limit,
    List<String> accepted,
  ) async {
    final request = await client.getUrl(uri);
    request.followRedirects = false;
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'Bantera/2.6 (https://bantera.app; language learning)',
    );
    request.headers.set(HttpHeaders.acceptHeader, accepted.join(', '));
    final response = await request.close();
    final mime = response.headers.contentType?.mimeType ?? '';
    if (response.statusCode != 200 ||
        !accepted.contains(mime) ||
        response.contentLength > limit) {
      throw const FormatException('Image unavailable');
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response) {
      if (bytes.length + chunk.length > limit) {
        throw const FormatException('Image too large');
      }
      bytes.add(chunk);
    }
    return (bytes: bytes.takeBytes(), mime: mime);
  }

  static List<AiImageAttachment> parseResults(dynamic json) {
    if (json is! Map || json['query'] is! Map) return [];
    final pages = json['query']['pages'];
    if (pages is! List) return [];
    final ordered = pages.whereType<Map>().toList()
      ..sort(
        (a, b) => ((a['index'] as num?) ?? 100).compareTo(
          (b['index'] as num?) ?? 100,
        ),
      );
    final result = <AiImageAttachment>[];
    final seen = <String>{};
    for (final page in ordered) {
      final infos = page['imageinfo'];
      if (infos is! List || infos.isEmpty || infos.first is! Map) continue;
      final info = infos.first as Map;
      final meta = info['extmetadata'];
      String field(String name) {
        final value = meta is Map ? meta[name] : null;
        return value is Map && value['value'] is String
            ? html.parseFragment(value['value']).text ?? ''
            : '';
      }

      final candidate = AiImageAttachment.fromJson({
        'title': (page['title'] as String? ?? '').replaceFirst('File:', ''),
        'url': info['thumburl'] ?? info['url'],
        'sourceUrl': info['descriptionurl'],
        'mime': info['thumbmime'] ?? info['mime'],
        'author': field('Artist'),
        'license': field('LicenseShortName'),
        'licenseUrl': field('LicenseUrl'),
      });
      if (candidate != null && seen.add(candidate.sourceUrl)) {
        result.add(candidate);
      }
      if (result.length == 6) break;
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
