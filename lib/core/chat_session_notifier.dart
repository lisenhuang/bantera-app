import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../domain/models/chat_models.dart';
import '../domain/models/models.dart';
import '../infrastructure/auth_api_client.dart';
import '../infrastructure/chat_api_client.dart';
import '../infrastructure/local_chat_repository.dart';
import '../infrastructure/push_notifications_service.dart';
import '../infrastructure/translation_service.dart';
import '../infrastructure/video_processing_service.dart';
import 'auth_api_error_localizations.dart';
import 'auth_session_notifier.dart';
import 'settings_notifier.dart';
import 'user_profile_notifier.dart';

class ChatSessionNotifier extends ChangeNotifier {
  ChatSessionNotifier._() {
    AuthSessionNotifier.instance.addListener(_handleAuthChanged);
    if (AuthSessionNotifier.instance.isAuthenticated) {
      _handleAuthChanged();
    }
  }

  static final ChatSessionNotifier instance = ChatSessionNotifier._();

  final ChatApiClient _apiClient = ChatApiClient.instance;
  final LocalChatRepository _localRepository = LocalChatRepository.instance;
  final Set<String> _activeThreadIds = <String>{};
  final Set<String> _updatingThreadNotificationIds = <String>{};
  final Map<String, bool> _partnerRecordingByThread = <String, bool>{};
  final StreamController<Map<String, dynamic>> _realtimeEventsController =
      StreamController<Map<String, dynamic>>.broadcast();

  AuthSession? _observedSession;
  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _reconnectTimer;
  bool _isLoading = false;
  bool _isRefreshingMessages = false;
  bool _globalNotificationsEnabled = true;
  String? _plainErrorMessage;
  AuthApiException? _authApiError;
  String? _ownerCacheKey;
  String? _lastRegisteredPushTokenKey;

  bool get isLoading => _isLoading;
  bool get isRefreshingMessages => _isRefreshingMessages;
  bool get globalNotificationsEnabled => _globalNotificationsEnabled;
  String? get plainErrorMessage => _plainErrorMessage;
  AuthApiException? get authApiError => _authApiError;

  Stream<List<ChatThreadSummary>> watchGroups() =>
      _localRepository.watchGroups();
  Stream<List<ChatUserSummary>> watchOnlineUsers() =>
      _localRepository.watchOnlineUsers();
  Stream<List<ChatThreadSummary>> watchDirectMessages() =>
      _localRepository.watchDirectMessages();
  Stream<List<ChatUserSummary>> watchBlockedUsers() =>
      _localRepository.watchBlockedUsers();
  Stream<List<ChatMessageItem>> watchMessages(String threadId) =>
      _localRepository.watchMessages(threadId);
  Stream<Map<String, dynamic>> get realtimeEvents =>
      _realtimeEventsController.stream;

  Future<ChatThreadSummary?> directMessageThreadForUser(String userId) {
    return _localRepository.directMessageThreadForUser(userId);
  }

  Future<void> ensureRealtimeConnected() async {
    await _connectWebSocket();
  }

  String? localizedErrorText(dynamic l10n) {
    if (_authApiError != null) {
      return localizeAuthApiError(l10n, _authApiError!);
    }
    return _plainErrorMessage;
  }

  bool isPartnerRecording(String threadId) {
    return _partnerRecordingByThread[threadId] == true;
  }

  bool isUpdatingThreadNotifications(String threadId) {
    return _updatingThreadNotificationIds.contains(threadId);
  }

