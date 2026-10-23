import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'ai_voice_overlap_test.dart' show Recorder, Api, Peer, until;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'reply can pause before completion and keep downloading while paused',
    () async {
      final dir = Directory.systemTemp.createTempSync('ai-pause');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final peers = <Peer>[];
      server.listen(
        (r) async => peers.add(Peer(await WebSocketTransformer.upgrade(r))),
      );
      final calls = <String>[];
      final drain = Completer<void>();
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (_) async => null,
      );
      messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
        calls.add(call.method);
        if (call.method == 'storagePath') return dir.path;
        if (call.method == 'playedFrames') return 1200;
        if (call.method == 'drain') await drain.future;
        if (call.method == 'stop' && !drain.isCompleted) drain.complete();
        return null;
      });
      final recorder = Recorder();
      final api = Api(server.port);
      final store = AiHistoryStore('pause');
      final chat = AiChatController.forTesting(
        store,
        recorder: recorder,
        api: api,
        voiceMetadata: () async => {},
      );
      try {
        await chat.initialize();
        await chat.record();
        recorder.speak();
        final sending = chat.sendRecording();
        await until(() => peers.isNotEmpty);
        await peers.first.committed.future;
        peers.first.audio('A reply still arriving.');
        await until(() => calls.contains('feed'));
        final streamedReply = chat.messages.last;
        expect(streamedReply.audio, isNull);
        expect(chat.isReceiving(streamedReply), true);
        expect(chat.isAutomaticReply(streamedReply), true);
        await chat.toggleReplyPlayback(streamedReply);
        expect(chat.isAutomaticReplyPaused(streamedReply), true);
        expect(calls.last, 'pausePlayback');
        // The server has not finished. More audio and captions must still arrive.
        peers.first.audio(' The rest arrives while paused.');
        await until(() => calls.where((m) => m == 'feed').length == 2);
        peers.first.complete('A complete reply still paused.');
        await until(() => calls.contains('drain'));
        final reply = store.messages.last;
        expect(identical(streamedReply, reply), true);
        expect(reply.audio, isNotNull);
        expect(chat.isReceiving(reply), false);
        expect(chat.isAutomaticReply(reply), true);
        expect(chat.isAutomaticReplyPaused(reply), true);
        final starts = calls.where((m) => m == 'startPlayback').length;
        await chat.toggleReplyPlayback(reply);
        expect(chat.isAutomaticReplyPaused(reply), false);
        expect(calls.last, 'resumePlayback');
        expect(drain.isCompleted, false);
        await chat.toggleReplyPlayback(reply);
        expect(chat.isAutomaticReplyPaused(reply), true);
        expect(calls.last, 'pausePlayback');
        expect(calls.where((m) => m == 'startPlayback').length, starts);
        expect(calls.where((m) => m == 'feed').length, 2);
        // Choosing another saved message stops automatic output and releases drain.
        await chat.stopAutomaticReplyPlayback();
        await sending;
        expect(chat.isAutomaticReply(reply), false);
        expect(reply.failed, false);
        expect(File(store.path(reply.audio!)).lengthSync(), 9644);
      } finally {
        if (!drain.isCompleted) drain.complete();
        chat.dispose();
        api.close();
        for (final peer in peers) {
          await peer.socket.close();
        }
        await server.close(force: true);
        await dir.delete(recursive: true);
      }
    },
  );
}
