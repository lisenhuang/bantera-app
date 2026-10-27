import 'dart:io';

import 'package:app/infrastructure/app_storage_service.dart';
import 'package:app/infrastructure/last_snapshot_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root, support, temporary;
  Future<File> write(String path, int size) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(List.filled(size, 1));
    return file;
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('storage-test-');
    support = await Directory('${root.path}/support').create();
    temporary = await Directory('${root.path}/temp').create();
  });
  tearDown(() => root.delete(recursive: true));

  test(
    'safe clearing keeps personal data, unknown files, active clips and symlinks',
    () async {
      final images = await write(
        '${temporary.path}/profile-avatars-v1/avatar',
        10,
      );
      final orphan = await write(
        '${temporary.path}/quick-practice-old/0.mp3',
        20,
      );
      final active = await write(
        '${temporary.path}/quick-practice-active/0.wav',
        30,
      );
      final unknown = await write(
        '${temporary.path}/quick-practice-old/keep.bin',
        40,
      );
      final dm = await write(
        '${support.path}/chat_audio/person/recording.wav',
        50,
      );
      final ai = await write(
        '${support.path}/bantera_ai/person/history.json',
        60,
      );
      final lesson = await write(
        '${support.path}/practice_audio_cache/lesson.wav',
        70,
      );
      final preferences = await write('${support.path}/auth_session.json', 80);
      final outside = await write('${root.path}/outside.wav', 90);
      await Link(
        '${temporary.path}/quick-practice-old/1.wav',
      ).create(outside.path);
      await Link('${temporary.path}/quick-practice-link').create(support.path);
      final snapshot = LastSnapshotCache(
        file: () async => File('${support.path}/last-practice-cache-v1.json'),
        maxAge: const Duration(days: 1),
        valid: (_) => true,
      );
      await snapshot.save('owner', {'cue': 'hello'});
      final service = AppStorageService(
        roots: [support, temporary, Directory('${support.path}/bantera_ai')],
        temporary: temporary,
        support: support,
        activeAudio: () => {active.parent.path},
        clearImages: () => images.delete(),
        clearSnapshots: snapshot.clearAll,
      );
      final usage = await service.scan();
      final snapshotBytes = await (await snapshot.file()).length();
      expect(usage.total, 360 + snapshotBytes);
      expect(usage.safeToClear, 30 + snapshotBytes);
      expect(usage.bytes[StorageCategory.directMessages], 50);
      expect(usage.bytes[StorageCategory.aiChats], 60);
      final after = await service.clearSafeCache();
      expect(after.safeToClear, 0);
      expect(after.total, 330);
      expect(snapshot.peek('owner'), isNull);
      expect(await orphan.exists(), isFalse);
      for (final file in [
        active,
        unknown,
        dm,
        ai,
        lesson,
        preferences,
        outside,
      ]) {
        expect(await file.exists(), isTrue, reason: file.path);
      }
      expect(
        await Link('${temporary.path}/quick-practice-old/1.wav').exists(),
        isTrue,
      );
    },
  );
}
