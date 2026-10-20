import 'package:app/core/apple_system_version.dart';
import 'package:app/domain/models/models.dart';
import 'package:app/infrastructure/translation_service.dart';
import 'package:app/presentation/quick_practice/practice_translation_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/translation');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final cues = <Cue>[
    Cue(
      id: 'cue',
      startTimeMs: 0,
      endTimeMs: 1000,
      originalText: 'Hello',
      translatedText: 'Saved translation',
    ),
  ];
  tearDown(() {
    translationCapabilityForTesting = null;
    messenger.setMockMethodCallHandler(channel, null);
  });
  for (final major in [15, 16, 17, 18, 26, 27]) {
    test(
      'iOS $major gates UI, native requests and Practice scoring together',
      () async {
        final supported = translationSupportedOn(
          isIOS: true,
          isAndroid: false,
          realMajor: major,
          effectiveMajor: major,
        );
        expect(supported, major >= 18);
        translationCapabilityForTesting = supported;
        var calls = 0, scoringCalls = 0;
        messenger.setMockMethodCallHandler(channel, (call) async {
          calls++;
          return call.method == 'translateTranscriptCues'
              ? [
                  {'id': 'cue', 'translatedText': 'Bonjour'},
                ]
              : [];
        });
        final marked = await PracticeTranslationController.markUsed(() async {
          scoringCalls++;
        });
        expect(marked, supported);
        expect(scoringCalls, supported ? 1 : 0);
        final service = TranslationService.instance;
        if (supported) {
          expect(
            await service.translateCues(
              sourceLocaleIdentifier: 'en',
              targetLocaleIdentifier: 'fr',
              cues: cues,
            ),
            {'cue': 'Bonjour'},
          );
          expect(calls, 1);
        } else {
          final unsupported = isA<TranslationException>().having(
            (e) => e.code,
            'code',
            'unsupported_os',
          );
          await expectLater(
            service.translateCues(
              sourceLocaleIdentifier: 'en',
              targetLocaleIdentifier: 'fr',
              cues: cues,
            ),
            throwsA(unsupported),
          );
          await expectLater(
            service.prepareTranslationAssets(
              sourceLocaleIdentifier: 'en',
              targetLocaleIdentifier: 'fr',
            ),
            throwsA(unsupported),
          );
          await expectLater(
            service.fetchSupportedLocales(sourceLocaleIdentifier: 'en'),
            throwsA(unsupported),
          );
          expect(await service.fetchAllTranslationLocales(), isEmpty);
          final controller = PracticeTranslationController();
          await controller.load(
            source: 'en',
            target: 'fr',
            texts: {'cue': 'Hello'},
            canStart: () => true,
          );
          expect(controller.loading, isFalse);
          expect(controller.failed, isFalse);
          controller.dispose();
          expect(calls, 0);
          expect(cues.single.translatedText, 'Saved translation');
        }
      },
    );
  }
  test(
    'developer mock cannot elevate actual OS; unknown Apple version fails closed',
    () {
      for (final real in [null, 15, 16, 17]) {
        expect(
          translationSupportedOn(
            isIOS: true,
            isAndroid: false,
            realMajor: real,
            effectiveMajor: 27,
          ),
          isFalse,
        );
      }
      expect(
        translationSupportedOn(
          isIOS: true,
          isAndroid: false,
          realMajor: 18,
          effectiveMajor: 15,
        ),
        isFalse,
      );
      expect(
        translationSupportedOn(isIOS: true, isAndroid: false, realMajor: 18),
        isTrue,
      );
    },
  );
  test('Android keeps its existing native translation bridge', () async {
    translationCapabilityForTesting = translationSupportedOn(
      isIOS: false,
      isAndroid: true,
    );
    final methods = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      methods.add(call.method);
      return call.method == 'prepareTranslationAssets' ? null : [];
    });
    await TranslationService.instance.prepareTranslationAssets(
      sourceLocaleIdentifier: 'en',
      targetLocaleIdentifier: 'fr',
    );
    await TranslationService.instance.translateCues(
      sourceLocaleIdentifier: 'en',
      targetLocaleIdentifier: 'fr',
      cues: cues,
    );
    expect(methods, ['prepareTranslationAssets', 'translateTranscriptCues']);
  });
}
