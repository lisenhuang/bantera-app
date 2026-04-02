import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../domain/models/models.dart';
import '../infrastructure/auth_api_client.dart';
import 'auth_session_notifier.dart';

class UserProfileNotifier extends ChangeNotifier {
  UserProfileNotifier._() {
    AuthSessionNotifier.instance.addListener(_handleAuthChanged);
  }

  static final UserProfileNotifier instance = UserProfileNotifier._();

  final AuthApiClient _apiClient = AuthApiClient.instance;

  AuthSession? _observedSession;
  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSavingName = false;
  bool _isUploadingImage = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSavingName => _isSavingName;
  bool get isUploadingImage => _isUploadingImage;
  bool get isBusy => _isLoading || _isSavingName || _isUploadingImage;
  String? get errorMessage => _errorMessage;
  String? get avatarUrl => _profile?.avatarUrl;

  String get displayName {
    final profileName = _profile?.name.trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }

    final accountLabel = AuthSessionNotifier.instance.session?.accountLabel
        .trim();
    if (accountLabel != null && accountLabel.isNotEmpty) {
      final atIndex = accountLabel.indexOf('@');
      return atIndex > 0 ? accountLabel.substring(0, atIndex) : accountLabel;
    }

    return 'Bantera user';
  }

  Future<void> loadProfile({bool force = false}) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      _clearState(notify: force);
      return;
    }
    if (_isLoading || (_profile != null && !force)) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _apiClient.fetchMyProfile(
        accessToken: session.accessToken,
      );
    } on AuthApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateName(String name) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      _setError('Sign in again to update your profile.');
      return false;
    }

    final normalizedName = name.trim();
    if (normalizedName.isEmpty || normalizedName.length > 80) {
      _setError('Name must be between 1 and 80 characters.');
      return false;
    }

    _isSavingName = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _apiClient.updateMyProfile(
        accessToken: session.accessToken,
        name: normalizedName,
      );
      return true;
    } on AuthApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSavingName = false;
      notifyListeners();
    }
  }

  Future<bool> uploadAvatar(File imageFile) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      _setError('Sign in again to update your profile image.');
      return false;
    }

    _isUploadingImage = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _apiClient.uploadMyProfileImage(
        accessToken: session.accessToken,
        imageFile: imageFile,
      );
      return true;
    } on AuthApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void _handleAuthChanged() {
    final session = AuthSessionNotifier.instance.session;
    final previousAccessToken = _observedSession?.accessToken;
    final nextAccessToken = session?.accessToken;
    if (previousAccessToken == nextAccessToken) {
      return;
    }

    _observedSession = session;
    if (session == null) {
      _clearState();
      return;
    }

    unawaited(loadProfile(force: true));
  }

  void _clearState({bool notify = true}) {
    _profile = null;
    _errorMessage = null;
    _isLoading = false;
    _isSavingName = false;
    _isUploadingImage = false;
    if (notify) {
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
