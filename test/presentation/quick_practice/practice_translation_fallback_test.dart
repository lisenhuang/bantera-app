import 'dart:async';
import 'dart:io';
import 'package:app/core/apple_system_version.dart';
import 'package:app/infrastructure/practice_translation_preferences.dart';
import 'package:app/infrastructure/translation_service.dart';
import 'package:app/presentation/quick_practice/practice_translation_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/translation');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory temp;
  late PracticeTranslationPreferences preferences;
  late PracticeTranslationController controller;
  late List<MethodCall> calls;
  late List<Map<String, Object>> options;
  var choices = 0, confirmations = 0;
  Map<String, Object> option(String id, {bool installed = true}) => {
    'identifier': id,
    'displayName': id,
    'isInstalled': installed,
  };
  setUp(() async {
    translationCapabilityForTesting = true;
    temp = await Directory.systemTemp.createTemp('practice-translation-test');
    preferences = PracticeTranslationPreferences(
      file: () async => File('${temp.path}/preferences.json'),
    );
    controller = PracticeTranslationController(preferences: preferences);
    calls = [];
    choices = 0;
    confirmations = 0;
    options = [option('en'), option('ja')];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'getSupportedTranslationLocales') return options;
      if (call.method == 'prepareTranslationAssets') return null;
      return [
        {'id': 'cue', 'translatedText': 'translated'},
      ];
    });
  });
  tearDown(() async {
    controller.dispose();
    messenger.setMockMethodCallHandler(channel, null);
    translationCapabilityForTesting = null;
    await temp.delete(recursive: true);
  });
  Future<void> load({
    String owner = 'alice',
    String source = 'zh-HK',
    String native = 'zh-CN',
    bool retry = false,
    bool allowDownload = true,
    bool choose = true,
    bool Function()? active,
    Future<TranslationLocaleOption?> Function(List<TranslationLocaleOption>)?
    picker,
  }) => controller.load(
    source: source,
    target: native,
    owner: owner,
    texts: const {'cue': 'hello'},
    retry: retry,
    canStart: active ?? () => true,
    chooseTarget:
        picker ??
        (options) async {
          choices++;
          return choose ? options.first : null;
        },
    confirmDownload: () async {
      confirmations++;
      return allowDownload;
    },
  );

  test(
    'unsupported native pair selects once and remembers after relaunch',
    () async {
      await load();
      expect(choices, 1);
      expect(controller.targetLocale, 'en');
      expect(calls.first.arguments['sourceLocaleIdentifier'], 'yue-HK');
      expect(await preferences.load('alice', 'yue'), 'en');
      controller.dispose();
      controller = PracticeTranslationController(
        preferences: PracticeTranslationPreferences(
          file: () async => File('${temp.path}/preferences.json'),
        ),
      );
      await load();
      expect(choices, 1);
      expect(controller.translations['cue'], 'translated');
      expect(confirmations, 0);
    },
  );
  test(
    'supported native language takes priority over a remembered fallback',
    () async {
      await preferences.save('alice', 'yue', 'en');
      options.add(option('zh-Hans'));
      await load();
      expect(choices, 0);
      expect(controller.targetLocale, 'zh-Hans');
    },
  );
  test(
    'fallbacks are separate for each account and learning language',
    () async {
      await load();
      await load(source: 'ko');
      await load(owner: 'bob');
      expect(choices, 3);
      expect(await preferences.load('alice', 'yue'), 'en');
      expect(await preferences.load('alice', 'ko'), 'en');
      expect(await preferences.load('bob', 'yue'), 'en');
    },
  );
  test('removed fallback asks again using currently supported pairs', () async {
    await preferences.save('alice', 'yue', 'fr');
    await load();
    expect(choices, 1);
    expect(controller.targetLocale, 'en');
  });
  test(
    'no supported pairs never offers invalid languages or starts download',
    () async {
      options = [];
      await load();
      expect(controller.issue, PracticeTranslationIssue.noLanguages);
      expect(choices, 0);
      expect(confirmations, 0);
      expect(calls, hasLength(1));
    },
  );
  test('download explains first, prepares once, then translates', () async {
    options = [option('zh-Hans', installed: false)];
    final states = <bool>[];
    controller.addListener(() => states.add(controller.preparing));
    await load();
    expect(choices, 0);
    expect(confirmations, 1);
    expect(calls.map((c) => c.method), [
      'getSupportedTranslationLocales',
      'prepareTranslationAssets',
      'translateTranscriptCues',
    ]);
    expect(states, contains(true));
    expect(controller.preparing, false);
    expect(controller.failed, false);
  });
  test(
    'declined download does not download or automatically re-prompt',
    () async {
      options = [option('en', installed: false)];
      await load(allowDownload: false);
      await load();
      expect(confirmations, 1);
      expect(choices, 1);
      expect(calls, hasLength(1));
      expect(controller.issue, PracticeTranslationIssue.downloadCancelled);
      await load(retry: true);
      expect(confirmations, 2);
      expect(choices, 1);
      expect(controller.failed, false);
    },
  );
  test('cancelled selection stays cancelled until explicit retry', () async {
    await load(choose: false);
    await load();
    expect(choices, 1);
    expect(calls, hasLength(1));
    expect(controller.issue, PracticeTranslationIssue.selectionCancelled);
    await load(retry: true);
    expect(choices, 2);
    expect(controller.failed, false);
  });
  test(
    'account switch while picker is open cannot save the old result',
    () async {
      final picked = Completer<TranslationLocaleOption?>();
      final opened = Completer<void>();
      final task = load(
        picker: (options) {
          opened.complete();
          return picked.future;
        },
      );
      await opened.future;
      controller.clear();
      picked.complete(
        const TranslationLocaleOption(
          identifier: 'en',
          displayName: 'English',
          isInstalled: true,
        ),
      );
      await task;
      expect(await preferences.load('alice', 'yue'), isNull);
      expect(controller.translations, isEmpty);
      expect(calls, hasLength(1));
    },
  );
  test(
    'call or backgrounding after pair check prevents opening picker',
    () async {
      var active = true;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        active = false;
        return options;
      });
      await load(active: () => active);
      expect(choices, 0);
      expect(confirmations, 0);
      expect(calls, hasLength(1));
    },
  );
  test(
    'native download cancellation stays retryable without reopening it',
    () async {
      options = [option('en', installed: false)];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'getSupportedTranslationLocales') return options;
        throw PlatformException(code: 'translation_failed');
      });
      await load();
      await load();
      expect(confirmations, 1);
      expect(calls.map((c) => c.method), [
        'getSupportedTranslationLocales',
        'prepareTranslationAssets',
      ]);
      expect(controller.failed, true);
      expect(controller.loading, false);
      expect(controller.preparing, false);
    },
  );
  test(
    'leaving during a download discards the result and never translates',
    () async {
      options = [option('en', installed: false)];
      final downloading = Completer<void>(), downloaded = Completer<void>();
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'getSupportedTranslationLocales') return options;
        downloading.complete();
        await downloaded.future;
        return null;
      });
      final task = load();
      await downloading.future;
      controller.clear();
      downloaded.complete();
      await task;
      expect(controller.translations, isEmpty);
      expect(controller.loading, false);
      expect(calls, hasLength(2));
    },
  );
  test('Cantonese and Chinese scripts are never silently substituted', () {
    final choices = [
      const TranslationLocaleOption(
        identifier: 'zh-Hans',
        displayName: 'Chinese',
        isInstalled: true,
      ),
    ];
    expect(
      PracticeTranslationController.matching(choices, 'zh-CN')?.identifier,
      'zh-Hans',
    );
    expect(PracticeTranslationController.matching(choices, 'zh-TW'), isNull);
    expect(PracticeTranslationController.matching(choices, 'zh-HK'), isNull);
    expect(PracticeTranslationController.matching(choices, 'yue-HK'), isNull);
  });
}
