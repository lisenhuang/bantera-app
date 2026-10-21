import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/ai_callback_notifier.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/dm_call_notifier.dart';
import '../../infrastructure/practice_audio_route.dart';
import '../../infrastructure/saved_practice_store.dart';
import '../../l10n/app_localizations.dart';

class SavedPracticeScreen extends StatefulWidget {
  const SavedPracticeScreen({super.key, required this.owner, this.store});

  final String owner;
  final SavedPracticeStore? store;

  @override
  State<SavedPracticeScreen> createState() => _SavedPracticeScreenState();
}

class _SavedPracticeScreenState extends State<SavedPracticeScreen>
    with WidgetsBindingObserver {
  final _player = AudioPlayer();
  StreamSubscription<void>? _completion;
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true, _failed = false;
  String? _playing, _removing;
  int _generation = 0;
  SavedPracticeStore get _store => widget.store ?? SavedPracticeStore.instance;
  AppLocalizations get l => AppLocalizations.of(context)!;
  bool get _sameOwner =>
      AuthSessionNotifier.instance.session?.cacheKey == widget.owner;
  bool get _callActive =>
      DmCallNotifier.instance.isActive ||
      AiCallbackNotifier.instance.aiActive ||
      AiCallbackNotifier.instance.ringing;
  bool get _canPlay =>
      mounted &&
      _sameOwner &&
      !_callActive &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
      ModalRoute.of(context)?.isCurrent == true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthSessionNotifier.instance.addListener(_sessionChanged);
    AiCallbackNotifier.instance.addListener(_callChanged);
    DmCallNotifier.instance.addListener(_callChanged);
    _completion = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = null);
    });
    unawaited(_load());
  }

  void _sessionChanged() {
    if (!_sameOwner) {
      unawaited(_stop());
      setState(() {
        _entries = [];
        _loading = false;
        _failed = false;
      });
    }
  }

  void _callChanged() {
    if (_callActive) {
      unawaited(_stop());
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_stop());
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

  Future<void> _stop() async {
    _generation++;
    if (mounted) setState(() => _playing = null);
    try {
      await _player.stop();
    } catch (_) {
      // A route can be disposed while a lifecycle or account change stops audio.
    }
  }

  Future<void> _play(String id, String url) async {
    if (!_canPlay) return;
    final wasPlaying = _playing == id;
    final generation = ++_generation;
    setState(() => _playing = null);
    try {
      await _player.stop();
      if (wasPlaying || !_canPlay || generation != _generation) return;
      await PracticeAudioRoute.prepare();
      if (!_canPlay || generation != _generation) return;
      setState(() => _playing = id);
      await _player.play(UrlSource(url));
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _playing = null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.practiceAudioError)));
      }
    }
  }

  Future<void> _remove(Map<String, dynamic> entry) async {
    if (!_sameOwner || _removing != null) return;
    setState(() => _removing = entry['id'] as String);
    try {
      await _stop();
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

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    AuthSessionNotifier.instance.removeListener(_sessionChanged);
    AiCallbackNotifier.instance.removeListener(_callChanged);
    DmCallNotifier.instance.removeListener(_callChanged);
    unawaited(_completion?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l.quickSaved)),
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
                Card(
                  key: ValueKey('saved-practice-${entry['id']}'),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: Text(entry['cue'] as String),
                    subtitle: Text('${entry['locale']} · ${entry['level']}'),
                    onExpansionChanged: (expanded) {
                      if (!expanded) unawaited(_stop());
                    },
                    children: [
                      _clip(
                        '${entry['id']}:cue',
                        l.quickCue1,
                        entry['cue'] as String,
                        entry['cueAudioUrl'] as String,
                      ),
                      for (final (index, choice)
                          in (entry['choices'] as List).indexed)
                        _clip(
                          '${entry['id']}:$index',
                          index == 0 ? l.quickCue2 : null,
                          choice['text'] as String,
                          choice['audioUrl'] as String,
                        ),
                      TextButton.icon(
                        onPressed: _removing == null
                            ? () => _remove(entry)
                            : null,
                        icon: const Icon(Icons.bookmark_remove_outlined),
                        label: Text(l.quickUnsave),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
            ],
          ),
  );

  Widget _clip(String id, String? label, String text, String url) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        Row(
          children: [
            IconButton(
              tooltip: _playing == id
                  ? l.practiceStop
                  : l.practiceListenCarefully,
              onPressed: url.isEmpty || _callActive
                  ? null
                  : () => _play(id, url),
              icon: Icon(
                _playing == id
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: SelectableText(text)),
          ],
        ),
      ],
    ),
  );
}
