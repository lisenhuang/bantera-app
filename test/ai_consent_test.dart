import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/core/ai_consent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late String? owner;
  late AiConsent consent;
  AiConsent create() =>
      AiConsent(currentOwner: () => owner, directory: () async => root);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('bantera-consent-test');
    owner = 'account-a';
    consent = create();
  });
  tearDown(() async {
    consent.dispose();
    await root.delete(recursive: true);
  });

  test('new and legacy users are denied without an explicit choice', () async {
    await File(
      '${root.path}/old.privacy-notice-v1-dismissed',
    ).writeAsString('dismissed');
    expect(await consent.isAllowed(owner!), false);
    await expectLater(
      consent.require(owner!),
      throwsA(isA<AiConsentRequired>()),
    );
    expect(
      await consent.request(),
      false,
    ); // No presenter, e.g. background launch.
  });

  test('decline does not persist permission and allows asking again', () async {
    consent.present = () async => false;
    expect(await consent.request(), false);
    expect(await consent.isAllowed(owner!), false);
    expect(await root.list().toList(), isEmpty);
    consent.present = () async => true;
    expect(await consent.request(), true);
  });

  test(
    'accepted version and timestamp survive restart for the same account only',
    () async {
      consent.present = () async => true;
      expect(await consent.request(), true);
      final record =
          jsonDecode(await (await root.list().single as File).readAsString())
              as Map;
      expect(record['version'], AiConsent.version);
      expect(DateTime.tryParse(record['updatedAt']), isNotNull);
      final restored = create();
      expect(await restored.isAllowed('account-a'), true);
      owner = 'account-b';
      expect(await restored.isAllowed('account-b'), false);
      expect(await restored.isAllowed('account-a'), false);
      restored.dispose();
    },
  );

  test('account change during the dialog never grants permission', () async {
    final response = Completer<bool>();
    final displayed = Completer<void>();
    consent.present = () {
      displayed.complete();
      return response.future;
    };
    final request = consent.request();
    await displayed.future;
    owner = 'account-b';
    response.complete(true);
    expect(await request, false);
    expect(await consent.isAllowed('account-b'), false);
    owner = 'account-a';
    expect(await consent.isAllowed('account-a'), false);
  });

  test('simultaneous actions share one consent dialog', () async {
    final response = Completer<bool>();
    final displayed = Completer<void>();
    var prompts = 0;
    consent.present = () {
      prompts++;
      displayed.complete();
      return response.future;
    };
    final first = consent.request();
    await displayed.future;
    final second = consent.request();
    response.complete(true);
    expect(await Future.wait([first, second]), [true, true]);
    expect(prompts, 1);
  });

  test(
    'withdrawal prevents an outstanding dialog from restoring consent',
    () async {
      final response = Completer<bool>();
      final displayed = Completer<void>();
      consent.present = () {
        displayed.complete();
        return response.future;
      };
      final request = consent.request();
      await displayed.future;
      await consent.revoke();
      response.complete(true);
      expect(await request, false);
      expect(await consent.isAllowed(owner!), false);
    },
  );

  test(
    'withdrawal immediately denies requests and persists across restart',
    () async {
      consent.present = () async => true;
      await consent.request();
      await consent.revoke();
      await expectLater(
        consent.require(owner!),
        throwsA(isA<AiConsentRequired>()),
      );
      final restored = create();
      expect(await restored.isAllowed(owner!), false);
      restored.dispose();
    },
  );

  test('corrupt or outdated consent cannot authorise a request', () async {
    consent.present = () async => true;
    await consent.request();
    final file = await root.list().single as File;
    await file.writeAsString('{broken');
    final corrupt = create();
    expect(await corrupt.isAllowed(owner!), false);
    corrupt.dispose();
    await file.writeAsString(
      jsonEncode({
        'version': 0,
        'allowed': true,
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
    final outdated = create();
    expect(await outdated.isAllowed(owner!), false);
    outdated.dispose();
  });

  test('storage failure cannot grant consent', () async {
    final blocker = File('${root.path}/file');
    await blocker.writeAsString('not a directory');
    final unavailable = AiConsent(
      currentOwner: () => owner,
      directory: () async => Directory(blocker.path),
    );
    unavailable.present = () async => true;
    expect(await unavailable.request(), false);
    expect(await unavailable.isAllowed(owner!), false);
    unavailable.dispose();
  });
}
