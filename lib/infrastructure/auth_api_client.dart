import 'dart:convert';
import 'dart:io';

import '../core/api_config_notifier.dart';
import '../domain/models/models.dart';

class AuthApiClient {
  AuthApiClient._();

  static final AuthApiClient instance = AuthApiClient._();

  final HttpClient _httpClient = HttpClient();

  String get displayBaseUrl => ApiConfigNotifier.instance.baseUrl;

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
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) {
      payload['name'] = name;
    }
    if (translationLanguage != null) {
      payload['translationLanguage'] = translationLanguage;
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
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
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
    } on SocketException {
      throw const AuthApiException(
        code: 'network_error',
        message:
            'Cannot reach the Bantera API. Check API_BASE_URL and make sure the backend is running.',
      );
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message:
            'The app could not establish a secure connection to the Bantera API.',
      );
    }
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
    try {
      final filename = videoFile.uri.pathSegments.isNotEmpty
          ? videoFile.uri.pathSegments.last
          : 'bantera-video.mp4';
      final boundary =
          'bantera-${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';

      final request = await _httpClient.postUrl(_resolve('/api/me/videos'));
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
    } on SocketException {
      throw const AuthApiException(
        code: 'network_error',
        message:
            'Cannot reach the Bantera API. Check API_BASE_URL and make sure the backend is running.',
      );
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message:
            'The app could not establish a secure connection to the Bantera API.',
      );
    }
  }

  Future<List<UploadedVideo>> fetchMyVideos({
    required String accessToken,
  }) async {
    try {
      final request = await _httpClient.getUrl(_resolve('/api/me/videos'));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );

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
    } on SocketException {
      throw const AuthApiException(
        code: 'network_error',
        message:
            'Cannot reach the Bantera API. Check API_BASE_URL and make sure the backend is running.',
      );
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message:
            'The app could not establish a secure connection to the Bantera API.',
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
      throw const AuthApiException(
        code: 'network_error',
        message:
            'Cannot reach the Bantera API. Check API_BASE_URL and make sure the backend is running.',
      );
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message:
            'The app could not establish a secure connection to the Bantera API.',
      );
    }
  }

  Future<Map<String, dynamic>> _sendJsonRequest({
    required String method,
    required String path,
    Map<String, dynamic>? payload,
    String? accessToken,
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
    );
  }

  UploadedVideo _uploadedVideoFromJson(Map<String, dynamic> json) {
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
      durationMs: (json['durationMs'] as num).toInt(),
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      videoWidth: (json['videoWidth'] as num?)?.toInt(),
      videoHeight: (json['videoHeight'] as num?)?.toInt(),
      videoContentType: json['videoContentType'] as String,
      videoUrl: json['videoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
