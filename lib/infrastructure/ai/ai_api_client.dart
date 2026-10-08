import 'ai_search_capabilities.dart';
import 'dart:async';
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'ai_device_data.dart';
import '../callkit_service.dart';
import '../push_notifications_service.dart';
import '../../core/api_config_notifier.dart';
import '../../core/settings_notifier.dart';
import '../../core/auth_session_notifier.dart';

class AiApiClient {
  final HttpClient _http = HttpClient()
    ..connectionTimeout = const Duration(seconds: 20);
  bool _closed = false;
  Future<String> _token(String owner) async {
    final token = await AuthSessionNotifier.instance.refreshAccessTokenForApi();
    if (_closed ||
        token == null ||
        AuthSessionNotifier.instance.session?.cacheKey != owner) {
      throw StateError('Session changed');
    }
    return token;
  }

  static Future<Map<String, dynamic>> clock() async {
    final now = DateTime.now();
    String zone;
    try {
      zone = (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {
      zone = now.timeZoneName;
    }
    return {
      'utc': now.toUtc().toIso8601String(),
      'timeZone': zone,
      'utcOffsetMinutes': now.timeZoneOffset.inMinutes,
    };
  }

  static Future<Map<String, dynamic>> metadata({
    required bool hasMetBanteraAi,
  }) async => {
    'hasMetBanteraAi': hasMetBanteraAi,
    'deviceWebSearch': true,
    'learningLevel': SettingsNotifier.instance.audioLevel?.name,
    'clock': await clock(),
    'pushToken': (await CallKitService.instance.token())?.token,
    'alertPushToken':
        (await PushNotificationsService.instance.getCachedToken())?.token,
  };
  // Best effort, bounded, metadata-only. Never upload chat text or audio here.
  Future<void> reportVoiceFailure(
    String owner,
    Map<String, dynamic> detail,
  ) async {
    try {
      final token = await _token(owner);
      final info = await PackageInfo.fromPlatform();
      final request = await _http
          .postUrl(
            Uri.parse(
              '${ApiConfigNotifier.instance.baseUrl}/api/chat/ai/diagnostics',
            ),
          )
          .timeout(const Duration(seconds: 5));
      if (_closed || AuthSessionNotifier.instance.session?.cacheKey != owner) {
        request.abort();
        return;
      }
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({
          ...detail,
          'appVersion': '${info.version}+${info.buildNumber}',
        }),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      await response.drain<void>().timeout(const Duration(seconds: 5));
    } catch (_) {
      // Offline, old servers, or diagnostic failures must not break the chat.
    }
  }

  Future<Map<String, dynamic>> reply({
    required String owner,
    required List<Map<String, String>> history,
    required String audioPath,
    required String requestId,
    required bool hasMetBanteraAi,
  }) async {
    final deviceData = await AiDeviceData.snapshot(owner);
    final meta = await metadata(hasMetBanteraAi: hasMetBanteraAi);
    final token = await _token(owner);
    final uri = Uri.parse(
      '${ApiConfigNotifier.instance.baseUrl}/api/chat/ai/reply',
    );
    final request = await _http.postUrl(uri);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    final boundary = 'Bantera${DateTime.now().microsecondsSinceEpoch}';
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );
    void field(String name, String value) => request.add(
      utf8.encode(
        '--$boundary\r\nContent-Disposition: form-data; name="$name"\r\n\r\n$value\r\n',
      ),
    );
    field('history', jsonEncode(history));
    field('deviceData', jsonEncode(deviceData));
    field('metadata', jsonEncode({...meta, 'deviceWebSearch': false}));
    field('requestId', requestId);
    request.add(
      utf8.encode(
        '--$boundary\r\nContent-Disposition: form-data; name="audio"; filename="message.wav"\r\nContent-Type: audio/wav\r\n\r\n',
      ),
    );
    await request.addStream(File(audioPath).openRead());
    request.add([13, 10]);
    request.add(utf8.encode('--$boundary--\r\n'));
    final response = await request.close().timeout(
      const Duration(seconds: 110),
    );
    final body = await utf8.decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 15));
    if (_closed || response.statusCode != 200) {
      throw StateError('AI unavailable');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<WebSocket> call(
    String owner,
    List<Map<String, String>> history, {
    required bool hasMetBanteraAi,
    bool resuming = false,
    int remainingSeconds = 540,
    String? callbackId,
  }) async {
    final token = await _token(owner);
    final base = Uri.parse(ApiConfigNotifier.instance.baseUrl);
    final socket = await WebSocket.connect(
      base
          .replace(
            scheme: base.scheme == 'https' ? 'wss' : 'ws',
            path: '/ws/chat/ai',
          )
          .toString(),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 20));
    if (_closed) {
      await socket.close();
      throw StateError('Cancelled');
    }
    socket.add(
      jsonEncode({
        'type': 'start',
        'resuming': resuming,
        'callbackId': ?callbackId,
        'remainingSeconds': remainingSeconds,
        'history': AiSearchCapabilities.withContext(history),
        'metadata': await metadata(hasMetBanteraAi: hasMetBanteraAi),
      }),
    );
    return socket;
  }

  Future<WebSocket> voice(
    String owner,
    List<Map<String, String>> history,
    String requestId, {
    required bool hasMetBanteraAi,
  }) async {
    final token = await _token(owner);
    final deviceData = await AiDeviceData.snapshot(owner);
    final meta = await metadata(hasMetBanteraAi: hasMetBanteraAi);
    if (_closed) throw StateError('Cancelled');
    final base = Uri.parse(ApiConfigNotifier.instance.baseUrl);
    final socket = await WebSocket.connect(
      base
          .replace(
            scheme: base.scheme == 'https' ? 'wss' : 'ws',
            path: '/ws/chat/ai/voice',
          )
          .toString(),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 20));
    if (_closed) {
      await socket.close();
      throw StateError('Cancelled');
    }
    socket.add(
      jsonEncode({
        'type': 'start',
        'requestId': requestId,
        'streamTranscripts': true,
        'history': AiSearchCapabilities.withContext(history),
        'deviceData': deviceData,
        'metadata': meta,
      }),
    );
    return socket;
  }

  Future<dynamic> reminderRequest(
    String owner,
    String method, [
    String path = '',
  ]) async {
    final token = await _token(owner);
    final request = await _http.openUrl(
      method,
      Uri.parse(
        '${ApiConfigNotifier.instance.baseUrl}/api/chat/ai/reminders$path',
      ),
    );
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    final response = await request.close().timeout(const Duration(seconds: 20));
    final body = await utf8.decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 20));
    if (_closed || response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Reminders unavailable');
    }
    return body.isEmpty ? null : jsonDecode(body);
  }

  void close() {
    _closed = true;
    _http.close(force: true);
  }
}
