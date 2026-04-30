import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/api_config_notifier.dart';
import '../domain/models/chat_models.dart';
import 'auth_api_client.dart';
import 'network_reachability.dart';

class ChatApiClient {
  ChatApiClient._();

  static final ChatApiClient instance = ChatApiClient._();

  final HttpClient _httpClient = HttpClient();

  Future<ChatBootstrap> fetchBootstrap({required String accessToken}) async {
    final json = await _sendJsonRequest(
      method: 'GET',
      path: '/api/chat/bootstrap',
      accessToken: accessToken,
    );
    return ChatBootstrap.fromJson(json);
  }

  Future<List<ChatMessageItem>> fetchMessages({
    required String accessToken,
    required String threadId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final uri = _resolve('/api/chat/threads/$threadId/messages').replace(
        queryParameters: <String, String>{
          'limit': '$limit',
          'offset': '$offset',
        },
      );
      final request = await _httpClient.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(responseText);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is! List) {
          throw const AuthApiException(
            code: 'invalid_response',
            message: 'The Bantera API returned an unexpected response.',
          );
        }
        return decoded
            .whereType<Map>()
            .map(
              (item) => ChatMessageItem.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList();
      }
      if (decoded is Map<String, dynamic>) {
        _throwApiException(decoded, response.statusCode);
      }
      throw AuthApiException(
        code: 'request_failed',
        message: 'The Bantera API request failed (${response.statusCode}).',
      );
    } on AuthApiException {
      rethrow;
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    }
  }

  Future<ChatMessageItem> sendDirectMessageAudio({
    required String accessToken,
    required String otherUserId,
    required File audioFile,
    required int durationMs,
  }) {
    return _sendAudioMessage(
      accessToken: accessToken,
      path: '/api/chat/threads/dm/$otherUserId/messages/audio',
      audioFile: audioFile,
      durationMs: durationMs,
    );
  }

  Future<ChatMessageItem> sendGroupAudio({
    required String accessToken,
    required String groupKind,
    required File audioFile,
    required int durationMs,
  }) {
    return _sendAudioMessage(
      accessToken: accessToken,
      path: '/api/chat/threads/group/$groupKind/messages/audio',
      audioFile: audioFile,
      durationMs: durationMs,
    );
  }

  Future<DownloadedChatAudio> downloadMessageAudio({
    required String accessToken,
    required String messageId,
  }) async {
    try {
      final request = await _httpClient.getUrl(
        _resolve('/api/chat/messages/$messageId/audio'),
      );
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        return DownloadedChatAudio(
          bytes: bytes,
          contentType: response.headers.contentType?.mimeType ?? 'audio/mp4',
        );
      }

      final text = await response.transform(utf8.decoder).join();
      final decoded = _tryDecodeJson(text);
      if (decoded != null) {
        _throwApiException(decoded, response.statusCode);
      }
      throw AuthApiException(
        code: 'request_failed',
        message: 'The Bantera API request failed (${response.statusCode}).',
      );
    } on AuthApiException {
      rethrow;
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    }
  }

  Future<void> acknowledgeMessageReceived({
    required String accessToken,
    required String messageId,
  }) async {
    await _sendEmptyRequest(
      method: 'POST',
      path: '/api/chat/messages/$messageId/received',
      accessToken: accessToken,
    );
  }

  Future<void> markThreadRead({
    required String accessToken,
    required String threadId,
  }) async {
    await _sendEmptyRequest(
      method: 'POST',
      path: '/api/chat/threads/$threadId/read',
      accessToken: accessToken,
    );
  }

  Future<void> updateGlobalNotifications({
    required String accessToken,
    required bool enabled,
  }) async {
    await _sendRequestAllowingNoContent(
      method: 'PUT',
      path: '/api/chat/notifications/global',
      accessToken: accessToken,
      payload: <String, Object?>{'enabled': enabled},
    );
  }

  Future<void> updateThreadNotifications({
    required String accessToken,
    required String threadId,
    required bool enabled,
  }) async {
    await _sendRequestAllowingNoContent(
      method: 'PUT',
      path: '/api/chat/threads/$threadId/notifications',
      accessToken: accessToken,
      payload: <String, Object?>{'enabled': enabled},
    );
  }

  Future<void> registerApnsToken({
    required String accessToken,
    required String token,
    required bool isSandbox,
  }) async {
    await _sendRequestAllowingNoContent(
      method: 'PUT',
      path: '/api/chat/push/apns-token',
      accessToken: accessToken,
      payload: <String, Object?>{'token': token, 'isSandbox': isSandbox},
    );
  }

  Future<void> blockUser({
    required String accessToken,
    required String otherUserId,
  }) async {
    await _sendEmptyRequest(
      method: 'POST',
      path: '/api/chat/blocks/$otherUserId',
      accessToken: accessToken,
    );
  }

  Future<void> unblockUser({
    required String accessToken,
    required String otherUserId,
  }) async {
    await _sendEmptyRequest(
      method: 'DELETE',
      path: '/api/chat/blocks/$otherUserId',
      accessToken: accessToken,
    );
  }

  Future<void> deleteDirectMessageForSelf({
    required String accessToken,
    required String threadId,
  }) async {
    await _sendEmptyRequest(
      method: 'DELETE',
      path: '/api/chat/threads/dm/$threadId',
      accessToken: accessToken,
    );
  }

  Future<List<ChatUserSummary>> fetchBlockedUsers({
    required String accessToken,
  }) async {
    try {
      final request = await _httpClient.getUrl(_resolve('/api/chat/blocks'));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(responseText);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is! List) {
          return const <ChatUserSummary>[];
        }
        return decoded
            .whereType<Map>()
            .map(
              (item) => ChatUserSummary.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList();
      }
      if (decoded is Map<String, dynamic>) {
        _throwApiException(decoded, response.statusCode);
      }
      return const <ChatUserSummary>[];
    } on AuthApiException {
      rethrow;
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    }
  }

  Future<ChatMessageItem> _sendAudioMessage({
    required String accessToken,
    required String path,
    required File audioFile,
    required int durationMs,
  }) async {
    try {
      final filename = audioFile.uri.pathSegments.isNotEmpty
          ? audioFile.uri.pathSegments.last
          : 'chat-audio.m4a';
      final boundary =
          'bantera-${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';
      final request = await _httpClient.postUrl(_resolve(path));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      void writeField(String name, String value) {
        request.write('--$boundary\r\n');
        request.write('Content-Disposition: form-data; name="$name"\r\n\r\n');
        request.write(value);
        request.write('\r\n');
      }

      writeField('durationMs', '$durationMs');
      request.write('--$boundary\r\n');
      request.write(
        'Content-Disposition: form-data; name="file"; filename="$filename"\r\n',
      );
      request.write(
        'Content-Type: ${_audioContentTypeForPath(filename)}\r\n\r\n',
      );
      await request.addStream(audioFile.openRead());
      request.write('\r\n--$boundary--\r\n');

      final response = await request.close();
      final json = await _parseJsonResponse(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ChatMessageItem.fromJson(json);
      }
      _throwApiException(json, response.statusCode);
    } on AuthApiException {
      rethrow;
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    }
  }

  Future<void> _sendEmptyRequest({
    required String method,
    required String path,
    required String accessToken,
  }) async {
    try {
      final request = await _httpClient.openUrl(method, _resolve(path));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await response.drain<void>();
        return;
      }

      final responseText = await response.transform(utf8.decoder).join();
      final decoded = _tryDecodeJson(responseText);
      if (decoded != null) {
        _throwApiException(decoded, response.statusCode);
      }
      throw AuthApiException(
        code: 'request_failed',
        message: 'The Bantera API request failed (${response.statusCode}).',
      );
    } on AuthApiException {
      rethrow;
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    }
  }

  Future<Map<String, dynamic>> _sendJsonRequest({
    required String method,
    required String path,
    required String accessToken,
    Map<String, Object?>? payload,
  }) async {
    try {
      final request = await _httpClient.openUrl(method, _resolve(path));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
      if (payload != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(payload)));
      }

      final response = await request.close();
      final json = await _parseJsonResponse(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json;
      }
      _throwApiException(json, response.statusCode);
    } on AuthApiException {
      rethrow;
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    }
  }

  Future<void> _sendRequestAllowingNoContent({
    required String method,
    required String path,
    required String accessToken,
    Map<String, Object?>? payload,
  }) async {
    try {
      final request = await _httpClient.openUrl(method, _resolve(path));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
      if (payload != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(payload)));
      }

      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await response.drain<void>();
        return;
      }

      final responseText = await response.transform(utf8.decoder).join();
      final decoded = _tryDecodeJson(responseText);
      if (decoded != null) {
        _throwApiException(decoded, response.statusCode);
      }
      throw AuthApiException(
        code: 'request_failed',
        message: 'The Bantera API request failed (${response.statusCode}).',
      );
    } on AuthApiException {
      rethrow;
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    }
  }

  Future<Map<String, dynamic>> _parseJsonResponse(
    HttpClientResponse response,
  ) async {
    final responseText = await response.transform(utf8.decoder).join();
    if (responseText.isEmpty) {
      throw const AuthApiException(
        code: 'invalid_response',
        message: 'The Bantera API returned an empty response.',
      );
    }

    final decoded = jsonDecode(responseText);
    if (decoded is! Map) {
      throw const AuthApiException(
        code: 'invalid_response',
        message: 'The Bantera API returned an unexpected response.',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  Map<String, dynamic>? _tryDecodeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore malformed error payloads.
    }
    return null;
  }

  Never _throwApiException(Map<String, dynamic> json, int statusCode) {
    final code = json['code']?.toString();
    final message = json['message']?.toString();
    if (code != null && message != null) {
      throw AuthApiException(code: code, message: message);
    }

    throw AuthApiException(
      code: 'request_failed',
      message: 'The Bantera API request failed ($statusCode).',
    );
  }

  Future<Never> _throwNetworkFailure() async {
    final kind = await NetworkReachability.classifyLocalConnectivity();
    log('ChatApiClient _throwNetworkFailure -> $kind', name: 'BanteraNetwork');
    switch (kind) {
      case NetworkIssueKind.cellularBlockedNoWifi:
        throw const AuthApiException(
          code: 'network_cellular_blocked',
          message:
              'Mobile data is turned off for Bantera. Enable it in Settings, or connect to Wi-Fi.',
        );
      case NetworkIssueKind.offlineGeneric:
        throw const AuthApiException(
          code: 'network_unreachable',
          message:
              'Could not connect to Bantera. Check your internet connection.',
        );
    }
  }

  Uri _resolve(String path) {
    final baseUrl = ApiConfigNotifier.instance.baseUrl;
    final baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return baseUri.resolve(normalizedPath);
  }

  static String _audioContentTypeForPath(String filename) {
    final normalized = filename.toLowerCase();
    if (normalized.endsWith('.aac')) {
      return 'audio/aac';
    }
    if (normalized.endsWith('.wav')) {
      return 'audio/wav';
    }
    if (normalized.endsWith('.mp3')) {
      return 'audio/mpeg';
    }
    if (normalized.endsWith('.webm')) {
      return 'audio/webm';
    }
    if (normalized.endsWith('.ogg')) {
      return 'audio/ogg';
    }
    return 'audio/mp4';
  }
}
