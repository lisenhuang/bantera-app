import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../infrastructure/callkit_service.dart';
import '../infrastructure/ai/ai_api_client.dart';
import '../infrastructure/push_notifications_service.dart';
import 'api_config_notifier.dart';
import 'auth_session_notifier.dart';
import 'chat_session_notifier.dart';
import 'dm_call_notifier.dart';
import '../presentation/chats/ai/ai_chat_controller.dart';

class AiCallbackNotifier extends ChangeNotifier {
  AiCallbackNotifier._() {
    _listenCallKit();
    ChatSessionNotifier.instance.realtimeEvents.listen((event) {
      if (event['type'] == 'ai.callback' && event['payload'] is Map) {
        unawaited(incoming(Map<String, dynamic>.from(event['payload'] as Map)));
      }
    });
    AuthSessionNotifier.instance.addListener(() {
      if (!AuthSessionNotifier.instance.isAuthenticated) {
        unawaited(close());
      }
    });
    PushNotificationsService.instance.latestNotificationTap.addListener(() {
      final p = PushNotificationsService.instance.latestNotificationTap.value;
      if (p != null && p['callerUserId'] == identity) unawaited(incoming(p));
    });
  }
  @visibleForTesting
  AiCallbackNotifier.forTesting({
    required CallKitService callKit,
    required AiChatController Function() createController,
    required Future<int> Function(String) acceptCallback,
  }) : _callKitOverride = callKit,
       _createController = createController,
       _acceptCallback = acceptCallback {
    _listenCallKit();
  }
  CallKitService? _callKitOverride;
  AiChatController Function()? _createController;
  Future<int> Function(String)? _acceptCallback;
  CallKitService get _callKit => _callKitOverride ?? CallKitService.instance;
  bool get usesSystemCallInterface => _callKit.supported;
  StreamSubscription<Map<String, dynamic>>? _callKitEvents;
  void _listenCallKit() {
    _callKitEvents = _callKit.events.listen((event) {
      if (handles(event)) {
        // Native cold starts can deliver incoming, answer and activation together.
        _events = _events.then((_) => _event(event));
      }
    });
  }

  @override
  void dispose() {
    _callKitEvents?.cancel();
    _expiry?.cancel();
    _statusTimer?.cancel();
    _activationTimeout?.cancel();
    super.dispose();
  }

