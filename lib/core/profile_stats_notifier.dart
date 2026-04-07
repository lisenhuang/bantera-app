import 'package:flutter/foundation.dart';

import '../infrastructure/auth_api_client.dart';
import 'auth_session_notifier.dart';

/// Singleton that holds the current user's upload and saved counts.
/// Call [refresh] from any screen that mutates these numbers so
/// [ProfileScreen] reflects the change immediately.
class ProfileStatsNotifier extends ChangeNotifier {
  ProfileStatsNotifier._();

  static final ProfileStatsNotifier instance = ProfileStatsNotifier._();

  int? uploadCount;
  int? savedCount;

  Future<void> refresh() async {
    final token = AuthSessionNotifier.instance.session?.accessToken;
    if (token == null) return;
    try {
      final stats = await AuthApiClient.instance.fetchProfileStats(
        accessToken: token,
      );
      uploadCount = stats.uploadCount;
      savedCount = stats.savedCount;
      notifyListeners();
    } catch (_) {}
  }
}
