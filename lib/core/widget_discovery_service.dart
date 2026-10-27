import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Device-only configuration discovery. Configuration is not usage telemetry.
enum WidgetConfigurationState { unknown, absent, present }

class WidgetDiscoveryService extends ChangeNotifier
    with WidgetsBindingObserver {
  WidgetDiscoveryService({
    required this.supported,
    required Future<bool?> Function() detect,
    required Future<File> Function() preferenceFile,
    Future<File> Function()? diagnosticFile,
    this.timeout = const Duration(seconds: 8),
    this.retryDelay = const Duration(seconds: 3),
    this.maxRetries = 3,
  }) : _detect = detect,
       _preferenceFile = preferenceFile,
       _diagnosticFile = diagnosticFile;

  static const channel = MethodChannel('bantera/practice_widget');
  static final instance = WidgetDiscoveryService(
    supported: Platform.isIOS,
    detect: () => channel.invokeMethod<bool>('hasConfiguredWidgets'),
    preferenceFile: () async => File(
      '${(await getApplicationSupportDirectory()).path}/widget-suggestion-dismissed',
    ),
    diagnosticFile: () async => File(
      '${(await getApplicationSupportDirectory()).path}/widget-discovery-state.json',
    ),
  );

  final bool supported;
  final Duration timeout, retryDelay;
  final int maxRetries;
  final Future<bool?> Function() _detect;
  final Future<File> Function() _preferenceFile;
  final Future<File> Function()? _diagnosticFile;
  WidgetConfigurationState state = WidgetConfigurationState.unknown;
  bool _dismissed = false, _preferencesKnown = false, _disposed = false;
  bool _active = true;
  Future<void>? _initializing, _checking;
  Future<void> _diagnosticQueue = Future.value();
  Timer? _retry;
  int _request = 0, _retryCount = 0;
  String? _error;

  // Settings is a permanent help entry. WidgetKit can report configurations
  // the user cannot see, so it must never hide access to the installation guide.
  // Only the Goal suggestion follows discovery and the dismissal preference.
  bool get showSettings => supported;
  bool get showGoal =>
      supported &&
      _preferencesKnown &&
      !_dismissed &&
      state == WidgetConfigurationState.absent;

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    if (!supported || _disposed) return;
    WidgetsBinding.instance.addObserver(this);
    await refresh();
  }

  Future<void> _loadPreferences() async {
    if (_preferencesKnown) return;
    try {
      final file = await _preferenceFile().timeout(timeout);
      _dismissed = await file.exists() && await file.readAsString() == 'true';
      _preferencesKnown = true;
    } catch (_) {
      // Keep Goal hidden, but do not disable discovery or Settings. Retry on
      // subsequent checks rather than caching a startup failure forever.
      _error = 'preference_read_failed';
    }
  }

  Future<void> refresh({bool retry = false}) {
    if (!supported || _disposed || !_active) return Future.value();
    if (_checking != null) return _checking!;
    _retry?.cancel();
    if (!retry) _retryCount = 0;
    final request = ++_request;
    final work = _check(request);
    _checking = work;
    unawaited(
      work.whenComplete(() {
        if (identical(_checking, work)) _checking = null;
      }),
    );
    return work;
  }

  bool _current(int request) => !_disposed && _active && request == _request;

  Future<void> _check(int request) async {
    _error = null;
    await _loadPreferences();
    if (!_current(request)) return;
    _record('checking');
    final pending = Future<bool?>.sync(_detect);
    var timedOut = false;
    // Preserve a delayed but valid answer unless a newer check/foreground
    // session has superseded it. Future.timeout alone discarded this answer.
    unawaited(
      pending.then((value) {
        if (timedOut && _current(request)) _apply(value);
      }, onError: (Object error, StackTrace stack) {}),
    );
    try {
      final configured = await pending.timeout(timeout);
      if (_current(request)) _apply(configured);
    } catch (error) {
      if (!_current(request)) return;
      timedOut = error is TimeoutException;
      _error = error is TimeoutException
          ? 'timeout'
          : error is MissingPluginException
          ? 'plugin_unavailable'
          : error is PlatformException
          ? error.code
          : 'detection_failed';
      _apply(null);
    }
  }

  void _apply(bool? configured) {
    state = switch (configured) {
      true => WidgetConfigurationState.present,
      false => WidgetConfigurationState.absent,
      null => WidgetConfigurationState.unknown,
    };
    if (configured != null) {
      _retry?.cancel();
      _error = _preferencesKnown ? null : 'preference_read_failed';
    }
    _record('completed');
    notifyListeners();
    if (configured == null || !_preferencesKnown) _scheduleRetry();
  }

  void _scheduleRetry() {
    if (!_active || _disposed || _retryCount >= maxRetries) return;
    _retry?.cancel();
    _retry = Timer(retryDelay, () {
      _retryCount++;
      unawaited(refresh(retry: true));
    });
  }

  void _record(String phase) {
    if (_diagnosticFile == null) return;
    // One overwritten local record. No account, progress, location or chat data.
    final data = jsonEncode({
      'at': DateTime.now().toUtc().toIso8601String(),
      'phase': phase,
      'state': state.name,
      'preferencesKnown': _preferencesKnown,
      'dismissed': _dismissed,
      'showGoal': showGoal,
      'showSettings': showSettings,
      'retry': _retryCount,
      'error': _error,
    });
    _diagnosticQueue = _diagnosticQueue.then((_) async {
      try {
        final file = await _diagnosticFile();
        await file.parent.create(recursive: true);
        await file.writeAsString(data, flush: true);
      } catch (_) {
        // Diagnostics must not affect discovery or the UI.
      }
    });
  }

  Future<void> dismissGoal() async {
    if (!supported || !_preferencesKnown) return;
    final file = await _preferenceFile();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString('true', flush: true);
    await temporary.rename(file.path);
    if (_disposed) return;
    _dismissed = true;
    _record('dismissed');
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _active = true;
      unawaited(refresh());
    } else if (state == AppLifecycleState.paused) {
      _active = false;
      _retry?.cancel();
      ++_request;
      _checking = null;
      this.state = WidgetConfigurationState.unknown;
      _record('background');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    ++_request;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
