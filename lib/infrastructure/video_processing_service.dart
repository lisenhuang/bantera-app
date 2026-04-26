import 'dart:io';

import 'package:flutter/services.dart';

import '../domain/models/models.dart';
import '../core/settings_notifier.dart';
import 'auth_api_client.dart';
import 'learning_language_catalog.dart';
import 'transcription_locale_option.dart';
import 'translation_service.dart';

export 'transcription_locale_option.dart';

class PreparedVideoUpload {
  const PreparedVideoUpload({
    required this.file,
    required this.fileName,
    required this.transcriptText,
    required this.transcriptLanguage,
    required this.transcriptLanguageCode,
    required this.transcriptCues,
    required this.durationMs,
    required this.fileSizeBytes,
    required this.videoWidth,
    required this.videoHeight,
    required this.contentType,
    required this.shouldDeleteAfterUse,
  });

  final File file;
  final String fileName;
  final String transcriptText;
  final String transcriptLanguage;
  final String transcriptLanguageCode;
  final List<VideoTranscriptCue> transcriptCues;
  final int durationMs;
  final int fileSizeBytes;
  final int? videoWidth;
  final int? videoHeight;
  final String contentType;
  final bool shouldDeleteAfterUse;
}

class RecordedAttemptTranscription {
  const RecordedAttemptTranscription({
    required this.transcriptText,
    required this.transcriptLanguage,
    required this.transcriptLanguageCode,
  });

  final String transcriptText;
  final String transcriptLanguage;
  final String transcriptLanguageCode;
}

class VideoProcessingException implements Exception {
  const VideoProcessingException({required this.code, required this.message});

  final String code;
  final String message;
}

class VideoProcessingService {
  VideoProcessingService._();

  static final VideoProcessingService instance = VideoProcessingService._();
  static const MethodChannel _channel = MethodChannel(
    'bantera/video_processing',
  );

  /// Ensures on-device SpeechTranscriber assets for [localeIdentifier] are
  /// downloaded (iOS 26+). Call before long-running work that will transcribe
  /// later (e.g. AI audio generation) so the user isn’t stuck after dialogue
  /// generation waiting for the model.
  Future<void> ensureTranscriptionModelInstalled({
    required String localeIdentifier,
  }) async {
    if (!Platform.isIOS) {
      throw const VideoProcessingException(
        code: 'unsupported_platform',
        message: 'Video transcription is currently available on iPhone only.',
      );
    }

    try {
      await _channel.invokeMethod<void>(
        'ensureTranscriptionModelInstalled',
        <String, Object?>{'localeIdentifier': localeIdentifier},
      );
    } on PlatformException catch (error) {
      throw VideoProcessingException(
        code: error.code,
        message:
            error.message ??
            'The speech recognition model could not be prepared.',
      );
    } on MissingPluginException {
      throw const VideoProcessingException(
        code: 'missing_native_bridge',
        message: 'The Bantera iOS video bridge is not available in this build.',
      );
    }
  }

  Future<void> ensureRecordedAudioTranscriptionReady({
    required String localeIdentifier,
  }) async {
    if (!Platform.isIOS) {
      throw const VideoProcessingException(
        code: 'unsupported_platform',
        message: 'Audio comparison is currently available on iPhone only.',
      );
    }

    try {
      await _channel.invokeMethod<void>(
        'ensureRecordedAudioTranscriptionReady',
        <String, Object?>{'localeIdentifier': localeIdentifier},
      );
    } on PlatformException catch (error) {
      throw VideoProcessingException(
        code: error.code,
        message:
            error.message ??
            'Speech recognition could not be prepared for this recording.',
      );
    } on MissingPluginException {
      throw const VideoProcessingException(
        code: 'missing_native_bridge',
        message: 'The Bantera iOS video bridge is not available in this build.',
      );
    }
  }

  static List<TranscriptionLocaleOption> _withoutZhTw(
    List<TranscriptionLocaleOption> options,
  ) => options.where((o) => o.identifier != 'zh-TW').toList();

  Future<List<TranscriptionLocaleOption>>
  _fetchNativeTranscriptionLocales() async {
    final raw =
        await _channel.invokeListMethod<dynamic>(
          'getSupportedTranscriptionLocales',
        ) ??
        const <dynamic>[];
    return raw
        .whereType<Map<Object?, Object?>>()
        .map(TranscriptionLocaleOption.fromMap)
        .where((o) => o.identifier.isNotEmpty)
        .toList();
  }

