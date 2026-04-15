import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import '../core/api_config_notifier.dart';
import '../domain/models/models.dart';
import 'learning_language_catalog.dart';
import 'network_reachability.dart';

class AuthApiClient {
  AuthApiClient._();

  static final AuthApiClient instance = AuthApiClient._();

  final HttpClient _httpClient = HttpClient();
  List<String> _dialogueLines = [];

  String get displayBaseUrl => ApiConfigNotifier.instance.baseUrl;

  // Called by AuthSessionNotifier at startup.
  // Returns the fresh access token, or null if the session could not be renewed
  // (in which case the notifier signs the user out).
  Future<String?> Function()? _onRefreshToken;

  // Deduplicates concurrent refresh calls — only one refresh runs at a time.
  Completer<String?>? _refreshInProgress;

  void setTokenRefresher(Future<String?> Function() refresher) {
    _onRefreshToken = refresher;
  }

  Future<String?> _doRefresh() async {
    if (_refreshInProgress != null) return _refreshInProgress!.future;
    final refresher = _onRefreshToken;
    if (refresher == null) return null;

    final completer = Completer<String?>();
    _refreshInProgress = completer;
    try {
      final token = await refresher();
      completer.complete(token);
      return token;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshInProgress = null;
    }
  }

  /// Runs [action] with the given [accessToken]. If the call throws an
  /// [AuthApiException] whose code is `token_expired`, silently refreshes and
  /// retries once. This covers every authenticated method that doesn't go
  /// through [_sendJsonRequest].
  Future<T> _retryWithRefresh<T>(
    String? accessToken,
    Future<T> Function(String? token) action,
  ) async {
    try {
      return await action(accessToken);
    } on AuthApiException catch (e) {
      if (e.code == 'token_expired' && accessToken != null) {
        final newToken = await _doRefresh();
        if (newToken != null) return action(newToken);
        throw const SessionExpiredException();
      }
      rethrow;
    }
  }

  Map<String, dynamic>? _tryDecodeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  /// Classifies low-level network failures for localized UI (`network_unreachable`,
  /// `network_cellular_blocked`).
  Future<Never> _throwNetworkFailure() async {
    final kind = await NetworkReachability.classifyLocalConnectivity();
    log('AuthApiClient _throwNetworkFailure -> $kind', name: 'BanteraNetwork');
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

  Future<AuthTokenResponse> refreshAuthToken({required String refreshToken}) {
    return _postAuth('/api/auth/refresh', {'refreshToken': refreshToken});
  }

  Future<AuthTokenResponse> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _postAuth('/api/auth/login', <String, dynamic>{
      'email': email,
      'password': password,
    });
  }

