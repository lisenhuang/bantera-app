import 'dart:async';
import 'dart:io';

import 'package:app/core/widget_discovery_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late File preference;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('widget-discovery-test');
    preference = File('${directory.path}/dismissed');
  });
  tearDown(() async => directory.delete(recursive: true));
  WidgetDiscoveryService service(
    Future<bool?> Function() detect, {
    bool supported = true,
    Duration timeout = const Duration(seconds: 1),
  }) {
    final s = WidgetDiscoveryService(
      supported: supported,
      detect: detect,
      preferenceFile: () async => preference,
      timeout: timeout,
    );
    addTearDown(s.dispose);
    return s;
  }

  test(
    'only confirmed absence shows Goal; Settings survives every detection state',
    () async {
      bool? result;
      Object? error;
      final s = service(() async {
        if (error != null) throw error;
        return result;
      });
      expect(s.showGoal, false);
      await s.initialize();
      expect(s.state, WidgetConfigurationState.unknown);
      result = false;
      await s.refresh();
      expect(s.showGoal, true);
      expect(s.showSettings, true);
      result = true;
      await s.refresh();
      expect(s.showGoal, false);
      expect(s.showSettings, true);
      error = PlatformException(code: 'widget_detection_failed');
      await s.refresh();
      expect(s.state, WidgetConfigurationState.unknown);
      expect(s.showSettings, true);
      expect(s.showGoal, false);
      error = MissingPluginException();
      await s.refresh();
      expect(s.state, WidgetConfigurationState.unknown);
    },
  );

  test(
    'dismissal survives restart, applies only to Goal and is device local',
    () async {
      final s = service(() async => false);
      await s.initialize();
      await s.dismissGoal();
      expect(s.showGoal, false);
      expect(s.showSettings, true);
      final restarted = service(() async => false);
      await restarted.initialize();
      expect(restarted.showGoal, false);
      expect(restarted.showSettings, true);
      expect(await preference.readAsString(), 'true');
    },
  );

  test(
    'Settings stays available before and after removing a pre-existing widget',
    () async {
      var installed = true;
      final s = service(() async => installed);
      await s.initialize();
      expect(s.showSettings, true);
      s.didChangeAppLifecycleState(AppLifecycleState.paused);
      installed = false;
      s.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await s.refresh();
      expect(s.showSettings, true);
      expect(s.showGoal, true);
      await s.dismissGoal();
      installed = true;
      await s.refresh();
      expect(s.showSettings, true);
      s.didChangeAppLifecycleState(AppLifecycleState.paused);
      installed = false;
      s.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await s.refresh();
      expect(s.showSettings, true);
      expect(s.showGoal, false);
    },
  );

  test(
    'unsupported platforms never query WidgetKit or write preferences',
    () async {
      final s = service(
        () async => throw StateError('must not query'),
        supported: false,
      );
      await s.initialize();
      await s.refresh();
      await s.dismissGoal();
      expect(s.showGoal, false);
      expect(s.showSettings, false);
      expect(await preference.exists(), false);
    },
  );

  test('timeout remains unknown but accepts a valid delayed result', () async {
    final pending = Completer<bool?>();
    final s = service(
      () => pending.future,
      timeout: const Duration(milliseconds: 10),
    );
    await s.initialize();
    expect(s.state, WidgetConfigurationState.unknown);
    pending.complete(false);
    await Future<void>.delayed(Duration.zero);
    expect(s.showSettings, true);
    expect(s.showGoal, true);
  });

  test('foreground rechecks and ignores a stale earlier response', () async {
    final pending = <Completer<bool?>>[];
    var first = true;
    final s = service(() {
      if (first) {
        first = false;
        return Future.value(false);
      }
      final c = Completer<bool?>();
      pending.add(c);
      return c.future;
    });
    await s.initialize();
    final old = s.refresh();
    await Future<void>.delayed(Duration.zero);
    s.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(s.showGoal, false);
    s.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    pending.last.complete(true);
    await Future<void>.delayed(Duration.zero);
    pending.first.complete(false);
    await old;
    expect(s.state, WidgetConfigurationState.present);
  });

  test('failed persistence leaves Goal suggestion available', () async {
    final s = service(() async => false);
    await s.initialize();
    await Directory('${preference.path}.tmp').create();
    await expectLater(s.dismissGoal(), throwsA(isA<FileSystemException>()));
    expect(s.showGoal, true);
    expect(s.showSettings, true);
  });
  test(
    'a transient WidgetKit failure retries and recovers without reopening',
    () async {
      var calls = 0;
      final s = WidgetDiscoveryService(
        supported: true,
        detect: () async {
          if (++calls == 1) {
            throw PlatformException(code: 'widget_detection_failed');
          }
          return false;
        },
        preferenceFile: () async => preference,
        retryDelay: const Duration(milliseconds: 10),
      );
      addTearDown(s.dispose);
      await s.initialize();
      expect(s.state, WidgetConfigurationState.unknown);
      expect(s.showGoal, false);
      expect(s.showSettings, true);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls, 2);
      expect(s.showGoal, true);
    },
  );

  test(
    'failed preference read does not disable discovery and retries locally',
    () async {
      var readable = false;
      var calls = 0;
      final s = WidgetDiscoveryService(
        supported: true,
        detect: () async {
          calls++;
          return false;
        },
        preferenceFile: () async {
          if (!readable) throw FileSystemException('temporarily unavailable');
          return preference;
        },
        retryDelay: const Duration(milliseconds: 10),
      );
      addTearDown(s.dispose);
      await s.initialize();
      expect(calls, 1);
      expect(s.showGoal, false);
      expect(s.showSettings, true);
      readable = true;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(s.showGoal, true);
    },
  );

  test('retries are bounded and stop while backgrounded', () async {
    var calls = 0;
    final s = WidgetDiscoveryService(
      supported: true,
      detect: () async {
        calls++;
        return null;
      },
      preferenceFile: () async => preference,
      retryDelay: const Duration(milliseconds: 10),
      maxRetries: 2,
    );
    addTearDown(s.dispose);
    await s.initialize();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(calls, 3);
    expect(s.state, WidgetConfigurationState.unknown);
    s.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(const Duration(milliseconds: 2));
    s.didChangeAppLifecycleState(AppLifecycleState.paused);
    final pausedCount = calls;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(calls, pausedCount);
  });

  test('newer checks supersede a delayed timed-out result', () async {
    final first = Completer<bool?>();
    var calls = 0;
    final s = service(
      () => ++calls == 1 ? first.future : Future.value(true),
      timeout: const Duration(milliseconds: 10),
    );
    await s.initialize();
    await s.refresh();
    first.complete(false);
    await Future<void>.delayed(Duration.zero);
    expect(s.state, WidgetConfigurationState.present);
    expect(s.showSettings, true);
  });
}
