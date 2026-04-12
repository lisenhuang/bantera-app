import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';

import '../core/auth_session_notifier.dart';
import '../core/api_config_notifier.dart';
import '../domain/models/models.dart';
import 'auth_api_client.dart';
import 'local_practice_database.dart';

/// A saved-cue entry — works for both server-video saves (id is a Guid string)
/// and local-only practice saves (id starts with 'saved-cue-').
class SavedCueRecord {
  final String id;
  final String mediaItemId;
  final String cueId;
  final int cueIndex;
  final String cueText;
  final MediaItem mediaItem;
  final DateTime savedAt;
  final bool isLocal;

  const SavedCueRecord({
    required this.id,
    required this.mediaItemId,
    required this.cueId,
    required this.cueIndex,
    required this.cueText,
    required this.mediaItem,
    required this.savedAt,
    required this.isLocal,
  });
}

class SavedCueRepository extends ChangeNotifier {
  SavedCueRepository._();

  static final SavedCueRepository instance = SavedCueRepository._();

  List<SavedCueRecord> _entries = const [];

  List<SavedCueRecord> get entries => _entries;

  String get _ownerKey {
    final key = AuthSessionNotifier.instance.session?.cacheKey.trim();
    return (key != null && key.isNotEmpty) ? key : 'local-device-user';
  }

  String? get _accessToken =>
      AuthSessionNotifier.instance.session?.accessToken;

  bool get _isAuthenticated => _accessToken != null;

  /// True when [mediaItem] should be saved on the server (has a videoUrl,
  /// not a temporary delete-on-dispose item).
  static bool _isServerVideo(MediaItem mediaItem) {
    final hasUrl = mediaItem.videoUrl?.trim().isNotEmpty ?? false;
    return hasUrl && !mediaItem.deleteLocalMediaOnDispose;
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    final serverEntries = await _loadFromServer();
    final localEntries = await _loadFromLocal();
    _entries = [...serverEntries, ...localEntries];
    notifyListeners();
  }

  Future<List<SavedCueRecord>> _loadFromServer() async {
    final token = _accessToken;
    if (token == null) return const [];
    try {
      final apiEntries = await AuthApiClient.instance.fetchSavedCues(
        accessToken: token,
      );
      return apiEntries.map((e) => _apiEntryToRecord(e)).toList();
    } catch (_) {
      return const [];
    }
  }

  SavedCueRecord _apiEntryToRecord(SavedCueApiEntry e) {
    final video = e.video;
    final mediaItem = _uploadedVideoToMediaItem(video);
    return SavedCueRecord(
      id: e.id,
      mediaItemId: video.id,
      cueId: e.cueId,
      cueIndex: e.cueIndex,
      cueText: _cueTextForIndex(mediaItem, e.cueIndex),
      mediaItem: mediaItem,
      savedAt: e.savedAt,
      isLocal: false,
    );
  }

  String _cueTextForIndex(MediaItem mediaItem, int index) {
    if (index >= 0 && index < mediaItem.cues.length) {
      return mediaItem.cues[index].originalText;
    }
    return '';
  }

  static MediaItem _uploadedVideoToMediaItem(UploadedVideo video) {
    final baseUrl = ApiConfigNotifier.instance.baseUrl;
    return MediaItem(
      id: video.id,
      title: _titleFromFileName(video.originalFileName),
      description: '',
      creator: User(
        id: video.userId,
        displayName: video.creatorDisplayName ?? 'Bantera',
        avatarUrl: '$baseUrl/api/users/${video.userId}/avatar',
        firstLanguage: '',
        learningLanguage: '',
        level: '',
      ),
      coverUrl: video.coverImageUrl ?? '',
      videoUrl: video.videoUrl,
      spokenLanguage: video.transcriptLanguage,
      accent: video.transcriptLanguageCode,
      durationMs: video.durationMs,
      cues: video.transcriptCues
          .map((c) => Cue(
                id: '${video.id}-${c.index}',
                startTimeMs: c.startMs,
                endTimeMs: c.endMs,
                originalText: c.text,
                translatedText: '',
              ))
          .toList(),
      transcriptionSource: video.isAiGenerated ? 'AI Generated' : 'User Upload',
      isAudioOnly: video.videoWidth == null && video.videoHeight == null,
    );
  }

