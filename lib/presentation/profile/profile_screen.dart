import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/profile_stats_notifier.dart';
import '../../core/theme.dart';
import '../../core/user_profile_notifier.dart';
import '../shared/locale_flag.dart';
import '../shared/profile_avatar.dart';
import 'edit_profile_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(ProfileStatsNotifier.instance.refresh());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        UserProfileNotifier.instance,
        ProfileStatsNotifier.instance,
      ]),
      builder: (context, _) {
        final profile = UserProfileNotifier.instance;
        final stats = ProfileStatsNotifier.instance;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                ProfileAvatar(
                  radius: 48,
                  imageUrl: profile.avatarUrl,
                  imagePath: profile.avatarImagePath,
                ),
                const SizedBox(height: 16),
                Text(
                  profile.displayName,
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(context, 'Practiced', '12 hrs'),
                    _buildStatColumn(
                      context,
                      'Uploads',
                      stats.uploadCount != null ? '${stats.uploadCount}' : '–',
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedScreen(),
                        ),
                      ),
                      child: _buildStatColumn(
                        context,
                        'Saved',
                        stats.savedCount != null ? '${stats.savedCount}' : '–',
                        tappable: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(color: BanteraTheme.backgroundLight, height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(
                          Icons.language,
                          color: BanteraTheme.primaryColor,
                        ),
                        title: const Text('My Native Language'),
                        trailing: _LanguageChip(
                          identifier: profile.nativeLanguage,
                          bold: false,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.school,
                          color: BanteraTheme.primaryColor,
                        ),
                        title: const Text('Learning'),
                        trailing: _LanguageChip(
                          identifier: profile.learningLanguage,
                          bold: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value, {
    bool tappable = false,
  }) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            if (tappable) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.identifier, required this.bold});

  final String? identifier;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    if (identifier == null || identifier!.trim().isEmpty) {
      return Text(
        'Not set',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
      );
    }

    final flag = flagEmojiForLocale(identifier!);
    return Text(
      '$flag  $identifier',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
