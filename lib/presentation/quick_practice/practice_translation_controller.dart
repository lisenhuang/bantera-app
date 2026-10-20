import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/translation_service.dart';

/// Translates the cue and both alternatives in one on-device batch. No backend
/// client or generative AI fallback is used. Late results cannot replace a newer
/// exercise or the user's newly selected translation language.
class PracticeTranslationController extends ChangeNotifier {
  final _service = TranslationService.instance;
  Future<void> _queue = Future.value();
  String? _key;
  int _generation = 0;
  bool _disposed = false;
  bool loading = false, failed = false;
  Map<String, String> translations = {};

  static String locale(String value) {
    final code = value.trim().replaceAll('_', '-');
    if (code.toLowerCase() == 'zh-hk' || code.toLowerCase() == 'zh-hant-hk') {
      return 'yue-HK'; // Cantonese must never silently become Mandarin.
    }
    return code;
  }

  static bool _sameLanguage(String source, String target) {
    if (source.toLowerCase() == target.toLowerCase()) return true;
    final a = source.toLowerCase().split('-').first;
    final b = target.toLowerCase().split('-').first;
    return a == b && a != 'zh'; // Keep simplified/traditional Chinese distinct.
  }

  Future<void> load({
    required String source,
    required String target,
    required Map<String, String> texts,
    required bool Function() canStart,
    bool retry = false,
  }) {
    if (_disposed) return Future.value();
    source = locale(source);
    target = locale(target);
    final key = jsonEncode([source, target, texts]);
    if (_key == key &&
        (loading ||
            translations.length == texts.length ||
            (failed && !retry))) {
      return _queue;
    }
    final generation = ++_generation;
    _key = key;
    translations = {};
    failed = false;
    loading = true;
    notifyListeners();
    bool current() => !_disposed && generation == _generation;
    _queue = _queue.then((_) async {
      if (!current()) return;
      try {
        if (!canStart()) return;
        if (_sameLanguage(source, target)) {
          translations = Map.of(texts);
          return;
        }
        Future<Map<String, String>> translate() => _service.translateCues(
          sourceLocaleIdentifier: source,
          targetLocaleIdentifier: target,
          cues: texts.entries
              .map(
                (e) => Cue(
                  id: e.key,
                  startTimeMs: 0,
                  endTimeMs: 0,
                  originalText: e.value,
                  translatedText: '',
                ),
              )
              .toList(),
        );
        Map<String, String> result;
        try {
          result = await translate();
        } on TranslationException catch (error) {
          if (error.code != 'translation_assets_not_installed') rethrow;
          if (!current() || !canStart()) return;
          await _service.prepareTranslationAssets(
            sourceLocaleIdentifier: source,
            targetLocaleIdentifier: target,
          );
          if (!current() || !canStart()) return;
          result = await translate();
        }
        if (!current()) return;
        translations = {
          for (final id in texts.keys)
            if ((result[id]?.trim() ?? '').isNotEmpty) id: result[id]!.trim(),
        };
        failed = translations.length != texts.length;
      } catch (_) {
        if (current()) failed = true;
      } finally {
        if (current()) {
          loading = false;
          notifyListeners();
        }
      }
    });
    return _queue;
  }

  void clear() {
    _generation++;
    _key = null;
    translations = {};
    loading = false;
    failed = false;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
