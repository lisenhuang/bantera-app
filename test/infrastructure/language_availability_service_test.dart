import 'dart:async';
import 'dart:io';

import 'package:app/infrastructure/auth_api_client.dart';
import 'package:app/infrastructure/language_availability_service.dart';
import 'package:app/infrastructure/region_service.dart';
import 'package:app/infrastructure/transcription_locale_option.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => HttpOverrides.global = null);

  test(
    'public availability accepts only a successful explicit true flag',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var status = 200;
      var body = '{"maoriPublicEnabled":true}';
      final paths = <String>[];
      server.listen((request) async {
        paths.add(request.uri.path);
        expect(request.headers.value(HttpHeaders.authorizationHeader), isNull);
        expect(
          request.headers.value(HttpHeaders.cacheControlHeader),
          'no-cache',
        );
        request.response.statusCode = status;
        request.response.write(body);
        await request.response.close();
      });
      final api = AuthApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      try {
        expect(await api.fetchMaoriPublicEnabled(), isTrue);
        for (final response in [
          '{}',
          '{"maoriPublicEnabled":false}',
          '{"maoriPublicEnabled":"true"}',
          '[]',
          'not json',
        ]) {
          body = response;
          expect(
            await api.fetchMaoriPublicEnabled(),
            isFalse,
            reason: response,
          );
        }
        status = 404;
        body = '{"maoriPublicEnabled":true}';
        expect(await api.fetchMaoriPublicEnabled(), isFalse);
        expect(paths.toSet(), {'/api/public/language-availability'});
      } finally {
        await server.close(force: true);
      }
      expect(await api.fetchMaoriPublicEnabled(), isFalse);
    },
  );

  test(
    'failed refresh revokes previous public availability and can retry',
    () async {
      var fail = false;
      var enabled = true;
      final service = LanguageAvailabilityService.forTesting(
        lookup: () async {
          if (fail) throw const SocketException('offline');
          return enabled;
        },
      );
      addTearDown(service.dispose);
      final changes = <bool>[];
      service.addListener(() => changes.add(service.maoriPublicEnabled));
      expect(service.maoriPublicEnabled, isFalse);
      expect(await service.refresh(), isTrue);
      fail = true;
      expect(await service.refresh(), isFalse);
      fail = false;
      expect(await service.refresh(), isTrue);
      enabled = false;
      expect(await service.refresh(), isFalse);
      expect(changes, [true, false, true, false]);
    },
  );

  test('concurrent picker loads share one availability lookup', () async {
    var calls = 0;
    final response = Completer<bool>();
    final service = LanguageAvailabilityService.forTesting(
      lookup: () {
        calls++;
        return response.future;
      },
    );
    addTearDown(service.dispose);
    final first = service.refresh();
    final second = service.refresh();
    expect(calls, 1);
    expect(service.maoriPublicEnabled, isFalse);
    response.complete(true);
    expect(await first, isTrue);
    expect(await second, isTrue);
  });

  test(
    'cached picker options follow setting changes and current account role',
    () async {
      var public = false;
      var admin = true;
      final availability = LanguageAvailabilityService.forTesting(
        lookup: () async => public,
      );
      final region = RegionService.forTesting(
        countryLookup: () async => 'NZ',
        appLocale: () => const Locale('en'),
        languageAvailability: availability,
      );
      addTearDown(region.dispose);
      addTearDown(availability.dispose);
      var options = [
        const TranscriptionLocaleOption(
          identifier: 'en-NZ',
          displayName: 'English',
          isInstalled: false,
        ),
      ];
      Future<void> refresh() async {
        options = await region.profileLanguageOptions(
          options,
          isAdmin: admin,
          currentIsAdmin: () => admin,
        );
      }

      await refresh();
      expect(options.first.identifier, 'mi-NZ');
      expect(options.first.isAdminOnly, isTrue);
      admin = false;
      await refresh();
      expect(options.map((o) => o.identifier), ['en-NZ']);
      public = true;
      await refresh();
      expect(options.first.identifier, 'mi-NZ');
      expect(options.first.isAdminOnly, isFalse);
      admin = true;
      await refresh();
      expect(options.first.isAdminOnly, isFalse);
      public = false;
      await refresh();
      expect(options.first.isAdminOnly, isTrue);
      admin = false;
      await refresh();
      expect(options.map((o) => o.identifier), ['en-NZ']);
    },
  );

  test(
    'role changes during async lookup cannot keep a cached admin choice',
    () async {
      var admin = true;
      final response = Completer<bool>();
      final availability = LanguageAvailabilityService.forTesting(
        lookup: () => response.future,
      );
      final region = RegionService.forTesting(
        countryLookup: () async => 'NZ',
        appLocale: () => const Locale('en'),
        languageAvailability: availability,
      );
      addTearDown(region.dispose);
      addTearDown(availability.dispose);
      final result = region.profileLanguageOptions(
        const [
          TranscriptionLocaleOption(
            identifier: 'mi-NZ',
            displayName: 'Māori',
            isInstalled: false,
            isAdminOnly: true,
          ),
        ],
        isAdmin: true,
        currentIsAdmin: () => admin,
      );
      admin = false;
      response.complete(false);
      expect(await result, isEmpty);
    },
  );
}
