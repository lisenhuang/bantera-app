import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/settings_notifier.dart';
import 'presentation/main_scaffold.dart';

void main() {
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
          home: const MainScaffold(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
