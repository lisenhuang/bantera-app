import 'package:app/core/ai_consent.dart';
import 'package:app/infrastructure/ai/ai_api_client.dart';
import 'package:app/infrastructure/auth_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'all conversational transports reject before auth, device reads or upload without consent',
    () async {
      final api = AiApiClient();
      final denied = throwsA(isA<AiConsentRequired>());
      await expectLater(
        api.summarize('no-consent', null, [
          {'role': 'user', 'text': 'private'},
        ]),
        denied,
      );
      await expectLater(
        api.reply(
          owner: 'no-consent',
          history: [],
          audioPath: '/does-not-exist.wav',
          requestId: 'test',
          hasMetBanteraAi: false,
        ),
        denied,
      );
      await expectLater(
        api.voice('no-consent', [], 'test', hasMetBanteraAi: false),
        denied,
      );
      await expectLater(
        api.call('no-consent', [], hasMetBanteraAi: false),
        denied,
      );
      api.close();
    },
  );

  test(
    'generation, avatar and correction APIs reject a caller that bypassed the consent UI',
    () async {
      final api = AuthApiClient.instance;
      final denied = throwsA(
        isA<AuthApiException>().having(
          (e) => e.code,
          'code',
          'ai_consent_required',
        ),
      );
      var started = false;
      await expectLater(
        api.generateAiAudioStreaming(
          accessToken: 'no-consent',
          language: 'English',
          languageCode: 'en',
          scenario: 'private',
          durationSeconds: 30,
          onDialogueDone: () {},
          onAudioDone: (_, _) {},
          onStarted: (_) => started = true,
          useV3: true,
        ),
        denied,
      );
      expect(started, false);
      await expectLater(
        api.requestGeneratedProfileImage(
          accessToken: 'no-consent',
          avatarGender: 'male',
        ),
        denied,
      );
      await expectLater(
        api.correctVideoTranscript(
          accessToken: 'no-consent',
          videoId: 'test',
          originalLines: ['private'],
          transcribedCues: [],
        ),
        denied,
      );
    },
  );
}
