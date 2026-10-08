import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/activity/word_activity.dart';
import '../l10n/app_localizations.dart';
import 'app_locale.dart';
import 'settings_notifier.dart';

/// The native extension receives only today's aggregates and translated labels.
class PracticeWidgetService {
  PracticeWidgetService._() : _send = _sendNative, _supported = Platform.isIOS;

  @visibleForTesting
  PracticeWidgetService.forTesting({
    required Future<void> Function(Map<String, Object>) send,
  }) : _send = send,
       _supported = true;

  static final instance = PracticeWidgetService._();
  static const channel = MethodChannel('bantera/practice_widget');
  final Future<void> Function(Map<String, Object>) _send;
  final bool _supported;
  final chatRequested = ValueNotifier(false);
  Future<void> _queue = Future.value();
  String? _lastSignature;
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_supported || _initialized) return;
    _initialized = true;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'openChat') await _takePendingOpen();
    });
    await _takePendingOpen();
  }

  Future<void> _takePendingOpen() async {
    try {
      if (await channel.invokeMethod<bool>('takePendingOpen') == true) {
        chatRequested.value = true;
      }
    } on PlatformException catch (_) {
      // A widget is optional and must not block app startup.
    } on MissingPluginException catch (_) {}
  }

  static Future<void> _sendNative(Map<String, Object> data) =>
      channel.invokeMethod<void>('update', data);

  Future<void> update({
    required bool signedIn,
    required WordTotals today,
    DateTime? now,
    AppLocalizations? localizations,
  }) {
    if (!_supported) return Future.value();
    final date = now ?? DateTime.now();
    final locale = localizations != null
        ? null
        : resolveAppLocale(
            preference: SettingsNotifier.instance.appLocalePreference,
            platformLocale: PlatformDispatcher.instance.locale,
          );
    // Queue all writes, including account clears, so an older asynchronous update
    // cannot overwrite a newer account's snapshot.
    _queue = _queue
        .then((_) async {
          final l =
              localizations ?? await AppLocalizations.delegate.load(locale!);
          final data = <String, Object>{
            'dateKey': wordActivityDateKey(date),
            'signedIn': signedIn,
            'spoken': signedIn ? today.spoken : 0,
            'listened': signedIn ? today.listened : 0,
            'locale': l.localeName,
            'labels': {
              'today': l.wordActivityToday,
              'spoken': l.wordActivitySpeaking,
              'listened': l.wordActivityListening,
              'words': l.wordActivityWords,
              'chat': 'Bantera AI',
              'signIn': l.authSignIn,
            },
          };
          final signature = jsonEncode(data);
          if (signature == _lastSignature) return;
          await _send(data);
          _lastSignature = signature;
        })
        .catchError((Object error) {
          debugPrint('[PracticeWidget] Update deferred: ${error.runtimeType}');
        });
    return _queue;
  }
}
