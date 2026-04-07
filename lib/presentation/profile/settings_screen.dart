import 'package:flutter/material.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/settings_notifier.dart';
import '../auth/api_base_url_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _titleTapCount = 0;

  void _handleTitleTap() async {
    _titleTapCount++;
    if (_titleTapCount < 16) return;
    _titleTapCount = 0;

    final auth = AuthSessionNotifier.instance;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const ApiBaseUrlScreen()),
    );

    if (changed == true && mounted) {
      auth.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleTitleTap,
          behavior: HitTestBehavior.opaque,
          child: const Text('Settings'),
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          SettingsNotifier.instance,
          AuthSessionNotifier.instance,
        ]),
        builder: (context, _) {
          final settings = SettingsNotifier.instance;
          final auth = AuthSessionNotifier.instance;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, 'Appearance'),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('Light'),
                      value: ThemeMode.light,
                      groupValue: settings.themeMode,
                      onChanged: (val) => settings.setThemeMode(val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark'),
                      value: ThemeMode.dark,
                      groupValue: settings.themeMode,
                      onChanged: (val) => settings.setThemeMode(val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      value: ThemeMode.system,
                      groupValue: settings.themeMode,
                      onChanged: (val) => settings.setThemeMode(val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Notifications'),
              Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Allow Notifications'),
                  subtitle: const Text(
                    'Receive alerts for messages and practice reminders.',
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (val) => settings.toggleNotifications(val),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Account'),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: Text(auth.session?.accountLabel ?? 'Signed out'),
                      subtitle: Text(
                        auth.session == null
                            ? 'No active Bantera session'
                            : 'Signed in with ${auth.session!.providerLabel}',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: auth.session == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Privacy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: auth.session == null
                          ? null
                          : () {
                              auth.signOut();
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