  static final instance = AiCallbackNotifier._();
  static const identity = 'ba07e2a0-a100-4000-8000-000000000001';
  bool aiActive = false;
  Future<void> _events = Future.value();
  AiChatController? controller;
  bool _started = false;
  bool _audioActive = false;
  bool _lastMuted = false;
  bool _lastSpeaker = false;
  Timer? _activationTimeout;
  String? id;
  String? _owner;
  bool ringing = false, accepted = false, accepting = false;
  Timer? _expiry, _statusTimer;
  final Set<String> _handled = {};
  bool handles(Map event) =>
      event['callerUserId'] == identity ||
      (id != null && event['callId']?.toString().toLowerCase() == id);
  Future<void> incoming(
    Map<String, dynamic> payload, {
    bool system = false,
  }) async {
    final callId = payload['callId']?.toString().toLowerCase();
    if (callId == null || _handled.contains(callId) || id == callId) return;
    if (aiActive ||
        DmCallNotifier.instance.isActive ||
        id != null ||
        !AuthSessionNotifier.instance.isAuthenticated ||
        payload['recipientUserId'] !=
            AuthSessionNotifier.instance.session?.userId) {
      await _callKit.update('end', callId);
      return;
    }
    final expires = int.tryParse(payload['expiresAt']?.toString() ?? '') ?? 0;
    final remaining = DateTime.fromMillisecondsSinceEpoch(
      expires * 1000,
    ).difference(DateTime.now());
    if (remaining.isNegative) {
      await _callKit.update('end', callId);
      return;
    }
    id = callId;
    _owner = AuthSessionNotifier.instance.session?.cacheKey;
    ringing = true;
    accepted = false;
    _audioActive = false;
    _lastMuted = false;
    _lastSpeaker = false;
    notifyListeners();
    _expiry = Timer(remaining, () => unawaited(close()));
    if (!system) await _callKit.report('incoming', payload);
    _statusTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(_check()),
    );
  }

  Future<void> _event(Map<String, dynamic> event) async {
    try {
      if (event['event'] != 'incoming' &&
          event['callId']?.toString().toLowerCase() != id) {
        return;
      }
      switch (event['event']) {
        case 'incoming':
          await incoming(event, system: true);
        case 'answer':
          if (event['callId']?.toString().toLowerCase() == id) {
            await accept(system: true);
          }
        case 'audioActivated':
          _audioActive = true;
          if (accepted) unawaited(_startAudio());
        case 'audioFailed':
          _reportFailure('callback_audio_failed');
          await close();
        case 'audioRoute':
          _lastSpeaker = event['speaker'] == true;
          controller?.updateSpeakerRoute(_lastSpeaker);
        case 'mute':
          final chat = controller;
          final muted = event['muted'] == true;
          _lastMuted = muted;
          chat?.setMuted(muted);
        case 'audioDeactivated':
        case 'ended':
          await close();
      }
    } catch (_) {
      await close();
    }
  }

  void _reportFailure(String code) {
    final owner = _owner, callId = id;
    if (owner == null || callId == null || _createController != null) return;
    // No reminder text, audio, tokens, or private conversation data in logs.
    final api = AiApiClient();
    unawaited(
      api
          .reportVoiceFailure(owner, {
            'requestId': callId,
            'code': code,
            'phase': 'callback',
            'inputBytes': 0,
            'outputBytes': 0,
            'elapsedMs': 0,
            'committed': accepted,
          })
          .whenComplete(api.close),
    );
  }

  Future<HttpClientResponse> _request(
    HttpClient client,
    String method,
    String path,
  ) async {
    final token = await AuthSessionNotifier.instance.refreshAccessTokenForApi();
    if (token == null ||
        AuthSessionNotifier.instance.session?.cacheKey != _owner) {
      throw StateError('Account changed');
    }
    final request = await client.openUrl(
      method,
      Uri.parse(
        '${ApiConfigNotifier.instance.baseUrl}/api/chat/ai/callbacks/$path',
      ),
    );
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    return request.close().timeout(const Duration(seconds: 8));
  }

  Future<void> _check() async {
    if (id == null || accepting || !ringing) return;
    final current = id;
    final client = HttpClient();
    try {
      final response = await _request(client, 'GET', current!);
      final body = await utf8.decoder.bind(response).join();
      if (id == current &&
          !accepting &&
          (response.statusCode != 200 ||
              (jsonDecode(body) as Map)['status'] != 'ringing')) {
        await close();
      }
    } catch (_) {
    } finally {
      client.close(force: true);
    }
  }

  Future<void> accept({bool system = false}) async {
    if (id == null || !ringing || accepting) return;
    if (_callKit.supported && !system) {
      await _callKit.report('requestAnswer', {'callId': id});
      return;
    }
    accepting = true;
    notifyListeners();
    final current = id;
    final client = HttpClient();
    try {
      final int status;
      if (_acceptCallback != null) {
        status = await _acceptCallback!(current!);
      } else {
        final response = await _request(
          client,
          'POST',
          '$current/accept',
        ).timeout(const Duration(seconds: 12));
        status = response.statusCode;
        await response.drain<void>();
      }
      if (status != 200 || id != current) {
        throw StateError('Expired');
      }
      _expiry?.cancel();
      _statusTimer?.cancel();
      // The notifier owns the conversation, so no widget/frame is needed to
      // answer a VoIP wake-up while the screen remains locked.
      final chat =
          _createController?.call() ??
          AiChatController(
            callKitManaged: _callKit.supported,
            callbackId: current,
          );
      controller = chat;
      await chat.initialize().timeout(const Duration(seconds: 8));
      if (id != current || !chat.loaded) {
        throw StateError('Call no longer available');
      }
      chat.addListener(_callChanged);
      ringing = false;
      accepted = true;
      aiActive = true;
      _started = false;
      chat.setMuted(_lastMuted);
      if (_callKit.supported) {
        _activationTimeout = Timer(const Duration(seconds: 12), () {
          _reportFailure('callback_activation_timeout');
          unawaited(close());
        });
        await _callKit.update('answerReady', current);
        if (_audioActive) unawaited(_startAudio());
      } else {
        unawaited(_startAudio());
      }
    } catch (_) {
      if (id == current) {
        _reportFailure('callback_accept_failed');
        await close();
      }
    } finally {
      client.close(force: true);
      accepting = false;
      notifyListeners();
    }
  }

  Future<void> _startAudio() async {
    final chat = controller;
    if (!accepted || chat == null || _started) return;
    _started = true;
    _activationTimeout?.cancel();
    try {
      await chat.startCall();
      if (!identical(chat, controller)) return;
      if (!chat.calling) {
        _reportFailure('callback_audio_failed');
        await close();
      } else {
        chat.updateSpeakerRoute(_lastSpeaker);
        await _callKit.update('audioStarted', id);
      }
    } catch (_) {
      if (identical(chat, controller)) {
        _reportFailure('callback_audio_failed');
        await close();
      }
    }
  }

  void _callChanged() {
    final chat = controller;
    if (chat == null || !_started) return;
    if (!chat.calling) {
      if (chat.failed) _reportFailure('callback_audio_failed');
      unawaited(close());
    } else if (chat.muted != _lastMuted) {
      _lastMuted = chat.muted;
      unawaited(
        _callKit.report('requestMute', {'callId': id, 'muted': chat.muted}),
      );
    }
  }

  Future<void> close() async {
    final current = id;
    if (current == null) return;
    _handled.add(current);
    if (_handled.length > 100) _handled.remove(_handled.first);
    _expiry?.cancel();
    _statusTimer?.cancel();
    final cancel = ringing;
    final chat = controller;
    controller = null;
    chat?.removeListener(_callChanged);
    _activationTimeout?.cancel();
    _started = false;
    _audioActive = false;
    aiActive = false;
    id = null;
    ringing = false;
    accepted = false;
    accepting = false;
    notifyListeners();
    await chat?.endCall();
    chat?.dispose();
    await _callKit.update('end', current);
    if (cancel) {
      final client = HttpClient();
      try {
        final r = await _request(client, 'DELETE', current);
        await r.drain<void>();
      } catch (_) {
      } finally {
        client.close(force: true);
      }
    }
  }
}
