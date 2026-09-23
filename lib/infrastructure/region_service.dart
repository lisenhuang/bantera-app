import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'transcription_locale_option.dart';

/// Works out, from the user's IP, whether they are outside mainland China.
///
/// Cloudflare fronts the API and answers `/cdn-cgi/trace` with the caller's
/// country (`loc=CN`), so no third-party geo-IP service is involved. Until the
/// lookup confirms a country other than CN, the user is treated as being in
/// mainland China.
class RegionService {
  RegionService._();

  static final RegionService instance = RegionService._();

  /// Always the production host: a custom dev base URL is not behind Cloudflare.
  static final Uri _traceUri = Uri.parse(
    'https://api.bantera.app/cdn-cgi/trace',
  );
  static const _timeout = Duration(seconds: 5);

  Future<bool>? _outsideMainlandChina;

  /// True only once the IP lookup confirms a country other than CN. Resolved
  /// once per app session; a failed lookup returns false and is retried on the
  /// next call.
  Future<bool> isOutsideMainlandChina() {
    return _outsideMainlandChina ??= _lookupCountry().then((country) {
      if (country == null) _outsideMainlandChina = null;
      return country != null && country != 'CN';
    });
  }

  Future<String?> _lookupCountry() async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.getUrl(_traceUri).timeout(_timeout);
      final response = await request.close().timeout(_timeout);
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(_timeout);
      if (response.statusCode != 200) return null;
      return parseTraceCountry(body);
    } catch (error) {
      log('Region lookup failed: $error', name: 'BanteraRegion');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Reads the `loc=XX` line of a Cloudflare trace response.
  static String? parseTraceCountry(String body) {
    for (final line in body.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('loc=')) {
        final code = trimmed.substring(4).trim().toUpperCase();
        return RegExp(r'^[A-Z]{2}$').hasMatch(code) ? code : null;
      }
    }
    return null;
  }

  /// Chinese (Taiwan) in any spelling: `zh-TW`, `zh_TW`, `zh-Hant-TW`.
  static bool isTaiwanChineseLocale(String identifier) {
    final parts = normalizeLocaleIdentifierForLookup(identifier).split('-');
    return parts.first == 'zh' && parts.skip(1).contains('tw');
  }

  /// Chinese (Taiwan) is hidden from language pickers unless the user is
  /// confirmed to be outside mainland China.
  Future<List<TranscriptionLocaleOption>> filterLanguageOptions(
    List<TranscriptionLocaleOption> options,
  ) async {
    if (!options.any((o) => isTaiwanChineseLocale(o.identifier))) {
      return options;
    }
    if (await isOutsideMainlandChina()) return options;
    return options.where((o) => !isTaiwanChineseLocale(o.identifier)).toList();
  }
}
