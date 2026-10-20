import 'dart:typed_data';
import 'dart:io';
import 'package:app/infrastructure/audio_waveform.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/chat_audio_waveform.dart';
import 'package:app/presentation/chats/chat_bubble_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'decoded waveform has full width in the Cue 1 column and animates progress',
    (tester) async {
      late File file;
      await tester.runAsync(() async {
        final directory = await Directory.systemTemp.createTemp(
          'cue-waveform-',
        );
        file = File('${directory.path}/cue.wav');
        await file.writeAsBytes(
          aiWave(Uint8List.fromList(List.filled(256, 64)), 16000),
        );
        await AudioWaveform.load(file.path);
      });
      addTearDown(() => file.parent.delete(recursive: true));
      Future<void> mount(double progress) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChatAudioWaveform(
                    progress: progress,
                    receiving: false,
                    animateProgress: true,
                    audioKey: file.path,
                    loadAudioPath: () async => file.path,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await mount(0);
      await tester.runAsync(() async {
        await AudioWaveform.load(file.path);
      });
      await tester.pumpAndSettle();
      final painted = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is AudioWaveformPainter,
      );
      expect(painted, findsOneWidget);
      expect(tester.getSize(painted), const Size(280, 32));
      await mount(.8);
      await tester.pump(const Duration(milliseconds: 90));
      final during =
          (tester.widget<CustomPaint>(painted).painter! as AudioWaveformPainter)
              .progress;
      expect(during, greaterThan(0));
      expect(during, lessThan(.8));
      await tester.pumpAndSettle();
      expect(
        (tester.widget<CustomPaint>(painted).painter! as AudioWaveformPainter)
            .progress,
        .8,
      );
      expect(tester.takeException(), isNull);
    },
  );
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
