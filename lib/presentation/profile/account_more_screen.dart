import 'package:flutter/material.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/profile_stats_notifier.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../../infrastructure/practice_progress_store.dart';
import '../../infrastructure/user_profile_cache_store.dart';
import '../../l10n/app_localizations.dart';

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

    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeletionTitle),
        content: Text(l10n.deleteAccountImmediateBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.deleteAccountConfirm),
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
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.couldNotDeleteAccount)),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountMoreTitle),
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
                        l10n.deleteAccount,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      subtitle: Text(l10n.deleteAccountSubtitle),
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
    final l10n = AppLocalizations.of(context)!;
    final canContinue = _controller.text == _requiredPhrase;

    return AlertDialog(
      title: Text(l10n.deleteAccountQuestionTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deleteAccountQuestionBody,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: l10n.typeDeleteLabel,
                border: const OutlineInputBorder(),
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
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: canContinue ? () => Navigator.pop(context, true) : null,
          child: Text(l10n.continueLabel),
        ),
      ],
    );
  }
}
