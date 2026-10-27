import 'dart:async';
import 'dart:io';

import 'package:app/infrastructure/last_snapshot_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late File file;
  var clock = DateTime.utc(2026, 10, 27);
  LastSnapshotCache cache() => LastSnapshotCache(
    file: () async => file,
    maxAge: const Duration(days: 1),
    valid: (data) => data['text'] is String,
    now: () => clock,
  );
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('snapshot-test-');
    file = File('${directory.path}/snapshot.json');
    clock = DateTime.utc(2026, 10, 27);
  });
  tearDown(() => directory.delete(recursive: true));

  test(
    'last item persists, scopes do not leak and returned maps are copies',
    () async {
      final first = cache();
      await first.save('user/en', {'text': 'one'});
      final read = first.peek('user/en')!..['text'] = 'modified';
      expect(read['text'], 'modified');
      expect(first.peek('user/en')?['text'], 'one');
      expect(await cache().read('other/en'), isNull);
      await first.save('user/ja', {'text': 'two'});
      expect(await cache().read('user/en'), isNull);
      expect((await cache().read('user/ja'))?['text'], 'two');
      expect(await directory.list().length, 1);
    },
  );
  test('expired, malformed and oversized files do not prevent use', () async {
    await cache().save('owner', {'text': 'one'});
    clock = clock.add(const Duration(days: 2));
    expect(await cache().read('owner'), isNull);
    await file.writeAsString('broken json');
    expect(await cache().read('owner'), isNull);
    final fresh = cache();
    await fresh.save('owner', {'text': 'valid'});
    await fresh.save('owner', {'text': 'a' * LastSnapshotCache.maxBytes});
    expect(fresh.peek('owner')?['text'], 'valid');
    await file.writeAsString('x' * (LastSnapshotCache.maxBytes + 1));
    expect(await cache().read('owner'), isNull);
  });
  test(
    'clear removes memory and disk, but scoped clear protects other owner',
    () async {
      final current = cache();
      await current.save('a', {'text': 'a'});
      await current.clear('b');
      expect((await cache().read('a'))?['text'], 'a');
      await current.clearAll();
      expect(current.peek('a'), isNull);
      expect(await file.exists(), isFalse);
      await current.save('b', {'text': 'b'});
      await current.clear('b');
      expect(current.peek('b'), isNull);
      expect(await cache().read('b'), isNull);
    },
  );
  test('a stale disk read cannot overwrite a newer network snapshot', () async {
    await cache().save('a', {'text': 'old'});
    final gate = Completer<File>();
    final current = LastSnapshotCache(
      file: () => gate.future,
      maxAge: const Duration(days: 1),
      valid: (_) => true,
      now: () => clock,
    );
    final pending = current.read('a');
    final save = current.save('a', {'text': 'new'});
    gate.complete(file);
    await pending;
    await save;
    expect(current.peek('a')?['text'], 'new');
    expect((await cache().read('a'))?['text'], 'new');
  });
  test(
    'out-of-order leaderboard responses do not replace a newer result',
    () async {
      final current = cache();
      await current.save('a', {'text': 'new', 'asOf': '2026-10-27T10:00:00Z'});
      await current.save('a', {'text': 'old', 'asOf': '2026-10-27T09:00:00Z'});
      expect(current.peek('a')?['text'], 'new');
    },
  );
}
