import 'dart:typed_data';
import 'package:app/infrastructure/audio_waveform.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/chat_audio_waveform.dart';
import 'package:app/presentation/chats/chat_bubble_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'waveform follows real amplitude and silence instead of invented bars',
    () {
      final pcm = Uint8List(128 * 2);
      final data = ByteData.sublistView(pcm);
      for (var i = 32; i < 64; i++) {
        data.setInt16(i * 2, 8192, Endian.little);
      }
      for (var i = 64; i < 96; i++) {
        data.setInt16(i * 2, -32768, Endian.little);
      }
      final peaks = wavePeaks(aiWave(pcm, 16000));
      expect(peaks.length, 64);
      expect(peaks.take(16), everyElement(0));
      expect(peaks.skip(16).take(16), everyElement(.25));
      expect(peaks.skip(32).take(16), everyElement(1));
      expect(peaks.skip(48), everyElement(0));
    },
  );
  test('malformed and truncated audio does not produce fake amplitude', () {
    expect(wavePeaks(Uint8List(3)), isEmpty);
    final wav = aiWave(Uint8List(128), 16000);
    expect(wavePeaks(wav.sublist(0, wav.length - 1)), isEmpty);
  });
  testWidgets('waveform keeps controls in one row at phone width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: ChatAudioHeader(
              playing: true,
              progress: .5,
              duration: '3:00',
              onPlay: () {},
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.translate),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(ChatAudioWaveform), findsOneWidget);
    expect(
      tester.getCenter(find.byIcon(Icons.translate)).dy,
      tester.getCenter(find.text('3:00')).dy,
    );
  });
}
