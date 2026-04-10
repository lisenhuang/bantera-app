import 'package:flutter/material.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/profile_stats_notifier.dart';
import '../../core/settings_notifier.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../../infrastructure/practice_progress_store.dart';
import '../../infrastructure/user_profile_cache_store.dart';
import '../auth/api_base_url_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _titleTapCount = 0;
  bool _isDeletingAccount = false;

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

  Future<void> _confirmDeleteAccount() async {
    final auth = AuthSessionNotifier.instance;
    if (auth.session == null || _isDeletingAccount) {
      return;
    }

    final explain = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _DeleteAccountAcknowledgeDialog(),
    );
    if (explain != true || !mounted) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: const Text(
          'Your account will be deleted immediately. You will need to create a new account to use Bantera again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) {
      return;
    }

    final session = auth.session;
    if (session == null) {
      return;
    }
    final cacheKey = session.cacheKey;

    setState(() => _isDeletingAccount = true);
    try {
      await AuthApiClient.instance.deleteAccount(
        accessToken: session.accessToken,
      );
      if (!mounted) {
        return;
      }
      await LocalPracticeRepository.instance.wipeAllDataForCurrentUser();
      await PracticeProgressStore.instance.clearAll();
      await UserProfileCacheStore.instance.removeAllForCacheKey(cacheKey);
      ProfileStatsNotifier.instance.reset();
      AuthSessionNotifier.instance.signOut();
      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete account. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
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
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: AuthSessionNotifier.instance,
            builder: (context, _) {
              final auth = AuthSessionNotifier.instance;
              final busy = _isDeletingAccount;

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
                                  if (busy || next.isEmpty) {
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
                          onTap: auth.session == null || busy
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
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: auth.session == null || busy
                              ? null
                              : _confirmSignOut,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.delete_forever_outlined,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            'Delete account',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          subtitle: const Text(
                            'Permanently remove your account and server data',
                          ),
                          onTap: auth.session == null || busy
                              ? null
                              : _confirmDeleteAccount,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          if (_isDeletingAccount)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
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

/// First step: explain deletion and require typing `Confirmed` before Continue.
class _DeleteAccountAcknowledgeDialog extends StatefulWidget {
  const _DeleteAccountAcknowledgeDialog();

  @override
  State<_DeleteAccountAcknowledgeDialog> createState() =>
      _DeleteAccountAcknowledgeDialogState();
}

class _DeleteAccountAcknowledgeDialogState
    extends State<_DeleteAccountAcknowledgeDialog> {
  static const _requiredPhrase = 'DELETE';

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _controller.text == _requiredPhrase;

    return AlertDialog(
      title: const Text('Delete account?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All of your personal information and any data you’ve generated will be '
              'permanently removed from our servers and can’t be recovered.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Type "DELETE" to continue',
                border: OutlineInputBorder(),
              ),
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: canContinue ? () => Navigator.pop(context, true) : null,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
