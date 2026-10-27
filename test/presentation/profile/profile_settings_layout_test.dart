import 'dart:io';
import 'package:flutter/services.dart';
import 'package:app/core/app_locale.dart';
import 'package:app/core/theme.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/edit_profile_screen.dart';
import 'package:app/presentation/profile/settings_screen.dart';
import 'package:app/presentation/shared/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

Widget app(
  Widget page, {
  bool dark = false,
  Locale locale = const Locale('en'),
  double scale = 1,
}) => MaterialApp(
  theme: dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme,
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: page,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (font.existsSync()) {
      await (FontLoader(
        'Roboto',
      )..addFont(font.readAsBytes().then(ByteData.sublistView))).load();
    }
  });
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Bantera',
      packageName: 'bantera.lisenhuang.com',
      version: '3.0.2',
      buildNumber: '416',
      buildSignature: '',
    );
  });

  testWidgets('profile identity is balanced and name remains editable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const EditProfileScreen()));
    await tester.pumpAndSettle();
    expect(find.text('My Native Language'), findsOneWidget);
    expect(find.text('Learning Language'), findsOneWidget);
    final identity = tester.getRect(
      find.byKey(const ValueKey('profile-identity')),
    );
    expect(identity.top, inInclusiveRange(70, 120));
    expect(identity.width, lessThanOrEqualTo(440));
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets(
    'profile layout fits small screens and large text in every locale',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final locale in AppLocalizations.supportedLocales) {
        await tester.pumpWidget(
          app(const EditProfileScreen(), locale: locale, scale: 2),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: locale.toLanguageTag());
        expect(find.byType(ProfileAvatar), findsOneWidget);
        await tester.ensureVisible(find.byType(ListTile).first);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('Settings keeps only the app display language', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const SettingsScreen(focusLanguages: true)));
    await tester.pumpAndSettle();
    expect(find.text('Languages'), findsOneWidget);
    expect(find.text('Display Language'), findsOneWidget);
    expect(find.text('My Native Language'), findsNothing);
    expect(find.text('Learning Language'), findsNothing);
    final languageY = tester.getTopLeft(find.text('Languages')).dy;
    final rateY = tester.getTopLeft(find.text('Rate & Share')).dy;
    final appearanceY = tester.getTopLeft(find.text('Appearance')).dy;
    expect(languageY, lessThan(rateY));
    expect(rateY, lessThan(appearanceY));
    expect(
      tester.getTopLeft(find.text('Account')).dy,
      lessThan(tester.getTopLeft(find.text('Support')).dy),
    );

    expect(
      tester.getTopLeft(find.text('Languages')).dy,
      inInclusiveRange(50, 100),
    );

    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings-languages.png'),
    );
    await tester.tap(find.byType(DropdownButton<AppLocalePreference>));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('language shortcuts focus the selectors on Edit Profile', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 650));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const EditProfileScreen(focusLanguages: true)));
    await tester.pumpAndSettle();
    expect(find.text('My Native Language').hitTestable(), findsOneWidget);
    expect(find.text('Learning Language').hitTestable(), findsOneWidget);
    expect(find.byType(DropdownButton<AppLocalePreference>), findsNothing);
  });

  for (final dark in [false, true]) {
    testWidgets('profile appearance ${dark ? 'dark' : 'light'}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(402, 874));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(app(const EditProfileScreen(), dark: dark));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(EditProfileScreen),
        matchesGoldenFile(
          'goldens/edit-profile-${dark ? 'dark' : 'light'}.png',
        ),
      );
    });
  }
}
