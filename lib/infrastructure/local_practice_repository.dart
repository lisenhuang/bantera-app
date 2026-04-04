import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/auth_session_notifier.dart';
import '../domain/models/models.dart';
import 'local_practice_database.dart';
import 'video_processing_service.dart';

class LocalPracticeRepositoryException implements Exception {
  const LocalPracticeRepositoryException(this.message);

  final String message;
}

class LocalPracticeRepository extends ChangeNotifier {
  LocalPracticeRepository._();

  static final LocalPracticeRepository instance = LocalPracticeRepository._();

  final LocalPracticeDatabase _database = LocalPracticeDatabase.instance;

  List<LocalPracticeVideoSummary> _videos = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _activeOwnerCacheKey;

  List<LocalPracticeVideoSummary> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String createDraftId() {
    return 'local-practice-${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> refreshForCurrentUser({bool showLoadingState = true}) async {
    final ownerCacheKey = _currentOwnerCacheKey;
    _activeOwnerCacheKey = ownerCacheKey;

    if (ownerCacheKey == null) {
      _videos = const [];
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    if (showLoadingState) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _videos = await _loadSummaries(ownerCacheKey);
    } catch (_) {
      _errorMessage =
          'Bantera could not load the videos saved on this iPhone.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LocalPracticeVideo> savePreparedSession({
    required String id,
    required String title,
    required PreparedVideoUpload prepared,
    required Map<String, String> translatedCueTexts,
    required String? translatedLanguage,
  }) async {
    final ownerCacheKey = _currentOwnerCacheKey ?? 'local-device-user';
    final normalizedTranslatedLanguage =
        translatedCueTexts.isEmpty ? null : _normalizeOptional(translatedLanguage);
    final persistedFile = await _persistPreparedVideo(id: id, prepared: prepared);
    final now = DateTime.now().millisecondsSinceEpoch;
    final spokenLanguage = prepared.transcriptLanguageCode.isEmpty
        ? prepared.transcriptLanguage
        : prepared.transcriptLanguageCode.toUpperCase();
    final preview = _normalizeTranscriptPreview(
      prepared.transcriptText,
      fallbackCues: prepared.transcriptCues,
    );

    await _database.transaction(() async {
      await (_database.delete(
        _database.localPracticeCueEntries,
      )..where((table) => table.itemId.equals(id))).go();
      await _database
          .into(_database.localPracticeEntries)
          .insertOnConflictUpdate(
            LocalPracticeEntriesCompanion.insert(
              id: id,
              ownerCacheKey: ownerCacheKey,
              title: title,
              transcriptPreview: preview,
              description:
                  'A private on-device listening session saved on this iPhone for cue-by-cue practice.',
              localVideoPath: persistedFile.path,
              spokenLanguage: spokenLanguage,
              accent: prepared.transcriptLanguage,
              durationMs: prepared.durationMs,
              cueCount: prepared.transcriptCues.length,
              fileSizeBytes: await persistedFile.length(),
              transcriptionSource: 'On Device',
              translatedLanguage: drift.Value(normalizedTranslatedLanguage),
              createdAtMillis: now,
              updatedAtMillis: now,
              lastOpenedAtMillis: drift.Value(now),
            ),
          );

      await _database.batch((batch) {
        batch.insertAll(
          _database.localPracticeCueEntries,
          prepared.transcriptCues.map((cue) {
            final cueId = _cueId(id, cue.index);
            return LocalPracticeCueEntriesCompanion.insert(
              id: cueId,
              itemId: id,
              cueIndex: cue.index,
              startTimeMs: cue.startMs,
              endTimeMs: cue.endMs,
              originalText: cue.text,
              translatedText: drift.Value(
                translatedCueTexts[cueId]?.trim() ?? '',
              ),
            );
          }).toList(),
        );
      });
    });

    final saved = await fetchVideo(id);
    if (saved == null) {
      throw const LocalPracticeRepositoryException(
        'Bantera could not save this video to your local practice library.',
      );
    }

    if (_activeOwnerCacheKey == ownerCacheKey) {
      await refreshForCurrentUser(showLoadingState: false);
    }

    return saved;
  }

  Future<LocalPracticeVideo?> fetchVideo(String id) async {
    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      return null;
    }

