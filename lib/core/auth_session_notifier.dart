import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'api_config_notifier.dart';
import '../infrastructure/auth_api_client.dart';

enum AuthProviderType { email, apple }

class AuthSession {
  const AuthSession({
    required this.provider,
    required this.accountLabel,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  final AuthProviderType provider;
  final String accountLabel;
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;

  String get providerLabel => switch (provider) {
    AuthProviderType.email => 'Email',
    AuthProviderType.apple => 'Apple',
  };

  String get cacheKey {
    final subject = _jwtSubject(accessToken);
    if (subject != null && subject.isNotEmpty) {
      return '${provider.name}:$subject';
    }

    return '${provider.name}:${accountLabel.trim().toLowerCase()}';
  }

  static String? _jwtSubject(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map<String, dynamic>) {
        return payload['sub']?.toString();
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}

class AuthSessionNotifier extends ChangeNotifier {
  AuthSessionNotifier._();

  static final AuthSessionNotifier instance = AuthSessionNotifier._();

  final AuthApiClient _apiClient = AuthApiClient.instance;

  AuthSession? _session;
  bool _isBusy = false;
  String? _errorMessage;

  AuthSession? get session => _session;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _session != null;
  String? get errorMessage => _errorMessage;
  String get apiBaseUrl => ApiConfigNotifier.instance.baseUrl;

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _runAuthAction(
      () => _apiClient.loginWithEmail(email: email, password: password),
      provider: AuthProviderType.email,
      accountLabel: email.trim().toLowerCase(),
    );
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _runAuthAction(
      () => _apiClient.registerWithEmail(email: email, password: password),
      provider: AuthProviderType.email,
      accountLabel: email.trim().toLowerCase(),
    );
  }

  Future<void> continueWithApple() async {
    if (!await SignInWithApple.isAvailable()) {
      _setError('Sign in with Apple is not available on this device.');
      return;
    }

    _setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw const AuthApiException(
          code: 'missing_identity_token',
          message: 'Apple did not return an identity token.',
        );
      }

      final response = await _apiClient.continueWithApple(
        identityToken: identityToken,
        userIdentifier: credential.userIdentifier,
        email: credential.email,
        givenName: credential.givenName,
        familyName: credential.familyName,
      );

      _session = AuthSession(
        provider: AuthProviderType.apple,
        accountLabel: _appleAccountLabel(credential.email),
        accessToken: response.accessToken,
        tokenType: response.tokenType,
        expiresIn: response.expiresIn,
        refreshToken: response.refreshToken,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code != AuthorizationErrorCode.canceled) {
        _errorMessage = 'Apple sign-in could not be completed.';
      }
    } on AuthApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _setBusy(false);
    }
  }

  void signOut() {
    _session = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _runAuthAction(
    Future<AuthTokenResponse> Function() action, {
    required AuthProviderType provider,
    required String accountLabel,
  }) async {
    _setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await action();
      _session = AuthSession(
        provider: provider,
        accountLabel: accountLabel,
        accessToken: response.accessToken,
        tokenType: response.tokenType,
        expiresIn: response.expiresIn,
        refreshToken: response.refreshToken,
      );
    } on AuthApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  static String _appleAccountLabel(String? email) {
    final normalized = email?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Apple account';
    }

    return normalized.toLowerCase();
  }
}
