import 'package:flutter/material.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/settings_notifier.dart';
import '../auth/api_base_url_screen.dart';
import 'account_more_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _titleTapCount = 0;

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to use your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    AuthSessionNotifier.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

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
        listenable: AuthSessionNotifier.instance,
        builder: (context, _) {
          final auth = AuthSessionNotifier.instance;

          return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader(context, 'Appearance'),
                  ListenableBuilder(
                    listenable: SettingsNotifier.instance,
                    builder: (context, _) {
                      final settings = SettingsNotifier.instance;
                      return Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.brightness_6_outlined,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Theme',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<ThemeMode>(
                                segments: const [
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.light,
                                    label: Text('Light'),
                                    icon: Icon(Icons.light_mode_outlined),
                                  ),
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.dark,
                                    label: Text('Dark'),
                                    icon: Icon(Icons.dark_mode_outlined),
                                  ),
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.system,
                                    label: Text('System'),
                                    icon: Icon(Icons.brightness_auto_outlined),
                                  ),
                                ],
                                selected: {settings.themeMode},
                                onSelectionChanged: (Set<ThemeMode> next) {
                                  if (next.isEmpty) {
                                    return;
                                  }
                                  SettingsNotifier.instance.setThemeMode(
                                    next.first,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                          leading: const Icon(Icons.more_horiz),
                          title: const Text('More'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: auth.session == null
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const AccountMoreScreen(),
                                    ),
                                  );
                                },
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
                              : _confirmSignOut,
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