  Future<void> refreshBootstrap({bool showLoadingState = true}) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null || _isLoading) {
      return;
    }

    _isLoading = true;
    _plainErrorMessage = null;
    _authApiError = null;
    if (showLoadingState) {
      notifyListeners();
    }

    try {
      final bootstrap = await _withRetry(
        (token) => _apiClient.fetchBootstrap(accessToken: token),
      );
      _ownerCacheKey = session.cacheKey;
      _globalNotificationsEnabled = bootstrap.globalNotificationsEnabled;
      SettingsNotifier.instance.toggleNotifications(
        bootstrap.globalNotificationsEnabled,
      );
      await _localRepository.replaceBootstrap(
        ownerCacheKey: session.cacheKey,
        bootstrap: bootstrap,
      );
      await refreshBlockedUsers();
      if (bootstrap.globalNotificationsEnabled) {
        unawaited(_syncPushToken(promptForPermission: false));
      }
      unawaited(_connectWebSocket());
    } on AuthApiException catch (error) {
      _authApiError = error;
      _plainErrorMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBlockedUsers() async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null || _ownerCacheKey == null) {
      return;
    }

    try {
      final blocked = await _withRetry(
        (token) => _apiClient.fetchBlockedUsers(accessToken: token),
      );
      await _localRepository.replaceBlockedUsers(
        ownerCacheKey: _ownerCacheKey!,
        users: blocked,
      );
    } on AuthApiException {
      // Keep cached list if the refresh fails.
    }
  }

  Future<void> loadMessages(String threadId) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null || _ownerCacheKey == null || threadId.trim().isEmpty) {
      return;
    }

    _isRefreshingMessages = true;
    notifyListeners();
    try {
      final messages = await _withRetry(
        (token) =>
            _apiClient.fetchMessages(accessToken: token, threadId: threadId),
      );
      await _localRepository.replaceMessages(
        ownerCacheKey: _ownerCacheKey!,
        threadId: threadId,
        messages: messages,
      );
    } on AuthApiException catch (error) {
      _authApiError = error;
      _plainErrorMessage = null;
    } finally {
      _isRefreshingMessages = false;
      notifyListeners();
    }
  }

  Future<ChatMessageItem> sendDirectMessageAudio({
    required String otherUserId,
    required File audioFile,
    required int durationMs,
  }) async {
    final message = await _withRetry(
      (token) => _apiClient.sendDirectMessageAudio(
        accessToken: token,
        otherUserId: otherUserId,
        audioFile: audioFile,
        durationMs: durationMs,
      ),
    );
    await refreshBootstrap(showLoadingState: false);
    await loadMessages(message.threadId);
    return message;
  }

  Future<ChatMessageItem> sendGroupAudio({
    required String groupKind,
    required File audioFile,
    required int durationMs,
  }) async {
    final message = await _withRetry(
      (token) => _apiClient.sendGroupAudio(
        accessToken: token,
        groupKind: groupKind,
        audioFile: audioFile,
        durationMs: durationMs,
      ),
    );
    await refreshBootstrap(showLoadingState: false);
    await loadMessages(message.threadId);
    return message;
  }

  Future<File> ensureLocalAudio(ChatMessageItem message) async {
    final existingPath = await _localRepository.resolveAudioPath(
      message.localAudioPath,
    );
    if (existingPath != null && await File(existingPath).exists()) {
      return File(existingPath);
    }

    final downloaded = await _withRetry(
      (token) => _apiClient.downloadMessageAudio(
        accessToken: token,
        messageId: message.messageId,
      ),
    );
    final storedReference = await _localRepository.storeAudioBytes(
      messageId: message.messageId,
      bytes: downloaded.bytes,
      contentType: downloaded.contentType,
    );
    await _localRepository.updateMessageLocalAudioPath(
      messageId: message.messageId,
      storedReference: storedReference,
    );

    if (!message.isMine && message.isDirectMessage) {
      unawaited(
        _withRetry<void>(
          (token) => _apiClient.acknowledgeMessageReceived(
            accessToken: token,
            messageId: message.messageId,
          ),
        ),
      );
    }

    final resolved = await _localRepository.resolveAudioPath(storedReference);
    return File(resolved!);
  }

  Future<ChatMessageItem?> transcribeMessage(ChatMessageItem message) async {
    final audioFile = await ensureLocalAudio(message);
    await _localRepository.updateMessageTranscript(
      messageId: message.messageId,
      transcriptText: message.localTranscriptText ?? '',
      transcriptLanguage:
          message.localTranscriptLanguage ?? message.spokenLanguageCode,
      transcriptLanguageCode:
          message.localTranscriptLanguageCode ?? message.spokenLanguageCode,
      status: 'processing',
    );

    try {
      final result = await VideoProcessingService.instance
          .transcribeRecordedAudio(
            inputFile: audioFile,
            localeIdentifier: message.spokenLanguageCode,
          );
      await _localRepository.updateMessageTranscript(
        messageId: message.messageId,
        transcriptText: result.transcriptText,
        transcriptLanguage: result.transcriptLanguage,
        transcriptLanguageCode: result.transcriptLanguageCode,
        status: 'ready',
      );
    } on VideoProcessingException catch (_) {
      await _localRepository.updateMessageTranscript(
        messageId: message.messageId,
        transcriptText: message.localTranscriptText ?? '',
        transcriptLanguage:
            message.localTranscriptLanguage ?? message.spokenLanguageCode,
        transcriptLanguageCode:
            message.localTranscriptLanguageCode ?? message.spokenLanguageCode,
        status: 'failed',
      );
      rethrow;
    }

    return _localRepository.getMessage(message.messageId);
  }

  Future<ChatMessageItem?> translateMessage(ChatMessageItem message) async {
    final source = (message.localTranscriptLanguageCode ?? '').trim();
    final transcript = (message.localTranscriptText ?? '').trim();
    if (source.isEmpty || transcript.isEmpty) {
      return null;
    }
    final target = (UserProfileNotifier.instance.nativeLanguage ?? '').trim();
    if (target.isEmpty || _localesEquivalent(source, target)) {
      return null;
    }

    await _localRepository.updateMessageTranslation(
      messageId: message.messageId,
      translationText: message.localTranslationText ?? '',
      translationLanguageCode: target,
      status: 'processing',
    );

    Future<Map<String, String>> doTranslate() {
      return TranslationService.instance.translateCues(
        sourceLocaleIdentifier: source,
        targetLocaleIdentifier: target,
        cues: [
          Cue(
            id: 'msg',
            startTimeMs: 0,
            endTimeMs: 0,
            originalText: transcript,
            translatedText: '',
          ),
        ],
      );
    }

    try {
      Map<String, String> result;
      try {
        result = await doTranslate();
      } on TranslationException catch (error) {
        if (error.code == 'translation_assets_not_installed') {
          await TranslationService.instance.prepareTranslationAssets(
            sourceLocaleIdentifier: source,
            targetLocaleIdentifier: target,
          );
          result = await doTranslate();
        } else {
          rethrow;
        }
      }

      final translated = (result['msg'] ?? '').trim();
      await _localRepository.updateMessageTranslation(
        messageId: message.messageId,
        translationText: translated,
        translationLanguageCode: target,
        status: translated.isEmpty ? 'failed' : 'ready',
      );
    } on TranslationException {
      await _localRepository.updateMessageTranslation(
        messageId: message.messageId,
        translationText: message.localTranslationText ?? '',
        translationLanguageCode: target,
        status: 'failed',
      );
      rethrow;
    }

    return _localRepository.getMessage(message.messageId);
  }

  Future<void> markThreadRead(String threadId) async {
    if (threadId.trim().isEmpty) {
      return;
    }

    await _localRepository.markThreadRead(threadId);
    try {
      await _withRetry<void>(
        (token) =>
            _apiClient.markThreadRead(accessToken: token, threadId: threadId),
      );
      await refreshBootstrap(showLoadingState: false);
    } on AuthApiException catch (error) {
      _authApiError = error;
      _plainErrorMessage = null;
      notifyListeners();
    }
  }

  Future<void> updateGlobalNotifications(bool enabled) async {
    await _withRetry<void>(
      (token) => _apiClient.updateGlobalNotifications(
        accessToken: token,
        enabled: enabled,
      ),
    );
    _globalNotificationsEnabled = enabled;
    SettingsNotifier.instance.toggleNotifications(enabled);
    if (enabled) {
      unawaited(_syncPushToken(promptForPermission: true));
      unawaited(_sendTestNotification());
    }
    notifyListeners();
  }

  Future<void> updateThreadNotifications({
    required String threadId,
    required bool enabled,
  }) async {
    final previousIsMuted = await _localRepository.threadMutedState(threadId);
    _updatingThreadNotificationIds.add(threadId);
    await _localRepository.updateThreadMutedState(
      threadId: threadId,
      isMuted: !enabled,
    );
    notifyListeners();

    try {
      await _withRetry<void>(
        (token) => _apiClient.updateThreadNotifications(
          accessToken: token,
          threadId: threadId,
          enabled: enabled,
        ),
      );
      await refreshBootstrap(showLoadingState: false);
    } on AuthApiException catch (error) {
      _authApiError = error;
      _plainErrorMessage = null;
      if (previousIsMuted != null) {
        await _localRepository.updateThreadMutedState(
          threadId: threadId,
          isMuted: previousIsMuted,
        );
      }
      rethrow;
    } catch (_) {
      if (previousIsMuted != null) {
        await _localRepository.updateThreadMutedState(
          threadId: threadId,
          isMuted: previousIsMuted,
        );
      }
      rethrow;
    } finally {
      _updatingThreadNotificationIds.remove(threadId);
      notifyListeners();
    }
  }

  Future<void> blockUser(String userId) async {
    await _withRetry<void>(
      (token) => _apiClient.blockUser(accessToken: token, otherUserId: userId),
    );
    await refreshBootstrap(showLoadingState: false);
    await refreshBlockedUsers();
  }

  Future<void> unblockUser(String userId) async {
    await _withRetry<void>(
      (token) =>
          _apiClient.unblockUser(accessToken: token, otherUserId: userId),
    );
    await refreshBootstrap(showLoadingState: false);
    await refreshBlockedUsers();
  }

  Future<void> deleteOwnMessage(ChatMessageItem message) async {
    if (!message.isMine) return;
    await _localRepository.deleteMessage(message.messageId);
    try {
      await _withRetry<void>(
        (token) => _apiClient.deleteOwnMessage(
          accessToken: token,
          messageId: message.messageId,
        ),
      );
      await refreshBootstrap(showLoadingState: false);
    } catch (_) {
      await refreshBootstrap(showLoadingState: false);
      rethrow;
    }
  }

  Future<void> deleteDirectMessageForSelf(String threadId) async {
    await _withRetry<void>(
      (token) => _apiClient.deleteDirectMessageForSelf(
        accessToken: token,
        threadId: threadId,
      ),
    );
    await refreshBootstrap(showLoadingState: false);
  }

  void registerActiveThread(String threadId) {
    if (threadId.trim().isEmpty) {
      return;
    }
    _activeThreadIds.add(threadId);
    unawaited(markThreadRead(threadId));
  }

  void unregisterActiveThread(String threadId) {
    _activeThreadIds.remove(threadId);
    _partnerRecordingByThread.remove(threadId);
    notifyListeners();
  }

  Future<void> sendRecordingEvent({
    required String threadId,
    required bool isRecording,
  }) async {
    await sendRealtimeEvent(
      isRecording ? 'dm.recording.started' : 'dm.recording.stopped',
      <String, Object?>{'threadId': threadId},
    );
  }

  Future<bool> sendRealtimeEvent(
    String type,
    Map<String, Object?> payload,
  ) async {
    final socket = _socket;
    if (socket == null || socket.readyState != WebSocket.open) {
      return false;
    }

    final raw = jsonEncode(<String, Object?>{'type': type, 'payload': payload});
    try {
      socket.add(raw);
      return true;
    } catch (_) {
      // Ignore transient websocket write failures.
      return false;
    }
  }

  Future<T> _withRetry<T>(Future<T> Function(String accessToken) action) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      throw const SessionExpiredException();
    }

    try {
      return await action(session.accessToken);
    } on AuthApiException catch (error) {
      if (error.code != 'token_expired') {
        rethrow;
      }

      final refreshed = await AuthSessionNotifier.instance
          .refreshAccessTokenForApi();
      if (refreshed == null) {
        throw const SessionExpiredException();
      }
      return action(refreshed);
    }
  }

  Future<void> _connectWebSocket() async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null || _socket != null || _socketSubscription != null) {
      return;
    }

    final socketUrl = _webSocketUrl();
    try {
      final socket = await WebSocket.connect(
        socketUrl,
        headers: <String, dynamic>{
          HttpHeaders.authorizationHeader: 'Bearer ${session.accessToken}',
        },
      );
      _socket = socket;
      _socketSubscription = socket.listen(
        _handleSocketMessage,
        onDone: _handleSocketClosed,
        onError: (_, _) {
          _handleSocketClosed();
        },
        cancelOnError: true,
      );
    } catch (_) {
      _handleSocketClosed();
    }
  }

  Future<void> _sendTestNotification() async {
    await _withRetry<void>(
      (token) => _apiClient.sendTestNotification(accessToken: token),
    );
  }

  Future<void> _syncPushToken({required bool promptForPermission}) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null || !_globalNotificationsEnabled) {
      return;
    }

    final token = promptForPermission
        ? await PushNotificationsService.instance
              .requestAuthorizationAndRegister()
        : await PushNotificationsService.instance.registerIfAuthorized();
    if (token == null || token.token.trim().isEmpty) {
      return;
    }
    const supportsCalls = true;
    final registrationKey = '${token.token}:$supportsCalls';
    if (_lastRegisteredPushTokenKey == registrationKey) {
      return;
    }

    try {
      await _withRetry<void>(
        (accessToken) => _apiClient.registerApnsToken(
          accessToken: accessToken,
          token: token.token,
          isSandbox: token.isSandbox,
          supportsCalls: supportsCalls,
        ),
      );
      _lastRegisteredPushTokenKey = registrationKey;
    } on AuthApiException {
      // Keep local state; next bootstrap or toggle can retry token sync.
    }
  }

  void _handleSocketMessage(dynamic event) {
    if (event is! String) {
      return;
    }

    try {
      final decoded = jsonDecode(event);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      final type = decoded['type']?.toString() ?? '';
      final payload = decoded['payload'];
      _realtimeEventsController.add(decoded);

      switch (type) {
        case 'ready':
        case 'presence.snapshot':
        case 'presence.changed':
          unawaited(refreshBootstrap(showLoadingState: false));
          break;
        case 'thread.updated':
          unawaited(refreshBootstrap(showLoadingState: false));
          final threadId = payload is Map
              ? payload['threadId']?.toString()
              : null;
          if (threadId != null && _activeThreadIds.contains(threadId)) {
            unawaited(loadMessages(threadId));
          }
          break;
        case 'message.created':
          final threadId = payload is Map
              ? payload['threadId']?.toString()
              : null;
          if (threadId != null && _activeThreadIds.contains(threadId)) {
            unawaited(loadMessages(threadId));
            unawaited(markThreadRead(threadId));
          }
          unawaited(refreshBootstrap(showLoadingState: false));
          break;
        case 'message.expired':
          final threadId = payload is Map
              ? payload['threadId']?.toString()
              : null;
          final messageId = payload is Map
              ? payload['messageId']?.toString()
              : null;
          if (messageId != null) {
            unawaited(_localRepository.markMessageExpired(messageId));
          }
          if (threadId != null && _activeThreadIds.contains(threadId)) {
            unawaited(loadMessages(threadId));
          }
          unawaited(refreshBootstrap(showLoadingState: false));
          break;
        case 'dm.recording.started':
          final threadId = payload is Map
              ? payload['threadId']?.toString() ?? ''
              : '';
          if (threadId.isNotEmpty) {
            _partnerRecordingByThread[threadId] = true;
            notifyListeners();
          }
          break;
        case 'dm.recording.stopped':
          final threadId = payload is Map
              ? payload['threadId']?.toString() ?? ''
              : '';
          if (threadId.isNotEmpty) {
            _partnerRecordingByThread[threadId] = false;
            notifyListeners();
          }
          break;
      }
    } catch (_) {
      // Ignore malformed socket payloads.
    }
  }

  void _handleSocketClosed() {
    _socketSubscription?.cancel();
    _socketSubscription = null;
    _socket = null;

    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      return;
    }
    _reconnectTimer ??= Timer(const Duration(seconds: 3), () {
      _reconnectTimer = null;
      unawaited(_connectWebSocket());
    });
  }

  String _webSocketUrl() {
    final baseUri = Uri.parse(AuthSessionNotifier.instance.apiBaseUrl);
    final scheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    return baseUri
        .replace(scheme: scheme, path: '/ws/chat', query: null, fragment: null)
        .toString();
  }

  void _handleAuthChanged() {
    final session = AuthSessionNotifier.instance.session;
    final previousAccessToken = _observedSession?.accessToken;
    final nextAccessToken = session?.accessToken;
    if (previousAccessToken == nextAccessToken) {
      return;
    }

    _observedSession = session;
    unawaited(_socketSubscription?.cancel());
    _socketSubscription = null;
    unawaited(_socket?.close());
    _socket = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _partnerRecordingByThread.clear();
    _lastRegisteredPushToken = null;

    if (session == null) {
      _ownerCacheKey = null;
      notifyListeners();
      return;
    }

    _ownerCacheKey = session.cacheKey;
    notifyListeners();
    unawaited(refreshBootstrap(showLoadingState: false));
  }
}

bool chatLocalesEquivalent(String first, String second) {
  final normalizedFirst = first.trim().toLowerCase();
  final normalizedSecond = second.trim().toLowerCase();
  if (normalizedFirst.isEmpty || normalizedSecond.isEmpty) {
    return false;
  }
  if (normalizedFirst == normalizedSecond) {
    return true;
  }
  final firstPrimary = normalizedFirst.split('-').first;
  final secondPrimary = normalizedSecond.split('-').first;
  return firstPrimary.isNotEmpty &&
      secondPrimary.isNotEmpty &&
      firstPrimary == secondPrimary;
}

bool _localesEquivalent(String first, String second) {
  return chatLocalesEquivalent(first, second);
}
