import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/activity/daily_word_goal.dart';
import '../domain/activity/goal_reminder_plan.dart';
import '../domain/activity/word_activity.dart';
import '../l10n/app_localizations.dart';
import 'app_locale.dart';
import 'settings_notifier.dart';

class GoalReminderService {
  GoalReminderService._() : _testing = false;
  @visibleForTesting
  GoalReminderService.forTesting() : _testing = true;
  final bool _testing;
  static final instance = GoalReminderService._();
  static const _firstId = 650000;
  static const _days = 60;
  static const _payload = 'daily-goal';
  final profileRequested = ValueNotifier(false);
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  Future<void> _queue = Future.value();
  int _generation = 0;
  String? _signature;
  bool get _supported => _testing || Platform.isIOS || Platform.isAndroid;

  Future<void> _initialize() => _initializing ??= () async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == _payload) profileRequested.value = true;
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true &&
        launch?.notificationResponse?.payload == _payload) {
      profileRequested.value = true;
    }
  }();

  Future<void> requestPermission() async {
    if (!_supported) return;
    try {
      await _initialize();
      await _notificationPermission();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null &&
          await android.canScheduleExactNotifications() != true) {
        await android.requestExactAlarmsPermission();
      }
    } catch (error) {
      debugPrint('[GoalReminder] Permission unavailable: ${error.runtimeType}');
    }
  }

  Future<void> _notificationPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: false, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Calls are serialized and superseded updates stop at every native await.
  /// This prevents an old account's reminder reappearing after sign-out.
  Future<void> update({
    required String? ownerId,
    required String? language,
    required DailyWordGoal? goal,
    required WordTotals today,
  }) {
    if (!_supported) return Future.value();
    final generation = ++_generation;
    _queue = _queue
        .then((_) async {
          if (generation != _generation) return;
          await _initialize();
          final settings = SettingsNotifier.instance;
          final enabled =
              ownerId != null &&
              language != null &&
              language.isNotEmpty &&
              settings.notificationsEnabled &&
              goal != null &&
              goal.notificationsEnabled &&
              (goal.listened > 0 || goal.spoken > 0);
          // Disabling and sign-out must clear requests even if timezone lookup fails.
          if (!enabled) {
            if (generation != _generation || _signature == 'disabled') return;
            _signature = null;
            for (var index = 0; index < _days; index++) {
              await _plugin.cancel(id: _firstId + index);
              if (generation != _generation) return;
            }
            _signature = 'disabled';
            return;
          }
          final zone = await FlutterTimezone.getLocalTimezone();
          final location = tz.getLocation(zone.identifier);
          final now = tz.TZDateTime.now(location);
          final locale = resolveAppLocale(
            preference: settings.appLocalePreference,
            platformLocale: PlatformDispatcher.instance.locale,
          );
          final dates = goalReminderDates(
            now: now,
            goal: goal,
            today: today,
            days: _days,
          );
          final signature =
              '$ownerId|$language|${goal.toJson()}|${settings.notificationsEnabled}|${zone.identifier}|$locale|${dates.map((d) => d.toIso8601String()).join(',')}';
          if (generation != _generation || signature == _signature) return;
          _signature = null;
          for (var index = 0; index < _days; index++) {
            await _plugin.cancel(id: _firstId + index);
            if (generation != _generation) return;
          }
          if (dates.isNotEmpty) {
            await _notificationPermission();
            if (generation != _generation) return;
            final android = _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
            final exact =
                await android?.canScheduleExactNotifications() == true;
            final l10n = await AppLocalizations.delegate.load(locale);
            for (var index = 0; index < dates.length; index++) {
              if (generation != _generation) return;
              await _plugin.zonedSchedule(
                id: _firstId + index,
                title: l10n.dailyGoalReminderTitle,
                body: l10n.dailyGoalReminderBody,
                scheduledDate: dates[index],
                notificationDetails: NotificationDetails(
                  android: AndroidNotificationDetails(
                    'daily_word_goal',
                    l10n.dailyGoalNotificationLabel,
                    channelDescription: l10n.dailyGoalNotificationHint,
                    importance: Importance.defaultImportance,
                    priority: Priority.defaultPriority,
                  ),
                  iOS: const DarwinNotificationDetails(
                    presentAlert: true,
                    presentBanner: true,
                    presentSound: true,
                  ),
                ),
                androidScheduleMode: exact
                    ? AndroidScheduleMode.exactAllowWhileIdle
                    : AndroidScheduleMode.inexactAllowWhileIdle,
                payload: _payload,
              );
            }
          }
          if (generation == _generation) _signature = signature;
        })
        .catchError((Object error, StackTrace stack) {
          if (_testing) Error.throwWithStackTrace(error, stack);
          _signature = null;
          debugPrint(
            '[GoalReminder] Scheduling deferred: ${error.runtimeType}',
          );
        });
    return _queue;
  }
}
