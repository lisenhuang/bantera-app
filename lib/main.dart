import 'package:flutter/material.dart';
import 'core/auth_session_notifier.dart';
import 'core/api_config_notifier.dart';
import 'core/theme.dart';
import 'core/settings_notifier.dart';
import 'presentation/auth/api_base_url_screen.dart';
import 'presentation/auth/auth_screen.dart';
import 'presentation/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    ApiConfigNotifier.instance.initialize(),
    SettingsNotifier.instance.initialize(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsNotifier.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Bantera',
          theme: BanteraTheme.lightTheme,
          darkTheme: BanteraTheme.darkTheme,
          themeMode: SettingsNotifier.instance.themeMode,
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
      ]),
      builder: (context, child) {
        if (!ApiConfigNotifier.instance.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!ApiConfigNotifier.instance.hasConfiguredBaseUrl) {
          return const ApiBaseUrlScreen(initialSetup: true);
        }

        if (AuthSessionNotifier.instance.isAuthenticated) {
          return const MainScaffold();
        }

        return const AuthScreen();
      },
    );
  }
}
