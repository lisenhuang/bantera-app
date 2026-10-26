import 'package:app/core/apple_system_version.dart';
import 'dart:async';
import 'package:app/presentation/quick_practice/practice_translation_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => translationCapabilityForTesting = true);
  tearDown(() => translationCapabilityForTesting = null);
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/translation');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const texts = {
    'cue': 'Where is the station?',
    'option0': 'Next to the bank.',
    'option1': 'At nine.',
  };
  late PracticeTranslationController controller;
  setUp(() => controller = PracticeTranslationController());
  tearDown(() {
    controller.dispose();
    messenger.setMockMethodCallHandler(channel, null);
  });
  List<Map<String, String>> response(String prefix) => texts.keys
      .map((id) => {'id': id, 'translatedText': '$prefix $id'})
      .toList();
  Future<void> load({
    String target = 'zh-Hant',
    bool retry = false,
    bool Function()? active,
  }) => controller.load(
    source: 'en-NZ',
    target: target,
    texts: texts,
    canStart: active ?? () => true,
    retry: retry,
  );

  test(
    'batches all three lines through native translation and reuses the result',
    () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return response('譯文');
      });
      await load();
      await load();
      expect(calls, hasLength(1));
      expect(calls.single.method, 'translateTranscriptCues');
      expect((calls.single.arguments as Map)['cues'], hasLength(3));
      expect(
        (calls.single.arguments as Map)['targetLocaleIdentifier'],
        'zh-Hant',
      );
      expect(controller.translations['option1'], '譯文 option1');
      expect(controller.failed, isFalse);
    },
  );
  test(
    'a changed target discards old results and translates the new language',
    () async {
      final first = Completer<Object?>();
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'cancelTranslation') return null;
        if (++calls == 1) return first.future;
        return response('nouveau');
      });
      final old = load();
      await Future<void>.delayed(Duration.zero);
      final latest = load(target: 'fr-FR');
      first.complete(response('old'));
      await old;
      await latest;
      expect(controller.translations['cue'], 'nouveau cue');
      expect(calls, 2);
    },
  );
  test('missing language assets prepare once and retry on the phone', () async {
    final methods = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      methods.add(call.method);
      if (methods.length == 1) {
        throw PlatformException(code: 'translation_assets_not_installed');
      }
      return call.method == 'prepareTranslationAssets'
          ? null
          : response('ready');
    });
    await load();
    expect(methods, [
      'translateTranscriptCues',
      'prepareTranslationAssets',
      'translateTranscriptCues',
    ]);
    expect(controller.failed, isFalse);
  });
  test(
    'background/call blocks model preparation and allows a later foreground retry',
    () async {
      var active = true;
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        active = false;
        throw PlatformException(code: 'translation_assets_not_installed');
      });
      await load(active: () => active);
      expect(calls, 1);
      expect(controller.failed, isFalse);
      active = true;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        return response('resumed');
      });
      await load(active: () => active);
      expect(controller.translations['cue'], 'resumed cue');
    },
  );
  test(
    'unsupported pair fails visibly without another service and supports retry',
    () async {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        throw PlatformException(code: 'unsupported_locale');
      });
      await load();
      await load();
      expect(controller.failed, isTrue);
      expect(calls, 1);
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => response('retry'),
      );
      await load(retry: true);
      expect(controller.failed, isFalse);
    },
  );
  test(
    'Cantonese stays Cantonese; matching English variants need no translation',
    () async {
      expect(PracticeTranslationController.locale('zh-HK'), 'yue-HK');
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (_) async {
        calls++;
        return [];
      });
      await load(target: 'en-US');
      expect(controller.translations, texts);
      expect(calls, 0);
    },
  );
  test('new exercise invalidates an in-flight translation', () async {
    final pending = Completer<Object?>();
    messenger.setMockMethodCallHandler(channel, (_) => pending.future);
    final task = load();
    await Future<void>.delayed(Duration.zero);
    controller.clear();
    pending.complete(response('obsolete'));
    await task;
    expect(controller.translations, isEmpty);
    expect(controller.loading, isFalse);
  });
}
