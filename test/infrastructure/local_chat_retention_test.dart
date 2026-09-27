import 'dart:io';

import 'package:app/domain/models/chat_models.dart';
import 'package:app/infrastructure/local_chat_database.dart';
import 'package:app/infrastructure/local_chat_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalChatDatabase database;
  late LocalChatRepository repository;
  String? owner;

  setUp(() {
    owner = 'alice';
    database = LocalChatDatabase.forTesting(NativeDatabase.memory());
    repository = LocalChatRepository.forTesting(database, () => owner);
  });
  tearDown(() => database.close());

  ChatMessageItem message(String id, {String type = 'dm'}) =>
      ChatMessageItem.fromJson({
        'messageId': id,
        'threadId': 'thread',
        'threadType': type,
        'senderUser': {'id': 'bob', 'name': 'Bob'},
        'durationMs': 1000,
        'spokenLanguageCode': 'en-US',
        'createdAt': '2026-09-01T00:00:00Z',
        'expiresAt': '2026-09-08T00:00:00Z',
        'audioUrl': '/audio/$id',
      });

  test(
    'cached DMs remain visible after expiry and empty server refresh',
    () async {
      await repository.replaceMessages(
        ownerCacheKey: 'alice',
        threadId: 'thread',
        messages: [message('cached'), message('not-downloaded')],
      );
      await repository.updateMessageLocalAudioPath(
        messageId: 'cached',
        storedReference: '/saved/voice.m4a',
      );
      await repository.markMessageExpired('cached');
      await repository.replaceMessages(
        ownerCacheKey: 'alice',
        threadId: 'thread',
        messages: [],
      );

      final messages = await repository.watchMessages('thread').first;
      expect(messages.map((m) => m.messageId), ['cached']);
      expect(messages.single.isServerVisible, isFalse);
      expect(messages.single.localAudioPath, '/saved/voice.m4a');
    },
  );

  test(
    'server metadata refresh preserves local audio and pagination preserves earlier messages',
    () async {
      await repository.replaceMessages(
        ownerCacheKey: 'alice',
        threadId: 'thread',
        messages: [message('first')],
      );
      await repository.updateMessageLocalAudioPath(
        messageId: 'first',
        storedReference: '/saved/first.m4a',
      );
      await repository.replaceMessages(
        ownerCacheKey: 'alice',
        threadId: 'thread',
        messages: [message('first')],
      );
      await repository.replaceMessages(
        ownerCacheKey: 'alice',
        threadId: 'thread',
        messages: [message('second')],
        replaceServerSnapshot: false,
      );
      final messages = await repository.watchMessages('thread').first;
      expect(messages.length, 2);
      expect(messages.first.localAudioPath, '/saved/first.m4a');
    },
  );

  test(
    'saved audio remains readable after expiry and manual deletion removes the file',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'bantera-chat-retention-',
      );
      try {
        final file = File('${directory.path}/voice.m4a');
        await file.writeAsBytes([1, 2, 3, 4], flush: true);
        await repository.replaceMessages(
          ownerCacheKey: 'alice',
          threadId: 'thread',
          messages: [message('saved')],
        );
        await repository.updateMessageLocalAudioPath(
          messageId: 'saved',
          storedReference: file.path,
        );
        await repository.markMessageExpired('saved');
        final saved = (await repository.watchMessages('thread').first).single;
        final path = await repository.resolveAudioPath(saved.localAudioPath);
        expect(await File(path!).readAsBytes(), [1, 2, 3, 4]);

        await repository.deleteMessage('saved');
        expect(await repository.watchMessages('thread').first, isEmpty);
        expect(await file.exists(), isFalse);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );

  test('bootstrap parses explicit deletions and tolerates older servers', () {
    expect(ChatBootstrap.fromJson({}).deletedMessageIds, isEmpty);
    expect(
      ChatBootstrap.fromJson({
        'deletedMessageIds': ['removed'],
      }).deletedMessageIds,
      ['removed'],
    );
  });

  test('archived DMs stay scoped to the signed-in account', () async {
    await repository.replaceMessages(
      ownerCacheKey: 'alice',
      threadId: 'thread',
      messages: [message('private')],
    );
    await repository.updateMessageLocalAudioPath(
      messageId: 'private',
      storedReference: '/saved/private.m4a',
    );
    await repository.markMessageExpired('private');
    owner = 'charlie';
    expect(await repository.watchMessages('thread').first, isEmpty);
    owner = null;
    expect(await repository.watchMessages('thread').first, isEmpty);
  });

  test(
    'ordinary missing group messages are not restored from local cache',
    () async {
      await repository.replaceMessages(
        ownerCacheKey: 'alice',
        threadId: 'thread',
        messages: [message('group', type: 'group')],
      );
      await repository.updateMessageLocalAudioPath(
        messageId: 'group',
        storedReference: '/saved/group.m4a',
      );
      await repository.markMessageExpired('group');
      expect(await repository.watchMessages('thread').first, isEmpty);
    },
  );
}