    final entry = await (_database.select(_database.localPracticeEntries)
          ..where(
            (table) =>
                table.id.equals(id) &
                table.ownerCacheKey.equals(ownerCacheKey),
          ))
        .getSingleOrNull();
    if (entry == null) {
      return null;
    }

    final cues = await (_database.select(_database.localPracticeCueEntries)
          ..where((table) => table.itemId.equals(id))
          ..orderBy([(table) => drift.OrderingTerm.asc(table.cueIndex)]))
        .get();

    return _mapVideo(entry, cues);
  }

  Future<LocalPracticeVideo> openVideo(String id) async {
    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      throw const LocalPracticeRepositoryException(
        'Sign in again to open videos saved on this iPhone.',
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await (_database.update(_database.localPracticeEntries)
          ..where(
            (table) =>
                table.id.equals(id) &
                table.ownerCacheKey.equals(ownerCacheKey),
          ))
        .write(
          LocalPracticeEntriesCompanion(
            updatedAtMillis: drift.Value(now),
            lastOpenedAtMillis: drift.Value(now),
          ),
        );

    final video = await fetchVideo(id);
    if (video == null) {
      throw const LocalPracticeRepositoryException(
        'Bantera could not find that saved practice video.',
      );
    }

    if (!await File(video.localVideoPath).exists()) {
      await deleteVideo(id);
      throw const LocalPracticeRepositoryException(
        'The saved video file is missing from this iPhone.',
      );
    }

    if (_activeOwnerCacheKey == ownerCacheKey) {
      await refreshForCurrentUser(showLoadingState: false);
    }

    return video;
  }

  Future<void> deleteVideo(String id) async {
    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      return;
    }

    final entry = await (_database.select(_database.localPracticeEntries)
          ..where(
            (table) =>
                table.id.equals(id) &
                table.ownerCacheKey.equals(ownerCacheKey),
          ))
        .getSingleOrNull();
    if (entry == null) {
      return;
    }

    await (_database.delete(_database.localPracticeEntries)
          ..where(
            (table) =>
                table.id.equals(id) &
                table.ownerCacheKey.equals(ownerCacheKey),
          ))
        .go();

    final file = File(entry.localVideoPath);
    if (await file.exists()) {
      await file.delete();
    }

    if (_activeOwnerCacheKey == ownerCacheKey) {
      await refreshForCurrentUser(showLoadingState: false);
    }
  }

  Future<void> resetTranslations({
    required String id,
    required String translatedLanguage,
  }) async {
    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction(() async {
      await (_database.update(_database.localPracticeEntries)
            ..where(
              (table) =>
                  table.id.equals(id) &
                  table.ownerCacheKey.equals(ownerCacheKey),
            ))
          .write(
            LocalPracticeEntriesCompanion(
              translatedLanguage: drift.Value(translatedLanguage),
              updatedAtMillis: drift.Value(now),
              lastOpenedAtMillis: drift.Value(now),
            ),
          );
      await (_database.update(_database.localPracticeCueEntries)
            ..where((table) => table.itemId.equals(id)))
          .write(
            const LocalPracticeCueEntriesCompanion(
              translatedText: drift.Value(''),
            ),
          );
    });

    if (_activeOwnerCacheKey == ownerCacheKey) {
      await refreshForCurrentUser(showLoadingState: false);
    }
  }

  Future<void> storeTranslations({
    required String id,
    required String translatedLanguage,
    required Map<String, String> translations,
  }) async {
    if (translations.isEmpty) {
      return;
    }

    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction(() async {
      await (_database.update(_database.localPracticeEntries)
            ..where(
              (table) =>
                  table.id.equals(id) &
                  table.ownerCacheKey.equals(ownerCacheKey),
            ))
          .write(
            LocalPracticeEntriesCompanion(
              translatedLanguage: drift.Value(translatedLanguage),
              updatedAtMillis: drift.Value(now),
              lastOpenedAtMillis: drift.Value(now),
            ),
          );

      await _database.batch((batch) {
        for (final entry in translations.entries) {
          batch.update(
            _database.localPracticeCueEntries,
            LocalPracticeCueEntriesCompanion(
              translatedText: drift.Value(entry.value.trim()),
            ),
            where: (table) =>
                table.itemId.equals(id) & table.id.equals(entry.key),
          );
        }
      });
    });

    if (_activeOwnerCacheKey == ownerCacheKey) {
      await refreshForCurrentUser(showLoadingState: false);
    }
  }

  Future<List<LocalPracticeVideoSummary>> _loadSummaries(
    String ownerCacheKey,
  ) async {
    final entries = await (_database.select(_database.localPracticeEntries)
          ..where((table) => table.ownerCacheKey.equals(ownerCacheKey))
          ..orderBy([(table) => drift.OrderingTerm.desc(table.updatedAtMillis)]))
        .get();

    return entries.map(_mapSummary).toList(growable: false);
  }

  LocalPracticeVideoSummary _mapSummary(LocalPracticeEntry entry) {
    return LocalPracticeVideoSummary(
      id: entry.id,
      title: entry.title,
      transcriptPreview: entry.transcriptPreview,
      spokenLanguage: entry.spokenLanguage,
      accent: entry.accent,
      durationMs: entry.durationMs,
      cueCount: entry.cueCount,
      fileSizeBytes: entry.fileSizeBytes,
      localVideoPath: entry.localVideoPath,
      translatedLanguage: entry.translatedLanguage,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entry.createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entry.updatedAtMillis),
      lastOpenedAt: entry.lastOpenedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(entry.lastOpenedAtMillis!),
    );
  }

  LocalPracticeVideo _mapVideo(
    LocalPracticeEntry entry,
    List<LocalPracticeCueEntry> cues,
  ) {
    return LocalPracticeVideo(
      id: entry.id,
      title: entry.title,
      transcriptPreview: entry.transcriptPreview,
      spokenLanguage: entry.spokenLanguage,
      accent: entry.accent,
      durationMs: entry.durationMs,
      cueCount: entry.cueCount,
      fileSizeBytes: entry.fileSizeBytes,
      localVideoPath: entry.localVideoPath,
      translatedLanguage: entry.translatedLanguage,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entry.createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entry.updatedAtMillis),
      lastOpenedAt: entry.lastOpenedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(entry.lastOpenedAtMillis!),
      description: entry.description,
      transcriptionSource: entry.transcriptionSource,
      cues: cues.map((cue) {
        return Cue(
          id: cue.id,
          startTimeMs: cue.startTimeMs,
          endTimeMs: cue.endTimeMs,
          originalText: cue.originalText,
          translatedText: cue.translatedText,
        );
      }).toList(growable: false),
    );
  }

  Future<File> _persistPreparedVideo({
    required String id,
    required PreparedVideoUpload prepared,
  }) async {
    final directory = await _localVideoDirectory;
    await directory.create(recursive: true);

    final extension = _preferredExtension(prepared);
    final destination = File(p.join(directory.path, '$id$extension'));

    final copied = await prepared.file.copy(destination.path);
    if (prepared.shouldDeleteAfterUse &&
        p.normalize(prepared.file.path) != p.normalize(copied.path)) {
      try {
        await prepared.file.delete();
      } catch (_) {
        // Leave temporary files alone if iOS is still holding them.
      }
    }

    return copied;
  }

  Future<Directory> get _localVideoDirectory async {
    final supportDirectory = await getApplicationSupportDirectory();
    return Directory(p.join(supportDirectory.path, 'local_practice_videos'));
  }

  String? get _currentOwnerCacheKey {
    final normalized = AuthSessionNotifier.instance.session?.cacheKey.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String _cueId(String itemId, int cueIndex) {
    return '$itemId-cue-$cueIndex';
  }

  static String _preferredExtension(PreparedVideoUpload prepared) {
    final fromFileName = p.extension(prepared.fileName).trim();
    if (fromFileName.isNotEmpty) {
      return fromFileName;
    }

    final fromPath = p.extension(prepared.file.path).trim();
    if (fromPath.isNotEmpty) {
      return fromPath;
    }

    return '.mp4';
  }

  static String _normalizeTranscriptPreview(
    String transcriptText, {
    required List<VideoTranscriptCue> fallbackCues,
  }) {
    final normalized = transcriptText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }

    return fallbackCues.map((cue) => cue.text.trim()).join(' ').trim();
  }

  static String? _normalizeOptional(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
