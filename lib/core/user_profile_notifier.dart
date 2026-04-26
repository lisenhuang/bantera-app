import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../domain/models/models.dart';
import '../infrastructure/auth_api_client.dart';
import '../infrastructure/transcription_locale_option.dart';
import '../infrastructure/user_profile_cache_store.dart';
import '../l10n/app_localizations.dart';
import 'auth_api_error_localizations.dart';
import 'auth_session_notifier.dart';

class UserProfileNotifier extends ChangeNotifier {
  UserProfileNotifier._() {
    AuthSessionNotifier.instance.addListener(_handleAuthChanged);
    // If a session was already restored from disk before this listener was
    // registered, trigger the profile load now.
    if (AuthSessionNotifier.instance.isAuthenticated) {
      _handleAuthChanged();
    }
  }

  static final UserProfileNotifier instance = UserProfileNotifier._();

  final AuthApiClient _apiClient = AuthApiClient.instance;
  final UserProfileCacheStore _cacheStore = UserProfileCacheStore.instance;

  AuthSession? _observedSession;
  UserProfile? _profile;
  String? _avatarImagePath;
  String? _activeCacheKey;
  bool _isLoading = false;
  bool _isSavingProfile = false;
  bool _isUploadingImage = false;
  String? _plainErrorMessage;
  AuthApiException? _authApiError;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSavingName => _isSavingProfile;
  bool get isSavingProfile => _isSavingProfile;
  bool get isUploadingImage => _isUploadingImage;
  bool get isBusy => _isLoading || _isSavingProfile || _isUploadingImage;

  String? get plainErrorMessage => _plainErrorMessage;

  AuthApiException? get authApiError => _authApiError;

  String? localizedError(AppLocalizations l10n) {
    if (_authApiError != null) {
      return localizeAuthApiError(l10n, _authApiError!);
    }
    return _plainErrorMessage;
  }

  String? get avatarImagePath => _avatarImagePath;
  String? get avatarUrl => _profile?.avatarUrl;
  String? get translationLanguage => _profile?.translationLanguage;
  String? get nativeLanguage => _profile?.nativeLanguage;
  String? get learningLanguage {
    final value = _profile?.learningLanguage;
    if (value == null || value.trim().isEmpty) return value;
    return normalizeLegacyLearningLanguageIdentifier(value);
  }

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