  Future<AuthTokenResponse> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _postAuth('/api/auth/register', <String, dynamic>{
      'email': email,
      'password': password,
    });
  }

  Future<AuthTokenResponse> continueWithApple({
    required String identityToken,
    String? userIdentifier,
    String? email,
    String? givenName,
    String? familyName,
  }) {
    return _postAuth('/api/auth/apple', <String, dynamic>{
      'identityToken': identityToken,
      'userIdentifier': userIdentifier,
      'email': email,
      'givenName': givenName,
      'familyName': familyName,
    });
  }

  Future<UserProfile> fetchMyProfile({required String accessToken}) async {
    final json = await _sendJsonRequest(
      method: 'GET',
      path: '/api/me/profile',
      accessToken: accessToken,
    );
    return _profileFromJson(json);
  }

  Future<UserProfile> updateMyProfile({
    required String accessToken,
    String? name,
    String? translationLanguage,
    String? nativeLanguage,
    String? learningLanguage,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) {
      payload['name'] = name;
    }
    if (translationLanguage != null) {
      payload['translationLanguage'] = translationLanguage;
    }
    if (nativeLanguage != null) {
      payload['nativeLanguage'] = nativeLanguage;
    }
    if (learningLanguage != null) {
      payload['learningLanguage'] = learningLanguage;
    }
    if (payload.isEmpty) {
      throw const AuthApiException(
        code: 'invalid_request',
        message: 'Choose at least one profile field to update.',
      );
    }

    final json = await _sendJsonRequest(
      method: 'PUT',
      path: '/api/me/profile',
      accessToken: accessToken,
      payload: payload,
    );
    return _profileFromJson(json);
  }

  Future<UserProfile> uploadMyProfileImage({
    required String accessToken,
    required File imageFile,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final filename = imageFile.uri.pathSegments.isNotEmpty
            ? imageFile.uri.pathSegments.last
            : 'profile.jpg';
        final boundary =
            'bantera-${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';

        final request = await _httpClient.postUrl(
          _resolve('/api/me/profile-image'),
        );
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          'multipart/form-data; boundary=$boundary',
        );

        request.write('--$boundary\r\n');
        request.write(
          'Content-Disposition: form-data; name="file"; filename="$filename"\r\n',
        );
        request.write('Content-Type: ${_contentTypeForPath(filename)}\r\n\r\n');
        await request.addStream(imageFile.openRead());
        request.write('\r\n--$boundary--\r\n');

        final response = await request.close();
        final json = await _parseJsonResponse(response);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return _profileFromJson(json);
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
    });
  }

  Future<UploadedVideo> uploadVideo({
    required String accessToken,
    required File videoFile,
    required String transcriptText,
    required String transcriptLanguage,
    required String transcriptLanguageCode,
    required List<VideoTranscriptCue> transcriptCues,
    required bool isPublic,
    required int durationMs,
    required int? videoWidth,
    required int? videoHeight,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final filename = videoFile.uri.pathSegments.isNotEmpty
            ? videoFile.uri.pathSegments.last
            : 'bantera-video.mp4';
        final boundary =
            'bantera-${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';

        final request = await _httpClient.postUrl(_resolve('/api/me/videos'));
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
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

        writeField('transcriptText', transcriptText);
        writeField('transcriptLanguage', transcriptLanguage);
        writeField('transcriptLanguageCode', transcriptLanguageCode);
        writeField(
          'transcriptCuesJson',
          jsonEncode(transcriptCues.map((cue) => cue.toJson()).toList()),
        );
        writeField('isPublic', isPublic.toString());
        writeField('durationMs', durationMs.toString());
        if (videoWidth != null) {
          writeField('videoWidth', videoWidth.toString());
        }
        if (videoHeight != null) {
          writeField('videoHeight', videoHeight.toString());
        }

        request.write('--$boundary\r\n');
        request.write(
          'Content-Disposition: form-data; name="file"; filename="$filename"\r\n',
        );
        request.write(
          'Content-Type: ${_videoContentTypeForPath(filename)}\r\n\r\n',
        );
        await request.addStream(videoFile.openRead());
        request.write('\r\n--$boundary--\r\n');

        final response = await request.close();
        final json = await _parseJsonResponse(response);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return _uploadedVideoFromJson(json);
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
    });
  }

  /// Fetches recent public videos (not owned by the caller) optionally
  /// filtered by [languageCode] (e.g. "en", "ja"). [limit] defaults to 5.
  /// Passing [accessToken] is optional — when provided the server excludes
  /// videos owned by that user.
  Future<List<UploadedVideo>> fetchPublicVideos({
    String? accessToken,
    String? languageCode,
    int limit = 20,
    int offset = 0,
    String? search,
    String? mediaType,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final params = <String, String>{
          'limit': limit.toString(),
          'offset': offset.toString(),
        };
        if (languageCode != null && languageCode.isNotEmpty) {
          params['languageCode'] = languageCode;
        }
        if (search != null && search.trim().isNotEmpty) {
          params['search'] = search.trim();
        }
        if (mediaType != null && mediaType.isNotEmpty) {
          params['mediaType'] = mediaType;
        }
        final base = _resolve('/api/videos/public');
        final uri = base.replace(queryParameters: params);

        final request = await _httpClient.getUrl(uri);
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        if (token != null && token.isNotEmpty) {
          request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        }

        final response = await request.close();
        final responseText = await response.transform(utf8.decoder).join();
        if (responseText.isEmpty) {
          throw const AuthApiException(
            code: 'invalid_response',
            message: 'The Bantera API returned an empty response.',
          );
        }

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
                (item) => _uploadedVideoFromJson(
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
    });
  }

  /// Public catalog for learning/transcription locale pickers (no auth).
  /// Returns null if the request fails or the response is unusable.
  Future<List<LearningLanguageRow>?> fetchLearningLanguagesCatalog() async {
    try {
      final request = await _httpClient.getUrl(
        _resolve('/api/public/learning-languages'),
      );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      if (responseText.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(responseText);
      if (decoded is! List) {
        return null;
      }

      final rows = <LearningLanguageRow>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          rows.add(LearningLanguageRow.fromJson(item));
        } else if (item is Map) {
          rows.add(
            LearningLanguageRow.fromJson(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
      return rows.isEmpty ? null : rows;
    } on Object {
      return null;
    }
  }

  /// Public catalog for iOS translation locale pickers (no auth).
  /// Returns null if the request fails or the response is unusable.
  Future<List<LearningLanguageRow>?> fetchTranslationLanguagesCatalog() async {
    try {
      final request = await _httpClient.getUrl(
        _resolve('/api/public/translation-languages'),
      );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      if (responseText.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(responseText);
      if (decoded is! List) {
        return null;
      }

      final rows = <LearningLanguageRow>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          rows.add(LearningLanguageRow.fromJson(item));
        } else if (item is Map) {
          rows.add(
            LearningLanguageRow.fromJson(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
      return rows.isEmpty ? null : rows;
    } on Object {
      return null;
    }
  }

  Future<List<UploadedVideo>> fetchMyVideos({
    required String accessToken,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.getUrl(_resolve('/api/me/videos'));
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

        final response = await request.close();
        final responseText = await response.transform(utf8.decoder).join();
        if (responseText.isEmpty) {
          throw const AuthApiException(
            code: 'invalid_response',
            message: 'The Bantera API returned an empty response.',
          );
        }

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
                (item) => _uploadedVideoFromJson(
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
    });
  }

  /// Streams progress from the single generate endpoint.
  /// Calls [onDialogueDone] when dialogue text is ready, then
  /// [onAudioDone] with the saved video and original dialogue lines when audio is ready.
  Future<void> generateAiAudioStreaming({
    required String accessToken,
    required String language,
    required String languageCode,
    required String scenario,
    String? scenarioId,
    required int durationSeconds,
    required void Function() onDialogueDone,
    required void Function(UploadedVideo video, List<String> lines) onAudioDone,
    bool retried = false,
  }) async {
    try {
      final payload = jsonEncode({
        'language': language,
        'languageCode': languageCode,
        'scenario': scenario,
        if (scenarioId != null && scenarioId.isNotEmpty)
          'scenarioId': scenarioId,
        'durationSeconds': durationSeconds,
      });
      final request = await _httpClient.postUrl(
        _resolve('/api/me/audio/generate'),
      );
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(payload));

      final response = await request.close();

      if (response.statusCode != 200) {
        final body = await response.transform(utf8.decoder).join();
        Map<String, dynamic> errJson = {};
        try {
          errJson = jsonDecode(body) as Map<String, dynamic>;
        } catch (_) {}

        if (!retried &&
            response.statusCode == 401 &&
            errJson['code']?.toString() == 'token_expired') {
          final newToken = await _doRefresh();
          if (newToken != null) {
            return generateAiAudioStreaming(
              accessToken: newToken,
              language: language,
              languageCode: languageCode,
              scenario: scenario,
              scenarioId: scenarioId,
              durationSeconds: durationSeconds,
              onDialogueDone: onDialogueDone,
              onAudioDone: onAudioDone,
              retried: true,
            );
          }
          throw const SessionExpiredException();
        }

        _throwApiException(errJson, response.statusCode);
      }

      final lines = response
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final dataStr = line.substring(6).trim();
        if (dataStr.isEmpty) continue;
        Map<String, dynamic> data;
        try {
          data = jsonDecode(dataStr) as Map<String, dynamic>;
        } catch (_) {
          continue;
        }

        final step = data['step'];
        if (step == 'dialogue') {
          _dialogueLines =
              (data['lines'] as List?)?.map((e) => e.toString()).toList() ?? [];
          onDialogueDone();
        } else if (step == 'done') {
          final videoMap = data['video'] as Map<String, dynamic>;
          onAudioDone(_uploadedVideoFromJson(videoMap), _dialogueLines);
          _dialogueLines = [];
        } else if (step == 'error') {
          throw AuthApiException(
            code: 'generation_failed',
            message: data['message']?.toString() ?? 'Generation failed.',
          );
        }
      }
    } on AuthApiException {
      rethrow;
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    } on HttpException {
      await _throwNetworkFailure();
    } on TimeoutException {
      await _throwNetworkFailure();
    }
  }

  Future<void> deleteVideo({
    required String accessToken,
    required String videoId,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.openUrl(
          'DELETE',
          _resolve('/api/me/videos/$videoId'),
        );
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close();
        if (response.statusCode == 204) {
          await response.drain<void>();
          return;
        }
        final json = await _parseJsonResponse(response);
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
    });
  }

  Future<void> removeVideoFromList({
    required String accessToken,
    required String videoId,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.openUrl(
          'POST',
          _resolve('/api/me/videos/$videoId/remove-from-list'),
        );
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close();
        if (response.statusCode == 204) {
          await response.drain<void>();
          return;
        }
        final json = await _parseJsonResponse(response);
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
    });
  }

  /// Permanently deletes the authenticated user's account on the server.
  Future<void> deleteAccount({required String accessToken}) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.openUrl(
          'DELETE',
          _resolve('/api/me'),
        );
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close();
        if (response.statusCode == 204) {
          await response.drain<void>();
          return;
        }
        if (response.statusCode == 404) {
          await response.drain<void>();
          throw const AuthApiException(
            code: 'not_found',
            message: 'Account could not be found.',
          );
        }
        final json = await _parseJsonResponse(response);
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
    });
  }

  Future<bool> checkVideoSaved({
    required String accessToken,
    required String videoId,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.getUrl(
          _resolve('/api/me/saved/$videoId'),
        );
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        if (response.statusCode == 401) {
          final decoded = jsonDecode(body);
          if (decoded is Map &&
              decoded['code']?.toString() == 'token_expired') {
            throw const AuthApiException(code: 'token_expired', message: '');
          }
        }
        if (response.statusCode != 200) return false;
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          return decoded['isSaved'] == true;
        }
        return false;
      } on AuthApiException {
        rethrow;
      } catch (_) {
        return false;
      }
    });
  }

  Future<void> saveVideo({
    required String accessToken,
    required String videoId,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.openUrl(
          'POST',
          _resolve('/api/me/saved/$videoId'),
        );
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        final response = await request.close();
        if (response.statusCode == 401) {
          final body = await response.transform(utf8.decoder).join();
          final json = _tryDecodeJson(body);
          if (json != null && json['code']?.toString() == 'token_expired') {
            throw const AuthApiException(code: 'token_expired', message: '');
          }
          return;
        }
        await response.drain<void>();
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
    });
  }

  Future<void> unsaveVideo({
    required String accessToken,
    required String videoId,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.openUrl(
          'DELETE',
          _resolve('/api/me/saved/$videoId'),
        );
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        final response = await request.close();
        if (response.statusCode == 401) {
          final body = await response.transform(utf8.decoder).join();
          final json = _tryDecodeJson(body);
          if (json != null && json['code']?.toString() == 'token_expired') {
            throw const AuthApiException(code: 'token_expired', message: '');
          }
          return;
        }
        await response.drain<void>();
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
    });
  }

  Future<String?> saveCue({
    required String accessToken,
    required String videoId,
    required String cueId,
    required int cueIndex,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.openUrl(
          'POST',
          _resolve('/api/me/saved-cues'),
        );
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        request.write(
          jsonEncode({
            'videoId': videoId,
            'cueId': cueId,
            'cueIndex': cueIndex,
          }),
        );
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        if (response.statusCode == 401) {
          final json = _tryDecodeJson(body);
          if (json != null && json['code']?.toString() == 'token_expired') {
            throw const AuthApiException(code: 'token_expired', message: '');
          }
          return null;
        }
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = _tryDecodeJson(body);
          return decoded?['id']?.toString();
        }
        return null;
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
    });
  }

  Future<void> unsaveCue({
    required String accessToken,
    required String entryId,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.openUrl(
          'DELETE',
          _resolve('/api/me/saved-cues/$entryId'),
        );
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        final response = await request.close();
        if (response.statusCode == 401) {
          final body = await response.transform(utf8.decoder).join();
          final json = _tryDecodeJson(body);
          if (json != null && json['code']?.toString() == 'token_expired') {
            throw const AuthApiException(code: 'token_expired', message: '');
          }
          return;
        }
        await response.drain<void>();
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
    });
  }

  Future<List<SavedCueApiEntry>> fetchSavedCues({
    required String accessToken,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.getUrl(
          _resolve('/api/me/saved-cues'),
        );
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        final response = await request.close();
        final responseText = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(responseText);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (decoded is! List) return [];
          return decoded.whereType<Map>().map((item) {
            final m = item.map((k, v) => MapEntry(k.toString(), v));
            return SavedCueApiEntry.fromJson(m);
          }).toList();
        }
        if (decoded is Map<String, dynamic>) {
          _throwApiException(decoded, response.statusCode);
        }
        return [];
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
    });
  }

  Future<List<UploadedVideo>> fetchSavedVideos({
    required String accessToken,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.getUrl(_resolve('/api/me/saved'));
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        final response = await request.close();
        final responseText = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(responseText);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (decoded is! List) return [];
          return decoded
              .whereType<Map>()
              .map(
                (item) => _uploadedVideoFromJson(
                  item.map((k, v) => MapEntry(k.toString(), v)),
                ),
              )
              .toList();
        }
        if (decoded is Map<String, dynamic>) {
          _throwApiException(decoded, response.statusCode);
        }
        return [];
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
    });
  }

  Future<({int uploadCount, int savedCount})> fetchProfileStats({
    required String accessToken,
  }) async {
    return _retryWithRefresh(accessToken, (token) async {
      try {
        final request = await _httpClient.getUrl(_resolve('/api/me/stats'));
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        final response = await request.close();
        final responseText = await response.transform(utf8.decoder).join();
        if (response.statusCode == 401) {
          final json = _tryDecodeJson(responseText);
          if (json != null && json['code']?.toString() == 'token_expired') {
            throw const AuthApiException(code: 'token_expired', message: '');
          }
        }
        final decoded = jsonDecode(responseText) as Map<String, dynamic>;
        return (
          uploadCount: (decoded['uploadCount'] as num?)?.toInt() ?? 0,
          savedCount: (decoded['savedCount'] as num?)?.toInt() ?? 0,
        );
      } on AuthApiException {
        rethrow;
      } catch (_) {
        return (uploadCount: 0, savedCount: 0);
      }
    });
  }

  Future<UploadedVideo> correctVideoTranscript({
    required String accessToken,
    required String videoId,
    required List<String> originalLines,
    required List<VideoTranscriptCue> transcribedCues,
  }) async {
    try {
      final json = await _sendJsonRequest(
        method: 'POST',
        path: '/api/me/videos/$videoId/transcript/correct',
        payload: {
          'originalLines': originalLines,
          'transcribedCues': transcribedCues.map((c) => c.toJson()).toList(),
        },
        accessToken: accessToken,
      );
      return _uploadedVideoFromJson(json);
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    }
  }

  Future<UploadedVideo> updateVideoTranscript({
    required String accessToken,
    required String videoId,
    required String transcriptText,
    required List<VideoTranscriptCue> transcriptCues,
  }) async {
    try {
      final json = await _sendJsonRequest(
        method: 'PATCH',
        path: '/api/me/videos/$videoId/transcript',
        payload: {
          'transcriptText': transcriptText,
          'transcriptCues': transcriptCues.map((c) => c.toJson()).toList(),
        },
        accessToken: accessToken,
      );
      return _uploadedVideoFromJson(json);
    } on SocketException {
      await _throwNetworkFailure();
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection.',
      );
    }
  }

  Future<AuthTokenResponse> _postAuth(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      final json = await _sendJsonRequest(
        method: 'POST',
        path: path,
        payload: payload,
      );
      return AuthTokenResponse.fromJson(json);
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
    Map<String, dynamic>? payload,
    String? accessToken,
    bool retried = false,
  }) async {
    final request = await _httpClient.openUrl(method, _resolve(path));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }
    if (payload != null) {
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(payload)));
    }

    final response = await request.close();
    final json = await _parseJsonResponse(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }

    if (!retried &&
        response.statusCode == 401 &&
        json['code']?.toString() == 'token_expired') {
      final newToken = await _doRefresh();
      if (newToken != null) {
        return _sendJsonRequest(
          method: method,
          path: path,
          payload: payload,
          accessToken: newToken,
          retried: true,
        );
      }
      throw const SessionExpiredException();
    }

    _throwApiException(json, response.statusCode);
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

  UserProfile _profileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      translationLanguage: json['translationLanguage'] as String?,
      nativeLanguage: json['nativeLanguage'] as String?,
      learningLanguage: json['learningLanguage'] as String?,
    );
  }

  UploadedVideo _uploadedVideoFromJson(Map<String, dynamic> json) =>
      uploadedVideoFromJsonPublic(json);

  static UploadedVideo uploadedVideoFromJsonPublic(Map<String, dynamic> json) {
    return UploadedVideo(
      id: json['id'] as String,
      userId: json['userId'] as String,
      originalFileName: json['originalFileName'] as String,
      transcriptText: json['transcriptText'] as String,
      transcriptLanguage: json['transcriptLanguage'] as String,
      transcriptLanguageCode: json['transcriptLanguageCode'] as String? ?? '',
      transcriptCues: ((json['transcriptCues'] as List?) ?? const [])
          .map((item) {
            if (item is Map<String, dynamic>) {
              return VideoTranscriptCue.fromJson(item);
            }
            if (item is Map) {
              return VideoTranscriptCue.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              );
            }
            return null;
          })
          .whereType<VideoTranscriptCue>()
          .toList(),
      isPublic: json['isPublic'] as bool,
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      isTranscriptionEstimated:
          json['isTranscriptionEstimated'] as bool? ?? false,
      durationMs: (json['durationMs'] as num).toInt(),
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      videoWidth: (json['videoWidth'] as num?)?.toInt(),
      videoHeight: (json['videoHeight'] as num?)?.toInt(),
      videoContentType: json['videoContentType'] as String,
      videoUrl: json['videoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      creatorDisplayName: json['creatorDisplayName'] as String?,
    );
  }

  Uri _resolve(String path) {
    final baseUrl = ApiConfigNotifier.instance.baseUrl;
    final baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return baseUri.resolve(normalizedPath);
  }

  static String _contentTypeForPath(String filename) {
    final normalized = filename.toLowerCase();
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.webp')) {
      return 'image/webp';
    }
    if (normalized.endsWith('.heic')) {
      return 'image/heic';
    }
    if (normalized.endsWith('.heif')) {
      return 'image/heif';
    }
    return 'image/jpeg';
  }

  static String _videoContentTypeForPath(String filename) {
    final normalized = filename.toLowerCase();
    if (normalized.endsWith('.mov')) {
      return 'video/quicktime';
    }
    if (normalized.endsWith('.m4v')) {
      return 'video/x-m4v';
    }
    return 'video/mp4';
  }
}

