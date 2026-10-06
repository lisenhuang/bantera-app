import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../infrastructure/callkit_service.dart';
import '../infrastructure/push_notifications_service.dart';
import 'api_config_notifier.dart';
import 'auth_session_notifier.dart';
import 'chat_session_notifier.dart';
import 'dm_call_notifier.dart';

class AiCallbackNotifier extends ChangeNotifier {
  AiCallbackNotifier._() {
    CallKitService.instance.events.listen((event) {
      if (handles(event)) unawaited(_event(event));
    });
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
  static final instance = AiCallbackNotifier._();
  static const identity = 'ba07e2a0-a100-4000-8000-000000000001';
  bool aiActive = false;
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
      await CallKitService.instance.update('end', callId);
      return;
    }
    final expires = int.tryParse(payload['expiresAt']?.toString() ?? '') ?? 0;
    final remaining = DateTime.fromMillisecondsSinceEpoch(
      expires * 1000,
    ).difference(DateTime.now());
    if (remaining.isNegative) {
      await CallKitService.instance.update('end', callId);
      return;
    }
    id = callId;
    _owner = AuthSessionNotifier.instance.session?.cacheKey;
    ringing = true;
    accepted = false;
    notifyListeners();
    _expiry = Timer(remaining, () => unawaited(close()));
    if (!system) await CallKitService.instance.report('incoming', payload);
    _statusTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(_check()),
    );
  }

  Future<void> _event(Map<String, dynamic> event) async {
    try {
      switch (event['event']) {
        case 'incoming':
          await incoming(event, system: true);
        case 'answer':
          if (event['callId']?.toString().toLowerCase() == id) {
            await accept(system: true);
          }
        case 'ended':
          if (!accepted) await close();
      }
    } catch (_) {
      await close();
    }
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
    if (CallKitService.instance.supported && !system) {
      await CallKitService.instance.report('requestAnswer', {'callId': id});
      return;
    }
    accepting = true;
    notifyListeners();
    final current = id;
    final client = HttpClient();
    try {
      final response = await _request(client, 'POST', '$current/accept');
      await response.drain<void>();
      if (response.statusCode != 200 || id != current) {
        throw StateError('Expired');
      }
      _expiry?.cancel();
      _statusTimer?.cancel();
      await CallKitService.instance.update('answerReady', id);
      ringing = false;
      accepted = true;
      // Hand audio ownership to the in-chat PCM session, not the human-call WebRTC engine.
      await CallKitService.instance.update('end', id);
    } catch (_) {
      await close();
    } finally {
      client.close(force: true);
      accepting = false;
      notifyListeners();
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
    id = null;
    ringing = false;
    accepted = false;
    accepting = false;
    notifyListeners();
    await CallKitService.instance.update('end', current);
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
