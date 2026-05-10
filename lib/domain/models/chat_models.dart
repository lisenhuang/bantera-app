class ChatUserSummary {
  const ChatUserSummary({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.learningLanguage,
    required this.learningLanguageDisplay,
    required this.nativeLanguage,
    required this.nativeLanguageDisplay,
    required this.isOnline,
  });

  factory ChatUserSummary.fromJson(Map<String, dynamic> json) {
    return ChatUserSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Bantera user',
      avatarUrl: json['avatarUrl']?.toString(),
      learningLanguage: json['learningLanguage']?.toString(),
      learningLanguageDisplay: json['learningLanguageDisplay']?.toString(),
      nativeLanguage: json['nativeLanguage']?.toString(),
      nativeLanguageDisplay: json['nativeLanguageDisplay']?.toString(),
      isOnline: json['isOnline'] == true,
    );
  }

  final String id;
  final String name;
  final String? avatarUrl;
  final String? learningLanguage;
  final String? learningLanguageDisplay;
  final String? nativeLanguage;
  final String? nativeLanguageDisplay;
  final bool isOnline;
}

class ChatIceServersConfig {
  const ChatIceServersConfig({required this.iceServers});

  factory ChatIceServersConfig.fromJson(Map<String, dynamic> json) {
    final servers = (json['iceServers'] as List?) ?? const [];
    return ChatIceServersConfig(
      iceServers: servers
          .whereType<Map>()
          .map(
            (server) => ChatIceServerEntry.fromJson(
              server.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
    );
  }

  final List<ChatIceServerEntry> iceServers;
}

class ChatIceServerEntry {
  const ChatIceServerEntry({
    required this.urls,
    required this.username,
    required this.credential,
  });

  factory ChatIceServerEntry.fromJson(Map<String, dynamic> json) {
    return ChatIceServerEntry(
      urls: ((json['urls'] as List?) ?? const [])
          .map((url) => url.toString())
          .where((url) => url.trim().isNotEmpty)
          .toList(),
      username: json['username']?.toString(),
      credential: json['credential']?.toString(),
    );
  }

  final List<String> urls;
  final String? username;
  final String? credential;
}

class ChatMessageItem {
  const ChatMessageItem({
    required this.messageId,
    required this.threadId,
    required this.threadType,
    required this.senderUser,
    required this.spokenLanguageCode,
    required this.durationMs,
    required this.createdAt,
    required this.expiresAt,
    required this.isMine,
    required this.audioUrl,
    required this.localAudioPath,
    required this.localTranscriptText,
    required this.localTranscriptStatus,
    required this.localTranscriptLanguage,
    required this.localTranscriptLanguageCode,
    required this.localTranslationText,
    required this.localTranslationStatus,
    required this.localTranslationLanguageCode,
    required this.isServerVisible,
  });

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    return ChatMessageItem(
      messageId: json['messageId']?.toString() ?? '',
      threadId: json['threadId']?.toString() ?? '',
      threadType: json['threadType']?.toString() ?? '',
      senderUser: ChatUserSummary.fromJson(
        (json['senderUser'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value),
            ) ??
            const <String, dynamic>{},
      ),
      spokenLanguageCode: json['spokenLanguageCode']?.toString() ?? '',
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      isMine: json['isMine'] == true,
      audioUrl: json['audioUrl']?.toString() ?? '',
      localAudioPath: null,
      localTranscriptText: null,
      localTranscriptStatus: null,
      localTranscriptLanguage: null,
      localTranscriptLanguageCode: null,
      localTranslationText: null,
      localTranslationStatus: null,
      localTranslationLanguageCode: null,
      isServerVisible: true,
    );
  }

  final String messageId;
  final String threadId;
  final String threadType;
  final ChatUserSummary senderUser;
  final String spokenLanguageCode;
  final int durationMs;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isMine;
  final String audioUrl;
  final String? localAudioPath;
  final String? localTranscriptText;
  final String? localTranscriptStatus;
  final String? localTranscriptLanguage;
  final String? localTranscriptLanguageCode;
  final String? localTranslationText;
  final String? localTranslationStatus;
  final String? localTranslationLanguageCode;
  final bool isServerVisible;

  bool get isDirectMessage => threadType == 'dm';
  bool get hasTranscript =>
      localTranscriptText != null && localTranscriptText!.trim().isNotEmpty;

  ChatMessageItem copyWith({
    String? localAudioPath,
    String? localTranscriptText,
    String? localTranscriptStatus,
    String? localTranscriptLanguage,
    String? localTranscriptLanguageCode,
    String? localTranslationText,
    String? localTranslationStatus,
    String? localTranslationLanguageCode,
    bool? isServerVisible,
  }) {
    return ChatMessageItem(
      messageId: messageId,
      threadId: threadId,
      threadType: threadType,
      senderUser: senderUser,
      spokenLanguageCode: spokenLanguageCode,
      durationMs: durationMs,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isMine: isMine,
      audioUrl: audioUrl,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      localTranscriptText: localTranscriptText ?? this.localTranscriptText,
      localTranscriptStatus:
          localTranscriptStatus ?? this.localTranscriptStatus,
      localTranscriptLanguage:
          localTranscriptLanguage ?? this.localTranscriptLanguage,
      localTranscriptLanguageCode:
          localTranscriptLanguageCode ?? this.localTranscriptLanguageCode,
      localTranslationText: localTranslationText ?? this.localTranslationText,
      localTranslationStatus:
          localTranslationStatus ?? this.localTranslationStatus,
      localTranslationLanguageCode:
          localTranslationLanguageCode ?? this.localTranslationLanguageCode,
      isServerVisible: isServerVisible ?? this.isServerVisible,
    );
  }
}

class ChatThreadSummary {
  const ChatThreadSummary({
    required this.threadId,
    required this.threadType,
    required this.title,
    required this.avatarUrl,
    required this.learningLanguage,
    required this.learningLanguageDisplay,
    required this.nativeLanguage,
    required this.nativeLanguageDisplay,
    required this.isMuted,
    required this.unreadCount,
    required this.lastMessageAt,
    required this.lastMessageDurationMs,
    required this.otherUser,
    required this.roleBadges,
    required this.section,
    required this.sectionOrder,
  });

