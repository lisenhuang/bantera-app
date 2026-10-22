import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../core/practice_review_service.dart';
import '../../../infrastructure/ai/ai_history_store.dart';
import '../../../infrastructure/ai/ai_video_search.dart';
import '../../../l10n/app_localizations.dart';

/// At most one loaded player, with no playback behind another route or call.
final activeAiVideo = ValueNotifier<String?>(null);

class AiVideoCards extends StatelessWidget {
  const AiVideoCards({
    super.key,
    required this.message,
    required this.enabled,
    required this.beforePlay,
  });
  final AiMessage message;
  final bool enabled;
  final Future<void> Function() beforePlay;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.videoSearchStatus == 'searching')
            Text(l.aiVideosSearching),
          if (message.videoSearchStatus == 'unavailable')
            Text(l.aiVideosUnavailable),
          for (final video in message.videos)
            _VideoCard(
              key: ValueKey(video.url),
              id: '${message.id}:${video.url}',
              video: video,
              enabled: enabled,
              beforePlay: beforePlay,
            ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  const _VideoCard({
    super.key,
    required this.id,
    required this.video,
    required this.enabled,
    required this.beforePlay,
  });
  final String id;
  final AiVideoAttachment video;
  final bool enabled;
  final Future<void> Function() beforePlay;
  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard>
    with WidgetsBindingObserver, RouteAware {
  WebViewController? _web;
  ModalRoute<dynamic>? _route;
  Timer? _timeout;
  int _epoch = 0;
  bool _failed = false, _loading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    activeAiVideo.addListener(_activeChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (_route != route) {
      practiceReviewRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) practiceReviewRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didUpdateWidget(_VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && (_web != null || _loading)) _stop(rebuild: false);
  }

  void _activeChanged() {
    if (activeAiVideo.value != widget.id && (_web != null || _loading)) _stop();
  }

  void _stop({bool rebuild = true}) {
    _epoch++;
    _timeout?.cancel();
    final web = _web;
    _web = null;
    _loading = false;
    // Navigate away as well as removing the platform view, to stop audio now.
    if (web != null) {
      unawaited(
        web.loadRequest(Uri.parse('about:blank')).catchError((Object _) {}),
      );
    }
    if (rebuild && mounted) setState(() {});
  }

  @override
  void didPushNext() => _stop();
  @override
  void didPop() => _stop();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _stop();
  }

  Future<void> _browser() async {
    _stop();
    await widget.beforePlay();
    if (!mounted || !widget.enabled) return;
    try {
      final opened = await launchUrl(
        Uri.parse(widget.video.url),
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      );
      if (!opened && mounted) setState(() => _failed = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _play() async {
    if (!widget.enabled || _loading) return;
    final id = widget.video.youtubeId;
    if (id == null) return _browser();
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      await widget.beforePlay();
      final package = await PackageInfo.fromPlatform();
      if (!mounted || !widget.enabled || epoch != _epoch) return;
      // YouTube requires the installed app identity as WebView referrer.
      if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(package.packageName)) {
        throw StateError('Invalid app ID');
      }
      final origin = 'https://${package.packageName.toLowerCase()}';
      activeAiVideo.value = widget.id;
      final params = WebViewPlatform.instance is WebKitWebViewPlatform
          ? WebKitWebViewControllerCreationParams(
              allowsInlineMediaPlayback: true,
              mediaTypesRequiringUserAction: const {
                PlaybackMediaTypes.audio,
                PlaybackMediaTypes.video,
              },
            )
          : const PlatformWebViewControllerCreationParams();
      final controller = WebViewController.fromPlatformCreationParams(
        params,
        onPermissionRequest: (request) => request.deny(),
      );
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.addJavaScriptChannel(
        'VideoState',
        onMessageReceived: (event) {
          if (!mounted || epoch != _epoch) return;
          _timeout?.cancel();
          if (event.message == 'error') {
            _stop();
            setState(() => _failed = true);
          }
          if (event.message == 'ready') setState(() => _loading = false);
        },
      );
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (!request.isMainFrame) return NavigationDecision.navigate;
            final uri = Uri.tryParse(request.url);
            if (request.url == 'about:blank' ||
                (uri?.scheme == 'https' && uri?.origin == origin)) {
              return NavigationDecision.navigate;
            }
            // Publisher navigation stays in the browser, outside the embedded view.
            return NavigationDecision.prevent;
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted && epoch == _epoch) {
              _stop();
              setState(() => _failed = true);
            }
          },
        ),
      );
      if (!mounted || !widget.enabled || epoch != _epoch) return;
      _web = controller;
      setState(() {});
      _timeout = Timer(const Duration(seconds: 20), () {
        if (mounted && epoch == _epoch && _loading) {
          _stop();
          setState(() => _failed = true);
        }
      });
      await controller.loadHtmlString(
        youtubePlayerHtml(id, origin),
        baseUrl: '$origin/',
      );
    } catch (_) {
      if (mounted && epoch == _epoch) {
        _stop();
        setState(() => _failed = true);
      }
    }
  }

  @override
  void dispose() {
    activeAiVideo.removeListener(_activeChanged);
    practiceReviewRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _stop(rebuild: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.video.title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            widget.video.provider,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (_web != null && constraints.maxWidth >= 200) {
                return SizedBox(
                  height: math.max(200, constraints.maxWidth * 9 / 16),
                  child: WebViewWidget(controller: _web!),
                );
              }
              return TextButton.icon(
                onPressed: widget.enabled && !_loading
                    ? (constraints.maxWidth >= 200 &&
                              widget.video.youtubeId != null
                          ? _play
                          : _browser)
                    : null,
                icon: const Icon(Icons.play_circle_outline),
                label: Text(l.aiPlayVideo),
              );
            },
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_failed) Text(l.aiVideoEmbedUnavailable),
          TextButton.icon(
            onPressed: widget.enabled ? _browser : null,
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: Text(l.aiOpenVideoBrowser),
          ),
        ],
      ),
    );
  }
}

/// Only validated video IDs and the installed package ID enter executable HTML.
String youtubePlayerHtml(String id, String origin) {
  if (!RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id) ||
      !RegExp(r'^https://[a-z0-9_.-]+$').hasMatch(origin)) {
    throw ArgumentError('Invalid player');
  }
  return '''<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="referrer" content="strict-origin-when-cross-origin">
<style>html,body,#player{margin:0;width:100%;height:100%;background:#000}</style></head><body>
<div id="player"></div><script src="https://www.youtube.com/iframe_api"></script><script>
var player;function onYouTubeIframeAPIReady(){player=new YT.Player('player',{
width:'100%',height:'100%',videoId:${jsonEncode(id)},
playerVars:{autoplay:0,playsinline:1,controls:1,origin:${jsonEncode(origin)}},
events:{onReady:function(){VideoState.postMessage('ready')},onError:function(){VideoState.postMessage('error')}}});}
</script></body></html>''';
}
