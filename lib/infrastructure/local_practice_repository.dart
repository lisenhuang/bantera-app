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
  static const String _managedVideoMarker =
      '/Library/Application Support/local_practice_videos/';
  static const String _managedAttemptMarker =
      '/Library/Application Support/compare_attempts/';

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
      _errorMessage = 'Bantera could not load the videos saved on this iPhone.';
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
    final normalizedTranslatedLanguage = translatedCueTexts.isEmpty
        ? null
        : _normalizeOptional(translatedLanguage);
    final persistedFile = await _persistPreparedVideo(
      id: id,
      prepared: prepared,
    );
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
              localVideoPath: await _storedVideoReferenceFor(persistedFile),
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
        if (normalizedTranslatedLanguage != null) {
          batch.insertAll(
            _database.localPracticeTranslationEntries,
            translatedCueTexts.entries
                .where((entry) => entry.value.trim().isNotEmpty)
                .map(
                  (entry) => LocalPracticeTranslationEntriesCompanion.insert(
                    itemId: id,
                    targetLanguage: normalizedTranslatedLanguage,
                    cueMode: 'long',
                    cueId: entry.key,
                    translatedText: entry.value.trim(),
                    updatedAtMillis: now,
                  ),
                )
                .toList(),
            mode: drift.InsertMode.insertOrReplace,
          );
        }
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

    final entry =
        await (_database.select(_database.localPracticeEntries)..where(
              (table) =>
                  table.id.equals(id) &
                  table.ownerCacheKey.equals(ownerCacheKey),
            ))
            .getSingleOrNull();
    if (entry == null) {
      return null;
    }

    final normalizedEntry = await _normalizeEntryPath(entry);

    final cues =
        await (_database.select(_database.localPracticeCueEntries)
              ..where((table) => table.itemId.equals(id))
              ..orderBy([(table) => drift.OrderingTerm.asc(table.cueIndex)]))
            .get();

    return _mapVideo(normalizedEntry, cues);
  }

  Future<LocalPracticeVideo> openVideo(String id) async {
    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      throw const LocalPracticeRepositoryException(
        'Sign in again to open videos saved on this iPhone.',
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await (_database.update(_database.localPracticeEntries)..where(
          (table) =>
              table.id.equals(id) & table.ownerCacheKey.equals(ownerCacheKey),
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

  /// Deletes all local practice rows and files for the current session's [cacheKey].
  /// Call before sign-out (e.g. after server account deletion).
  Future<void> wipeAllDataForCurrentUser() async {
    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      return;
    }

    final entries = await (_database.select(
      _database.localPracticeEntries,
    )..where((table) => table.ownerCacheKey.equals(ownerCacheKey))).get();

    for (final entry in entries) {
      await deleteVideo(entry.id);
    }
  }

  Future<void> deleteVideo(String id) async {
    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      return;
    }

    final entry =
        await (_database.select(_database.localPracticeEntries)..where(
              (table) =>
                  table.id.equals(id) &
                  table.ownerCacheKey.equals(ownerCacheKey),
            ))
            .getSingleOrNull();
    if (entry == null) {
      return;
    }

    await (_database.delete(_database.localPracticeEntries)..where(
          (table) =>
              table.id.equals(id) & table.ownerCacheKey.equals(ownerCacheKey),
        ))
        .go();

    await _deleteCueAttemptsForMediaItem(
      ownerCacheKey: ownerCacheKey,
      mediaItemId: id,
    );

    final file = File(await _resolveVideoPath(entry.localVideoPath));
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
      await (_database.update(_database.localPracticeEntries)..where(
            (table) =>
                table.id.equals(id) & table.ownerCacheKey.equals(ownerCacheKey),
          ))
          .write(
            LocalPracticeEntriesCompanion(
              translatedLanguage: drift.Value(translatedLanguage),
              updatedAtMillis: drift.Value(now),
              lastOpenedAtMillis: drift.Value(now),
            ),
          );
      await (_database.update(
        _database.localPracticeCueEntries,
      )..where((table) => table.itemId.equals(id))).write(
        const LocalPracticeCueEntriesCompanion(translatedText: drift.Value('')),
      );
      await (_database.delete(_database.localPracticeTranslationEntries)..where(
            (table) =>
                table.itemId.equals(id) &
                table.targetLanguage.equals(translatedLanguage),
          ))
          .go();
    });

    if (_activeOwnerCacheKey == ownerCacheKey) {
      await refreshForCurrentUser(showLoadingState: false);
    }
  }

  Future<void> storeTranslations({
    required String id,
    required String translatedLanguage,
    required String cueMode,
    required Map<String, String> translations,
    bool refreshSummaries = true,
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
      await (_database.update(_database.localPracticeEntries)..where(
            (table) =>
                table.id.equals(id) & table.ownerCacheKey.equals(ownerCacheKey),
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
          final text = entry.value.trim();
          if (text.isEmpty) {
            continue;
          }
          batch.insert(
            _database.localPracticeTranslationEntries,
            LocalPracticeTranslationEntriesCompanion.insert(
              itemId: id,
              targetLanguage: translatedLanguage,
              cueMode: cueMode,
              cueId: entry.key,
              translatedText: text,
              updatedAtMillis: now,
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
          if (cueMode == 'long') {
            batch.update(
              _database.localPracticeCueEntries,
              LocalPracticeCueEntriesCompanion(
                translatedText: drift.Value(text),
              ),
              where: (table) =>
                  table.itemId.equals(id) & table.id.equals(entry.key),
            );
          }
        }
      });
    });

    if (refreshSummaries && _activeOwnerCacheKey == ownerCacheKey) {
      await refreshForCurrentUser(showLoadingState: false);
    }
  }

  Future<Map<String, String>> fetchTranslations({
    required String id,
    required String translatedLanguage,
    required String cueMode,
  }) async {
    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      return const {};
    }

    final entry =
        await (_database.select(_database.localPracticeEntries)..where(
              (table) =>
                  table.id.equals(id) &
                  table.ownerCacheKey.equals(ownerCacheKey),
            ))
            .getSingleOrNull();
    if (entry == null) {
      return const {};
    }

    final rows =
        await (_database.select(_database.localPracticeTranslationEntries)
              ..where(
                (table) =>
                    table.itemId.equals(id) &
                    table.targetLanguage.equals(translatedLanguage) &
                    table.cueMode.equals(cueMode),
              ))
            .get();
    if (rows.isNotEmpty) {
      return {
        for (final row in rows)
          if (row.translatedText.trim().isNotEmpty)
            row.cueId: row.translatedText,
      };
    }

    if (cueMode != 'long' ||
        entry.translatedLanguage?.trim() != translatedLanguage.trim()) {
      return const {};
    }

    final legacyRows = await (_database.select(
      _database.localPracticeCueEntries,
    )..where((table) => table.itemId.equals(id))).get();
    return {
      for (final row in legacyRows)
        if (row.translatedText.trim().isNotEmpty) row.id: row.translatedText,
    };
  }

  Future<LocalCuePracticeAttempt> saveCueAttempt({
    required String mediaItemId,
    required String cueId,
    required String transcriptText,
    required String sourceLocaleIdentifier,
    required String audioPath,
    required int matchedCount,
    required int unexpectedCount,
    required int missingCount,
    required int recordingDurationMs,
  }) async {
    final ownerCacheKey = _currentOwnerCacheKey ?? 'local-device-user';
    final attemptId = 'attempt-${DateTime.now().microsecondsSinceEpoch}';
    final persistedAudio = await _persistAttemptAudio(
      id: attemptId,
      sourcePath: audioPath,
    );
    final createdAtMillis = DateTime.now().millisecondsSinceEpoch;

    await _database
        .into(_database.localCueAttemptEntries)
        .insertOnConflictUpdate(
          LocalCueAttemptEntriesCompanion.insert(
            id: attemptId,
            ownerCacheKey: ownerCacheKey,
            mediaItemId: mediaItemId,
            cueId: cueId,
            transcriptText: transcriptText.trim(),
            sourceLocaleIdentifier: sourceLocaleIdentifier.trim(),
            audioPath: await _storedAttemptReferenceFor(persistedAudio),
            matchedCount: matchedCount,
            unexpectedCount: unexpectedCount,
            missingCount: missingCount,
            recordingDurationMs: recordingDurationMs,
            createdAtMillis: createdAtMillis,
          ),
        );

    final savedAttempts = await _loadCueAttempts(
      ownerCacheKey,
      mediaItemId: mediaItemId,
      cueId: cueId,
    );
    final saved = savedAttempts.cast<LocalCuePracticeAttempt?>().firstWhere(
      (attempt) => attempt?.id == attemptId,
      orElse: () => null,
    );
    if (saved == null) {
      throw const LocalPracticeRepositoryException(
        'Bantera could not save this attempt on your iPhone.',
      );
    }

    return saved;
  }

  Future<List<LocalCuePracticeAttempt>> fetchCueAttempts({
    required String mediaItemId,
    required String cueId,
  }) async {
    final ownerCacheKey = _currentOwnerCacheKey;
    if (ownerCacheKey == null) {
      return const [];
    }

    return _loadCueAttempts(
      ownerCacheKey,
      mediaItemId: mediaItemId,
      cueId: cueId,
    );
  }

  Future<List<LocalPracticeVideoSummary>> _loadSummaries(
    String ownerCacheKey,
  ) async {
    final entries =
        await (_database.select(_database.localPracticeEntries)
              ..where((table) => table.ownerCacheKey.equals(ownerCacheKey))
              ..orderBy([
                (table) => drift.OrderingTerm.desc(table.updatedAtMillis),
              ]))
            .get();

    final normalized = <LocalPracticeVideoSummary>[];
    for (final entry in entries) {
      normalized.add(await _mapSummary(await _normalizeEntryPath(entry)));
    }
    return normalized;
  }

  Future<List<LocalCuePracticeAttempt>> _loadCueAttempts(
    String ownerCacheKey, {
    required String mediaItemId,
    required String cueId,
  }) async {
    final entries =
        await (_database.select(_database.localCueAttemptEntries)
              ..where(
                (table) =>
                    table.ownerCacheKey.equals(ownerCacheKey) &
                    table.mediaItemId.equals(mediaItemId) &
                    table.cueId.equals(cueId),
              )
              ..orderBy([
                (table) => drift.OrderingTerm.desc(table.createdAtMillis),
              ]))
            .get();

    final attempts = <LocalCuePracticeAttempt>[];
    final missingIds = <String>[];
    for (final entry in entries) {
      final normalizedEntry = await _normalizeCueAttemptPath(entry);
      final resolvedAudioPath = await _resolveAttemptPath(
        normalizedEntry.audioPath,
      );
      if (!await File(resolvedAudioPath).exists()) {
        missingIds.add(entry.id);
        continue;
      }
      attempts.add(_mapCueAttempt(normalizedEntry, resolvedAudioPath));
    }

    if (missingIds.isNotEmpty) {
      await (_database.delete(
        _database.localCueAttemptEntries,
      )..where((table) => table.id.isIn(missingIds))).go();
    }

    return attempts;
  }

  Future<LocalPracticeVideoSummary> _mapSummary(
    LocalPracticeEntry entry,
  ) async {
    final resolvedVideoPath = await _resolveVideoPath(entry.localVideoPath);
    return LocalPracticeVideoSummary(
      id: entry.id,
      title: entry.title,
      transcriptPreview: entry.transcriptPreview,
      spokenLanguage: entry.spokenLanguage,
      accent: entry.accent,
      durationMs: entry.durationMs,
      cueCount: entry.cueCount,
      fileSizeBytes: entry.fileSizeBytes,
      localVideoPath: resolvedVideoPath,
      translatedLanguage: entry.translatedLanguage,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entry.createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entry.updatedAtMillis),
      lastOpenedAt: entry.lastOpenedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(entry.lastOpenedAtMillis!),
    );
  }

  Future<LocalPracticeVideo> _mapVideo(
    LocalPracticeEntry entry,
    List<LocalPracticeCueEntry> cues,
  ) async {
    final resolvedVideoPath = await _resolveVideoPath(entry.localVideoPath);
    return LocalPracticeVideo(
      id: entry.id,
      title: entry.title,
      transcriptPreview: entry.transcriptPreview,
      spokenLanguage: entry.spokenLanguage,
      accent: entry.accent,
      durationMs: entry.durationMs,
      cueCount: entry.cueCount,
      fileSizeBytes: entry.fileSizeBytes,
      localVideoPath: resolvedVideoPath,
      translatedLanguage: entry.translatedLanguage,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entry.createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entry.updatedAtMillis),
      lastOpenedAt: entry.lastOpenedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(entry.lastOpenedAtMillis!),
      description: entry.description,
      transcriptionSource: entry.transcriptionSource,
      cues: cues
          .map((cue) {
            return Cue(
              id: cue.id,
              startTimeMs: cue.startTimeMs,
              endTimeMs: cue.endTimeMs,
              originalText: cue.originalText,
              translatedText: cue.translatedText,
            );
          })
          .toList(growable: false),
    );
  }

  LocalCuePracticeAttempt _mapCueAttempt(
    LocalCueAttemptEntry entry,
    String resolvedAudioPath,
  ) {
    return LocalCuePracticeAttempt(
      id: entry.id,
      mediaItemId: entry.mediaItemId,
      cueId: entry.cueId,
      transcriptText: entry.transcriptText,
      sourceLocaleIdentifier: entry.sourceLocaleIdentifier,
      audioPath: resolvedAudioPath,
      matchedCount: entry.matchedCount,
      unexpectedCount: entry.unexpectedCount,
      missingCount: entry.missingCount,
      recordingDurationMs: entry.recordingDurationMs,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entry.createdAtMillis),
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

  Future<File> _persistAttemptAudio({
    required String id,
    required String sourcePath,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw const LocalPracticeRepositoryException(
        'Bantera could not access the recorded attempt audio.',
      );
    }

    final directory = await _attemptAudioDirectory;
    await directory.create(recursive: true);

    final extension = p.extension(sourceFile.path).trim();
    final destination = File(
      p.join(directory.path, '$id${extension.isEmpty ? '.wav' : extension}'),
    );

    if (p.normalize(sourceFile.path) == p.normalize(destination.path)) {
      return sourceFile;
    }

    final copied = await sourceFile.copy(destination.path);
    try {
      await sourceFile.delete();
    } catch (_) {
      // Leave temporary recorder files alone if iOS is still holding them.
    }

    return copied;
  }

  Future<String> _storedVideoReferenceFor(File file) async {
    final resolvedPath = file.absolute.path;
    final supportDirectory = await getApplicationSupportDirectory();
    final supportPath = p.normalize(supportDirectory.path);
    final normalizedPath = p.normalize(resolvedPath);

    if (p.isWithin(supportPath, normalizedPath)) {
      return p.relative(normalizedPath, from: supportPath);
    }

    return normalizedPath;
  }

  Future<String> _storedAttemptReferenceFor(File file) async {
    final resolvedPath = file.absolute.path;
    final supportDirectory = await getApplicationSupportDirectory();
    final supportPath = p.normalize(supportDirectory.path);
    final normalizedPath = p.normalize(resolvedPath);

    if (p.isWithin(supportPath, normalizedPath)) {
      return p.relative(normalizedPath, from: supportPath);
    }

    return normalizedPath;
  }

  Future<String> _resolveVideoPath(String storedReference) async {
    final normalizedReference = p.normalize(storedReference.trim());
    if (normalizedReference.isEmpty) {
      return normalizedReference;
    }

    if (!p.isAbsolute(normalizedReference)) {
      final supportDirectory = await getApplicationSupportDirectory();
      return p.normalize(p.join(supportDirectory.path, normalizedReference));
    }

    final existingAbsolute = File(normalizedReference);
    if (await existingAbsolute.exists()) {
      return existingAbsolute.path;
    }

    final remapped = await _remapManagedAbsolutePath(normalizedReference);
    if (remapped != null) {
      return remapped;
    }

    return normalizedReference;
  }

  Future<String> _resolveAttemptPath(String storedReference) async {
    final normalizedReference = p.normalize(storedReference.trim());
    if (normalizedReference.isEmpty) {
      return normalizedReference;
    }

    if (!p.isAbsolute(normalizedReference)) {
      final supportDirectory = await getApplicationSupportDirectory();
      return p.normalize(p.join(supportDirectory.path, normalizedReference));
    }

    final existingAbsolute = File(normalizedReference);
    if (await existingAbsolute.exists()) {
      return existingAbsolute.path;
    }

    final remapped = await _remapManagedAttemptAbsolutePath(
      normalizedReference,
    );
    if (remapped != null) {
      return remapped;
    }

    return normalizedReference;
  }

  Future<String?> _remapManagedAbsolutePath(String absolutePath) async {
    final normalizedAbsolute = p.normalize(absolutePath);
    final markerIndex = normalizedAbsolute.indexOf(_managedVideoMarker);
    if (markerIndex < 0) {
      return null;
    }

    final relativeSuffix = normalizedAbsolute.substring(
      markerIndex + _managedVideoMarker.length,
    );
    final directory = await _localVideoDirectory;
    final candidate = File(p.normalize(p.join(directory.path, relativeSuffix)));
    if (await candidate.exists()) {
      return candidate.path;
    }

    return null;
  }

  Future<String?> _remapManagedAttemptAbsolutePath(String absolutePath) async {
    final normalizedAbsolute = p.normalize(absolutePath);
    final markerIndex = normalizedAbsolute.indexOf(_managedAttemptMarker);
    if (markerIndex < 0) {
      return null;
    }

    final relativeSuffix = normalizedAbsolute.substring(
      markerIndex + _managedAttemptMarker.length,
    );
    final directory = await _attemptAudioDirectory;
    final candidate = File(p.normalize(p.join(directory.path, relativeSuffix)));
    if (await candidate.exists()) {
      return candidate.path;
    }

    return null;
  }

  Future<LocalPracticeEntry> _normalizeEntryPath(
    LocalPracticeEntry entry,
  ) async {
    final resolvedPath = await _resolveVideoPath(entry.localVideoPath);
    final preferredStoredReference = await _storedReferenceForResolvedPath(
      resolvedPath,
    );

    final normalizedStoredPath = p.normalize(entry.localVideoPath.trim());
    final normalizedPreferred = p.normalize(preferredStoredReference);

    if (normalizedStoredPath == normalizedPreferred) {
      return entry.copyWith(localVideoPath: normalizedPreferred);
    }

    await (_database.update(
      _database.localPracticeEntries,
    )..where((table) => table.id.equals(entry.id))).write(
      LocalPracticeEntriesCompanion(
        localVideoPath: drift.Value(preferredStoredReference),
      ),
    );

    return entry.copyWith(localVideoPath: preferredStoredReference);
  }

  Future<LocalCueAttemptEntry> _normalizeCueAttemptPath(
    LocalCueAttemptEntry entry,
  ) async {
    final resolvedPath = await _resolveAttemptPath(entry.audioPath);
    final preferredStoredReference = await _storedReferenceForResolvedPath(
      resolvedPath,
    );

    final normalizedStoredPath = p.normalize(entry.audioPath.trim());
    final normalizedPreferred = p.normalize(preferredStoredReference);

    if (normalizedStoredPath == normalizedPreferred) {
      return entry.copyWith(audioPath: normalizedPreferred);
    }

    await (_database.update(
      _database.localCueAttemptEntries,
    )..where((table) => table.id.equals(entry.id))).write(
      LocalCueAttemptEntriesCompanion(
        audioPath: drift.Value(preferredStoredReference),
      ),
    );

    return entry.copyWith(audioPath: preferredStoredReference);
  }

  Future<String> _storedReferenceForResolvedPath(String resolvedPath) async {
    final normalizedResolved = p.normalize(resolvedPath);
    if (!p.isAbsolute(normalizedResolved)) {
      return normalizedResolved;
    }

    final supportDirectory = await getApplicationSupportDirectory();
    final supportPath = p.normalize(supportDirectory.path);
    if (p.isWithin(supportPath, normalizedResolved)) {
      return p.relative(normalizedResolved, from: supportPath);
    }

    return normalizedResolved;
  }

  Future<Directory> get _localVideoDirectory async {
    final supportDirectory = await getApplicationSupportDirectory();
    return Directory(p.join(supportDirectory.path, 'local_practice_videos'));
  }

  Future<Directory> get _attemptAudioDirectory async {
    final supportDirectory = await getApplicationSupportDirectory();
    return Directory(p.join(supportDirectory.path, 'compare_attempts'));
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

  Future<void> _deleteCueAttemptsForMediaItem({
    required String ownerCacheKey,
    required String mediaItemId,
  }) async {
    final entries =
        await (_database.select(_database.localCueAttemptEntries)..where(
              (table) =>
                  table.ownerCacheKey.equals(ownerCacheKey) &
                  table.mediaItemId.equals(mediaItemId),
            ))
            .get();

    await (_database.delete(_database.localCueAttemptEntries)..where(
          (table) =>
              table.ownerCacheKey.equals(ownerCacheKey) &
              table.mediaItemId.equals(mediaItemId),
        ))
        .go();

    for (final entry in entries) {
      final file = File(await _resolveAttemptPath(entry.audioPath));
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
