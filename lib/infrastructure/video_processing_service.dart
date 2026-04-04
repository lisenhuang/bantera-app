import 'dart:io';

import 'package:flutter/services.dart';

import '../domain/models/models.dart';

class TranscriptionLocaleOption {
  const TranscriptionLocaleOption({
    required this.identifier,
    required this.displayName,
    required this.isInstalled,
  });

  factory TranscriptionLocaleOption.fromMap(Map<Object?, Object?> map) {
    return TranscriptionLocaleOption(
      identifier: map['identifier']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      isInstalled: map['isInstalled'] == true,
    );
  }

  final String identifier;
  final String displayName;
  final bool isInstalled;
}

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

  Future<List<TranscriptionLocaleOption>> fetchSupportedLocales() async {
    if (!Platform.isIOS) {
      throw const VideoProcessingException(
        code: 'unsupported_platform',
        message: 'Video transcription is currently available on iPhone only.',
      );
    }

    try {
      final locales =
          await _channel.invokeListMethod<dynamic>(
            'getSupportedTranscriptionLocales',
          ) ??
          const <dynamic>[];

      return locales
          .whereType<Map<Object?, Object?>>()
          .map(TranscriptionLocaleOption.fromMap)
          .where((option) => option.identifier.isNotEmpty)
          .toList();
    } on PlatformException catch (error) {
      throw VideoProcessingException(
        code: error.code,
        message:
            error.message ??
            'The app could not load the transcription language list.',
      );
    } on MissingPluginException {
      throw const VideoProcessingException(
        code: 'missing_native_bridge',
        message: 'The Bantera iOS video bridge is not available in this build.',
      );
    }
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