  /// Resolves locales for the native-language picker: combines iOS transcription locales
  /// and iOS translation locales (deduped by identifier). Falls back to both API catalogs,
  /// then to embedded lists.
  Future<List<TranscriptionLocaleOption>> fetchNativeLanguageOptions() async {
    if (Platform.isIOS) {
      try {
        // a) iOS transcription locales
        final txOptions = await _fetchNativeTranscriptionLocales();

        // b) iOS translation locales (all, no source filter)
        final trOptions = await TranslationService.instance
            .fetchAllTranslationLocales();

        // c) Merge + deduplicate by identifier (transcription takes precedence)
        final seen = <String>{};
        final combined = <TranscriptionLocaleOption>[];
        for (final o in txOptions) {
          if (seen.add(o.identifier)) combined.add(o);
        }
        for (final t in trOptions) {
          if (seen.add(t.identifier)) {
            combined.add(
              TranscriptionLocaleOption(
                identifier: t.identifier,
                displayName: t.displayName,
                isInstalled: t.isInstalled,
              ),
            );
          }
        }

        if (combined.isNotEmpty) return combined;
      } on PlatformException {
        // Fall through to API / embedded fallback.
      } on MissingPluginException {
        // Fall through to API / embedded fallback.
      } catch (_) {
        // Fall through to API / embedded fallback.
      }
    }

    // d) API fallback: transcription + translation catalogs
    final txApi = await AuthApiClient.instance.fetchLearningLanguagesCatalog();
    final trApi = await AuthApiClient.instance
        .fetchTranslationLanguagesCatalog();
    final allApi = [...(txApi ?? []), ...(trApi ?? [])];
    if (allApi.isNotEmpty) {
      final seen = <String>{};
      return allApi
          .where((r) => r.identifier.isNotEmpty && seen.add(r.identifier))
          .map(
            (r) => TranscriptionLocaleOption(
              identifier: r.identifier,
              displayName: r.displayName,
              isInstalled: false,
              flagEmoji: r.flagEmoji,
            ),
          )
          .toList();
    }

    // e) Embedded fallback: both lists deduped
    final seen = <String>{};
    return [
      ...kFallbackLearningLanguages,
      ...kFallbackTranslationLanguages,
    ].where((o) => seen.add(o.identifier)).toList();
  }

  /// Resolves locales for UI: public API first, then embedded [kFallbackLearningLanguages].
  /// Listing languages is supported on all platforms; transcription features remain
  /// iOS-only elsewhere.
  ///
  /// When [excludeZhTwForLearning] is true, drops `zh-TW` (product learning language
  /// uses Mandarin `zh` / zh-CN only). Native language pickers should pass false.
  Future<List<TranscriptionLocaleOption>> fetchSupportedLocales({
    bool excludeZhTwForLearning = false,
  }) async {
    List<TranscriptionLocaleOption> maybeFilter(
      List<TranscriptionLocaleOption> list,
    ) => excludeZhTwForLearning ? _withoutZhTw(list) : list;

    final fromApi = await AuthApiClient.instance
        .fetchLearningLanguagesCatalog();
    if (fromApi != null && fromApi.isNotEmpty) {
      return maybeFilter(
        fromApi
            .where((row) => row.identifier.isNotEmpty)
            .map(
              (row) => TranscriptionLocaleOption(
                identifier: row.identifier,
                displayName: row.displayName,
                isInstalled: false,
                flagEmoji: row.flagEmoji,
              ),
            )
            .toList(),
      );
    }

    return maybeFilter(
      List<TranscriptionLocaleOption>.from(kFallbackLearningLanguages),
    );
  }

  /// Resolves locales for learning-language pickers. In normal product mode this
  /// uses the API learning-language catalog. A Dev-only in-memory toggle can
  /// switch the picker to the full native iOS transcription locale list.
  Future<List<TranscriptionLocaleOption>> fetchLearningLanguageOptions() async {
    if (Platform.isIOS &&
        SettingsNotifier.instance.devShowAllLearningLanguages) {
      try {
        final nativeOptions = await _fetchNativeTranscriptionLocales();
        if (nativeOptions.isNotEmpty) {
          return nativeOptions;
        }
      } on PlatformException {
        // Fall through to product catalog.
      } on MissingPluginException {
        // Fall through to product catalog.
      } catch (_) {
        // Fall through to product catalog.
      }
    }

    return fetchSupportedLocales(excludeZhTwForLearning: true);
  }