  factory ChatThreadSummary.fromJson(
    Map<String, dynamic> json, {
    required String section,
    required int sectionOrder,
  }) {
    return ChatThreadSummary(
      threadId: json['threadId']?.toString() ?? '',
      threadType: json['threadType']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      learningLanguage: json['learningLanguage']?.toString(),
      learningLanguageDisplay: json['learningLanguageDisplay']?.toString(),
      nativeLanguage: json['nativeLanguage']?.toString(),
      nativeLanguageDisplay: json['nativeLanguageDisplay']?.toString(),
      isMuted: json['isMuted'] == true,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessageAt: DateTime.tryParse(json['lastMessageAt']?.toString() ?? ''),
      lastMessageDurationMs: (json['lastMessageDurationMs'] as num?)?.toInt(),
      otherUser: json['otherUser'] is Map
          ? ChatUserSummary.fromJson(
              (json['otherUser'] as Map).map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
          : null,
      roleBadges: ((json['roleBadges'] as List?) ?? const [])
          .map((badge) => badge.toString())
          .where((badge) => badge.trim().isNotEmpty)
          .toList(),
      section: section,
      sectionOrder: sectionOrder,
    );
  }

  final String threadId;
  final String threadType;
  final String title;
  final String? avatarUrl;
  final String? learningLanguage;
  final String? learningLanguageDisplay;
  final String? nativeLanguage;
  final String? nativeLanguageDisplay;
  final bool isMuted;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final int? lastMessageDurationMs;
  final ChatUserSummary? otherUser;
  final List<String> roleBadges;
  final String section;
  final int sectionOrder;

  bool get isGroup => threadType == 'group';
}

class ChatBootstrap {
  const ChatBootstrap({
    required this.globalNotificationsEnabled,
    required this.groups,
    required this.onlineUsers,
    required this.directMessages,
  });

  factory ChatBootstrap.fromJson(Map<String, dynamic> json) {
    final groupsJson = (json['groups'] as List?) ?? const [];
    final onlineUsersJson = (json['onlineUsers'] as List?) ?? const [];
    final dmsJson = (json['directMessages'] as List?) ?? const [];

    return ChatBootstrap(
      globalNotificationsEnabled: json['globalNotificationsEnabled'] == true,
      groups: groupsJson
          .whereType<Map>()
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => ChatThreadSummary.fromJson(
              entry.value.map((key, value) => MapEntry(key.toString(), value)),
              section: 'group',
              sectionOrder: entry.key,
            ),
          )
          .toList(),
      onlineUsers: onlineUsersJson
          .whereType<Map>()
          .map(
            (item) => ChatUserSummary.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
      directMessages: dmsJson
          .whereType<Map>()
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => ChatThreadSummary.fromJson(
              entry.value.map((key, value) => MapEntry(key.toString(), value)),
              section: 'dm',
              sectionOrder: entry.key,
            ),
          )
          .toList(),
    );
  }

  final bool globalNotificationsEnabled;
  final List<ChatThreadSummary> groups;
  final List<ChatUserSummary> onlineUsers;
  final List<ChatThreadSummary> directMessages;
}

class DownloadedChatAudio {
  const DownloadedChatAudio({required this.bytes, required this.contentType});

  final List<int> bytes;
  final String contentType;
}