  Future<void> loadProfile({
    bool force = false,
    bool showLoadingState = true,
  }) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      _clearState(notify: force);
      return;
    }
    if (_isLoading || (_profile != null && !force)) {
      return;
    }

    _isLoading = true;
    _plainErrorMessage = null;
    _authApiError = null;
    if (showLoadingState) {
      notifyListeners();
    }

    final requestCacheKey = session.cacheKey;

    try {
      final profile = await _apiClient.fetchMyProfile(
        accessToken: session.accessToken,
      );
      if (!_isCurrentCacheKey(requestCacheKey)) {
        return;
      }

      await _applyRemoteProfile(requestCacheKey, profile);
    } on AuthApiException catch (error) {
      if (!_isCurrentCacheKey(requestCacheKey)) {
        return;
      }
      _authApiError = error;
      _plainErrorMessage = null;
      notifyListeners();
    } finally {
      if (_isCurrentCacheKey(requestCacheKey)) {
        _isLoading = false;
        if (showLoadingState) {
          notifyListeners();
        }
      }
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

    _isSavingProfile = true;
    _plainErrorMessage = null;
    _authApiError = null;
    notifyListeners();

    try {
      final updatedProfile = await _apiClient.updateMyProfile(
        accessToken: session.accessToken,
        name: normalizedName,
      );
      await _applyRemoteProfile(session.cacheKey, updatedProfile);
      return true;
    } on AuthApiException catch (error) {
      _authApiError = error;
      _plainErrorMessage = null;
      return false;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> updateNativeLanguage(String nativeLanguage) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      _setError('Sign in again to save your native language.');
      return false;
    }

    final normalized = nativeLanguage.trim();
    if (normalized.length > 35) {
      _setError('Choose a valid native language.');
      return false;
    }

    _isSavingProfile = true;
    _plainErrorMessage = null;
    _authApiError = null;
    notifyListeners();

    try {
      final updatedProfile = await _apiClient.updateMyProfile(
        accessToken: session.accessToken,
        nativeLanguage: normalized,
      );
      await _applyRemoteProfile(session.cacheKey, updatedProfile);
      return true;
    } on AuthApiException catch (error) {
      _authApiError = error;
      _plainErrorMessage = null;
      return false;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> updateLearningLanguage(String learningLanguage) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      _setError('Sign in again to save your learning language.');
      return false;
    }

    final normalized = learningLanguage.trim();
    if (normalized.isEmpty || normalized.length > 35) {
      _setError('Choose a valid learning language.');
      return false;
    }

    _isSavingProfile = true;
    _plainErrorMessage = null;
    _authApiError = null;
    notifyListeners();

    try {
      final updatedProfile = await _apiClient.updateMyProfile(
        accessToken: session.accessToken,
        learningLanguage: normalized,
      );
      await _applyRemoteProfile(session.cacheKey, updatedProfile);
      return true;
    } on AuthApiException catch (error) {
      _authApiError = error;
      _plainErrorMessage = null;
      return false;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> updateTranslationLanguage(String translationLanguage) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      _setError('Sign in again to save your translation language.');
      return false;
    }

    final normalizedLanguage = translationLanguage.trim();
    if (normalizedLanguage.isEmpty || normalizedLanguage.length > 35) {
      _setError('Choose a valid translation language.');
      return false;
    }

    _isSavingProfile = true;
    _plainErrorMessage = null;
    _authApiError = null;
    notifyListeners();

    try {
      final updatedProfile = await _apiClient.updateMyProfile(
        accessToken: session.accessToken,
        translationLanguage: normalizedLanguage,
      );
      await _applyRemoteProfile(session.cacheKey, updatedProfile);
      return true;
    } on AuthApiException catch (error) {
      _authApiError = error;
      _plainErrorMessage = null;
      return false;
    } finally {
      _isSavingProfile = false;
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
    _plainErrorMessage = null;
    _authApiError = null;
    notifyListeners();

    try {
      final updatedProfile = await _apiClient.uploadMyProfileImage(
        accessToken: session.accessToken,
        imageFile: imageFile,
      );
      await _applyRemoteProfile(
        session.cacheKey,
        updatedProfile,
        avatarSourceFile: imageFile,
      );
      return true;
    } on AuthApiException catch (error) {
      _authApiError = error;
      _plainErrorMessage = null;
      return false;
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_plainErrorMessage == null && _authApiError == null) {
      return;
    }

    _plainErrorMessage = null;
    _authApiError = null;
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
      _activeCacheKey = null;
      _clearState();
      return;
    }

    _activeCacheKey = session.cacheKey;
    unawaited(_restoreCachedProfileAndRefresh(session));
  }

  void _clearState({bool notify = true}) {
    _profile = null;
    _avatarImagePath = null;
    _plainErrorMessage = null;
    _authApiError = null;
    _isLoading = false;
    _isSavingProfile = false;
    _isUploadingImage = false;
    if (notify) {
      notifyListeners();
    }
  }

  void _setError(String message) {
    _plainErrorMessage = message;
    _authApiError = null;
    notifyListeners();
  }

  Future<void> _restoreCachedProfileAndRefresh(AuthSession session) async {
    final cacheKey = session.cacheKey;
    final cached = await _cacheStore.read(cacheKey);
    if (!_isCurrentCacheKey(cacheKey)) {
      return;
    }

    if (cached != null) {
      _profile = cached.profile;
      _avatarImagePath = cached.avatarPath;
      _plainErrorMessage = null;
      _authApiError = null;
      notifyListeners();
    }

    await loadProfile(force: true, showLoadingState: _profile == null);
  }

  Future<void> _applyRemoteProfile(
    String cacheKey,
    UserProfile profile, {
    File? avatarSourceFile,
  }) async {
    if (!_isCurrentCacheKey(cacheKey)) {
      return;
    }

    final previousAvatarUrl = _profile?.avatarUrl;
    _profile = profile;
    _plainErrorMessage = null;
    _authApiError = null;
    await _cacheStore.write(cacheKey, profile, avatarPath: _avatarImagePath);
    notifyListeners();

    if (profile.avatarUrl == null || profile.avatarUrl!.trim().isEmpty) {
      if (_avatarImagePath != null) {
        await _cacheStore.clearAvatar(cacheKey);
        _avatarImagePath = null;
        await _cacheStore.write(cacheKey, profile, avatarPath: null);
        if (_isCurrentCacheKey(cacheKey)) {
          notifyListeners();
        }
      }
      return;
    }

    if (avatarSourceFile != null) {
      final cachedPath = await _cacheStore.cacheAvatarFromFile(
        cacheKey,
        avatarSourceFile,
      );
      if (!_isCurrentCacheKey(cacheKey)) {
        return;
      }

      if (cachedPath != null) {
        _avatarImagePath = cachedPath;
        await _cacheStore.write(cacheKey, profile, avatarPath: cachedPath);
        notifyListeners();
      }
      return;
    }

    final shouldRefreshAvatar =
        _avatarImagePath == null || previousAvatarUrl != profile.avatarUrl;
    if (!shouldRefreshAvatar) {
      return;
    }

    final cachedPath = await _cacheStore.cacheAvatarFromUrl(
      cacheKey,
      profile.avatarUrl!,
    );
    if (!_isCurrentCacheKey(cacheKey) || cachedPath == null) {
      return;
    }

    _avatarImagePath = cachedPath;
    await _cacheStore.write(cacheKey, profile, avatarPath: cachedPath);
    notifyListeners();
  }

  bool _isCurrentCacheKey(String cacheKey) {
    return _activeCacheKey == cacheKey &&
        AuthSessionNotifier.instance.session?.cacheKey == cacheKey;
  }
}