class AuthTokenResponse {
  AuthTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      refreshToken: json['refreshToken'] as String,
    );
  }

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;
}

class AuthApiException implements Exception {
  const AuthApiException({required this.code, required this.message});

  final String code;
  final String message;
}

/// Thrown when the session could not be renewed and the user has been signed
/// out. This is NOT an [AuthApiException] on purpose — callers that show
/// `AuthApiException.message` to the user won't catch it, so no confusing
/// error dialog appears while the app navigates back to the login screen.
class SessionExpiredException implements Exception {
  const SessionExpiredException();
}

class SavedCueApiEntry {
  final String id;
  final String cueId;
  final int cueIndex;
  final DateTime savedAt;
  final UploadedVideo video;

  const SavedCueApiEntry({
    required this.id,
    required this.cueId,
    required this.cueIndex,
    required this.savedAt,
    required this.video,
  });

  factory SavedCueApiEntry.fromJson(Map<String, dynamic> json) {
    final videoMap =
        (json['video'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ??
        const <String, dynamic>{};
    return SavedCueApiEntry(
      id: json['id']?.toString() ?? '',
      cueId: json['cueId']?.toString() ?? '',
      cueIndex: (json['cueIndex'] as num?)?.toInt() ?? 0,
      savedAt: json['savedAt'] != null
          ? DateTime.tryParse(json['savedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      video: AuthApiClient.uploadedVideoFromJsonPublic(videoMap),
    );
  }
}
