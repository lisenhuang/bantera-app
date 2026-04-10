import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/api_config_notifier.dart';
import 'core/app_locale.dart';
import 'core/auth_session_notifier.dart';
import 'core/settings_notifier.dart';
import 'core/theme.dart';
import 'core/user_profile_notifier.dart';
import 'l10n/app_localizations.dart';
import 'presentation/auth/auth_screen.dart';
import 'presentation/main_scaffold.dart';
import 'presentation/onboarding/learning_language_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    ApiConfigNotifier.instance.initialize(),
    SettingsNotifier.instance.initialize(),
    AuthSessionNotifier.instance.initialize(),
  ]);
  UserProfileNotifier.instance;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (SettingsNotifier.instance.appLocalePreference ==
        AppLocalePreference.system) {
      SettingsNotifier.instance.notifyLocaleChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsNotifier.instance,
      builder: (context, _) {
        final settings = SettingsNotifier.instance;
        final platform = WidgetsBinding.instance.platformDispatcher.locale;
        final locale = resolveAppLocale(
          preference: settings.appLocalePreference,
          platformLocale: platform,
        );
        return MaterialApp(
          title: 'Bantera',
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: BanteraTheme.lightTheme,
          darkTheme: BanteraTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const AppRoot(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthSessionNotifier.instance,
        ApiConfigNotifier.instance,
        UserProfileNotifier.instance,
      ]),
      builder: (context, child) {
        if (!ApiConfigNotifier.instance.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!AuthSessionNotifier.instance.isAuthenticated) {
          return const AuthScreen();
        }

        final profile = UserProfileNotifier.instance;
        if (profile.isLoading && profile.profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final lang = profile.learningLanguage?.trim() ?? '';
        if (lang.isEmpty) {
          return const LearningLanguageSetupScreen();
        }

        return const MainScaffold();
      },
    );
  }
}
