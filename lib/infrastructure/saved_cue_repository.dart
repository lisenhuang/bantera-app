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
  final int? startTimeMs;
  final int? endTimeMs;
  final String? cueMode;
  final String? parentCueId;
  final int? parentCueIndex;
  final MediaItem mediaItem;
  final DateTime savedAt;
  final bool isLocal;

  const SavedCueRecord({
    required this.id,
    required this.mediaItemId,
    required this.cueId,
    required this.cueIndex,
    required this.cueText,
    this.startTimeMs,
    this.endTimeMs,
    this.cueMode,
    this.parentCueId,
    this.parentCueIndex,
    required this.mediaItem,
    required this.savedAt,
    required this.isLocal,
  });
}

class SavedCueMetadata {
  const SavedCueMetadata({
    required this.cueText,
    required this.startTimeMs,
    required this.endTimeMs,
    required this.cueMode,
    required this.parentCueId,
    required this.parentCueIndex,
  });

  final String cueText;
  final int startTimeMs;
  final int endTimeMs;
  final String cueMode;
  final String? parentCueId;
  final int? parentCueIndex;
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

  String? get _accessToken => AuthSessionNotifier.instance.session?.accessToken;

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
    final resolved = _resolveSavedCueDetails(mediaItem, e);
    return SavedCueRecord(
      id: e.id,
      mediaItemId: video.id,
      cueId: e.cueId,
      cueIndex: e.cueIndex,
      cueText: resolved.cueText,
      startTimeMs: resolved.startTimeMs,
      endTimeMs: resolved.endTimeMs,
      cueMode: resolved.cueMode,
      parentCueId: resolved.parentCueId,
      parentCueIndex: resolved.parentCueIndex,
      mediaItem: mediaItem,
      savedAt: e.savedAt,
      isLocal: false,
    );
  }

  ({
    String cueText,
    int? startTimeMs,
    int? endTimeMs,
    String? cueMode,
    String? parentCueId,
    int? parentCueIndex,
  })
  _resolveSavedCueDetails(MediaItem mediaItem, SavedCueApiEntry entry) {
    final normalizedMode = _normalizeCueMode(entry.cueMode);
    final longCues = mediaItem.cues;
    final shortCues = _buildShortCuesOrEmpty(mediaItem);
    final longMatchIndex = longCues.indexWhere((cue) => cue.id == entry.cueId);
    final shortMatchIndex = shortCues.indexWhere(
      (cue) => cue.id == entry.cueId,
    );

    String? cueText = _nonEmptyOrNull(entry.cueText);
    int? startTimeMs = entry.startTimeMs;
    int? endTimeMs = entry.endTimeMs;
    String? cueMode = normalizedMode;
    String? parentCueId = _nonEmptyOrNull(entry.parentCueId);
    int? parentCueIndex = entry.parentCueIndex;

    if (shortMatchIndex >= 0) {
      final cue = shortCues[shortMatchIndex];
      cueText ??= cue.originalText;
      startTimeMs ??= cue.startTimeMs;
      endTimeMs ??= cue.endTimeMs;
      cueMode ??= 'short';
      final parent = _parentCueFor(cue, longCues);
      parentCueId ??= parent?.cue.id;
      parentCueIndex ??= parent?.index;
    } else if (longMatchIndex >= 0) {
      final cue = longCues[longMatchIndex];
      cueText ??= cue.originalText;
      startTimeMs ??= cue.startTimeMs;
      endTimeMs ??= cue.endTimeMs;
      cueMode ??= 'long';
      parentCueId ??= cue.id;
      parentCueIndex ??= longMatchIndex;
    } else if (entry.cueIndex >= 0 && entry.cueIndex < longCues.length) {
      final cue = longCues[entry.cueIndex];
      cueText ??= cue.originalText;
      startTimeMs ??= cue.startTimeMs;
      endTimeMs ??= cue.endTimeMs;
      cueMode ??= 'long';
      parentCueId ??= cue.id;
      parentCueIndex ??= entry.cueIndex;
    }

    return (
      cueText: cueText ?? '',
      startTimeMs: startTimeMs,
      endTimeMs: endTimeMs,
      cueMode: cueMode,
      parentCueId: parentCueId,
      parentCueIndex: parentCueIndex,
    );
  }

  static String? _normalizeCueMode(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'short' || normalized == 'long') {
      return normalized;
    }
    return null;
  }

  static String? _nonEmptyOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static List<Cue> _buildShortCuesOrEmpty(MediaItem mediaItem) {
    if (mediaItem.shortCues.isEmpty) {
      return const [];
    }
    return mediaItem.shortCues;
  }

  static ({Cue cue, int index})? _parentCueFor(Cue cue, List<Cue> parentCues) {
    for (var i = 0; i < parentCues.length; i++) {
      final parent = parentCues[i];
      if (parent.id == cue.id) {
        return (cue: parent, index: i);
      }
    }
    for (var i = 0; i < parentCues.length; i++) {
      final parent = parentCues[i];
      if (cue.startTimeMs >= parent.startTimeMs &&
          cue.startTimeMs < parent.endTimeMs) {
        return (cue: parent, index: i);
      }
    }
    return null;
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
          .map(
            (c) => Cue(
              id: '${video.id}-${c.index}',
              startTimeMs: c.startMs,
              endTimeMs: c.endMs,
              originalText: c.text,
              translatedText: '',
            ),
          )
          .toList(),
      shortCues: video.transcriptShortCues
          .map(
            (c) => Cue(
              id: '${video.id}-s${c.index}',
              startTimeMs: c.startMs,
              endTimeMs: c.endMs,
              originalText: c.text,
              translatedText: '',
            ),
          )
          .toList(),
      hasBackendShortCues: video.transcriptShortCues.isNotEmpty,
      transcriptionSource: video.isAiGenerated ? 'AI Generated' : 'User Upload',
      isAudioOnly: video.videoWidth == null && video.videoHeight == null,
      createdAt: video.createdAt,
      transcriptionVersion: video.transcriptionVersion,
      dialogueLines: video.dialogueLines,
      wordTiming: video.wordTiming,
    );
  }

  static String _titleFromFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }

  Future<List<SavedCueRecord>> _loadFromLocal() async {
    final db = LocalPracticeDatabase.instance;
    final rows =
        await (db.select(db.savedCueEntries)
              ..where((t) => t.ownerCacheKey.equals(_ownerKey))
              ..orderBy([(t) => drift.OrderingTerm.desc(t.savedAtMillis)]))
            .get();

    final result = <SavedCueRecord>[];
    for (final row in rows) {
      try {
        final mediaItem = MediaItem.fromJson(
          jsonDecode(row.mediaItemJson) as Map<String, dynamic>,
        );
        result.add(
          SavedCueRecord(
            id: row.id,
            mediaItemId: row.mediaItemId,
            cueId: row.cueId,
            cueIndex: row.cueIndex,
            cueText: row.cueText,
            startTimeMs: row.startTimeMs,
            endTimeMs: row.endTimeMs,
            cueMode: row.cueMode,
            parentCueId: row.parentCueId,
            parentCueIndex: row.parentCueIndex,
            mediaItem: mediaItem,
            savedAt: DateTime.fromMillisecondsSinceEpoch(row.savedAtMillis),
            isLocal: true,
          ),
        );
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
    required SavedCueMetadata metadata,
  }) async {
    final existing = _entries
        .where((e) => e.mediaItemId == mediaItem.id && e.cueId == cue.id)
        .firstOrNull;
    if (_isServerVideo(mediaItem) && _isAuthenticated) {
      await _toggleServer(
        mediaItem: mediaItem,
        cue: cue,
        cueIndex: cueIndex,
        metadata: metadata,
        existing: existing,
      );
    } else {
      await _toggleLocal(
        mediaItem: mediaItem,
        cue: cue,
        cueIndex: cueIndex,
        metadata: metadata,
        existing: existing,
      );
    }
  }

  Future<void> _toggleServer({
    required MediaItem mediaItem,
    required Cue cue,
    required int cueIndex,
    required SavedCueMetadata metadata,
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
        cueText: metadata.cueText,
        startTimeMs: metadata.startTimeMs,
        endTimeMs: metadata.endTimeMs,
        cueMode: metadata.cueMode,
        parentCueId: metadata.parentCueId,
        parentCueIndex: metadata.parentCueIndex,
      );
    }
    await load();
  }

  Future<void> _toggleLocal({
    required MediaItem mediaItem,
    required Cue cue,
    required int cueIndex,
    required SavedCueMetadata metadata,
    required SavedCueRecord? existing,
  }) async {
    final db = LocalPracticeDatabase.instance;
    if (existing != null) {
      await (db.delete(
        db.savedCueEntries,
      )..where((t) => t.id.equals(existing.id))).go();
    } else {
      await db
          .into(db.savedCueEntries)
          .insert(
            SavedCueEntriesCompanion.insert(
              id: 'saved-cue-${DateTime.now().microsecondsSinceEpoch}',
              ownerCacheKey: _ownerKey,
              mediaItemId: mediaItem.id,
              cueId: cue.id,
              cueIndex: cueIndex,
              cueText: metadata.cueText,
              startTimeMs: drift.Value(metadata.startTimeMs),
              endTimeMs: drift.Value(metadata.endTimeMs),
              cueMode: drift.Value(metadata.cueMode),
              parentCueId: drift.Value(metadata.parentCueId),
              parentCueIndex: drift.Value(metadata.parentCueIndex),
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
      await Future.wait(
        serverEntries.map(
          (e) => AuthApiClient.instance.unsaveCue(
            accessToken: token,
            entryId: e.id,
          ),
        ),
      );
    }
    // Delete local entries
    final db = LocalPracticeDatabase.instance;
    await (db.delete(
      db.savedCueEntries,
    )..where((t) => t.ownerCacheKey.equals(_ownerKey))).go();
    await load();
  }

  Future<void> deleteSavedCue(SavedCueRecord entry) async {
    if (entry.isLocal) {
      final db = LocalPracticeDatabase.instance;
      await (db.delete(
        db.savedCueEntries,
      )..where((t) => t.id.equals(entry.id))).go();
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