  static String _titleFromFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }

  Future<List<SavedCueRecord>> _loadFromLocal() async {
    final db = LocalPracticeDatabase.instance;
    final rows = await (db.select(db.savedCueEntries)
          ..where((t) => t.ownerCacheKey.equals(_ownerKey))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.savedAtMillis)]))
        .get();

    final result = <SavedCueRecord>[];
    for (final row in rows) {
      try {
        final mediaItem = MediaItem.fromJson(
          jsonDecode(row.mediaItemJson) as Map<String, dynamic>,
        );
        result.add(SavedCueRecord(
          id: row.id,
          mediaItemId: row.mediaItemId,
          cueId: row.cueId,
          cueIndex: row.cueIndex,
          cueText: row.cueText,
          mediaItem: mediaItem,
          savedAt: DateTime.fromMillisecondsSinceEpoch(row.savedAtMillis),
          isLocal: true,
        ));
      } catch (_) {
        // Skip malformed rows
      }
    }
    return result;
  }

  // ── Query ─────────────────────────────────────────────────────────────────

  bool isSaved(String mediaItemId, String cueId) {
    return _entries.any(
      (e) => e.mediaItemId == mediaItemId && e.cueId == cueId,
    );
  }

  // ── Toggle ────────────────────────────────────────────────────────────────

  Future<void> toggleSaveCue({
    required MediaItem mediaItem,
    required Cue cue,
    required int cueIndex,
  }) async {
    final existing = _entries
        .where((e) => e.mediaItemId == mediaItem.id && e.cueId == cue.id)
        .firstOrNull;
    final alreadySaved = existing != null;

    if (_isServerVideo(mediaItem) && _isAuthenticated) {
      await _toggleServer(
        mediaItem: mediaItem,
        cue: cue,
        cueIndex: cueIndex,
        existing: existing,
      );
    } else {
      await _toggleLocal(
        mediaItem: mediaItem,
        cue: cue,
        cueIndex: cueIndex,
        existing: existing,
      );
    }
  }

  Future<void> _toggleServer({
    required MediaItem mediaItem,
    required Cue cue,
    required int cueIndex,
    required SavedCueRecord? existing,
  }) async {
    final token = _accessToken!;
    if (existing != null) {
      await AuthApiClient.instance.unsaveCue(
        accessToken: token,
        entryId: existing.id,
      );
    } else {
      await AuthApiClient.instance.saveCue(
        accessToken: token,
        videoId: mediaItem.id,
        cueId: cue.id,
        cueIndex: cueIndex,
      );
    }
    await load();
  }

  Future<void> _toggleLocal({
    required MediaItem mediaItem,
    required Cue cue,
    required int cueIndex,
    required SavedCueRecord? existing,
  }) async {
    final db = LocalPracticeDatabase.instance;
    if (existing != null) {
      await (db.delete(db.savedCueEntries)
            ..where((t) => t.id.equals(existing.id)))
          .go();
    } else {
      await db.into(db.savedCueEntries).insert(
        SavedCueEntriesCompanion.insert(
          id: 'saved-cue-${DateTime.now().microsecondsSinceEpoch}',
          ownerCacheKey: _ownerKey,
          mediaItemId: mediaItem.id,
          cueId: cue.id,
          cueIndex: cueIndex,
          cueText: cue.originalText,
          mediaItemJson: jsonEncode(mediaItem.toJson()),
          savedAtMillis: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
    await load();
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteAll() async {
    final token = _accessToken;
    // Delete server entries
    if (token != null) {
      final serverEntries = _entries.where((e) => !e.isLocal).toList();
      await Future.wait(serverEntries.map((e) =>
          AuthApiClient.instance.unsaveCue(accessToken: token, entryId: e.id)));
    }
    // Delete local entries
    final db = LocalPracticeDatabase.instance;
    await (db.delete(db.savedCueEntries)
          ..where((t) => t.ownerCacheKey.equals(_ownerKey)))
        .go();
    await load();
  }

  Future<void> deleteSavedCue(SavedCueRecord entry) async {
    if (entry.isLocal) {
      final db = LocalPracticeDatabase.instance;
      await (db.delete(db.savedCueEntries)
            ..where((t) => t.id.equals(entry.id)))
          .go();
    } else {
      final token = _accessToken;
      if (token != null) {
        await AuthApiClient.instance.unsaveCue(
          accessToken: token,
          entryId: entry.id,
        );
      }
    }
    await load();
  }
}

