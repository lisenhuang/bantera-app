import '../../core/auth_session_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../core/settings_notifier.dart';
import '../../core/word_activity_notifier.dart';
import '../auth_api_client.dart';
import '../local_practice_repository.dart';
import '../practice_progress_store.dart';
import '../saved_cue_repository.dart';

class AiDeviceData {
  static const names = [
    'get_learning_profile',
    'get_practice_history',
    'get_saved_media',
    'get_saved_cues',
    'get_daily_goal',
  ];
  static String short(String text) =>
      text.substring(0, text.length.clamp(0, 600));
  static Future<Map<String, dynamic>> read(String name, String owner) async {
    void check() {
      if (AuthSessionNotifier.instance.session?.cacheKey != owner) {
        throw StateError('Account changed');
      }
    }

    check();
    Map<String, dynamic> result;
    switch (name) {
      case 'get_learning_profile':
        final profile = UserProfileNotifier.instance;
        result = {
          'storage': 'server-backed profile',
          'name': profile.displayName,
          'learningLanguageAndAccent': profile.learningLanguage,
          'nativeLanguage': profile.nativeLanguage,
          'learningLevel': SettingsNotifier.instance.audioLevel?.name,
          'learningLevelStorage':
              'device-only Discover preference; null means all levels',
        };
      case 'get_practice_history':
        final store = PracticeProgressStore.instance;
        await store.load();
        check();
        result = {
          'storage': 'device only',
          'total': store.entries.length,
          'limit': 30,
          'items': store.entries
              .take(30)
              .map(
                (e) => {
                  'title': short(e.mediaItem.title),
                  'language': e.mediaItem.spokenLanguage,
                  'accent': e.mediaItem.accent,
                  'completedCues': e.completedCues,
                  'totalCues': e.totalCues,
                  'lastPracticedAt': e.lastPracticedAt
                      .toUtc()
                      .toIso8601String(),
                },
              )
              .toList(),
        };
      case 'get_saved_cues':
        final store = SavedCueRepository.instance;
        await store.load();
        check();
        result = {
          'storage': 'mixed; see each item',
          'total': store.entries.length,
          'limit': 30,
          'items': store.entries
              .take(30)
              .map(
                (e) => {
                  'text': short(e.cueText),
                  'lesson': short(e.mediaItem.title),
                  'storage': e.isLocal ? 'device only' : 'server-backed',
                },
              )
              .toList(),
        };
      case 'get_saved_media':
        final token = await AuthSessionNotifier.instance
            .refreshAccessTokenForApi();
        check();
        if (token == null) throw StateError('Signed out');
        final saved = await AuthApiClient.instance.fetchSavedVideos(
          accessToken: token,
        );
        check();
        await LocalPracticeRepository.instance.refreshForCurrentUser(
          showLoadingState: false,
        );
        check();
        result = {
          'storage':
              'bookmarks are server-backed; local practice files are device only',
          'savedCount': saved.length,
          'limit': 20,
          'saved': saved
              .take(20)
              .map(
                (e) => {
                  'title': short(e.originalFileName),
                  'language': e.transcriptLanguageCode,
                },
              )
              .toList(),
          'localPractice': LocalPracticeRepository.instance.videos
              .take(20)
              .map(
                (e) => {
                  'title': short(e.title),
                  'language': e.spokenLanguage,
                  'accent': e.accent,
                },
              )
              .toList(),
        };
      case 'get_daily_goal':
        final activity = WordActivityNotifier.instance;
        await activity.sync(fetchIfClean: false);
        check();
        final totals = activity.summary;
        result = {
          'storage':
              'daily goal is device only; word activity totals sync to server',
          'goal': activity.dailyGoal?.toJson(),
          'today': totals.today.toJson(),
          'week': totals.week.toJson(),
          'total': totals.total.toJson(),
        };
      default:
        return {'unavailable': true};
    }
    check();
    return result;
  }

  static Future<Map<String, dynamic>> snapshot(String owner) async {
    final data = <String, dynamic>{};
    await Future.wait(
      names.map((name) async {
        try {
          data[name] = await read(
            name,
            owner,
          ).timeout(const Duration(seconds: 8));
        } catch (_) {
          data[name] = {'unavailable': true};
        }
      }),
    );
    return data;
  }
}
