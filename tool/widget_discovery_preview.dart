// Simulator-only visual QA entry point; never used by production main.dart.
import 'package:app/core/settings_notifier.dart';
import 'package:app/core/widget_discovery_service.dart';
import 'package:app/core/theme.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/profile_screen.dart';
import 'package:app/presentation/profile/settings_screen.dart';
import 'package:app/presentation/widgets/widget_discovery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  if (!kDebugMode) throw StateError('Simulator QA is debug-only');
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsNotifier.instance.initialize();
  await WidgetDiscoveryService.instance.initialize();
  runApp(const Preview());
}

class Preview extends StatefulWidget {
  const Preview({super.key});
  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  int page = 0;
  bool dark = false, largeText = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(largeText ? 2.5 : 1)),
      child: child!,
    ),
    home: Scaffold(
      body: switch (page) {
        0 => const ProfileScreen(),
        1 => const SettingsScreen(),
        _ => const WidgetGuideScreen(),
      },
      bottomNavigationBar: SafeArea(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (final entry in ['Goal', 'Settings', 'Guide'].asMap().entries)
              TextButton(
                onPressed: () => setState(() => page = entry.key),
                child: Text(entry.value),
              ),
            IconButton(
              tooltip: 'Theme',
              onPressed: () => setState(() => dark = !dark),
              icon: const Icon(Icons.contrast),
            ),
            IconButton(
              tooltip: 'Large text',
              onPressed: () => setState(() => largeText = !largeText),
              icon: const Icon(Icons.text_increase),
            ),
          ],
        ),
      ),
    ),
  );
}
