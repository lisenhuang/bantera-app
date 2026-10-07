import 'package:app/core/settings_notifier.dart';
import 'package:app/domain/audio_level.dart';
import 'package:app/infrastructure/ai/ai_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => SettingsNotifier.instance.setAudioLevel(null));

  test(
    'each new AI session reads the latest Discover level, including All',
    () async {
      for (final level in <AudioLevel?>[
        AudioLevel.beginner,
        AudioLevel.advanced,
        AudioLevel.intermediate,
        null,
      ]) {
        await SettingsNotifier.instance.setAudioLevel(level);
        final metadata = await AiApiClient.metadata(hasMetBanteraAi: true);
        expect(metadata['learningLevel'], level?.name);
        expect(metadata['clock'], isA<Map>());
        expect(metadata['hasMetBanteraAi'], isTrue);
      }
    },
  );
}
