import '../../shared/swipe_action_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/auth_session_notifier.dart';
import '../../../infrastructure/ai/ai_api_client.dart';
import '../../../l10n/app_localizations.dart';

class AiRemindersScreen extends StatefulWidget {
  const AiRemindersScreen({super.key, this.api, this.owner});
  final AiApiClient? api;
  final String? owner;
  @override
  State<AiRemindersScreen> createState() => _AiRemindersScreenState();
}

class _AiRemindersScreenState extends State<AiRemindersScreen> {
  late final _api = widget.api ?? AiApiClient();
  late final _owner =
      widget.owner ?? AuthSessionNotifier.instance.session!.cacheKey;
  List<Map>? _items;
  bool _failed = false;
  bool _clearing = false;
  int _revision = 0;
  String? _revealed;
  final _cancelling = <String>{};
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _load() async {
    if (_clearing || _cancelling.isNotEmpty) return;
    try {
      final revision = _revision;
      final items =
          await _api.reminderRequest(_owner, 'GET', '/history') as List;
      if (mounted && revision == _revision) {
        setState(() {
          _items = items.cast<Map>();
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _cancel(Map item) async {
    if (_clearing || _cancelling.isNotEmpty) return;
    final l = AppLocalizations.of(context)!;
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteLabel),
        content: Text(item['reminder'] as String? ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.closeLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.deleteLabel),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final id = item['id'] as String;
    _revision++;
    setState(() => _cancelling.add(id));
    try {
      await _api.reminderRequest(_owner, 'DELETE', '/history/$id');
      if (mounted) {
        setState(() {
          _items?.removeWhere((row) => row['id'] == id);
          _revealed = null;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.onboardingLoadFailed)));
      }
    } finally {
      if (mounted) setState(() => _cancelling.remove(id));
    }
  }

  Future<void> _clearAll() async {
    if (_clearing || _cancelling.isNotEmpty) return;
    final l = AppLocalizations.of(context)!;
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.clearAllLabel),
        content: Text(l.aiRemindersClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.clearAllLabel),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    _revision++;
    setState(() => _clearing = true);
    try {
      final result =
          await _api.reminderRequest(_owner, 'DELETE', '/history') as Map;
      final remaining = (result['remaining'] as List).cast<Map>();
      if (!mounted) return;
      setState(() {
        _items = remaining;
        _revealed = null;
      });
      if (remaining.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.aiRemindersRetained)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.onboardingLoadFailed)));
      }
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  String _status(Map item, AppLocalizations l) => switch (item['status']) {
    'scheduled' || 'queued' => l.aiReminderPending,
    'generating' || 'ringing' => l.aiReminderPreparing,
    'ready' => l.aiReminderReady,
    'delivered' || 'answered' => l.aiReminderDelivered,
    'cancelled' => l.aiReminderCancelled,
    _ => l.aiReminderFailed,
  };
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [...?_items]
      ..sort((a, b) {
        bool active(Map i) => [
          'scheduled',
          'queued',
          'generating',
          'ready',
          'ringing',
        ].contains(i['status']);
        if (active(a) != active(b)) return active(a) ? -1 : 1;
        return active(a)
            ? (a['dueAt'] as String).compareTo(b['dueAt'] as String)
            : (b['dueAt'] as String).compareTo(a['dueAt'] as String);
      });
    return Scaffold(
      appBar: AppBar(
        title: Text(l.aiRemindersTitle),
        actions: [
          IconButton(
            tooltip: l.clearAllLabel,
            onPressed:
                _items?.isNotEmpty == true && !_clearing && _cancelling.isEmpty
                ? _clearAll
                : null,
            icon: _clearing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: _failed && _items == null
            ? Center(
                child: TextButton(
                  onPressed: _load,
                  child: Text(l.onboardingRetry),
                ),
              )
            : _items == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        l.aiReminderScheduleHelp,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    if (_failed)
                      TextButton(
                        onPressed: _load,
                        child: Text(l.onboardingRetry),
                      ),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 64),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l.aiReminderEmpty,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    for (final item in items) _card(item, l, theme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _card(Map item, AppLocalizations l, ThemeData theme) {
    final call = item['delivery'] == 'call';
    final date = DateTime.parse(item['dueAt'] as String).toLocal();
    final locale = Localizations.localeOf(context).toString();
    return SwipeActionCard(
      key: ValueKey(item['id']),
      revealed: _revealed == item['id'],
      onReveal: (value) =>
          setState(() => _revealed = value ? item['id'] as String : null),
      onRemove: _clearing || _cancelling.isNotEmpty
          ? null
          : () => _cancel(item),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  call ? Icons.phone_outlined : Icons.voice_chat_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    call ? l.aiReminderCall : l.aiReminderMessage,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Text(
                  _status(item, l),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item['reminder'] as String? ?? 'Bantera AI',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat.yMMMd(locale).format(date)} · ${TimeOfDay.fromDateTime(date).format(context)}',
              style: theme.textTheme.bodyMedium,
            ),
            if (_cancelling.contains(item['id']))
              const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
