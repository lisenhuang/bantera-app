import 'dart:convert';
import 'dart:io';

import '../core/api_config_notifier.dart';
import '../core/auth_session_notifier.dart';

enum PaidKeyMode { regularOnly, fallback, paidOnly }

extension PaidKeyModeValue on PaidKeyMode {
  String get wireValue => switch (this) {
    PaidKeyMode.regularOnly => 'regular_only',
    PaidKeyMode.fallback => 'fallback',
    PaidKeyMode.paidOnly => 'paid_only',
  };
}

class PaidKeyPreference {
  const PaidKeyPreference(this.canConfigure, this.mode);
  final bool canConfigure;
  final PaidKeyMode mode;
  factory PaidKeyPreference.fromJson(Map<String, dynamic> json) =>
      PaidKeyPreference(
        json['canConfigure'] == true,
        PaidKeyMode.values.firstWhere(
          (mode) => mode.wireValue == json['mode'],
          orElse: () => PaidKeyMode.regularOnly,
        ),
      );
}

class PaidKeyAccessRevoked implements Exception {}

class PaidKeyPreferenceClient {
  final HttpClient _http = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);
  bool _closed = false;

  Future<PaidKeyPreference> load(String owner) => _request(owner);
  Future<PaidKeyPreference> save(String owner, PaidKeyMode mode) =>
      _request(owner, mode);

  Future<PaidKeyPreference> _request(String owner, [PaidKeyMode? mode]) async {
    final auth = AuthSessionNotifier.instance;
    final token = await auth.refreshAccessTokenForApi();
    void checkOwner() {
      if (_closed || token == null || auth.session?.cacheKey != owner) {
        throw StateError('Session changed');
      }
    }

    checkOwner();
    final uri = Uri.parse(
      '${ApiConfigNotifier.instance.baseUrl}/api/me/ai-key-preference',
    );
    final request = await _http
        .openUrl(mode == null ? 'GET' : 'PUT', uri)
        .timeout(const Duration(seconds: 15));
    try {
      checkOwner();
    } catch (_) {
      request.abort();
      rethrow;
    }
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    if (mode != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'mode': mode.wireValue}));
    }
    final response = await request.close().timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      await response.drain<void>().timeout(const Duration(seconds: 10));
      if (response.statusCode == 403) throw PaidKeyAccessRevoked();
      throw StateError('Preference unavailable');
    }
    var body = '';
    await for (final chunk
        in utf8.decoder.bind(response).timeout(const Duration(seconds: 10))) {
      body += chunk;
      if (body.length > 4096) throw StateError('Invalid preference response');
    }
    checkOwner();
    return PaidKeyPreference.fromJson(jsonDecode(body) as Map<String, dynamic>);
  }

  void close() {
    _closed = true;
    _http.close(force: true);
  }
}
