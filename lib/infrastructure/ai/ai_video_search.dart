import 'ai_web_search.dart';

/// Public video links from actual search results, never URLs invented by AI.
class AiVideoAttachment {
  const AiVideoAttachment({
    required this.title,
    required this.url,
    this.excerpt = '',
  });
  final String title, url, excerpt;
  String? get youtubeId => youtubeVideoId(url);
  String get provider => Uri.parse(url).host.replaceFirst('www.', '');
  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'excerpt': excerpt,
  };
  static AiVideoAttachment? fromJson(dynamic value) {
    final source = AiWebSource.fromJson(value);
    if (source == null) return null;
    final uri = Uri.parse(source.url);
    final id = youtubeVideoId(source.url);
    final host = uri.host.toLowerCase();
    final otherVideo =
        ((host == 'vimeo.com' || host == 'www.vimeo.com') &&
            RegExp(r'^/\d+/?$').hasMatch(uri.path)) ||
        ((host == 'www.dailymotion.com' || host == 'dailymotion.com') &&
            RegExp(r'^/video/[a-zA-Z0-9]+').hasMatch(uri.path)) ||
        ((host == 'www.ted.com' || host == 'ted.com') &&
            uri.path.startsWith('/talks/'));
    if (id == null && !otherVideo) return null;
    return AiVideoAttachment(
      title: source.title,
      url: id == null ? source.url : 'https://www.youtube.com/watch?v=$id',
      excerpt: source.excerpt,
    );
  }

  static String? youtubeVideoId(String url) {
    final uri = AiWebSource.safeUrl(url);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    String? id;
    if (host == 'youtu.be') {
      if (uri.pathSegments.length == 1) id = uri.pathSegments.first;
    } else if ([
      'youtube.com',
      'www.youtube.com',
      'm.youtube.com',
    ].contains(host)) {
      if (uri.path == '/watch') id = uri.queryParameters['v'];
      if (uri.pathSegments.length == 2 &&
          ['shorts', 'embed', 'live'].contains(uri.pathSegments.first)) {
        id = uri.pathSegments.last;
      }
    }
    return id != null && RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id)
        ? id
        : null;
  }
}