  Future<PreparedVideoUpload> prepareVideoForUpload({
    required File inputFile,
    required String localeIdentifier,
  }) async {
    if (!Platform.isIOS) {
      throw const VideoProcessingException(
        code: 'unsupported_platform',
        message: 'Video transcription is currently available on iPhone only.',
      );
    }

    try {
      final response = await _channel.invokeMapMethod<Object?, Object?>(
        'prepareVideoForUpload',
        <String, Object?>{
          'inputPath': inputFile.path,
          'localeIdentifier': localeIdentifier,
        },
      );

      final map = response ?? const <Object?, Object?>{};
      final outputPath = map['outputPath']?.toString();
      if (outputPath == null || outputPath.isEmpty) {
        throw const VideoProcessingException(
          code: 'invalid_native_response',
          message:
              'The prepared video could not be loaded from the iOS bridge.',
        );
      }

      return PreparedVideoUpload(
        file: File(outputPath),
        fileName:
            map['fileName']?.toString() ?? inputFile.uri.pathSegments.last,
        transcriptText: map['transcriptText']?.toString() ?? '',
        transcriptLanguage:
            map['transcriptLanguage']?.toString() ?? localeIdentifier,
        transcriptLanguageCode:
            map['transcriptLanguageCode']?.toString() ??
            localeIdentifier.split(RegExp(r'[-_]')).first.toLowerCase(),
        transcriptCues: _parseTranscriptCues(map['transcriptCues']),
        durationMs: _toInt(map['durationMs']),
        fileSizeBytes: _toInt(map['fileSizeBytes']),
        videoWidth: _toNullableInt(map['videoWidth']),
        videoHeight: _toNullableInt(map['videoHeight']),
        contentType: map['contentType']?.toString() ?? 'video/mp4',
        shouldDeleteAfterUse: map['shouldDeleteAfterUse'] == true,
      );
    } on VideoProcessingException {
      rethrow;
    } on PlatformException catch (error) {
      throw VideoProcessingException(
        code: error.code,
        message:
            error.message ??
            'The app could not prepare the selected video for upload.',
      );
    } on MissingPluginException {
      throw const VideoProcessingException(
        code: 'missing_native_bridge',
        message: 'The Bantera iOS video bridge is not available in this build.',
      );
    }
  }

  Future<PreparedVideoUpload> transcribeAudioForUpload({
    required File inputFile,
    required String localeIdentifier,
  }) async {
    if (!Platform.isIOS) {
      throw const VideoProcessingException(
        code: 'unsupported_platform',
        message: 'Audio transcription is currently available on iPhone only.',
      );
    }

    try {
      final response = await _channel.invokeMapMethod<Object?, Object?>(
        'transcribeAudioForUpload',
        <String, Object?>{
          'inputPath': inputFile.path,
          'localeIdentifier': localeIdentifier,
        },
      );

      final map = response ?? const <Object?, Object?>{};
      return PreparedVideoUpload(
        file: inputFile,
        fileName: inputFile.uri.pathSegments.last,
        transcriptText: map['transcriptText']?.toString() ?? '',
        transcriptLanguage:
            map['transcriptLanguage']?.toString() ?? localeIdentifier,
        transcriptLanguageCode:
            map['transcriptLanguageCode']?.toString() ??
            localeIdentifier.split(RegExp(r'[-_]')).first.toLowerCase(),
        transcriptCues: _parseTranscriptCues(map['transcriptCues']),
        durationMs: 0,
        fileSizeBytes: 0,
        videoWidth: null,
        videoHeight: null,
        contentType: 'audio/wav',
        shouldDeleteAfterUse: false,
      );
    } on VideoProcessingException {
      rethrow;
    } on PlatformException catch (error) {
      throw VideoProcessingException(
        code: error.code,
        message:
            error.message ?? 'The app could not transcribe this audio file.',
      );
    } on MissingPluginException {
      throw const VideoProcessingException(
        code: 'missing_native_bridge',
        message: 'The Bantera iOS video bridge is not available in this build.',
      );
    }
  }

  Future<RecordedAttemptTranscription> transcribeRecordedAudio({
    required File inputFile,
    required String localeIdentifier,
  }) async {
    if (!Platform.isIOS) {
      throw const VideoProcessingException(
        code: 'unsupported_platform',
        message: 'Audio comparison is currently available on iPhone only.',
      );
    }

    try {
      final response = await _channel.invokeMapMethod<Object?, Object?>(
        'transcribeRecordedAudio',
        <String, Object?>{
          'inputPath': inputFile.path,
          'localeIdentifier': localeIdentifier,
        },
      );

      final map = response ?? const <Object?, Object?>{};
      return RecordedAttemptTranscription(
        transcriptText: map['transcriptText']?.toString().trim() ?? '',
        transcriptLanguage:
            map['transcriptLanguage']?.toString() ?? localeIdentifier,
        transcriptLanguageCode:
            map['transcriptLanguageCode']?.toString() ??
            localeIdentifier.split(RegExp(r'[-_]')).first.toLowerCase(),
      );
    } on PlatformException catch (error) {
      throw VideoProcessingException(
        code: error.code,
        message:
            error.message ??
            'The app could not transcribe this recorded attempt.',
      );
    } on MissingPluginException {
      throw const VideoProcessingException(
        code: 'missing_native_bridge',
        message: 'The Bantera iOS video bridge is not available in this build.',
      );
    }
  }

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return _toInt(value);
  }

  static List<VideoTranscriptCue> _parseTranscriptCues(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<Object?, Object?>>()
        .map(
          (cue) => VideoTranscriptCue.fromJson(
            cue.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((cue) => cue.text.isNotEmpty)
        .toList();
  }
}
