import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../core/app_locale.dart';
import '../core/app_resume_notifier.dart';
import '../core/settings_notifier.dart';
import 'transcription_locale_option.dart';
import 'learning_language_catalog.dart';
import 'language_availability_service.dart';

/// Works out, from the user's IP, whether they are outside mainland China.
///
/// Cloudflare fronts the API and answers `/cdn-cgi/trace` with the caller's
/// country (`loc=CN`), so no third-party geo-IP service is involved. Until the
/// lookup confirms a country other than CN, the user is treated as being in
/// mainland China.
class RegionService extends ChangeNotifier {
  RegionService._()
    : _countryLookup = null,
      _appLocale = null,
      _languageAvailability = LanguageAvailabilityService.instance {
    AppResumeNotifier.instance.addListener(_refreshCountry);
  }

  @visibleForTesting
  RegionService.forTesting({
    required Future<String?> Function() countryLookup,
    required Locale Function() appLocale,
    LanguageAvailabilityService? languageAvailability,
  }) : _countryLookup = countryLookup,
       _appLocale = appLocale,
       _languageAvailability = languageAvailability;

  final Future<String?> Function()? _countryLookup;
  final Locale Function()? _appLocale;
  final LanguageAvailabilityService? _languageAvailability;

  static final RegionService instance = RegionService._();

  /// Always the production host: a custom dev base URL is not behind Cloudflare.
  static final Uri _traceUri = Uri.parse(
    'https://api.bantera.app/cdn-cgi/trace',
  );
  static const _timeout = Duration(seconds: 5);

  Future<bool>? _outsideMainlandChina;
  bool _lookupPending = false;
  String? _confirmedCountry;
  bool _confirmedOutsideMainlandChina = false;

  /// IP-only visibility for group chats and DM call controls, independent of
  /// the app's display, native and learning languages. Hidden during startup.
  bool get showSocialChatFeatures => _confirmedOutsideMainlandChina;

  void _refreshCountry() {
    unawaited(isOutsideMainlandChina(refresh: true));
  }

  /// True only once the IP lookup confirms a country other than CN. Resolved
  /// per foreground session; resume refreshes the IP after network changes.
  /// Failed lookups hide the controls and are retried on the next call.
  Future<bool> isOutsideMainlandChina({bool refresh = false}) {
    if (refresh && !_lookupPending) _outsideMainlandChina = null;
    return _outsideMainlandChina ??= _resolveCountry();
  }

  Future<bool> _resolveCountry() async {
    _lookupPending = true;
    String? country;
    try {
      final value = await Future<String?>.sync(
        _countryLookup ?? _lookupCountry,
      );
      country = value == null ? null : parseTraceCountry('loc=$value');
    } catch (_) {
      // Injected lookups and unexpected transport failures also fail closed.
    }
    _lookupPending = false;
    if (country == null) _outsideMainlandChina = null;
    _confirmedCountry = country;
    final outside = country != null && country != 'CN';
    if (_confirmedOutsideMainlandChina != outside) {
      _confirmedOutsideMainlandChina = outside;
      notifyListeners();
    }
    return outside;
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
        return RegExp(r'^[A-Z]{2}$').hasMatch(code) && code != 'XX'
            ? code
            : null;
      }
    }
    return null;
  }

  /// Learning lists promote NZ choices only after a successful IP lookup.
  /// Cached lists are re-sorted when opened after a foreground/network refresh.
  Future<List<TranscriptionLocaleOption>> profileLanguageOptions(
    Iterable<TranscriptionLocaleOption> options, {
    required bool isAdmin,
    bool Function()? currentIsAdmin,
    bool nativeLanguage = false,
  }) async {
    if (!nativeLanguage) {
      await Future.wait([
        isOutsideMainlandChina(),
        if (_languageAvailability != null) _languageAvailability.refresh(),
      ]);
    }
    return filterLanguageOptions(
      profileLanguageOptionsForRole(
        options,
        isAdmin: currentIsAdmin?.call() ?? isAdmin,
        maoriPublicEnabled: _languageAvailability?.maoriPublicEnabled ?? false,
        nativeLanguage: nativeLanguage,
        preferNewZealand: _confirmedCountry == 'NZ',
      ),
    );
  }

  /// Chinese (Taiwan) in any spelling: `zh-TW`, `zh_TW`, `zh-Hant-TW`.
  static bool isTaiwanChineseLocale(String identifier) {
    final parts = normalizeLocaleIdentifierForLookup(identifier).split('-');
    return parts.first == 'zh' && parts.skip(1).contains('tw');
  }

  bool get _usesSimplifiedChinese {
    final locale =
        _appLocale?.call() ??
        resolveAppLocale(
          preference: SettingsNotifier.instance.appLocalePreference,
          platformLocale: WidgetsBinding.instance.platformDispatcher.locale,
        );
    return resolvePlatformLocale(locale) ==
        AppLocalePreference.zhCn.explicitLocale;
  }

  /// Chinese (Taiwan) is hidden when the app UI is Simplified Chinese, or
  /// unless the user's IP is confirmed to be outside mainland China.
  Future<List<TranscriptionLocaleOption>> filterLanguageOptions(
    List<TranscriptionLocaleOption> options,
  ) async {
    if (!options.any((o) => isTaiwanChineseLocale(o.identifier))) {
      return options;
    }
    if (!_usesSimplifiedChinese) {
      final outsideMainlandChina = await isOutsideMainlandChina();
      // The app language may change while the country lookup is in flight.
      if (outsideMainlandChina && !_usesSimplifiedChinese) return options;
    }
    return options.where((o) => !isTaiwanChineseLocale(o.identifier)).toList();
  }
}
