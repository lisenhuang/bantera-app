import 'package:flutter/material.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/profile_stats_notifier.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../../infrastructure/practice_progress_store.dart';
import '../../infrastructure/user_profile_cache_store.dart';

/// Secondary settings page for account actions (e.g. delete account).
class AccountMoreScreen extends StatefulWidget {
  const AccountMoreScreen({super.key});

  @override
  State<AccountMoreScreen> createState() => _AccountMoreScreenState();
}

class _AccountMoreScreenState extends State<AccountMoreScreen> {
  bool _isDeletingAccount = false;

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
        title: const Text('More'),
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
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
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
}

/// First step: explain deletion and require typing `DELETE` before Continue.
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
