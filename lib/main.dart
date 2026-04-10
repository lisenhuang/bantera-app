import 'package:flutter/material.dart';
import 'core/auth_session_notifier.dart';
import 'core/api_config_notifier.dart';
import 'core/theme.dart';
import 'core/settings_notifier.dart';
import 'core/user_profile_notifier.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsNotifier.instance,
      builder: (context, _) {
        final settings = SettingsNotifier.instance;
        return MaterialApp(
          title: 'Bantera',
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
