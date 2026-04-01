import 'dart:convert';
import 'dart:io';

import '../core/api_config_notifier.dart';

class AuthApiClient {
  AuthApiClient._();

  static final AuthApiClient instance = AuthApiClient._();

  final HttpClient _httpClient = HttpClient();

  String get displayBaseUrl => ApiConfigNotifier.instance.baseUrl;

  Future<AuthTokenResponse> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _postAuth(
      '/api/auth/login',
      <String, dynamic>{
        'email': email,
        'password': password,
      },
    );
  }

  Future<AuthTokenResponse> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _postAuth(
      '/api/auth/register',
      <String, dynamic>{
        'email': email,
        'password': password,
      },
    );
  }

  Future<AuthTokenResponse> continueWithApple({
    required String identityToken,
    String? userIdentifier,
    String? email,
    String? givenName,
    String? familyName,
  }) {
    return _postAuth(
      '/api/auth/apple',
      <String, dynamic>{
        'identityToken': identityToken,
        'userIdentifier': userIdentifier,
        'email': email,
        'givenName': givenName,
        'familyName': familyName,
      },
    );
  }

  Future<AuthTokenResponse> _postAuth(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      final request = await _httpClient.postUrl(_resolve(path));
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();
      final decoded = responseText.isEmpty ? null : jsonDecode(responseText);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map) {
          return AuthTokenResponse.fromJson(Map<String, dynamic>.from(decoded));
        }

        throw const AuthApiException(
          code: 'invalid_response',
          message: 'The Bantera API returned an unexpected response.',
        );
      }

      if (decoded is Map) {
        final error = Map<String, dynamic>.from(decoded);
        final code = error['code']?.toString();
        final message = error['message']?.toString();
        if (code != null && message != null) {
          throw AuthApiException(code: code, message: message);
        }
      }

      throw AuthApiException(
        code: 'request_failed',
        message: 'The Bantera API request failed (${response.statusCode}).',
      );
    } on SocketException {
      throw const AuthApiException(
        code: 'network_error',
        message: 'Cannot reach the Bantera API. Check API_BASE_URL and make sure the backend is running.',
      );
    } on HandshakeException {
      throw const AuthApiException(
        code: 'tls_error',
        message: 'The app could not establish a secure connection to the Bantera API.',
      );
    }
  }

  Uri _resolve(String path) {
    final baseUrl = ApiConfigNotifier.instance.baseUrl;
    final baseUri = Uri.parse(
      baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
    );
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return baseUri.resolve(normalizedPath);
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
  const AuthApiException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}
