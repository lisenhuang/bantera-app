import 'dart:convert';
import 'dart:io';

import 'package:app/domain/models/models.dart';
import 'package:app/infrastructure/practice_progress_store.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/practice/practice_player_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Go to first cue replays after the audio reaches its end', (
    tester,
  ) async {
    final directory = Directory.systemTemp.createTempSync(
      'bantera-cue-restart-',
    );
    addTearDown(() => directory.deleteSync(recursive: true));
    const mediaId = 'restart-audio';
    const url = 'https://example.test/audio.wav';
    final cache = Directory('${directory.path}/practice_audio_cache')
      ..createSync();
    File('${cache.path}/$mediaId.wav').writeAsBytesSync([1, 2]);
    File(
      '${cache.path}/$mediaId.json',
    ).writeAsStringSync(jsonEncode({'url': url}));
    final messenger = tester.binding.defaultBinaryMessenger;
    for (final channel in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
      'com.llfbandit.record/messages',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (_) async => null,
      );
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => directory.path,
    );
    await tester.runAsync(
      () => PracticeProgressStore.instance.setCueIndex(mediaId, 1),
    );
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    String? playerId;
    var releaseMode = 'ReleaseMode.release';
    var loaded = false;
    var position = 0;
    var resumes = 0;
    final seeks = <int>[];
    void emit(String event, [Object? value]) {
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'xyz.luan/audioplayers/events/$playerId',
        const StandardMethodCodec().encodeSuccessEnvelope({
          'event': event,
          'value': value,
        }),
        (_) {},
      );
    }

    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        final args = call.arguments as Map;
        switch (call.method) {
          case 'create':
            playerId = args['playerId'] as String;
            messenger.setMockMethodCallHandler(
              MethodChannel('xyz.luan/audioplayers/events/$playerId'),
              (_) async => null,
            );
          case 'setReleaseMode':
            releaseMode = args['releaseMode'] as String;
          case 'setSourceUrl':
            loaded = true;
            emit('audio.onPrepared', true);
          case 'getDuration':
            return 4000;
          case 'getCurrentPosition':
            return position;
          case 'seek':
            // Mirrors native iOS: a released AVPlayer has no current item,
            // so seeking cannot send the completion event Dart awaits.
            if (loaded) {
              position = args['position'] as int;
              seeks.add(position);
              emit('audio.onSeekComplete');
            }
          case 'resume':
            if (loaded) resumes++;
        }
        return null;
      },
    );
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final media = MediaItem(
      id: mediaId,
      title: 'Replay test',
      description: '',
      coverUrl: '',
      creator: User(
        id: 'owner',
        displayName: 'Owner',
        avatarUrl: '',
        firstLanguage: '',
        learningLanguage: '',
        level: '',
      ),
      spokenLanguage: 'English',
      accent: 'en-AU',
      durationMs: 4000,
      isAudioOnly: true,
      videoUrl: url,
      transcriptionSource: 'AI Generated',
      cues: [
        Cue(
          id: 'first',
          startTimeMs: 300,
          endTimeMs: 1900,
          originalText: 'First sentence.',
          translatedText: '',
        ),
        Cue(
          id: 'last',
          startTimeMs: 2200,
          endTimeMs: 4000,
          originalText: 'Last sentence.',
          translatedText: '',
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: PracticePlayerScreen(mediaItem: media, initialCueIndex: 1),
      ),
    );
    // Filesystem work runs outside the widget test's fake clock.
    for (var i = 0; i < 50 && !loaded; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(loaded, isTrue);
    expect(find.text('2/2'), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.play_circle_fill));
    await tester.pump();

    // Simulate natural completion, including release/reset by the native player.
    position = 0;
    if (releaseMode == 'ReleaseMode.release') loaded = false;
    emit('audio.onComplete');
    await tester.pump();
    expect(find.byIcon(CupertinoIcons.play_circle_fill), findsOneWidget);
    final playsBeforeRestart = resumes;

    await tester.tap(find.byIcon(CupertinoIcons.forward_fill));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Go to first cue'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1/2'), findsOneWidget);
    expect(seeks.last, 300);
    expect(resumes, playsBeforeRestart + 1);
    expect(
      await tester.runAsync(
        () => PracticeProgressStore.instance.getCueIndex(mediaId),
      ),
      0,
    );
    final progress = find.byKey(const ValueKey('practice-cue-progress'));
    final track = tester.getRect(progress);
    final time = tester.getRect(
      find.byKey(const ValueKey('practice-cue-time')),
    );
    expect(track.width, greaterThan(92));
    expect(time.center.dy, closeTo(track.center.dy, 1));
    await tester.tapAt(Offset(track.left + track.width * .4, track.center.dy));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1/2'), findsOneWidget);
    await tester.tapAt(Offset(track.right - 2, track.center.dy));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('2/2'), findsOneWidget);
    expect(seeks.last, 2200);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
  });
}
