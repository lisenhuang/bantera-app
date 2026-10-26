import 'dart:convert';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'practice_translation_route.dart';
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

/// Translates the cue and alternatives in on-device batches, using English
/// only when a direct pair is unavailable and both bridge steps exist. No backend
/// client or generative AI fallback is used. Late results cannot replace a newer
/// exercise or the user's newly selected translation language.
class PracticeTranslationController extends ChangeNotifier {
  PracticeTranslationController({PracticeTranslationPreferences? preferences})
    : _preferences = preferences ?? PracticeTranslationPreferences.instance;
  final PracticeTranslationPreferences _preferences;
  final _service = TranslationService.instance;
  Future<void> _queue = Future.value();
  Future<void> _nativeBarrier = Future.value();
  _PracticeTranslationJob? _job;

  void _cancelJob() {
    final job = _job;
    _job = null;
    if (job == null) return;
    final cancellation = job.cancel(_service);
    _nativeBarrier = Future.wait([_nativeBarrier, cancellation]).then((_) {});
  }

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

  static String locale(String value) => practiceTranslationLocale(value);

  static String languageKey(String value) =>
      practiceTranslationLanguageKey(value);

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

  Future<bool> changeTarget({
    required String source,
    required String owner,
    required bool Function() canStart,
    required Future<TranslationLocaleOption?> Function(
      List<TranslationLocaleOption>,
    )
    chooseTarget,
  }) async {
    if (_disposed || !supportsBuiltInTranslation || !canStart()) return false;
    // Suspend the obsolete operation before opening a picker. If dismissed,
    // the screen resumes the previous choice after its modal has closed.
    if (loading) {
      _generation++;
      _key = null;
      _cancelJob();
      loading = false;
      preparing = false;
      notifyListeners();
    }
    final generation = _generation;
    bool current() => !_disposed && generation == _generation && canStart();
    await _nativeBarrier;
    if (!current()) return false;
    final options = await PracticeTranslationRoute.options(
      source: locale(source),
      canContinue: current,
    );
    if (!current()) return false;
    if (options.isEmpty) {
      throw const TranslationException(
        code: 'no_languages',
        message: 'No supported translation languages.',
      );
    }
    final choice = await chooseTarget(options);
    if (!current() || choice == null) return false;
    final selected = matching(options, choice.identifier);
    if (selected == null) return false;
    await _preferences.saveOverride(
      owner,
      languageKey(source),
      selected.identifier,
    );
    if (!current()) return false;
    clear();
    targetLocale = selected.identifier;
    notifyListeners();
    return true;
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
    _cancelJob();
    final job = _PracticeTranslationJob();
    _job = job;
    _key = key;
    translations = {};
    failed = false;
    preparing = false;
    issue = null;
    targetLocale = null;
    loading = true;
    notifyListeners();
    bool current() => !_disposed && generation == _generation;
    _queue = _nativeBarrier.then((_) async {
      if (!current()) return;
      try {
        if (!supportsBuiltInTranslation || !canStart()) return;
        final override = owner == null
            ? null
            : await _preferences.loadOverride(owner, languageKey(source));
        if (!current() || !canStart()) return;
        if (override == null && languageKey(source) == languageKey(target)) {
          targetLocale = target;
          translations = Map.of(texts);
          return;
        }
        TranslationLocaleOption? selected;
        if (chooseTarget != null) {
          final options = await PracticeTranslationRoute.options(
            source: source,
            canContinue: () => current() && canStart(),
          );
          if (!current() || !canStart()) return;
          selected = matching(options, override) ?? matching(options, target);
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
            // Only accept a route verified using this phone’s supported pairs.
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
        final via = selected is PracticeTranslationRoute
            ? selected.viaEnglish?.identifier
            : null;
        final steps = [
          if (via != null) (source: source, target: via),
          (source: via ?? source, target: target),
        ];
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
            for (final step in steps) {
              if (!current() || !canStart()) return false;
              await job.run(
                () => _service.prepareTranslationAssets(
                  sourceLocaleIdentifier: step.source,
                  targetLocaleIdentifier: step.target,
                  requestId: job.id,
                ),
              );
            }
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
        Future<Map<String, String>> translate() async {
          var input = Map.of(texts);
          for (final step in steps) {
            if (!current() || !canStart()) return {};
            final result = await job.run(
              () => _service.translateCues(
                requestId: job.id,
                sourceLocaleIdentifier: step.source,
                targetLocaleIdentifier: step.target,
                cues: input.entries
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
              ),
            );
            // Never display an intermediate English result or pass a partially
            // translated batch on as if it were complete.
            if (texts.keys.any((id) => (result[id]?.trim() ?? '').isEmpty)) {
              throw const TranslationException(
                code: 'incomplete_translation',
                message: 'Translation could not be completed.',
              );
            }
            input = {for (final id in texts.keys) id: result[id]!.trim()};
          }
          return input;
        }

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
        if (!current() || !canStart()) return;
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
        if (identical(_job, job)) _job = null;
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
    _cancelJob();
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
    _cancelJob();
    super.dispose();
  }
}

/// Cancels the wait independently of an OS-managed model download. Every native
/// result still has an observer, so late success/errors cannot leak into the UI.
class _PracticeTranslationJob {
  final id = const Uuid().v4();
  final _cancelled = Completer<void>();
  bool _nativeActive = false;

  Future<T> run<T>(Future<T> Function() operation) async {
    if (_cancelled.isCompleted) {
      throw const TranslationException(
        code: 'cancelled',
        message: 'Translation cancelled.',
      );
    }
    _nativeActive = true;
    try {
      return await Future.any([
        operation(),
        _cancelled.future.then<T>(
          (_) => throw const TranslationException(
            code: 'cancelled',
            message: 'Translation cancelled.',
          ),
        ),
      ]);
    } finally {
      _nativeActive = false;
    }
  }

  Future<void> cancel(TranslationService service) async {
    final active = _nativeActive;
    if (!_cancelled.isCompleted) _cancelled.complete();
    if (active) await service.cancelRequest(id);
  }
}
