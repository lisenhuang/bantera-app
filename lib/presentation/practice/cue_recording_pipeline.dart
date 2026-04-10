import 'dart:io';

import '../../domain/models/models.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../../infrastructure/video_processing_service.dart';
import 'attempt_comparison.dart';

/// Outcome of transcribing and scoring a saved recording file.
class ProcessedCueAttempt {
  const ProcessedCueAttempt({
    required this.comparison,
    required this.resolvedAudioPath,
    this.savedAttempt,
    this.saveErrorMessage,
  });

  final AttemptComparisonResult comparison;
  final String resolvedAudioPath;
  final LocalCuePracticeAttempt? savedAttempt;
  final String? saveErrorMessage;
}

/// Transcribes [audioFile], compares to [expectedCueText], saves locally.
Future<ProcessedCueAttempt> processRecordingFile({
  required File audioFile,
  required String expectedCueText,
  required String mediaItemId,
  required String cueId,
  required String sourceLocaleIdentifier,
  required int recordingDurationMs,
}) async {
  final transcription = await VideoProcessingService.instance
      .transcribeRecordedAudio(
    inputFile: audioFile,
    localeIdentifier: sourceLocaleIdentifier,
  );
  final recognizedText = transcription.transcriptText.trim();
  if (recognizedText.isEmpty) {
    throw const VideoProcessingException(
      code: 'empty_transcript',
      message:
          'No transcript could be generated for this attempt. Try again closer to the microphone.',
    );
  }

  final comparison = buildAttemptComparison(
    expectedText: expectedCueText,
    actualText: recognizedText,
  );

  LocalCuePracticeAttempt? savedAttempt;
  String? saveFailureMessage;
  try {
    savedAttempt = await LocalPracticeRepository.instance.saveCueAttempt(
      mediaItemId: mediaItemId,
      cueId: cueId,
      transcriptText: recognizedText,
      sourceLocaleIdentifier: sourceLocaleIdentifier,
      audioPath: audioFile.path,
      matchedCount: comparison.matchedCount,
      unexpectedCount: comparison.unexpectedCount,
      missingCount: comparison.missingCount,
      recordingDurationMs: recordingDurationMs,
    );
  } on LocalPracticeRepositoryException catch (error) {
    saveFailureMessage = error.message;
  }

  return ProcessedCueAttempt(
    comparison: comparison,
    resolvedAudioPath: savedAttempt?.audioPath ?? audioFile.path,
    savedAttempt: savedAttempt,
    saveErrorMessage: saveFailureMessage,
  );
}
