import 'package:flutter/foundation.dart';

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
  final String spokenLanguage;
  final String accent;
  final int durationMs;
  final List<Cue> cues;
  final int plays;
  final String transcriptionSource;

  MediaItem({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.coverUrl,
    required this.spokenLanguage,
    required this.accent,
    required this.durationMs,
    required this.cues,
    this.plays = 0,
    required this.transcriptionSource,
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
