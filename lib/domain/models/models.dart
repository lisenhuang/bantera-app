class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? translationLanguage;

  UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.translationLanguage,
  });
}

class VideoTranscriptCue {
  final int index;
  final int startMs;
  final int endMs;
  final String text;

  const VideoTranscriptCue({
    required this.index,
    required this.startMs,
    required this.endMs,
    required this.text,
  });

  factory VideoTranscriptCue.fromJson(Map<String, dynamic> json) {
    return VideoTranscriptCue(
      index: (json['index'] as num?)?.toInt() ?? 0,
      startMs: (json['startMs'] as num?)?.toInt() ?? 0,
      endMs: (json['endMs'] as num?)?.toInt() ?? 0,
      text: json['text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'index': index,
      'startMs': startMs,
      'endMs': endMs,
      'text': text,
    };
  }
}

class UploadedVideo {
  final String id;
  final String userId;
  final String originalFileName;
  final String transcriptText;
  final String transcriptLanguage;
  final String transcriptLanguageCode;
  final List<VideoTranscriptCue> transcriptCues;
  final bool isPublic;
  final int durationMs;
  final int fileSizeBytes;
  final int? videoWidth;
  final int? videoHeight;
  final String videoContentType;
  final String? videoUrl;
  final DateTime createdAt;

  UploadedVideo({
    required this.id,
    required this.userId,
    required this.originalFileName,
    required this.transcriptText,
    required this.transcriptLanguage,
    required this.transcriptLanguageCode,
    required this.transcriptCues,
    required this.isPublic,
    required this.durationMs,
    required this.fileSizeBytes,
    required this.videoWidth,
    required this.videoHeight,
    required this.videoContentType,
    required this.videoUrl,
    required this.createdAt,
  });
}

class LocalPracticeVideoSummary {
  final String id;
  final String title;
  final String transcriptPreview;
  final String spokenLanguage;
  final String accent;
  final int durationMs;
  final int cueCount;
  final int fileSizeBytes;
  final String localVideoPath;
  final String? translatedLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;

  const LocalPracticeVideoSummary({
    required this.id,
    required this.title,
    required this.transcriptPreview,
    required this.spokenLanguage,
    required this.accent,
    required this.durationMs,
    required this.cueCount,
    required this.fileSizeBytes,
    required this.localVideoPath,
    required this.translatedLanguage,
    required this.createdAt,
    required this.updatedAt,
    required this.lastOpenedAt,
  });
}

class LocalPracticeVideo extends LocalPracticeVideoSummary {
  final String description;
  final String transcriptionSource;
  final List<Cue> cues;

  const LocalPracticeVideo({
    required super.id,
    required super.title,
    required super.transcriptPreview,
    required super.spokenLanguage,
    required super.accent,
    required super.durationMs,
    required super.cueCount,
    required super.fileSizeBytes,
    required super.localVideoPath,
    required super.translatedLanguage,
    required super.createdAt,
    required super.updatedAt,
    required super.lastOpenedAt,
    required this.description,
    required this.transcriptionSource,
    required this.cues,
  });

  MediaItem toMediaItem({required User creator}) {
    return MediaItem(
      id: id,
      title: title,
      description: description,
      creator: creator,
      coverUrl: '',
      localVideoPath: localVideoPath,
      spokenLanguage: spokenLanguage,
      accent: accent,
      durationMs: durationMs,
      cues: cues,
      transcriptionSource: transcriptionSource,
      translatedLanguage: translatedLanguage,
    );
  }
}

class LocalCuePracticeAttempt {
  final String id;
  final String mediaItemId;
  final String cueId;
  final String transcriptText;
  final String sourceLocaleIdentifier;
  final String audioPath;
  final int matchedCount;
  final int unexpectedCount;
  final int missingCount;
  final int recordingDurationMs;
  final DateTime createdAt;

  const LocalCuePracticeAttempt({
    required this.id,
    required this.mediaItemId,
    required this.cueId,
    required this.transcriptText,
    required this.sourceLocaleIdentifier,
    required this.audioPath,
    required this.matchedCount,
    required this.unexpectedCount,
    required this.missingCount,
    required this.recordingDurationMs,
    required this.createdAt,
  });
}

class User {
  final String id;
  final String displayName;
  final String avatarUrl;
  final String firstLanguage;
  final String learningLanguage;
  final String level;
  final String bio;
  final bool openToExchange;

  User({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.firstLanguage,
    required this.learningLanguage,
    required this.level,
    this.bio = '',
    this.openToExchange = false,
  });
}

class Cue {
  final String id;
  final int startTimeMs;
  final int endTimeMs;
  final String originalText;
  final String translatedText;
  final bool isBookmarked;
  final List<String> notes;

  Cue({
    required this.id,
    required this.startTimeMs,
    required this.endTimeMs,
    required this.originalText,
    required this.translatedText,
    this.isBookmarked = false,
    this.notes = const [],
  });
}

class MediaItem {
  final String id;
  final String title;
  final String description;
  final User creator;
  final String coverUrl;
  final String? videoUrl;
  final String? localVideoPath;
  final Map<String, String> mediaHeaders;
  final bool deleteLocalMediaOnDispose;
  final String spokenLanguage;
  final String accent;
  final int durationMs;
  final List<Cue> cues;
  final int plays;
  final String transcriptionSource;
  final String? translatedLanguage;

  MediaItem({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.coverUrl,
    this.videoUrl,
    this.localVideoPath,
    this.mediaHeaders = const {},
    this.deleteLocalMediaOnDispose = false,
    required this.spokenLanguage,
    required this.accent,
    required this.durationMs,
    required this.cues,
    this.plays = 0,
    required this.transcriptionSource,
    this.translatedLanguage,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final int durationMs;
  final DateTime timestamp;
  final String transcriptPreview;
  final String translatedPreview;
  final bool isListened;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.durationMs,
    required this.timestamp,
    required this.transcriptPreview,
    required this.translatedPreview,
    this.isListened = false,
  });
}

class ChatThread {
  final String id;
  final List<User> participants;
  final ChatMessage lastMessage;
  final bool isGroup;

  ChatThread({
    required this.id,
    required this.participants,
    required this.lastMessage,
    this.isGroup = false,
  });
}
