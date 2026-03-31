import '../domain/models/models.dart';

class MockData {
  static final User currentUser = User(
    id: 'u1',
    displayName: 'Eason',
    avatarUrl: 'https://i.pravatar.cc/150?u=eason',
    firstLanguage: 'Chinese',
    learningLanguage: 'English',
    level: 'Intermediate (B1)',
    bio: 'Software engineer looking to improve casual English listening and speaking skills.',
    openToExchange: true,
  );

  static final User partnerUser = User(
    id: 'u2',
    displayName: 'Sarah',
    avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
    firstLanguage: 'English',
    learningLanguage: 'Chinese',
    level: 'Beginner (A2)',
    bio: 'Living in Taiwan, wanting to improve daily Chinese conversation.',
    openToExchange: true,
  );

  static final User creatorUser = User(
    id: 'u3',
    displayName: 'DailyVocab',
    avatarUrl: 'https://i.pravatar.cc/150?u=creator',
    firstLanguage: 'English',
    learningLanguage: 'Spanish',
    level: 'Native',
  );

  static final List<MediaItem> recommendedMedia = [
    MediaItem(
      id: 'm1',
      title: 'Ordering Coffee in Sydney',
      description: 'A quick interaction at a local cafe.',
      creator: creatorUser,
      coverUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&q=80&w=400',
      spokenLanguage: 'English',
      accent: 'AU',
      durationMs: 45000,
      plays: 1250,
      transcriptionSource: 'App Generated',
      cues: [
        Cue(id: 'c1', startTimeMs: 0, endTimeMs: 4000, originalText: "Hey mate, how's it going today?", translatedText: "嘿，兄弟，今天怎麼樣？", isBookmarked: true),
        Cue(id: 'c2', startTimeMs: 4500, endTimeMs: 8000, originalText: "Not bad, I'll just grab a flat white, thanks.", translatedText: "還不錯，請給我一杯澳式白咖啡，謝謝。"),
        Cue(id: 'c3', startTimeMs: 8500, endTimeMs: 12000, originalText: "Have here or takeaway?", translatedText: "內用還是外帶？"),
        Cue(id: 'c4', startTimeMs: 12500, endTimeMs: 15000, originalText: "Takeaway, cheers.", translatedText: "外帶，謝謝。"),
      ],
    ),
    MediaItem(
      id: 'm2',
      title: 'Airport Security Announcement',
      description: 'Standard airport PA announcement.',
      creator: creatorUser,
      coverUrl: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?auto=format&fit=crop&q=80&w=400',
      spokenLanguage: 'English',
      accent: 'US',
      durationMs: 30000,
      plays: 890,
      transcriptionSource: 'Manual',
      cues: [
        Cue(id: 'c5', startTimeMs: 0, endTimeMs: 5000, originalText: "Welcome to terminal four. Please have your boarding pass ready.", translatedText: "歡迎來到四號航站樓。請準備好您的登機證。"),
      ],
    ),
  ];

  static final List<ChatThread> recentChats = [
    ChatThread(
      id: 't1',
      participants: [currentUser, partnerUser],
      lastMessage: ChatMessage(
        id: 'msg1',
        senderId: 'u2',
        durationMs: 12000,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        transcriptPreview: "Your Chinese sounds really good! I was wondering...",
        translatedPreview: "你的中文聽起來很不錯！我在想...",
      ),
    ),
  ];
}
