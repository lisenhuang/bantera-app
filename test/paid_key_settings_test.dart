import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/infrastructure/paid_key_preference_client.dart';
import 'package:app/presentation/profile/paid_key_settings.dart';

class FakeClient extends PaidKeyPreferenceClient {
  PaidKeyPreference value;
  bool revoked = false;
  bool fail = false;
  FakeClient(this.value);
  @override
  Future<PaidKeyPreference> load(String owner) async => value;
  @override
  Future<PaidKeyPreference> save(String owner, PaidKeyMode mode) async {
    if (revoked) throw PaidKeyAccessRevoked();
    if (fail) throw StateError('offline');
    return value = PaidKeyPreference(true, mode);
  }
}

Widget app(FakeClient client) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: PaidKeySettings(owner: 'owner', client: client),
  ),
);
void main() {
  testWidgets('hidden for accounts without paid access', (tester) async {
    await tester.pumpWidget(
      app(FakeClient(const PaidKeyPreference(false, PaidKeyMode.regularOnly))),
    );
    await tester.pumpAndSettle();
    expect(find.text('AI key preference'), findsNothing);
  });
  testWidgets('allowed account can save each mode without losing access', (
    tester,
  ) async {
    final client = FakeClient(
      const PaidKeyPreference(true, PaidKeyMode.fallback),
    );
    await tester.pumpWidget(app(client));
    await tester.pumpAndSettle();
    for (final entry in {
      'Paid key only': PaidKeyMode.paidOnly,
      'Regular keys only': PaidKeyMode.regularOnly,
      'Use paid key as fallback': PaidKeyMode.fallback,
    }.entries) {
      await tester.tap(find.text('AI key preference'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.key).last);
      await tester.pumpAndSettle();
      expect(client.value.mode, entry.value);
      expect(find.text('AI key preference'), findsOneWidget);
      expect(find.text(entry.key), findsOneWidget);
    }
  });
  testWidgets(
    'failed save keeps previous mode and revoked access hides control',
    (tester) async {
      final client = FakeClient(
        const PaidKeyPreference(true, PaidKeyMode.fallback),
      )..fail = true;
      await tester.pumpWidget(app(client));
      await tester.pumpAndSettle();
      await tester.tap(find.text('AI key preference'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paid key only'));
      await tester.pumpAndSettle();
      expect(client.value.mode, PaidKeyMode.fallback);
      expect(find.text('Failed to save.'), findsOneWidget);
      client.revoked = true;
      await tester.tap(find.text('AI key preference'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paid key only'));
      await tester.pumpAndSettle();
      expect(find.text('AI key preference'), findsNothing);
    },
  );
}
