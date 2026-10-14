import 'package:flutter/material.dart';
import '../../infrastructure/paid_key_preference_client.dart';
import '../../l10n/app_localizations.dart';

/// Only mounted for the current account. Permission and mode always come from the server.
class PaidKeySettings extends StatefulWidget {
  const PaidKeySettings({super.key, required this.owner, this.client});
  final String owner;
  final PaidKeyPreferenceClient? client;
  @override
  State<PaidKeySettings> createState() => _PaidKeySettingsState();
}

class _PaidKeySettingsState extends State<PaidKeySettings>
    with WidgetsBindingObserver {
  late final PaidKeyPreferenceClient _client =
      widget.client ?? PaidKeyPreferenceClient();
  PaidKeyPreference? _preference;
  int _revision = 0;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _client.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_saving) _load();
  }

  Future<void> _load() async {
    final revision = ++_revision;
    try {
      final value = await _client.load(widget.owner);
      if (mounted && revision == _revision) setState(() => _preference = value);
    } catch (_) {
      if (mounted && revision == _revision) setState(() => _preference = null);
    }
  }

  String _label(AppLocalizations l, PaidKeyMode mode) => switch (mode) {
    PaidKeyMode.regularOnly => l.aiKeysRegular,
    PaidKeyMode.fallback => l.aiKeysFallback,
    PaidKeyMode.paidOnly => l.aiKeysPaidOnly,
  };
  Future<void> _choose() async {
    final l = AppLocalizations.of(context)!;
    final selected = await showDialog<PaidKeyMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.aiKeysTitle),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text(l.aiKeysDescription),
          ),
          for (final mode in PaidKeyMode.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, mode),
              child: Row(
                children: [
                  Expanded(child: Text(_label(l, mode))),
                  if (_preference?.mode == mode)
                    const Icon(Icons.check, size: 20),
                ],
              ),
            ),
        ],
      ),
    );
    if (!mounted || selected == null || _preference?.canConfigure != true) {
      return;
    }
    ++_revision; // Ignore any permission refresh that started before this save.
    setState(() => _saving = true);
    try {
      final value = await _client.save(widget.owner, selected);
      if (mounted) setState(() => _preference = value);
    } on PaidKeyAccessRevoked {
      if (mounted) setState(() => _preference = null);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.onboardingFailedSave)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _preference;
    if (value == null || !value.canConfigure) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.auto_awesome_outlined),
        title: Text(l.aiKeysTitle),
        subtitle: Text(_label(l, value.mode)),
        trailing: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: _saving ? null : _choose,
      ),
    );
  }
}
