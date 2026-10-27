import 'dart:io';
import 'package:app/core/apple_system_version.dart';
import 'package:app/infrastructure/translation_service.dart';
import 'package:app/infrastructure/video_processing_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Maori never invokes system translation or recorded transcription', () async {
    translationCapabilityForTesting = true;
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const translation = MethodChannel('bantera/translation');
    const transcription = MethodChannel('bantera/video_processing');
    var calls = 0;
    for (final channel in [translation, transcription]) {
      messenger.setMockMethodCallHandler(channel, (_) async { calls++; return null; });
    }
    addTearDown(() {
      translationCapabilityForTesting = null;
      for (final channel in [translation, transcription]) {
        messenger.setMockMethodCallHandler(channel, null);
      }
    });
    expect(await VideoProcessingService.instance.supportsPracticeTranscription('MI_nz'), isFalse);
    final transcript = await VideoProcessingService.instance.transcribeRecordedAudio(
      inputFile: File('/unused.m4a'), localeIdentifier: 'mi-NZ');
    expect(transcript.transcriptText, isEmpty);
    expect(await TranslationService.instance.fetchSupportedLocales(sourceLocaleIdentifier: 'mi-NZ'), isEmpty);
    await TranslationService.instance.prepareTranslationAssets(sourceLocaleIdentifier: 'mi-NZ', targetLocaleIdentifier: 'en-NZ');
    expect(calls, 0);
  });
}
