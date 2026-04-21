class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? translationLanguage;
  final String? nativeLanguage;
  final String? learningLanguage;

  UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.translationLanguage,
    this.nativeLanguage,
    this.learningLanguage,
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

class WordTiming {
  final String word;
  final int startMs;
  final int endMs;
  final double? confidence;

  const WordTiming({
    required this.word,
    required this.startMs,
    required this.endMs,
    this.confidence,
  });

  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      word: json['word']?.toString() ?? '',
      startMs: (json['startMs'] as num?)?.toInt() ?? 0,
      endMs: (json['endMs'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'word': word,
      'startMs': startMs,
      'endMs': endMs,
      if (confidence != null) 'confidence': confidence,
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
  final List<VideoTranscriptCue> transcriptShortCues;
  final bool isPublic;
  final bool isAiGenerated;
  final bool isTranscriptionEstimated;
  final int durationMs;
  final int fileSizeBytes;
  final int? videoWidth;
  final int? videoHeight;
  final String videoContentType;
  final String? videoUrl;
  final String? coverImageUrl;
  final DateTime createdAt;
  final String? creatorDisplayName;
  final int? transcriptionVersion;
  final List<String>? dialogueLines;
  final List<WordTiming>? wordTiming;

  UploadedVideo({
    required this.id,
    required this.userId,
    required this.originalFileName,
    required this.transcriptText,
    required this.transcriptLanguage,
    required this.transcriptLanguageCode,
    required this.transcriptCues,
    this.transcriptShortCues = const [],
    required this.isPublic,
    required this.isAiGenerated,
    required this.isTranscriptionEstimated,
    required this.durationMs,
    required this.fileSizeBytes,
    required this.videoWidth,
    required this.videoHeight,
    required this.videoContentType,
    required this.videoUrl,
    this.coverImageUrl,
    required this.createdAt,
    this.creatorDisplayName,
    this.transcriptionVersion,
    this.dialogueLines,
    this.wordTiming,
  });

  MediaItem toMediaItem({required User creator}) {
    return MediaItem(
      id: id,
      title: _titleFromFileName(originalFileName),
      description: transcriptText,
      creator: creator,
      coverUrl: coverImageUrl ?? '',
      videoUrl: videoUrl,
      spokenLanguage: transcriptLanguage,
      accent: transcriptLanguageCode,
      durationMs: durationMs,
      cues: transcriptCues
          .map(
            (cue) => Cue(
              id: '$id-${cue.index}',
              startTimeMs: cue.startMs,
              endTimeMs: cue.endMs,
              originalText: cue.text,
              translatedText: '',
            ),
          )
          .toList(),
      shortCues: transcriptShortCues
          .map(
            (cue) => Cue(
              id: '$id-s${cue.index}',
              startTimeMs: cue.startMs,
              endTimeMs: cue.endMs,
              originalText: cue.text,
              translatedText: '',
            ),
          )
          .toList(),
      hasBackendShortCues: transcriptShortCues.isNotEmpty,
      transcriptionSource: isAiGenerated ? 'AI Generated' : 'User Upload',
      isAudioOnly: videoWidth == null && videoHeight == null,
      transcriptionVersion: transcriptionVersion,
      dialogueLines: dialogueLines,
      wordTiming: wordTiming,
    );
  }

  static String _titleFromFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }
}

class PendingAudioJob {
  final String id;
  final String status;
  final String? videoId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  const PendingAudioJob({
    required this.id,
    required this.status,
    required this.videoId,
    required this.createdAt,
    required this.completedAt,
    required this.errorMessage,
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      firstLanguage: json['firstLanguage']?.toString() ?? '',
      learningLanguage: json['learningLanguage']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      openToExchange: json['openToExchange'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'firstLanguage': firstLanguage,
    'learningLanguage': learningLanguage,
    'level': level,
    'bio': bio,
    'openToExchange': openToExchange,
  };
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

  factory Cue.fromJson(Map<String, dynamic> json) {
    return Cue(
      id: json['id']?.toString() ?? '',
      startTimeMs: (json['startTimeMs'] as num?)?.toInt() ?? 0,
      endTimeMs: (json['endTimeMs'] as num?)?.toInt() ?? 0,
      originalText: json['originalText']?.toString() ?? '',
      translatedText: json['translatedText']?.toString() ?? '',
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTimeMs': startTimeMs,
    'endTimeMs': endTimeMs,
    'originalText': originalText,
    'translatedText': translatedText,
    'isBookmarked': isBookmarked,
    'notes': notes,
  };
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
  final List<Cue> shortCues;
  final bool hasBackendShortCues;
  final int plays;
  final String transcriptionSource;
  final String? translatedLanguage;
  final bool isAudioOnly;
  final int? transcriptionVersion;
  final List<String>? dialogueLines;
  final List<WordTiming>? wordTiming;

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
    this.shortCues = const [],
    this.hasBackendShortCues = false,
    this.plays = 0,
    required this.transcriptionSource,
    this.translatedLanguage,
    this.isAudioOnly = false,
    this.transcriptionVersion,
    this.dialogueLines,
    this.wordTiming,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      creator: User.fromJson(json['creator'] as Map<String, dynamic>? ?? {}),
      coverUrl: json['coverUrl']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString(),
      localVideoPath: json['localVideoPath']?.toString(),
      spokenLanguage: json['spokenLanguage']?.toString() ?? '',
      accent: json['accent']?.toString() ?? '',
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      cues:
          (json['cues'] as List<dynamic>?)
              ?.map((e) => Cue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      shortCues:
          (json['shortCues'] as List<dynamic>?)
              ?.map((e) => Cue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hasBackendShortCues: json['hasBackendShortCues'] as bool? ?? false,
      transcriptionSource: json['transcriptionSource']?.toString() ?? '',
      translatedLanguage: json['translatedLanguage']?.toString(),
      isAudioOnly: json['isAudioOnly'] as bool? ?? false,
      transcriptionVersion: (json['transcriptionVersion'] as num?)?.toInt(),
      dialogueLines: (json['dialogueLines'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      wordTiming: (json['wordTiming'] as List<dynamic>?)
          ?.map((e) {
            if (e is Map<String, dynamic>) return WordTiming.fromJson(e);
            if (e is Map) {
              return WordTiming.fromJson(
                e.map((key, value) => MapEntry(key.toString(), value)),
              );
            }
            return null;
          })
          .whereType<WordTiming>()
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'creator': creator.toJson(),
    'coverUrl': coverUrl,
    'videoUrl': videoUrl,
    'localVideoPath': localVideoPath,
    'spokenLanguage': spokenLanguage,
    'accent': accent,
    'durationMs': durationMs,
    'cues': cues.map((c) => c.toJson()).toList(),
    'shortCues': shortCues.map((c) => c.toJson()).toList(),
    'hasBackendShortCues': hasBackendShortCues,
    'transcriptionSource': transcriptionSource,
    'translatedLanguage': translatedLanguage,
    'isAudioOnly': isAudioOnly,
    'transcriptionVersion': transcriptionVersion,
    'dialogueLines': dialogueLines,
    'wordTiming': wordTiming?.map((w) => w.toJson()).toList(),
  };
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
