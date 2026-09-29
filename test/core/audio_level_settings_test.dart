import 'dart:convert';
import 'dart:io';

import 'package:app/core/settings_notifier.dart';
import 'package:app/domain/audio_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Defaults to all and persists level, latest rapid change, and reset',
    () async {
      final dir = await Directory.systemTemp.createTemp('bantera-level-test-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/settings.json');
      final first = SettingsNotifier.forTesting(settingsFile: file);
      await first.initialize();
      expect(first.audioLevel, isNull);
      await first.setAudioLevel(AudioLevel.beginner);
      final restored = SettingsNotifier.forTesting(settingsFile: file);
      await restored.initialize();
      expect(restored.audioLevel, AudioLevel.beginner);
      await Future.wait([
        restored.setAudioLevel(AudioLevel.advanced),
        restored.setAudioLevel(AudioLevel.intermediate),
        restored.setAudioLevel(AudioLevel.beginner),
      ]);
      final latest = SettingsNotifier.forTesting(settingsFile: file);
      await latest.initialize();
      expect(latest.audioLevel, AudioLevel.beginner);
      await latest.setAudioLevel(null);
      final cleared = SettingsNotifier.forTesting(settingsFile: file);
      await cleared.initialize();
      expect(cleared.audioLevel, isNull);
      expect(jsonDecode(await file.readAsString())['audioLevel'], isNull);
    },
  );

  test('Old settings and unknown levels default to all', () async {
    final dir = await Directory.systemTemp.createTemp('bantera-level-test-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/settings.json');
    for (final data in [
      {'themeMode': 'dark'},
      {'audioLevel': 'native'},
    ]) {
      await file.writeAsString(jsonEncode(data));
      final settings = SettingsNotifier.forTesting(settingsFile: file);
      await settings.initialize();
      expect(settings.audioLevel, isNull);
    }
  });
}
