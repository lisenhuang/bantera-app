import 'package:flutter/material.dart';

import '../../core/settings_notifier.dart';

/// Dev-only screen to mock the iOS major version for feature-gate testing.
/// Only accessible on real iOS 26+ devices via the Dev screen.
class DevMockVersionScreen extends StatelessWidget {
  const DevMockVersionScreen({super.key});

  static const _options = [
    _VersionOption(label: 'Real device (off)', version: null, subtitle: 'Use actual iOS version'),
    _VersionOption(label: 'iOS 26', version: 26, subtitle: 'On-device translation, full feature set'),
    _VersionOption(label: 'iOS 18', version: 18, subtitle: 'Cloud translation, no on-device packs'),
    _VersionOption(label: 'iOS 15', version: 15, subtitle: 'No translation support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock iOS Version')),
      body: ListenableBuilder(
        listenable: SettingsNotifier.instance,
        builder: (context, _) {
          final current = SettingsNotifier.instance.devMockIosMajorVersion;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Overrides the iOS version used for all feature checks in the app. '
                'The real device OS does not change — only how the app behaves.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (int i = 0; i < _options.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      RadioListTile<int?>(
                        value: _options[i].version,
                        groupValue: current,
                        title: Text(_options[i].label),
                        subtitle: Text(_options[i].subtitle),
                        onChanged: (v) {
                          SettingsNotifier.instance.setDevMockIosMajorVersion(v);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VersionOption {
  const _VersionOption({
    required this.label,
    required this.version,
    required this.subtitle,
  });

  final String label;
  final int? version;
  final String subtitle;
}
