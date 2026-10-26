import 'dart:async';
import 'dart:io';
import 'package:app/core/apple_system_version.dart';
import 'package:app/infrastructure/practice_translation_preferences.dart';
import 'package:app/presentation/quick_practice/practice_translation_controller.dart';
import 'package:app/presentation/quick_practice/practice_translation_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/translation');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory temp;
  late PracticeTranslationPreferences prefs;
  late PracticeTranslationController controller;
  late List<MethodCall> calls;
  late List<Map<String, Object>> direct, onward;
  var confirmations = 0, picks = 0;
  var consent = true, active = true;
  String? failingSource;
  var incompleteEnglish = false;
  Completer<void>? firstStep;
  const texts = {'cue': '你去邊度？', 'option0': '我去學校。', 'option1': '我去銀行。'};
  Map<String, Object> option(String id, {bool installed = true}) => {
    'identifier': id,
    'displayName': id,
    'isInstalled': installed,
  };
  List<Map<String, String>> translated(String prefix) => [
    for (final id in texts.keys) {'id': id, 'translatedText': '$prefix $id'},
  ];
  setUp(() async {
    translationCapabilityForTesting = true;
    temp = await Directory.systemTemp.createTemp('translation-bridge');
    prefs = PracticeTranslationPreferences(
      file: () async => File('${temp.path}/prefs.json'),
    );
    controller = PracticeTranslationController(preferences: prefs);
    calls = [];
    direct = [option('en'), option('ja')];
    onward = [
      option('zh-Hans'),
      option('zh-Hant'),
      option('yue'),
      option('ja'),
    ];
    confirmations = picks = 0;
    consent = active = true;
    failingSource = null;
    incompleteEnglish = false;
    firstStep = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      final source = call.arguments['sourceLocaleIdentifier'];
      if (call.method == 'getSupportedTranslationLocales') {
        return source == 'en' ? onward : direct;
      }
      if (call.method == 'prepareTranslationAssets') return null;
      if (source == failingSource) {
        throw PlatformException(code: 'translation_failed');
      }
      if (source == 'yue-HK') {
        await firstStep?.future;
        return incompleteEnglish
            ? translated('English').take(2).toList()
            : translated('English');
      }
      expect(source, 'en');
      expect(call.arguments['cues'], [
        for (final id in texts.keys) {'id': id, 'text': 'English $id'},
      ]);
      return translated('中文');
    });
  });
  tearDown(() async {
    controller.dispose();
    messenger.setMockMethodCallHandler(channel, null);
    translationCapabilityForTesting = null;
    await temp.delete(recursive: true);
  });
  Future<void> load({String target = 'zh-CN', bool retry = false}) =>
      controller.load(
        source: 'zh-HK',
        target: target,
        owner: 'alice',
        texts: texts,
        canStart: () => active,
        retry: retry,
        chooseTarget: (options) async {
          picks++;
          return options.first;
        },
        confirmDownload: () async {
          confirmations++;
          return consent;
        },
      );
  Iterable<MethodCall> getTranslations() =>
      calls.where((c) => c.method == 'translateTranscriptCues');
  test(
    'bridged native language translates every cue twice with stable IDs',
    () async {
      await load();
      expect(picks, 0);
      expect(confirmations, 0);
      expect(controller.targetLocale, 'zh-Hans');
      expect(
        getTranslations().map(
          (c) => [
            c.arguments['sourceLocaleIdentifier'],
            c.arguments['targetLocaleIdentifier'],
          ],
        ),
        [
          ['yue-HK', 'en'],
          ['en', 'zh-Hans'],
        ],
      );
      expect(controller.translations, {
        for (final id in texts.keys) id: '中文 $id',
      });
      expect(controller.failed, false);
      await load();
      expect(getTranslations().length, 2);
    },
  );
  test(
    'direct target remains preferred even if English can also reach it',
    () async {
      direct.add(option('zh-Hans'));
      await load();
      expect(
        getTranslations().single.arguments['targetLocaleIdentifier'],
        'zh-Hans',
      );
      expect(controller.failed, false);
    },
  );
  test(
    'picker includes only verified destinations and keeps scripts distinct',
    () async {
      final options = await PracticeTranslationRoute.options(
        source: 'yue-HK',
        canContinue: () => true,
      );
      expect(options.map((o) => o.identifier), [
        'en',
        'ja',
        'zh-Hans',
        'zh-Hant',
      ]);
      expect(options[1], isNot(isA<PracticeTranslationRoute>()));
      expect(
        (options[2] as PracticeTranslationRoute).viaEnglish?.identifier,
        'en',
      );
      expect(PracticeTranslationController.matching(options, 'zh-HK'), isNull);
    },
  );
  test(
    'no source-to-English path does not invent unsupported targets',
    () async {
      direct = [option('ja')];
      final options = await PracticeTranslationRoute.options(
        source: 'yue-HK',
        canContinue: () => true,
      );
      expect(options.map((o) => o.identifier), ['ja']);
      expect(calls.length, 1);
      direct = [];
      await load();
      expect(controller.issue, PracticeTranslationIssue.noLanguages);
      expect(getTranslations(), isEmpty);
    },
  );
  test(
    'onward discovery failure preserves working direct translations',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.arguments['sourceLocaleIdentifier'] == 'en') {
          throw PlatformException(code: 'unavailable');
        }
        return direct;
      });
      final options = await PracticeTranslationRoute.options(
        source: 'yue-HK',
        canContinue: () => true,
      );
      expect(options.map((o) => o.identifier), ['en', 'ja']);
    },
  );
  for (final missingFirst in [false, true]) {
    test(
      'download confirmation covers both steps, missing first=$missingFirst',
      () async {
        direct[0] = option('en', installed: !missingFirst);
        onward[0] = option('zh-Hans', installed: missingFirst);
        await load();
        expect(confirmations, 1);
        final prepares = calls.where(
          (c) => c.method == 'prepareTranslationAssets',
        );
        expect(
          prepares.map(
            (c) => [
              c.arguments['sourceLocaleIdentifier'],
              c.arguments['targetLocaleIdentifier'],
            ],
          ),
          [
            ['yue-HK', 'en'],
            ['en', 'zh-Hans'],
          ],
        );
        expect(controller.failed, false);
      },
    );
  }
  test(
    'download refusal starts neither step and stays cancelled until retry',
    () async {
      onward[0] = option('zh-Hans', installed: false);
      consent = false;
      await load();
      await load();
      expect(confirmations, 1);
      expect(controller.issue, PracticeTranslationIssue.downloadCancelled);
      expect(
        calls.where((c) => c.method != 'getSupportedTranslationLocales'),
        isEmpty,
      );
      consent = true;
      await load(retry: true);
      expect(controller.failed, false);
    },
  );
  for (final failure in ['yue-HK', 'en']) {
    test('failure in $failure never reveals intermediate English', () async {
      failingSource = failure;
      await load();
      expect(controller.failed, true);
      expect(controller.translations, isEmpty);
      expect(getTranslations().length, failure == 'en' ? 2 : 1);
    });
  }
  test(
    'incomplete intermediate batch is rejected before the second step',
    () async {
      incompleteEnglish = true;
      await load();
      expect(controller.failed, true);
      expect(controller.translations, isEmpty);
      expect(getTranslations().length, 1);
    },
  );
  for (final clear in [false, true]) {
    test(
      'leaving between steps prevents further translation, clear=$clear',
      () async {
        firstStep = Completer<void>();
        final task = load();
        while (getTranslations().isEmpty) {
          await Future<void>.delayed(Duration.zero);
        }
        if (clear) {
          controller.clear();
        } else {
          active = false;
        }
        firstStep!.complete();
        await task;
        expect(getTranslations().length, 1);
        expect(controller.translations, isEmpty);
        expect(controller.loading, false);
      },
    );
  }
  test(
    'manual bridged target is remembered per learning language after relaunch',
    () async {
      expect(
        await controller.changeTarget(
          source: 'zh-HK',
          owner: 'alice',
          canStart: () => true,
          chooseTarget: (options) async =>
              options.firstWhere((o) => o.identifier == 'zh-Hant'),
        ),
        true,
      );
      expect(await prefs.loadOverride('alice', 'yue'), 'zh-Hant');
      expect(await prefs.loadOverride('bob', 'yue'), isNull);
      expect(await prefs.loadOverride('alice', 'ja'), isNull);
      controller.dispose();
      controller = PracticeTranslationController(preferences: prefs);
      await load();
      expect(controller.targetLocale, 'zh-Hant');
      expect(picks, 0);
      expect(
        getTranslations().last.arguments['targetLocaleIdentifier'],
        'zh-Hant',
      );
    },
  );
}
