import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api_config_notifier.dart';
import '../core/app_resume_notifier.dart';
import 'auth_api_client.dart';

/// Public language rollout flags are confirmed by the current API, never disk.
class LanguageAvailabilityService extends ChangeNotifier {
  LanguageAvailabilityService._()
    : _lookup = AuthApiClient.instance.fetchMaoriPublicEnabled {
    AppResumeNotifier.instance.addListener(_refreshOnResume);
    ApiConfigNotifier.instance.addListener(_apiChanged);
  }

  @visibleForTesting
  LanguageAvailabilityService.forTesting({
    required Future<bool> Function() lookup,
  }) : _lookup = lookup;

  static final LanguageAvailabilityService instance =
      LanguageAvailabilityService._();

  final Future<bool> Function() _lookup;
  Future<bool>? _pending;
  bool _maoriPublicEnabled = false;
  bool _disposed = false;
  int _generation = 0;

  bool get maoriPublicEnabled => _maoriPublicEnabled;

  void _refreshOnResume() => unawaited(refresh());

  void _apiChanged() {
    _generation++;
    _pending = null;
    _setEnabled(false);
    unawaited(refresh());
  }

  /// Picker openings always refresh; concurrent callers share one lookup.
  /// Missing endpoints, malformed responses and failures restore testing-only.
  Future<bool> refresh() => _pending ??= _load(_generation);

  Future<bool> _load(int generation) async {
    var enabled = false;
    try {
      enabled = await _lookup();
    } catch (_) {
      // A stale success must not turn an unavailable setting into public access.
    }
    if (!_disposed && generation == _generation) {
      _pending = null;
      _setEnabled(enabled);
    }
    return _maoriPublicEnabled;
  }

  void _setEnabled(bool value) {
    if (_maoriPublicEnabled == value) return;
    _maoriPublicEnabled = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    AppResumeNotifier.instance.removeListener(_refreshOnResume);
    ApiConfigNotifier.instance.removeListener(_apiChanged);
    super.dispose();
  }
}
