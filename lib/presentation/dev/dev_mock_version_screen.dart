import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/settings_notifier.dart';

/// Dev-only screen to mock the iOS major version for feature-gate testing.
class DevMockVersionScreen extends StatelessWidget {
  const DevMockVersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final realVersionLabel =
        Platform.isIOS ? Platform.operatingSystemVersion : '';

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
                'Overrides the iOS version used for feature checks and native '
                'routing. The real device OS does not change — only how the app behaves.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    RadioListTile<int?>(
                      value: null,
                      groupValue: current,
                      title: const Text('Real device'),
                      subtitle: Text(
                        realVersionLabel.isEmpty
                            ? 'Use actual iOS version'
                            : 'Current: $realVersionLabel',
                      ),
                      onChanged: (v) {
                        SettingsNotifier.instance.setDevMockIosMajorVersion(v);
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    RadioListTile<int?>(
                      value: 18,
                      groupValue: current,
                      title: const Text('iOS 18.0'),
                      subtitle: const Text(
                        'No SpeechTranscriber and Live Translation',
                      ),
                      onChanged: (v) {
                        SettingsNotifier.instance.setDevMockIosMajorVersion(v);
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    RadioListTile<int?>(
                      value: 17,
                      groupValue: current,
                      title: const Text('iOS 17.0'),
                      subtitle: const Text('No Translation framework'),
                      onChanged: (v) {
                        SettingsNotifier.instance.setDevMockIosMajorVersion(v);
                      },
                    ),
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
