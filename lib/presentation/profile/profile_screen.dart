import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/user_profile_notifier.dart';
import '../../infrastructure/mock_data.dart';
import '../shared/profile_avatar.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;

    return ListenableBuilder(
      listenable: UserProfileNotifier.instance,
      builder: (context, _) {
        final profile = UserProfileNotifier.instance;

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
                const SizedBox(height: 4),
                Text(
                  user.bio,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
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
                    _buildStatColumn(context, 'Uploads', '3'),
                    _buildStatColumn(context, 'Saved', '14'),
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
                        title: const Text('First Language'),
                        trailing: Text(
                          user.firstLanguage,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.school,
                          color: BanteraTheme.primaryColor,
                        ),
                        title: const Text('Learning'),
                        subtitle: Text('Current Level: ${user.level}'),
                        trailing: Text(
                          user.learningLanguage,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      SwitchListTile(
                        activeColor: BanteraTheme.primaryColor,
                        secondary: const Icon(Icons.handshake),
                        title: const Text('Open to Language Exchange'),
                        subtitle: const Text(
                          'Allow matching with complementary learners',
                        ),
                        value: user.openToExchange,
                        onChanged: (val) {},
                      ),
                    ],
                  ),
                ),
                Container(color: BanteraTheme.backgroundLight, height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Notes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          title: const Text('New vocabs from Coffee dialog'),
                          subtitle: const Text('Flat white, takeaway...'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
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

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
