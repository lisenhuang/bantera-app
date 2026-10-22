import 'dart:convert';
import '../../core/apple_system_version.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/translation_service.dart';
import '../../infrastructure/practice_translation_preferences.dart';

enum PracticeTranslationIssue {
  unavailable,
  noLanguages,
  selectionCancelled,
  downloadCancelled,
}

/// Translates the cue and both alternatives in one on-device batch. No backend
/// client or generative AI fallback is used. Late results cannot replace a newer
/// exercise or the user's newly selected translation language.
class PracticeTranslationController extends ChangeNotifier {
  PracticeTranslationController({PracticeTranslationPreferences? preferences})
    : _preferences = preferences ?? PracticeTranslationPreferences.instance;
  final PracticeTranslationPreferences _preferences;
  final _service = TranslationService.instance;
  Future<void> _queue = Future.value();
  String? _key;
  int _generation = 0;
  bool _disposed = false;
  bool loading = false, failed = false, preparing = false;
  PracticeTranslationIssue? issue;
  String? targetLocale;
  Map<String, String> translations = {};

  /// This guard also protects scoring when an old/stale UI action is invoked.
  static Future<bool> markUsed(Future<void> Function() persist) async {
    if (!supportsBuiltInTranslation) return false;
    await persist();
    return true;
  }

  static String locale(String value) {
    final code = value.trim().replaceAll('_', '-');
    if (code.toLowerCase() == 'zh-hk' || code.toLowerCase() == 'zh-hant-hk') {
      return 'yue-HK'; // Cantonese must never silently become Mandarin.
    }
    return code;
  }

  static String languageKey(String value) {
    final code = locale(value).toLowerCase();
    final parts = code.split('-');
    if (parts.first == 'zh') {
      return parts.contains('hant') ||
              parts.contains('tw') ||
              parts.contains('mo')
          ? 'zh-hant'
          : 'zh-hans';
    }
    return parts.first;
  }

  static TranslationLocaleOption? matching(
    List<TranslationLocaleOption> options,
    String? requested,
  ) {
    if (requested == null || requested.trim().isEmpty) return null;
    for (final option in options) {
      if (locale(option.identifier).toLowerCase() ==
          locale(requested).toLowerCase()) {
        return option;
      }
    }
    for (final option in options) {
      if (languageKey(option.identifier) == languageKey(requested)) {
        return option;
      }
    }
    return null;
  }

  Future<void> load({
    required String source,
    required String target,
    required Map<String, String> texts,
    required bool Function() canStart,
    bool retry = false,
    String? owner,
    Future<TranslationLocaleOption?> Function(List<TranslationLocaleOption>)?
    chooseTarget,
    Future<bool> Function()? confirmDownload,
  }) {
    if (_disposed || !supportsBuiltInTranslation) return Future.value();
    source = locale(source);
    target = locale(target);
    final key = jsonEncode([owner, source, target, texts]);
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
    preparing = false;
    issue = null;
    targetLocale = null;
    loading = true;
    notifyListeners();
    bool current() => !_disposed && generation == _generation;
    _queue = _queue.then((_) async {
      if (!current()) return;
      try {
        if (!supportsBuiltInTranslation || !canStart()) return;
        if (languageKey(source) == languageKey(target)) {
          targetLocale = target;
          translations = Map.of(texts);
          return;
        }
        TranslationLocaleOption? selected;
        if (chooseTarget != null) {
          final options = await _service.fetchSupportedLocales(
            sourceLocaleIdentifier: source,
          );
          if (!current() || !canStart()) return;
          selected = matching(options, target);
          if (selected == null && owner != null) {
            final saved = await _preferences.load(owner, languageKey(source));
            if (!current() || !canStart()) return;
            selected = matching(options, saved);
          }
          if (selected == null) {
            if (options.isEmpty) {
              issue = PracticeTranslationIssue.noLanguages;
              failed = true;
              return;
            }
            selected = await chooseTarget(options);
            if (!current() || !canStart()) return;
            if (selected == null) {
              issue = PracticeTranslationIssue.selectionCancelled;
              failed = true;
              return;
            }
            // Only accept a pair returned by the phone for this source.
            selected = matching(options, selected.identifier);
            if (selected == null) throw StateError('Unsupported selection');
            if (owner != null) {
              await _preferences.save(
                owner,
                languageKey(source),
                selected.identifier,
              );
              if (!current() || !canStart()) return;
            }
          }
          target = locale(selected.identifier);
        }
        targetLocale = target;
        Future<bool> prepare() async {
          if (!current() || !canStart()) return false;
          if (confirmDownload != null && !await confirmDownload()) {
            if (current()) {
              issue = PracticeTranslationIssue.downloadCancelled;
              failed = true;
            }
            return false;
          }
          if (!current() || !canStart()) return false;
          preparing = true;
          notifyListeners();
          try {
            await _service.prepareTranslationAssets(
              sourceLocaleIdentifier: source,
              targetLocaleIdentifier: target,
            );
          } finally {
            if (current()) {
              preparing = false;
              notifyListeners();
            }
          }
          return current() && canStart();
        }

        var prepared = false;
        if (selected != null && !selected.isInstalled) {
          if (!await prepare()) return;
          prepared = true;
        }
        if (!current() || !canStart()) return;
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
          if (error.code != 'translation_assets_not_installed' || prepared) {
            rethrow;
          }
          if (!await prepare()) return;
          result = await translate();
        }
        if (!current()) return;
        translations = {
          for (final id in texts.keys)
            if ((result[id]?.trim() ?? '').isNotEmpty) id: result[id]!.trim(),
        };
        failed = translations.length != texts.length;
      } catch (_) {
        if (current()) {
          failed = true;
          issue ??= PracticeTranslationIssue.unavailable;
        }
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
    preparing = false;
    issue = null;
    targetLocale = null;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
