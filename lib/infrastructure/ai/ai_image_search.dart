import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
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
        source == null ||
        !['image/jpeg', 'image/png', 'image/webp'].contains(field('mime')) ||
        field('title').isEmpty ||
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

  String get sourceName => Uri.parse(sourceUrl).host == 'commons.wikimedia.org'
      ? 'Wikimedia Commons'
      : Uri.parse(sourceUrl).host.replaceFirst(RegExp(r'^www\.'), '');

  AiImageAttachment withMime(String type) => AiImageAttachment(
    title: title,
    url: url,
    sourceUrl: sourceUrl,
    author: author,
    license: license,
    licenseUrl: licenseUrl,
    mime: type,
    file: file,
  );

  static Uri? imageUrl(String value) => AiWebSource.safeUrl(value);
}

typedef AiDownloadedImage = ({AiImageAttachment image, Uint8List bytes});

/// Runs public image search and bounded image downloads on the phone. URLs come
/// from search results, never the model. No app credentials are forwarded.
class AiImageSearch {
  AiImageSearch() : _onError = null;
  @visibleForTesting
  AiImageSearch.forTesting({required void Function(String, Object) onError})
    : _onError = onError;
  final void Function(String, Object)? _onError;
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
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 4)
      ..findProxy = ((_) => 'DIRECT')
      ..connectionFactory = (uri, proxyHost, proxyPort) async {
        if (AiWebSource.safeUrl(uri.toString()) == null || proxyHost != null) {
          throw const FormatException('Public HTTPS required');
        }
        final addresses = await InternetAddress.lookup(uri.host);
        if (addresses.isEmpty || addresses.any((a) => !isPublicAddress(a))) {
          throw const FormatException('Non-public image address');
        }
        addresses.sort(
          (a, b) => (a.type == InternetAddressType.IPv4 ? 0 : 1).compareTo(
            b.type == InternetAddressType.IPv4 ? 0 : 1,
          ),
        );
        // Pin the validated address so a second DNS lookup cannot change it.
        final task = await Socket.startConnect(addresses.first, uri.port);
        Socket? raw;
        final secured = task.socket.then((socket) async {
          raw = socket;
          try {
            // A custom HttpClient connection factory owns the TLS handshake.
            // Keep SNI and certificate verification bound to the original host.
            return await SecureSocket.secure(socket, host: uri.host);
          } catch (_) {
            socket.destroy();
            rethrow;
          }
        });
        return ConnectionTask.fromSocket<Socket>(secured, () {
          task.cancel();
          raw?.destroy();
        });
      };
    _active.add(client);
    try {
      Future<List<AiDownloadedImage>> runSearch() async {
        try {
          final web = await _searchWeb(
            client,
            query,
            generation,
          ).timeout(const Duration(seconds: 7));
          if (web.isNotEmpty || generation != _generation) return web;
        } catch (error) {
          _onError?.call('web', error);
        }
        if (generation != _generation) return [];
        return await _search(client, query, generation);
      }

      return await runSearch().timeout(const Duration(seconds: 12));
    } catch (error) {
      _onError?.call('search', error);
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
    return _download(client, candidates, generation);
  }

  Future<List<AiDownloadedImage>> _searchWeb(
    HttpClient client,
    String query,
    int generation,
  ) async {
    final page = await _get(
      client,
      Uri.https('www.bing.com', '/images/search', {
        'q': query,
        'form': 'HDRSC2',
        'adlt': 'strict',
        'safeSearch': 'Strict',
      }),
      2 * 1024 * 1024,
      const ['text/html'],
    );
    return _download(
      client,
      parseWebResults(utf8.decode(page.bytes, allowMalformed: true)),
      generation,
    );
  }

  Future<List<AiDownloadedImage>> _download(
    HttpClient client,
    List<AiImageAttachment> candidates,
    int generation,
  ) async {
    final downloaded = await Future.wait(
      candidates.take(4).map((candidate) async {
        try {
          final data = await _get(
            client,
            AiImageAttachment.imageUrl(candidate.url)!,
            3 * 1024 * 1024,
            const ['image/jpeg', 'image/png', 'image/webp'],
          );
          if (generation != _generation) return null;
          await validateImage(data.bytes);
          if (generation != _generation) return null;
          return (image: candidate.withMime(data.mime), bytes: data.bytes);
        } catch (error) {
          _onError?.call('download', error);
          return null;
        }
      }),
    );
    return generation == _generation
        ? downloaded.whereType<AiDownloadedImage>().take(2).toList()
        : [];
  }

  /// Public Bing image-result metadata includes the publisher page and preview.
  /// A search result is not evidence of a reuse licence; source rights remain unknown.
  static List<AiImageAttachment> parseWebResults(String markup) {
    final doc = html.parse(markup);
    if (doc.querySelector('#b_captcha, #challenge-form, #anomaly-modal') !=
        null) {
      return [];
    }
    final result = <AiImageAttachment>[];
    final seen = <String>{};
    for (final row in doc.querySelectorAll('a.iusc[m]')) {
      try {
        final value = jsonDecode(row.attributes['m']!);
        if (value is! Map) continue;
        String url(String field) {
          final text = value[field] is String ? value[field] as String : '';
          final uri = Uri.tryParse(text);
          return uri?.scheme == 'http'
              ? uri!.replace(scheme: 'https').toString()
              : text;
        }

        final candidate = AiImageAttachment.fromJson({
          'title': value['t'],
          'url': url('turl').isNotEmpty ? url('turl') : url('murl'),
          'sourceUrl': url('purl'),
          'author': '',
          'license': '',
          'mime': 'image/jpeg',
        });
        if (candidate != null && seen.add(candidate.sourceUrl)) {
          result.add(candidate);
        }
        if (result.length == 6) break;
      } catch (_) {
        /* Skip malformed metadata; never execute page scripts. */
      }
    }
    return result;
  }

  static bool isPublicAddress(InternetAddress address) {
    final b = address.rawAddress;
    if (b.length == 4) {
      return !(b[0] == 0 ||
          b[0] == 10 ||
          b[0] == 127 ||
          b[0] >= 224 ||
          (b[0] == 100 && b[1] >= 64 && b[1] <= 127) ||
          (b[0] == 169 && b[1] == 254) ||
          (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
          (b[0] == 192 && (b[1] == 168 || b[1] == 0)) ||
          (b[0] == 198 && (b[1] == 18 || b[1] == 19 || b[1] == 51)) ||
          (b[0] == 203 && b[1] == 0 && b[2] == 113));
    }
    // Only global IPv6 unicast, excluding documentation allocations and mapped IPv4.
    return b.length == 16 &&
        (b[0] & 0xe0) == 0x20 &&
        !(b[0] == 0x20 && b[1] == 0x02) &&
        !(b[0] == 0x20 && b[1] == 0x01 && b[2] == 0x00) &&
        !(b[0] == 0x20 && b[1] == 0x01 && b[2] == 0x0d && b[3] == 0xb8);
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
    for (var redirect = 0; redirect <= 3; redirect++) {
      if (AiWebSource.safeUrl(uri.toString()) == null) {
        throw const FormatException('Unsafe image URL');
      }
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'Bantera/2.10 (https://bantera.app; language learning)',
      );
      request.headers.set(HttpHeaders.acceptHeader, accepted.join(', '));
      final response = await request.close();
      if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
        final location = response.headers.value(HttpHeaders.locationHeader);
        // Close rather than draining unbounded redirect bodies. Each hop gets fresh DNS validation.
        (await response.detachSocket()).destroy();
        if (location == null || redirect == 3) {
          throw const FormatException('Image redirect');
        }
        uri = uri.resolve(location);
        continue;
      }
      final mime = response.headers.contentType?.mimeType ?? '';
      if (response.statusCode != 200 ||
          !accepted.contains(mime) ||
          response.contentLength > limit) {
        (await response.detachSocket()).destroy();
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
    throw const FormatException('Image redirect');
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
