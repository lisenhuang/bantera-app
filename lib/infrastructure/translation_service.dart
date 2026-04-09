import 'dart:io';

import 'package:flutter/services.dart';

import '../domain/models/models.dart';

class TranslationLocaleOption {
  const TranslationLocaleOption({
    required this.identifier,
    required this.displayName,
    required this.isInstalled,
  });

  factory TranslationLocaleOption.fromMap(Map<Object?, Object?> map) {
    return TranslationLocaleOption(
      identifier: map['identifier']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      isInstalled: map['isInstalled'] == true,
    );
  }

  final String identifier;
  final String displayName;
  final bool isInstalled;
}

class TranslationException implements Exception {
  const TranslationException({required this.code, required this.message});

  final String code;
  final String message;
}

class TranslationService {
  TranslationService._();

  static final TranslationService instance = TranslationService._();
  static const MethodChannel _channel = MethodChannel('bantera/translation');

  /// Ensures on-device translation language packs are downloaded for the pair.
  /// On iOS 26+, may present the system download UI (SwiftUI `translationTask`).
  /// No-op when the target is already installed.
  Future<void> prepareTranslationAssets({
    required String sourceLocaleIdentifier,
    required String targetLocaleIdentifier,
  }) async {
    if (!Platform.isIOS) {
      throw const TranslationException(
        code: 'unsupported_platform',
        message: 'Cue translation is currently available on iPhone only.',
      );
    }

    try {
      await _channel.invokeMethod<void>(
        'prepareTranslationAssets',
        <String, Object?>{
          'sourceLocaleIdentifier': sourceLocaleIdentifier,
          'targetLocaleIdentifier': targetLocaleIdentifier,
        },
      );
    } on PlatformException catch (error) {
      throw TranslationException(
        code: error.code,
        message:
            error.message ??
            'The app could not prepare on-device translation for this language.',
      );
    } on MissingPluginException {
      throw const TranslationException(
        code: 'missing_native_bridge',
        message: 'The Bantera iOS translation bridge is not available.',
      );
    }
  }

  Future<List<TranslationLocaleOption>> fetchSupportedLocales({
    required String sourceLocaleIdentifier,
  }) async {
    if (!Platform.isIOS) {
      throw const TranslationException(
        code: 'unsupported_platform',
        message: 'Cue translation is currently available on iPhone only.',
      );
    }

    try {
      final locales =
          await _channel.invokeListMethod<dynamic>(
            'getSupportedTranslationLocales',
            <String, Object?>{'sourceLocaleIdentifier': sourceLocaleIdentifier},
          ) ??
          const <dynamic>[];

      return locales
          .whereType<Map<Object?, Object?>>()
          .map(TranslationLocaleOption.fromMap)
          .where((option) => option.identifier.isNotEmpty)
          .toList();
    } on PlatformException catch (error) {
      throw TranslationException(
        code: error.code,
        message:
            error.message ??
            'The app could not load the translation language list.',
      );
    } on MissingPluginException {
      throw const TranslationException(
        code: 'missing_native_bridge',
        message: 'The Bantera iOS translation bridge is not available.',
      );
    }
  }

  Future<Map<String, String>> translateCues({
    required String sourceLocaleIdentifier,
    required String targetLocaleIdentifier,
    required List<Cue> cues,
  }) async {
    if (!Platform.isIOS) {
      throw const TranslationException(
        code: 'unsupported_platform',
        message: 'Cue translation is currently available on iPhone only.',
      );
    }

    final inputCues = cues
        .where((cue) => cue.originalText.trim().isNotEmpty)
        .map((cue) => <String, Object?>{'id': cue.id, 'text': cue.originalText})
        .toList();

    try {
      final response =
          await _channel.invokeListMethod<dynamic>(
            'translateTranscriptCues',
            <String, Object?>{
              'sourceLocaleIdentifier': sourceLocaleIdentifier,
              'targetLocaleIdentifier': targetLocaleIdentifier,
              'cues': inputCues,
            },
          ) ??
          const <dynamic>[];

      final translated = <String, String>{};
      for (final item in response.whereType<Map<Object?, Object?>>()) {
        final id = item['id']?.toString().trim() ?? '';
        final text = item['translatedText']?.toString() ?? '';
        if (id.isEmpty) {
          continue;
        }
        translated[id] = text;
      }

      return translated;
    } on PlatformException catch (error) {
      throw TranslationException(
        code: error.code,
        message:
            error.message ??
            'The app could not translate this listening practice session.',
      );
    } on MissingPluginException {
      throw const TranslationException(
        code: 'missing_native_bridge',
        message: 'The Bantera iOS translation bridge is not available.',
      );
    }
  }
}
