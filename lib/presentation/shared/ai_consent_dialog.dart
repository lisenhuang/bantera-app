import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ai_consent.dart';
import '../../l10n/app_localizations.dart';
import '../chats/ai/ai_reminders_screen.dart';

Future<bool> showAiConsentDialog(BuildContext context) async {
  if (WidgetsBinding.instance.lifecycleState != null &&
      WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
    return false;
  }
  final l = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.aiConsentTitle),
          constraints: const BoxConstraints(maxWidth: 560),
          scrollable: true,
          content: const AiConsentDetails(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.aiConsentDecline),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.aiConsentAgree),
            ),
          ],
        ),
      ) ==
      true;
}

class AiConsentDetails extends StatelessWidget {
  const AiConsentDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.aiConsentIntro),
        const SizedBox(height: 16),
        Text('Google', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(l.aiConsentGoogle),
        const SizedBox(height: 16),
        Text('Cloudflare', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(l.aiConsentCloudflare),
        const SizedBox(height: 16),
        Text(l.aiConsentSearch),
        const SizedBox(height: 16),
        Text(l.aiConsentChoice),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse('https://bantera.app/privacy#ai-services'),
            mode: LaunchMode.externalApplication,
          ),
          child: Text(l.aiConsentPolicy),
        ),
      ],
    );
  }
}

class AiConsentSettingsScreen extends StatefulWidget {
  const AiConsentSettingsScreen({super.key});

  @override
  State<AiConsentSettingsScreen> createState() =>
      _AiConsentSettingsScreenState();
}

class _AiConsentSettingsScreenState extends State<AiConsentSettingsScreen> {
  bool? _allowed;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final consent = AiConsent.instance;
    final owner = consent.currentOwner();
    final allowed = owner != null && await consent.isAllowed(owner);
    if (mounted) setState(() => _allowed = allowed);
  }

  Future<void> _change() async {
    setState(() => _busy = true);
    try {
      if (_allowed == true) {
        await AiConsent.instance.revoke();
      } else {
        await AiConsent.instance.request();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.aiConsentSaveFailed),
          ),
        );
      }
    } finally {
      await _load();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.aiConsentSettings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const AiConsentDetails(),
            const SizedBox(height: 16),
            Text(_allowed == true ? l.aiConsentEnabled : l.aiConsentDisabled),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy || _allowed == null ? null : _change,
              child: Text(
                _allowed == true ? l.aiConsentRevoke : l.aiConsentAgree,
              ),
            ),
            const SizedBox(height: 12),
            Text(l.aiConsentExistingRequests),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AiRemindersScreen(),
                ),
              ),
              child: Text(l.aiRemindersTitle),
            ),
          ],
        ),
      ),
    );
  }
}
