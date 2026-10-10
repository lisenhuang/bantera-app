import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingSocket extends Fake implements WebSocket {
  final messages = <dynamic>[];

  @override
  void add(dynamic data) => messages.add(data);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const recorderChannel = MethodChannel('com.llfbandit.record/messages');
  const timezoneChannel = MethodChannel('flutter_timezone');
  late AiChatController chat;
  late _RecordingSocket socket;
  final audioMethods = <String>[];

  setUp(() {
    audioMethods.clear();
    messenger.setMockMethodCallHandler(recorderChannel, (_) async => null);
    messenger.setMockMethodCallHandler(
      timezoneChannel,
      (_) async => 'Pacific/Auckland',
    );
    messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
      audioMethods.add(call.method);
      return null;
    });
    chat =
        AiChatController.forTesting(
            AiHistoryStore('clock-test')..hasMetBanteraAi = true,
          )
          ..loaded = true
          ..calling = true
          ..connected = true;
    socket = _RecordingSocket();
  });

  tearDown(() {
    chat.dispose();
    messenger.setMockMethodCallHandler(recorderChannel, null);
    messenger.setMockMethodCallHandler(timezoneChannel, null);
    messenger.setMockMethodCallHandler(AiChatController.audio, null);
  });

  test(
    'microphone peaks during an AI reply send audio without a clock turn',
    () async {
      await chat.receiveCallEventForTesting(Uint8List(24000));
      await chat.receiveCallEventForTesting(
        jsonEncode({
          'type': 'transcript',
          'role': 'model',
          'text': 'Here is my answer.',
        }),
      );
      final reply = chat.messages.single;
      expect(chat.isReceiving(reply), isTrue);

      final silence = Uint8List(640);
      final loudPcm = Uint8List(640);
      final samples = ByteData.sublistView(loudPcm);
      for (var i = 0; i < loudPcm.length; i += 2) {
        samples.setInt16(i, -2400, Endian.little);
      }

      chat.microphoneForTesting(silence, socket);
      chat.microphoneForTesting(loudPcm, socket);
      chat.microphoneForTesting(silence, socket);
      // A previous clock update fetched the timezone asynchronously before
      // sending its text frame, so inspect after that work could complete.
      await Future<void>.delayed(Duration.zero);

      expect(socket.messages, hasLength(3));
      expect(socket.messages, everyElement(isA<Uint8List>()));
      expect(socket.messages[0], orderedEquals(silence));
      expect(socket.messages[1], orderedEquals(loudPcm));
      expect(socket.messages[2], orderedEquals(silence));
      expect(socket.messages.whereType<String>(), isEmpty);
      expect(chat.messages.single, same(reply));
      expect(chat.isReceiving(reply), isTrue);
      expect(audioMethods, ['feed']);
    },
  );

  test('microphone route events update the speaker without sending audio', () {
    chat.microphoneForTesting({'type': 'route', 'speaker': false}, socket);

    expect(chat.speaker, isFalse);
    expect(socket.messages, isEmpty);
    expect(chat.connected, isTrue);
    expect(chat.calling, isTrue);
  });
}
