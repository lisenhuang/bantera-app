import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/ai_callback_notifier.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/dm_call_notifier.dart';
import '../../infrastructure/saved_practice_store.dart';
import '../../l10n/app_localizations.dart';
import 'saved_practice_confirmation.dart';
import 'saved_practice_tile.dart';

class SavedPracticeScreen extends StatefulWidget {
  const SavedPracticeScreen({super.key, required this.owner, this.store});

  final String owner;
  final SavedPracticeStore? store;

  @override
  State<SavedPracticeScreen> createState() => _SavedPracticeScreenState();
}

class _SavedPracticeScreenState extends State<SavedPracticeScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true, _failed = false;
  String? _removing;
  SavedPracticeStore get _store => widget.store ?? SavedPracticeStore.instance;
  AppLocalizations get l => AppLocalizations.of(context)!;
  bool get _sameOwner =>
      AuthSessionNotifier.instance.session?.cacheKey == widget.owner;
  bool get _callActive =>
      DmCallNotifier.instance.isActive ||
      AiCallbackNotifier.instance.aiActive ||
      AiCallbackNotifier.instance.ringing;
  @override
  void initState() {
    super.initState();
    AuthSessionNotifier.instance.addListener(_sessionChanged);
    AiCallbackNotifier.instance.addListener(_callChanged);
    DmCallNotifier.instance.addListener(_callChanged);
    unawaited(_load());
  }

  void _sessionChanged() {
    if (!_sameOwner) {
      setState(() {
        _entries = [];
        _loading = false;
        _failed = false;
      });
    }
  }

  void _callChanged() {
    if (mounted) setState(() {});
  }

  void _open(Map<String, dynamic> entry) {
    if (!_sameOwner || _callActive || _removing != null) return;
    Navigator.of(context).pop(entry);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final entries = await _store.load(widget.owner);
      if (mounted && _sameOwner) setState(() => _entries = entries);
    } catch (_) {
      if (mounted && _sameOwner) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(Map<String, dynamic> entry) async {
    if (!_sameOwner || _removing != null) return;
    setState(() => _removing = entry['id'] as String);
    try {
      final confirmed = await confirmSavedPracticeRemoval(
        context,
        cue: entry['cue'] as String,
      );
      if (!confirmed || !mounted || !_sameOwner) return;
      await _store.setSaved(owner: widget.owner, exercise: entry, saved: false);
      if (mounted && _sameOwner) {
        setState(
          () => _entries.removeWhere((item) => item['id'] == entry['id']),
        );
      }
    } catch (_) {
      if (mounted && _sameOwner) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.quickSavedError)));
      }
    } finally {
      if (mounted) setState(() => _removing = null);
    }
  }

  Future<void> _clearAll() async {
    if (!_sameOwner || _removing != null || _entries.isEmpty) return;
    setState(() => _removing = 'all');
    try {
      final confirmed = await confirmSavedPracticeRemoval(context);
      if (!confirmed || !mounted || !_sameOwner) return;
      await _store.clear(widget.owner);
      if (mounted && _sameOwner) {
        setState(() {
          _entries = [];
        });
      }
    } catch (_) {
      if (mounted && _sameOwner) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.quickSavedError)));
      }
    } finally {
      if (mounted) setState(() => _removing = null);
    }
  }

  @override
  void dispose() {
    AuthSessionNotifier.instance.removeListener(_sessionChanged);
    AiCallbackNotifier.instance.removeListener(_callChanged);
    DmCallNotifier.instance.removeListener(_callChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(l.quickSaved),
      actions: [
        IconButton(
          key: const ValueKey('clear-all-saved-practice'),
          tooltip: l.quickClearSavedTitle,
          icon: const Icon(Icons.delete_outline),
          onPressed: _loading || _removing != null || _entries.isEmpty
              ? null
              : _clearAll,
        ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _failed
        ? Center(
            child: TextButton(onPressed: _load, child: Text(l.quickSavedError)),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l.quickSavedDeviceNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              if (_entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(l.quickSavedEmpty, textAlign: TextAlign.center),
                ),
              for (final entry in _entries)
                SavedPracticeTile(
                  key: ValueKey('saved-practice-${entry['id']}'),
                  cue: entry['cue'] as String,
                  subtitle: '${entry['locale']} · ${entry['level']}',
                  onOpen: _callActive || _removing != null
                      ? null
                      : () => _open(entry),
                  onRemove: _removing == null ? () => _remove(entry) : null,
                ),
            ],
          ),
  );
}
