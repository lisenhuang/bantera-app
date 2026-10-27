import 'package:flutter/services.dart';

import '../domain/models/models.dart';
import '../core/apple_system_version.dart';
import 'transcription_locale_option.dart';

class TranslationLocaleOption {
  const TranslationLocaleOption({
    required this.identifier,
    required String displayName,
    required this.isInstalled,
  }) : _displayName = displayName;

  factory TranslationLocaleOption.fromMap(Map<Object?, Object?> map) {
    return TranslationLocaleOption(
      identifier: map['identifier']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      isInstalled: map['isInstalled'] == true,
    );
  }

  final String identifier;
  final String _displayName;
  String get displayName => localeDisplayName(identifier, _displayName);
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

  static void _requireSupport() {
    if (!supportsBuiltInTranslation) {
      throw const TranslationException(
        code: 'unsupported_os',
        message: 'On-device translation is unavailable on this device.',
      );
    }
  }

  /// End only the named Practice request. OS-managed model downloads may
  /// continue, but the caller can move on to a different language immediately.
  Future<void> cancelRequest(String requestId) async {
    try {
      await _channel.invokeMethod<void>('cancelTranslation', {
        'requestId': requestId,
      });
    } on PlatformException {
      // The old result is also invalidated by the caller.
    } on MissingPluginException {
      // Compatibility with platforms that do not present a native session.
    }
  }

  /// Ensures on-device translation language packs are downloaded for the pair.
  /// On iOS 18+, may present the system download UI (SwiftUI `translationTask`).
  /// No-op when both languages are already installed.
  Future<void> prepareTranslationAssets({
    required String sourceLocaleIdentifier,
    required String targetLocaleIdentifier,
    String? requestId,
  }) async {
    if (isMaoriLanguage(sourceLocaleIdentifier) ||
        isMaoriLanguage(targetLocaleIdentifier))
      return;
    _requireSupport();
    // iOS: Apple Translation framework. Android: Google ML Kit (both on-device).
    try {
      await _channel
          .invokeMethod<void>('prepareTranslationAssets', <String, Object?>{
            'requestId': ?requestId,
            'sourceLocaleIdentifier': sourceLocaleIdentifier,
            'targetLocaleIdentifier': targetLocaleIdentifier,
          });
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

  /// Fetches all iOS built-in translation locales without source-locale filtering.
  /// Used for native-language pickers that need the full translation language list.
  /// Returns empty list on non-iOS or when unavailable.
  Future<List<TranslationLocaleOption>> fetchAllTranslationLocales() async {
    if (!supportsBuiltInTranslation) return const [];
    try {
      final locales =
          await _channel.invokeListMethod<dynamic>(
            'getAllSupportedTranslationLocales',
          ) ??
          const <dynamic>[];
      return locales
          .whereType<Map<Object?, Object?>>()
          .map(TranslationLocaleOption.fromMap)
          .where((option) => option.identifier.isNotEmpty)
          .toList();
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  Future<List<TranslationLocaleOption>> fetchSupportedLocales({
    required String sourceLocaleIdentifier,
  }) async {
    if (isMaoriLanguage(sourceLocaleIdentifier)) return const [];
    _requireSupport();
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
    String? requestId,
  }) async {
    if (isMaoriLanguage(sourceLocaleIdentifier) ||
        isMaoriLanguage(targetLocaleIdentifier))
      return const {};
    _requireSupport();
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
              'requestId': ?requestId,
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
