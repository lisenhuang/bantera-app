import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../domain/models/chat_models.dart';
import '../domain/models/models.dart';
import '../infrastructure/auth_api_client.dart';
import '../infrastructure/chat_api_client.dart';
import '../infrastructure/callkit_service.dart';
import '../infrastructure/local_chat_repository.dart';
import '../infrastructure/push_notifications_service.dart';
import '../infrastructure/translation_service.dart';
import '../infrastructure/video_processing_service.dart';
import 'app_resume_notifier.dart';
import 'auth_api_error_localizations.dart';
import 'auth_session_notifier.dart';
import 'settings_notifier.dart';
import 'user_profile_notifier.dart';

class ChatSessionNotifier extends ChangeNotifier {
  ChatSessionNotifier._() {
    AuthSessionNotifier.instance.addListener(_handleAuthChanged);
    AppResumeNotifier.instance.addListener(_handleAppResumed);
    CallKitService.instance.tokenChanges.addListener(_voipTokenChanged);
    CallKitService.instance.events.listen((event) {
      if (event['event'] == 'tokenInvalidated') {
        final token = event['token']?.toString();
        if (token != null &&
            token.isNotEmpty &&
            AuthSessionNotifier.instance.isAuthenticated) {
          unawaited(
            _withRetry<void>(
              (access) => _apiClient.unregisterVoipToken(access, token),
            ).catchError((Object _) {}),
          );
        }
      }
    });
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
  Future<void>? _connecting;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _reconnectTimer;
  bool _isLoading = false;
  bool _isRefreshingMessages = false;
  bool _globalNotificationsEnabled = true;
  String? _plainErrorMessage;
  AuthApiException? _authApiError;
  String? _ownerCacheKey;
  String? _lastRegisteredPushTokenKey;
  String? _lastRegisteredVoipTokenKey;
  Future<void>? _voipSync;
  final Map<String, Future<File>> _audioDownloads = {};
  final Map<String, String> _pendingDmSync = {};
  bool _isSyncingDmAudio = false;
  int _cacheEpoch = 0;
  final Set<String> _deletedMessageIds = {};

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
      if (AuthSessionNotifier.instance.session?.cacheKey != session.cacheKey) {
        return;
      }
      if (bootstrap.deletedMessageIds.any(
        (id) => !_deletedMessageIds.contains(id),
      )) {
        _cacheEpoch++;
      }
      _deletedMessageIds.addAll(bootstrap.deletedMessageIds);
      for (final id in bootstrap.deletedMessageIds) {
        await _localRepository.deleteMessage(
          id,
          ownerCacheKey: session.cacheKey,
        );
      }
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
      if (AuthSessionNotifier.instance.session?.cacheKey == session.cacheKey) {
        _queueDmSync(
          bootstrap.directMessages.map((thread) => thread.threadId),
          session.cacheKey,
        );
      }
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

    final cacheEpoch = _cacheEpoch;
    _isRefreshingMessages = true;
    notifyListeners();
    try {
      final messages = await _withRetry(
        (token) =>
            _apiClient.fetchMessages(accessToken: token, threadId: threadId),
      );
      if (AuthSessionNotifier.instance.session?.cacheKey != session.cacheKey ||
          cacheEpoch != _cacheEpoch) {
        return;
      }
      await _localRepository.replaceMessages(
        ownerCacheKey: session.cacheKey,
        threadId: threadId,
        messages: messages
            .where((m) => !_deletedMessageIds.contains(m.messageId))
            .toList(),
        replaceServerSnapshot: messages.length < 100,
      );
      if (messages.any((message) => message.isDirectMessage)) {
        _queueDmSync([threadId], session.cacheKey);
      }
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
    final owner = AuthSessionNotifier.instance.session?.cacheKey;
    if (owner == null) throw const SessionExpiredException();
    final savedAudio = await _localRepository.storeAudioBytes(
      messageId: 'outgoing-${DateTime.now().microsecondsSinceEpoch}',
      bytes: await audioFile.readAsBytes(),
      contentType: 'audio/mp4',
      ownerCacheKey: owner,
    );
    if (AuthSessionNotifier.instance.session?.cacheKey != owner) {
      throw const SessionExpiredException();
    }
    final message = await _withRetry(
      (token) => _apiClient.sendDirectMessageAudio(
        accessToken: token,
        otherUserId: otherUserId,
        audioFile: audioFile,
        durationMs: durationMs,
      ),
    );
    await _localRepository.replaceMessages(
      ownerCacheKey: owner,
      threadId: message.threadId,
      messages: [message],
      replaceServerSnapshot: false,
    );
    await _localRepository.updateMessageLocalAudioPath(
      messageId: message.messageId,
      storedReference: savedAudio,
      ownerCacheKey: owner,
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

  void _queueDmSync(Iterable<String> threadIds, String owner) {
    for (final threadId in threadIds) {
      _pendingDmSync[threadId] = owner;
    }
    if (!_isSyncingDmAudio) unawaited(_syncDmAudio());
  }

  Future<void> _syncDmAudio() async {
    _isSyncingDmAudio = true;
    try {
      while (_pendingDmSync.isNotEmpty) {
        final entry = _pendingDmSync.entries.first;
        final threadId = entry.key;
        final owner = entry.value;
        final cacheEpoch = _cacheEpoch;
        _pendingDmSync.remove(threadId);
        try {
          var offset = 0;
          while (AuthSessionNotifier.instance.session?.cacheKey == owner &&
              cacheEpoch == _cacheEpoch) {
            final messages = await _withRetry(
              (token) => _apiClient.fetchMessages(
                accessToken: token,
                threadId: threadId,
                offset: offset,
              ),
            );
            if (AuthSessionNotifier.instance.session?.cacheKey != owner ||
                cacheEpoch != _cacheEpoch) {
              break;
            }
            await _localRepository.replaceMessages(
              ownerCacheKey: owner,
              threadId: threadId,
              messages: messages
                  .where((m) => !_deletedMessageIds.contains(m.messageId))
                  .toList(),
              replaceServerSnapshot: false,
            );
            for (final message in messages.where((m) => m.isDirectMessage)) {
              if (AuthSessionNotifier.instance.session?.cacheKey != owner ||
                  cacheEpoch != _cacheEpoch) {
                break;
              }
              if (_deletedMessageIds.contains(message.messageId)) continue;
              try {
                await ensureLocalAudio(message);
              } catch (error) {
                debugPrint(
                  '[ChatCache] Download deferred: ${error.runtimeType}',
                );
              }
            }
            if (messages.length < 100) break;
            offset += messages.length;
          }
        } catch (error) {
          debugPrint('[ChatCache] Sync deferred: ${error.runtimeType}');
        }
      }
    } finally {
      _isSyncingDmAudio = false;
    }
  }

  Future<File> ensureLocalAudio(ChatMessageItem message) async {
    final owner = AuthSessionNotifier.instance.session?.cacheKey;
    if (owner == null) throw const SessionExpiredException();
    if (_deletedMessageIds.contains(message.messageId)) {
      throw const AuthApiException(
        code: 'chat_not_found',
        message: 'This message was deleted.',
      );
    }
    final key = '$owner:${message.messageId}';
    final existing = _audioDownloads[key];
    if (existing != null) return existing;
    final task = _downloadAndCacheAudio(message, owner);
    _audioDownloads[key] = task;
    try {
      return await task;
    } finally {
      _audioDownloads.remove(key);
    }
  }

  Future<File> _downloadAndCacheAudio(
    ChatMessageItem message,
    String owner,
  ) async {
    final current = await _localRepository.getMessage(
      message.messageId,
      ownerCacheKey: owner,
    );
    final existingPath = await _localRepository.resolveAudioPath(
      current?.localAudioPath ?? message.localAudioPath,
    );
    File? file;
    if (existingPath != null && await File(existingPath).exists()) {
      file = File(existingPath);
    }
    if (file == null) {
      if (AuthSessionNotifier.instance.session?.cacheKey != owner) {
        throw const SessionExpiredException();
      }
      final downloaded = await _withRetry(
        (token) => _apiClient.downloadMessageAudio(
          accessToken: token,
          messageId: message.messageId,
        ),
      );
      if (AuthSessionNotifier.instance.session?.cacheKey != owner) {
        throw const SessionExpiredException();
      }
      if (_deletedMessageIds.contains(message.messageId)) {
        throw const AuthApiException(
          code: 'chat_not_found',
          message: 'This message was deleted.',
        );
      }
      final storedReference = await _localRepository.storeAudioBytes(
        messageId: message.messageId,
        bytes: downloaded.bytes,
        contentType: downloaded.contentType,
        ownerCacheKey: owner,
      );
      if (_deletedMessageIds.contains(message.messageId)) {
        final path = await _localRepository.resolveAudioPath(storedReference);
        if (path != null) {
          try {
            await File(path).delete();
          } on FileSystemException {
            /* Already removed. */
          }
        }
        throw const AuthApiException(
          code: 'chat_not_found',
          message: 'This message was deleted.',
        );
      }
      await _localRepository.updateMessageLocalAudioPath(
        messageId: message.messageId,
        storedReference: storedReference,
        ownerCacheKey: owner,
      );
      file = File((await _localRepository.resolveAudioPath(storedReference))!);
    }
    // Acknowledge only after durable storage. Retry a failed receipt even when
    // the file was already cached on an earlier pass.
    if (!message.isMine &&
        message.isDirectMessage &&
        message.expiresAt == null &&
        AuthSessionNotifier.instance.session?.cacheKey == owner) {
      try {
        await _withRetry<void>(
          (token) => _apiClient.acknowledgeMessageReceived(
            accessToken: token,
            messageId: message.messageId,
          ),
        );
      } catch (error) {
        debugPrint('[ChatCache] Receipt deferred: ${error.runtimeType}');
      }
    }
    if (AuthSessionNotifier.instance.session?.cacheKey != owner) {
      throw const SessionExpiredException();
    }
    return file;
  }

  Future<ChatMessageItem?> transcribeMessage(ChatMessageItem message) async {
    final audioFile = await ensureLocalAudio(message);
    // Clear any stale translation so it doesn't mismatch the new transcript.
    if (message.localTranscriptStatus == 'ready') {
      await _localRepository.updateMessageTranslation(
        messageId: message.messageId,
        translationText: '',
        translationLanguageCode: '',
        status: '',
      );
    }
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
            // Chat DMs / group messages use the default (auto-corrected) level so
            // the reader can understand what the other person said. Unlike the
            // practice flow, we are not surfacing pronunciation mistakes here.
            allowAutoCorrection: true,
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
      await _syncPushToken(promptForPermission: true);
      // Register first so a newly authorized device receives the test alert.
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
    _cacheEpoch++;
    _deletedMessageIds.add(message.messageId);
    await _localRepository.deleteMessage(message.messageId);
    try {
      await _withRetry<void>(
        (token) => _apiClient.deleteOwnMessage(
          accessToken: token,
          messageId: message.messageId,
        ),
      );
      await refreshBootstrap(showLoadingState: false);
    } on AuthApiException catch (error) {
      await refreshBootstrap(showLoadingState: false);
      if (error.code != 'chat_not_found') {
        _deletedMessageIds.remove(message.messageId);
        rethrow;
      }
    }
  }

  Future<void> deleteDirectMessageForSelf(String threadId) async {
    await _withRetry<void>(
      (token) => _apiClient.deleteDirectMessageForSelf(
        accessToken: token,
        threadId: threadId,
      ),
    );
    _cacheEpoch++;
    _pendingDmSync.remove(threadId);
    await _localRepository.deleteLocalThread(threadId);
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
    if (_connecting != null) return _connecting;
    final task = _openWebSocket();
    _connecting = task;
    try {
      await task;
    } finally {
      _connecting = null;
    }
  }

  Future<void> _openWebSocket() async {
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
      if (AuthSessionNotifier.instance.session?.accessToken !=
          session.accessToken) {
        await socket.close();
        return;
      }
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

  void _handleAppResumed() {
    // Permission may have changed in iOS Settings while the app was away.
    unawaited(_syncPushToken(promptForPermission: false));
    unawaited(refreshBootstrap(showLoadingState: false));
  }

  Future<void> _syncPushToken({required bool promptForPermission}) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null || !_globalNotificationsEnabled) {
      return;
    }

    try {
      final token =
          await (promptForPermission
                  ? PushNotificationsService.instance
                        .requestAuthorizationAndRegister()
                  : PushNotificationsService.instance.registerIfAuthorized())
              .timeout(const Duration(seconds: 20));
      if (token == null ||
          token.token.trim().isEmpty ||
          AuthSessionNotifier.instance.session?.cacheKey != session.cacheKey ||
          !_globalNotificationsEnabled) {
        return;
      }
      const supportsCalls = true;
      final registrationKey =
          '${session.cacheKey}:${token.token}:${token.isSandbox}:$supportsCalls';
      if (_lastRegisteredPushTokenKey == registrationKey) {
        return;
      }

      await _withRetry<void>(
        (accessToken) => _apiClient.registerApnsToken(
          accessToken: accessToken,
          token: token.token,
          isSandbox: token.isSandbox,
          supportsCalls: supportsCalls,
        ),
      );
      if (AuthSessionNotifier.instance.session?.cacheKey == session.cacheKey) {
        _lastRegisteredPushTokenKey = registrationKey;
      }
    } catch (error) {
      // Native permission/registration failures must not become unhandled
      // background errors. Retry on the next bootstrap, resume, or toggle.
      debugPrint('[ChatPush] Token registration failed: ${error.runtimeType}');
    } finally {
      await _syncVoipToken();
    }
  }

  void _voipTokenChanged() {
    unawaited(_syncVoipToken());
  }

  Future<void> _syncVoipToken() async {
    if (_voipSync != null) return _voipSync;
    final task = _registerVoipToken();
    _voipSync = task;
    try {
      await task;
    } finally {
      _voipSync = null;
    }
  }

  Future<void> _registerVoipToken() async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null || !_globalNotificationsEnabled) return;
    try {
      final token = await CallKitService.instance.token();
      if (token == null) return;
      final alert = await PushNotificationsService.instance.getCachedToken();
      final key =
          '${session.cacheKey}:${token.token}:${token.isSandbox}:${alert?.token}';
      if (key == _lastRegisteredVoipTokenKey) return;
      if (AuthSessionNotifier.instance.session?.cacheKey != session.cacheKey) {
        return;
      }
      await _withRetry<void>(
        (accessToken) => _apiClient.registerVoipToken(
          accessToken: accessToken,
          token: token.token,
          isSandbox: token.isSandbox,
          alertToken: alert?.token,
        ),
      );
      if (AuthSessionNotifier.instance.session?.cacheKey == session.cacheKey) {
        _lastRegisteredVoipTokenKey = key;
      }
    } catch (error) {
      debugPrint('[CallKit] Registration failed: ${error.runtimeType}');
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

    if (_observedSession?.cacheKey != session?.cacheKey) {
      _cacheEpoch++;
      _pendingDmSync.clear();
      _deletedMessageIds.clear();
    }
    _observedSession = session;
    unawaited(_socketSubscription?.cancel());
    _socketSubscription = null;
    unawaited(_socket?.close());
    _socket = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _partnerRecordingByThread.clear();
    _lastRegisteredPushTokenKey = null;
    _lastRegisteredVoipTokenKey = null;

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
