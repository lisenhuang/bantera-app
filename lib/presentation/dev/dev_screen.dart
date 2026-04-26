import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/settings_notifier.dart';
import '../auth/api_base_url_screen.dart';
import 'dev_mock_version_screen.dart';

class DevScreen extends StatelessWidget {
  const DevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: const Text('API Base URL'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => const ApiBaseUrlScreen(),
                      ),
                    );
                    if (changed == true && context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
                if (Platform.isIOS) ...[
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_iphone_outlined),
                    title: const Text('Mock iOS Version'),
                    subtitle: const Text(
                      'Override version for feature-gate testing',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const DevMockVersionScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  ListenableBuilder(
                    listenable: SettingsNotifier.instance,
                    builder: (context, _) {
                      final settings = SettingsNotifier.instance;
                      return SwitchListTile(
                        secondary: const Icon(Icons.language_outlined),
                        title: const Text('Show all learning languages'),
                        subtitle: const Text(
                          'Use native iOS transcription locales. Resets on restart.',
                        ),
                        value: settings.devShowAllLearningLanguages,
                        onChanged: SettingsNotifier
                            .instance
                            .setDevShowAllLearningLanguages,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
