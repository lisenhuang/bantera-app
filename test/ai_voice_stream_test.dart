import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_voice_stream.dart';

void main() {
  test(
    'uploads before send, streams playback before completion, and resets partial retries',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = StreamController<dynamic>();
      final peer = Completer<WebSocket>();
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        peer.complete(socket);
        socket.listen(received.add);
      });
      final played = <List<int>>[];
      var resets = 0;
      final stream = AiVoiceStream(
        connect: () => WebSocket.connect('ws://127.0.0.1:${server.port}'),
        onAudio: (bytes) async => played.add(bytes),
        onReset: () async {
          resets++;
        },
      );
      final incoming = StreamIterator(received.stream);
      try {
        stream.add(
          Uint8List.fromList([1, 2, 3, 4]),
        ); // During connection setup.
        final socket = await peer.future;
        socket.add(jsonEncode({'type': 'ready'}));
        expect(await incoming.moveNext(), true);
        expect(incoming.current, [1, 2, 3, 4]);
        expect(stream.committed, false);
        stream.add(Uint8List.fromList([5, 6]));
        expect(await incoming.moveNext(), true);
        expect(incoming.current, [5, 6]);
        final result = stream.send({
          'clock': {'timeZone': 'Pacific/Auckland'},
        });
        expect(await incoming.moveNext(), true);
        expect(jsonDecode(incoming.current as String)['type'], 'commit');
        socket.add([10, 11]);
        await _until(() => played.length == 1);
        expect(played.single, [
          10,
          11,
        ]); // Playback starts without waiting for complete.
        socket.add(jsonEncode({'type': 'reset'}));
        socket.add([12, 13]);
        await _until(() => played.length == 2);
        expect(resets, 1);
        socket.add(
          jsonEncode({
            'type': 'complete',
            'inputText': 'Hello',
            'outputText': 'Hi',
          }),
        );
        final reply = await result;
        expect(reply['inputText'], 'Hello');
        final wave = base64Decode(reply['audio'] as String);
        expect(wave.sublist(44), [12, 13]); // Old partial output was discarded.
        await socket.close();
      } finally {
        await stream.close();
        await incoming.cancel();
        await received.close();
        await server.close(force: true);
      }
    },
  );

  test(
    'cancel before connection completes closes it without committing',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final closed = Completer<void>();
      final gate = Completer<void>();
      var messages = 0;
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        socket.listen(
          (_) {
            messages++;
          },
          onDone: () {
            closed.complete();
          },
        );
      });
      final stream = AiVoiceStream(
        connect: () async {
          await gate.future;
          return WebSocket.connect('ws://127.0.0.1:${server.port}');
        },
        onAudio: (_) async {},
        onReset: () async {},
      );
      stream.add(Uint8List(320));
      await stream.close();
      gate.complete();
      await closed.future.timeout(const Duration(seconds: 3));
      expect(messages, 0);
      expect(stream.committed, false);
      await server.close(force: true);
    },
  );

  test(
    'post-commit disconnect fails without silently resending the message',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        socket.add(jsonEncode({'type': 'ready'}));
        socket.listen((event) {
          if (event is String && jsonDecode(event)['type'] == 'commit') {
            socket.close();
          }
        });
      });
      final stream = AiVoiceStream(
        connect: () => WebSocket.connect('ws://127.0.0.1:${server.port}'),
        onAudio: (_) async {},
        onReset: () async {},
      );
      stream.add(Uint8List(320));
      await expectLater(stream.send({}), throwsStateError);
      expect(stream.committed, true);
      await stream.close();
      await server.close(force: true);
    },
  );
}

Future<void> _until(bool Function() check) async {
  for (var n = 0; n < 100; n++) {
    if (check()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for audio event');
}
