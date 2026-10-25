import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../infrastructure/practice_translation_preferences.dart';

bool supportsPracticePronunciation(String? locale) {
  final code = (locale ?? '').replaceAll('_', '-').toLowerCase();
  return const {
    'zh',
    'yue',
    'ja',
    'ko',
    'th',
    'hi',
    'ar',
    'he',
    'ru',
    'uk',
    'el',
  }.contains(code.split('-').first);
}

class PracticePronunciationController extends ChangeNotifier {
  PracticePronunciationController({PracticeTranslationPreferences? preferences})
    : preferences =
          preferences ??
          PracticeTranslationPreferences(
            file: () async => File(
              '${(await getApplicationSupportDirectory()).path}/practice_pronunciation.json',
            ),
          );
  final PracticeTranslationPreferences preferences;
  bool enabled = false;
  bool saving = false;
  bool active = false;
  String status = 'preparing';
  Map<String, dynamic>? data;
  String? _owner, _locale, _id;
  Future<Map<String, dynamic>> Function(String)? _fetch;
  Timer? _timer;
  int _epoch = 0;
  bool _disposed = false, _loadingPreference = false, _fetching = false;

  void configure({
    required String? owner,
    required String? locale,
    required String? id,
    required Map<String, dynamic>? embedded,
    required bool active,
    required Future<Map<String, dynamic>> Function(String) fetch,
  }) {
    final changedOwner = owner != _owner || locale != _locale;
    final changedExercise = changedOwner || id != _id;
    this.active = active;
    _fetch = fetch;
    if (changedExercise) {
      _epoch++;
      _timer?.cancel();
      _fetching = false;
      _owner = owner;
      _locale = locale;
      _id = id;
      data = embedded;
      status = embedded?['status'] as String? ?? 'preparing';
    }
    if (changedOwner) {
      enabled = false;
      saving = false;
      _loadingPreference = true;
      unawaited(_loadPreference(owner, locale));
    }
    if (!active) _timer?.cancel();
    if (changedExercise) notifyListeners();
    _request();
  }

  Future<void> _loadPreference(String? owner, String? locale) async {
    var selected = false;
    try {
      if (owner != null && locale != null) {
        selected = await preferences.load(owner, locale) == 'on';
      }
    } catch (_) {}
    if (_disposed || owner != _owner || locale != _locale) return;
    enabled = selected;
    _loadingPreference = false;
    notifyListeners();
    _request();
  }

  Future<bool> setEnabled(bool value) async {
    final owner = _owner, locale = _locale;
    if (owner == null || locale == null || saving || _loadingPreference) {
      return false;
    }
    saving = true;
    notifyListeners();
    try {
      await preferences.save(owner, locale, value ? 'on' : 'off');
      if (_disposed || owner != _owner || locale != _locale) return false;
      enabled = value;
      if (!value) _timer?.cancel();
      return true;
    } catch (_) {
      return false;
    } finally {
      if (!_disposed && owner == _owner && locale == _locale) {
        saving = false;
        notifyListeners();
        _request();
      }
    }
  }

  void retry() {
    status = 'preparing';
    _request();
    notifyListeners();
  }

  void _request() {
    if (_disposed ||
        _loadingPreference ||
        _fetching ||
        !enabled ||
        !active ||
        _id == null ||
        !supportsPracticePronunciation(_locale) ||
        status == 'ready' ||
        status == 'unavailable' ||
        status == 'unsupported') {
      return;
    }
    _timer?.cancel();
    unawaited(_poll(_epoch, _id!));
  }

  Future<void> _poll(int epoch, String id) async {
    _fetching = true;
    try {
      final result = await _fetch!(id);
      if (_disposed || epoch != _epoch) return;
      data = result;
      status = result['status'] as String? ?? 'unavailable';
    } catch (_) {
      if (!_disposed && epoch == _epoch) status = 'unavailable';
    } finally {
      if (!_disposed && epoch == _epoch) {
        _fetching = false;
        notifyListeners();
        if (enabled && active && status == 'preparing') {
          _timer = Timer(const Duration(seconds: 5), _request);
        }
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _timer?.cancel();
    super.dispose();
  }
}
