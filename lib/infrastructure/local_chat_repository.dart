import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/auth_session_notifier.dart';
import '../domain/models/chat_models.dart';
import 'local_chat_database.dart';

class LocalChatRepository {
  LocalChatRepository._();

  static final LocalChatRepository instance = LocalChatRepository._();

  final LocalChatDatabase _database = LocalChatDatabase.instance;

  String? get _currentOwnerCacheKey {
    final normalized = AuthSessionNotifier.instance.session?.cacheKey.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  Stream<List<ChatThreadSummary>> watchGroups() {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return Stream.value(const <ChatThreadSummary>[]);
    }

    final query = (_database.select(_database.chatThreadEntries)
      ..where((table) => table.ownerCacheKey.equals(ownerKey))
      ..where((table) => table.section.equals('group'))
      ..orderBy([
        (table) => drift.OrderingTerm.asc(table.sectionOrder),
        (table) => drift.OrderingTerm.desc(table.lastMessageAtMillis),
      ]));
    return query.watch().map((rows) => rows.map(_threadFromRow).toList());
  }

  Stream<List<ChatThreadSummary>> watchDirectMessages() {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return Stream.value(const <ChatThreadSummary>[]);
    }

    final query = (_database.select(_database.chatThreadEntries)
      ..where((table) => table.ownerCacheKey.equals(ownerKey))
      ..where((table) => table.section.equals('dm'))
      ..orderBy([
        (table) => drift.OrderingTerm.desc(table.lastMessageAtMillis),
        (table) => drift.OrderingTerm.asc(table.sectionOrder),
      ]));
    return query.watch().map((rows) => rows.map(_threadFromRow).toList());
  }

  Stream<List<ChatUserSummary>> watchOnlineUsers() {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return Stream.value(const <ChatUserSummary>[]);
    }

    final query = (_database.select(_database.chatUserEntries)
      ..where((table) => table.ownerCacheKey.equals(ownerKey))
      ..where((table) => table.isOnline.equals(true))
      ..orderBy([(table) => drift.OrderingTerm.asc(table.name)]));
    return query.watch().map((rows) => rows.map(_userFromRow).toList());
  }

  Stream<List<ChatUserSummary>> watchBlockedUsers() {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return Stream.value(const <ChatUserSummary>[]);
    }

    final query = (_database.select(_database.chatBlockEntries)
      ..where((table) => table.ownerCacheKey.equals(ownerKey))
      ..orderBy([(table) => drift.OrderingTerm.asc(table.name)]));
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ChatUserSummary(
              id: row.userId,
              name: row.name,
              avatarUrl: row.avatarUrl,
              learningLanguage: row.learningLanguage,
              learningLanguageDisplay: row.learningLanguageDisplay,
              nativeLanguage: row.nativeLanguage,
              nativeLanguageDisplay: row.nativeLanguageDisplay,
              isOnline: row.isOnline,
            ),
          )
          .toList(),
    );
  }

  Stream<List<ChatMessageItem>> watchMessages(String threadId) {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null || threadId.trim().isEmpty) {
      return Stream.value(const <ChatMessageItem>[]);
    }

    final query = (_database.select(_database.chatMessageEntries)
      ..where((table) => table.ownerCacheKey.equals(ownerKey))
      ..where((table) => table.threadId.equals(threadId))
      ..where((table) => table.isServerVisible.equals(true))
      ..orderBy([(table) => drift.OrderingTerm.asc(table.createdAtMillis)]));
    return query.watch().map((rows) => rows.map(_messageFromRow).toList());
  }

  Future<void> replaceBootstrap({
    required String ownerCacheKey,
    required ChatBootstrap bootstrap,
  }) async {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction(() async {
      await (_database.delete(
        _database.chatThreadEntries,
      )..where((table) => table.ownerCacheKey.equals(ownerCacheKey))).go();
      await (_database.delete(
        _database.chatUserEntries,
      )..where((table) => table.ownerCacheKey.equals(ownerCacheKey))).go();

      final allThreads = <ChatThreadSummary>[
        ...bootstrap.groups,
        ...bootstrap.directMessages,
      ];
      for (final thread in allThreads) {
        await _database
            .into(_database.chatThreadEntries)
            .insertOnConflictUpdate(
              ChatThreadEntriesCompanion.insert(
                ownerCacheKey: ownerCacheKey,
                threadId: thread.threadId,
                threadType: thread.threadType,
                title: thread.title,
                avatarUrl: drift.Value(thread.avatarUrl),
                learningLanguage: drift.Value(thread.learningLanguage),
                learningLanguageDisplay: drift.Value(
                  thread.learningLanguageDisplay,
                ),
                nativeLanguage: drift.Value(thread.nativeLanguage),
                nativeLanguageDisplay: drift.Value(
                  thread.nativeLanguageDisplay,
                ),
                isMuted: drift.Value(thread.isMuted),
                unreadCount: drift.Value(thread.unreadCount),
                lastMessageAtMillis: drift.Value(
                  thread.lastMessageAt?.millisecondsSinceEpoch,
                ),
                lastMessageDurationMs: drift.Value(
                  thread.lastMessageDurationMs,
                ),
                otherUserId: drift.Value(thread.otherUser?.id),
                roleBadgesJson: drift.Value(jsonEncode(thread.roleBadges)),
                section: thread.section,
                sectionOrder: drift.Value(thread.sectionOrder),
                updatedAtMillis: nowMillis,
              ),
            );
      }

      final users = <String, ChatUserSummary>{};
      for (final user in bootstrap.onlineUsers) {
        users[user.id] = user;
      }
      for (final thread in bootstrap.directMessages) {
        final otherUser = thread.otherUser;
        if (otherUser != null) {
          users[otherUser.id] = otherUser;
        }
      }

      for (final user in users.values) {
        await _database
            .into(_database.chatUserEntries)
            .insertOnConflictUpdate(
              ChatUserEntriesCompanion.insert(
                ownerCacheKey: ownerCacheKey,
                userId: user.id,
                name: user.name,
                avatarUrl: drift.Value(user.avatarUrl),
                learningLanguage: drift.Value(user.learningLanguage),
                learningLanguageDisplay: drift.Value(
                  user.learningLanguageDisplay,
                ),
                nativeLanguage: drift.Value(user.nativeLanguage),
                nativeLanguageDisplay: drift.Value(user.nativeLanguageDisplay),
                isOnline: drift.Value(user.isOnline),
                updatedAtMillis: nowMillis,
              ),
            );
      }
    });
  }

  Future<void> replaceBlockedUsers({
    required String ownerCacheKey,
    required List<ChatUserSummary> users,
  }) async {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction(() async {
      await (_database.delete(
        _database.chatBlockEntries,
      )..where((table) => table.ownerCacheKey.equals(ownerCacheKey))).go();

      for (final user in users) {
        await _database
            .into(_database.chatBlockEntries)
            .insert(
              ChatBlockEntriesCompanion.insert(
                ownerCacheKey: ownerCacheKey,
                userId: user.id,
                name: user.name,
                avatarUrl: drift.Value(user.avatarUrl),
                learningLanguage: drift.Value(user.learningLanguage),
                learningLanguageDisplay: drift.Value(
                  user.learningLanguageDisplay,
                ),
                nativeLanguage: drift.Value(user.nativeLanguage),
                nativeLanguageDisplay: drift.Value(user.nativeLanguageDisplay),
                isOnline: drift.Value(user.isOnline),
                updatedAtMillis: nowMillis,
              ),
            );
      }
    });
  }

  Future<void> replaceMessages({
    required String ownerCacheKey,
    required String threadId,
    required List<ChatMessageItem> messages,
  }) async {
    final existingRows =
        await (_database.select(_database.chatMessageEntries)
              ..where((table) => table.ownerCacheKey.equals(ownerCacheKey))
              ..where((table) => table.threadId.equals(threadId)))
            .get();
    final existingById = {for (final row in existingRows) row.messageId: row};
    final nowMillis = DateTime.now().millisecondsSinceEpoch;

    await _database.transaction(() async {
      await (_database.update(_database.chatMessageEntries)
            ..where((table) => table.ownerCacheKey.equals(ownerCacheKey))
            ..where((table) => table.threadId.equals(threadId)))
          .write(
            const ChatMessageEntriesCompanion(
              isServerVisible: drift.Value(false),
            ),
          );

      for (final message in messages) {
        final previous = existingById[message.messageId];
        await _database
            .into(_database.chatMessageEntries)
            .insertOnConflictUpdate(
              ChatMessageEntriesCompanion.insert(
                ownerCacheKey: ownerCacheKey,
                messageId: message.messageId,
                threadId: message.threadId,
                threadType: message.threadType,
                senderUserId: message.senderUser.id,
                senderName: message.senderUser.name,
                senderAvatarUrl: drift.Value(message.senderUser.avatarUrl),
                senderLearningLanguage: drift.Value(
                  message.senderUser.learningLanguage,
                ),
                senderLearningLanguageDisplay: drift.Value(
                  message.senderUser.learningLanguageDisplay,
                ),
                senderNativeLanguage: drift.Value(
                  message.senderUser.nativeLanguage,
                ),
                senderNativeLanguageDisplay: drift.Value(
                  message.senderUser.nativeLanguageDisplay,
                ),
                senderIsOnline: drift.Value(message.senderUser.isOnline),
                spokenLanguageCode: message.spokenLanguageCode,
                durationMs: message.durationMs,
                createdAtMillis: message.createdAt.millisecondsSinceEpoch,
                expiresAtMillis: drift.Value(
                  message.expiresAt?.millisecondsSinceEpoch,
                ),
                isMine: drift.Value(message.isMine),
                audioUrl: message.audioUrl,
                localAudioPath: drift.Value(
                  previous?.localAudioPath ?? message.localAudioPath,
                ),
                localTranscriptText: drift.Value(
                  previous?.localTranscriptText ?? message.localTranscriptText,
                ),
                localTranscriptStatus: drift.Value(
                  previous?.localTranscriptStatus ??
                      message.localTranscriptStatus,
                ),
                localTranscriptLanguage: drift.Value(
                  previous?.localTranscriptLanguage ??
                      message.localTranscriptLanguage,
                ),
                localTranscriptLanguageCode: drift.Value(
                  previous?.localTranscriptLanguageCode ??
                      message.localTranscriptLanguageCode,
                ),
                isServerVisible: const drift.Value(true),
                updatedAtMillis: nowMillis,
              ),
            );
      }
    });
  }

  Future<ChatMessageItem?> getMessage(String messageId) async {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return null;
    }

    final row =
        await (_database.select(_database.chatMessageEntries)
              ..where((table) => table.ownerCacheKey.equals(ownerKey))
              ..where((table) => table.messageId.equals(messageId)))
            .getSingleOrNull();
    return row == null ? null : _messageFromRow(row);
  }

  Future<void> markMessageExpired(String messageId) async {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return;
    }

    await (_database.update(_database.chatMessageEntries)
          ..where((table) => table.ownerCacheKey.equals(ownerKey))
          ..where((table) => table.messageId.equals(messageId)))
        .write(
          ChatMessageEntriesCompanion(
            isServerVisible: const drift.Value(false),
            updatedAtMillis: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<void> updateMessageLocalAudioPath({
    required String messageId,
    required String storedReference,
  }) async {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return;
    }

    await (_database.update(_database.chatMessageEntries)
          ..where((table) => table.ownerCacheKey.equals(ownerKey))
          ..where((table) => table.messageId.equals(messageId)))
        .write(
          ChatMessageEntriesCompanion(
            localAudioPath: drift.Value(storedReference),
            updatedAtMillis: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<void> updateMessageTranscript({
    required String messageId,
    required String transcriptText,
    required String transcriptLanguage,
    required String transcriptLanguageCode,
    required String status,
  }) async {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return;
    }

    await (_database.update(_database.chatMessageEntries)
          ..where((table) => table.ownerCacheKey.equals(ownerKey))
          ..where((table) => table.messageId.equals(messageId)))
        .write(
          ChatMessageEntriesCompanion(
            localTranscriptText: drift.Value(transcriptText),
            localTranscriptLanguage: drift.Value(transcriptLanguage),
            localTranscriptLanguageCode: drift.Value(transcriptLanguageCode),
            localTranscriptStatus: drift.Value(status),
            updatedAtMillis: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<void> updateThreadMutedState({
    required String threadId,
    required bool isMuted,
  }) async {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return;
    }

    await (_database.update(_database.chatThreadEntries)
          ..where((table) => table.ownerCacheKey.equals(ownerKey))
          ..where((table) => table.threadId.equals(threadId)))
        .write(
          ChatThreadEntriesCompanion(
            isMuted: drift.Value(isMuted),
            updatedAtMillis: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<void> markThreadRead(String threadId) async {
    final ownerKey = _currentOwnerCacheKey;
    if (ownerKey == null) {
      return;
    }

    await (_database.update(_database.chatThreadEntries)
          ..where((table) => table.ownerCacheKey.equals(ownerKey))
          ..where((table) => table.threadId.equals(threadId)))
        .write(
          ChatThreadEntriesCompanion(
            unreadCount: const drift.Value(0),
            updatedAtMillis: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<String> storeAudioBytes({
    required String messageId,
    required List<int> bytes,
    required String contentType,
  }) async {
    final ownerKey = _currentOwnerCacheKey ?? 'anonymous';
    final directory = await _chatAudioDirectory(ownerKey);
    await directory.create(recursive: true);
    final extension = _audioExtensionForContentType(contentType);
    final file = File(p.join(directory.path, '$messageId.$extension'));
    await file.writeAsBytes(bytes, flush: true);
    return _storedReferenceForPath(file.path);
  }

  Future<String?> resolveAudioPath(String? storedReference) async {
    final normalizedReference = p.normalize((storedReference ?? '').trim());
    if (normalizedReference.isEmpty) {
      return null;
    }

    if (!p.isAbsolute(normalizedReference)) {
      final supportDirectory = await getApplicationSupportDirectory();
      final absolute = p.normalize(
        p.join(supportDirectory.path, normalizedReference),
      );
      return absolute;
    }

    if (File(normalizedReference).existsSync()) {
      return normalizedReference;
    }

    final supportDirectory = await getApplicationSupportDirectory();
    final marker = '${p.separator}chat_audio${p.separator}';
    final markerIndex = normalizedReference.indexOf(marker);
    if (markerIndex < 0) {
      return normalizedReference;
    }

    final suffix = normalizedReference.substring(markerIndex + marker.length);
    return p.normalize(p.join(supportDirectory.path, 'chat_audio', suffix));
  }

  ChatThreadSummary _threadFromRow(ChatThreadEntry row) {
    final roleBadges = _decodeRoleBadges(row.roleBadgesJson);
    final otherUser = row.otherUserId == null || row.otherUserId!.trim().isEmpty
        ? null
        : ChatUserSummary(
            id: row.otherUserId!,
            name: row.title,
            avatarUrl: row.avatarUrl,
            learningLanguage: row.learningLanguage,
            learningLanguageDisplay: row.learningLanguageDisplay,
            nativeLanguage: row.nativeLanguage,
            nativeLanguageDisplay: row.nativeLanguageDisplay,
            isOnline: false,
          );
    return ChatThreadSummary(
      threadId: row.threadId,
      threadType: row.threadType,
      title: row.title,
      avatarUrl: row.avatarUrl,
      learningLanguage: row.learningLanguage,
      learningLanguageDisplay: row.learningLanguageDisplay,
      nativeLanguage: row.nativeLanguage,
      nativeLanguageDisplay: row.nativeLanguageDisplay,
      isMuted: row.isMuted,
      unreadCount: row.unreadCount,
      lastMessageAt: row.lastMessageAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.lastMessageAtMillis!),
      lastMessageDurationMs: row.lastMessageDurationMs,
      otherUser: otherUser,
      roleBadges: roleBadges,
      section: row.section,
      sectionOrder: row.sectionOrder,
    );
  }

  ChatUserSummary _userFromRow(ChatUserEntry row) {
    return ChatUserSummary(
      id: row.userId,
      name: row.name,
      avatarUrl: row.avatarUrl,
      learningLanguage: row.learningLanguage,
      learningLanguageDisplay: row.learningLanguageDisplay,
      nativeLanguage: row.nativeLanguage,
      nativeLanguageDisplay: row.nativeLanguageDisplay,
      isOnline: row.isOnline,
    );
  }

  ChatMessageItem _messageFromRow(ChatMessageEntry row) {
    return ChatMessageItem(
      messageId: row.messageId,
      threadId: row.threadId,
      threadType: row.threadType,
      senderUser: ChatUserSummary(
        id: row.senderUserId,
        name: row.senderName,
        avatarUrl: row.senderAvatarUrl,
        learningLanguage: row.senderLearningLanguage,
        learningLanguageDisplay: row.senderLearningLanguageDisplay,
        nativeLanguage: row.senderNativeLanguage,
        nativeLanguageDisplay: row.senderNativeLanguageDisplay,
        isOnline: row.senderIsOnline,
      ),
      spokenLanguageCode: row.spokenLanguageCode,
      durationMs: row.durationMs,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMillis),
      expiresAt: row.expiresAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.expiresAtMillis!),
      isMine: row.isMine,
      audioUrl: row.audioUrl,
      localAudioPath: row.localAudioPath,
      localTranscriptText: row.localTranscriptText,
      localTranscriptStatus: row.localTranscriptStatus,
      localTranscriptLanguage: row.localTranscriptLanguage,
      localTranscriptLanguageCode: row.localTranscriptLanguageCode,
      isServerVisible: row.isServerVisible,
    );
  }

  List<String> _decodeRoleBadges(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((item) => item.toString()).toList();
      }
    } catch (_) {
      // Ignore malformed cache rows.
    }
    return const <String>[];
  }

  Future<Directory> _chatAudioDirectory(String ownerKey) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final safeOwner = ownerKey.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return Directory(p.join(supportDirectory.path, 'chat_audio', safeOwner));
  }

  Future<String> _storedReferenceForPath(String absolutePath) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final normalizedAbsolute = p.normalize(absolutePath);
    final normalizedSupport = p.normalize(supportDirectory.path);
    if (p.isWithin(normalizedSupport, normalizedAbsolute)) {
      return p.relative(normalizedAbsolute, from: normalizedSupport);
    }
    return normalizedAbsolute;
  }

  static String _audioExtensionForContentType(String contentType) {
    final normalized = contentType.trim().toLowerCase();
    return switch (normalized) {
      'audio/aac' => 'aac',
      'audio/mpeg' => 'mp3',
      'audio/wav' || 'audio/x-wav' => 'wav',
      'audio/webm' => 'webm',
      'audio/ogg' => 'ogg',
      _ => 'm4a',
    };
  }
}
