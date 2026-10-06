import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/api_config_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/practice_progress_store.dart';
import '../../l10n/app_localizations.dart';
import '../practice/practice_player_screen.dart';

class PracticeHistoryScreen extends StatefulWidget {
  const PracticeHistoryScreen({super.key, this.store});
  final PracticeProgressStore? store;

  @override
  State<PracticeHistoryScreen> createState() => _PracticeHistoryScreenState();
}

class _PracticeHistoryScreenState extends State<PracticeHistoryScreen> {
  late final PracticeProgressStore _store =
      widget.store ?? PracticeProgressStore.instance;
  bool _loading = true;
  bool _failed = false;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      await _store.load();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(PracticeHistoryEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final owner = _store.currentOwner;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeFromListTitle),
        content: Text(l10n.practiceHistoryRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.removeFromListLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || owner != _store.currentOwner) return;
    setState(() => _removing = true);
    try {
      await _store.remove(entry.mediaItem.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.onboardingLoadFailed)));
      }
    } finally {
      if (mounted) setState(() => _removing = false);
    }
  }

  Future<void> _resume(PracticeHistoryEntry entry) async {
    final owner = _store.currentOwner;
    final token = AuthSessionNotifier.instance.session?.accessToken;
    final mediaUrl = Uri.tryParse(entry.mediaItem.videoUrl ?? '');
    final apiUrl = Uri.parse(ApiConfigNotifier.instance.baseUrl);
    // Tokens are never persisted in history or sent to a different origin.
    final headers = <String, String>{
      if (token != null &&
          mediaUrl != null &&
          mediaUrl.scheme == apiUrl.scheme &&
          mediaUrl.host == apiUrl.host &&
          mediaUrl.port == apiUrl.port)
        'Authorization': 'Bearer $token',
    };
    final item = MediaItem.fromJson(
      entry.mediaItem.toJson(),
      mediaHeaders: headers,
    );
    final local = item.localVideoPath;
    if (local != null && local.isNotEmpty && !await File(local).exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.practiceHistoryUnavailable,
          ),
        ),
      );
      return;
    }
    if (!mounted || owner != _store.currentOwner) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticePlayerScreen(mediaItem: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.practiceHistoryTitle)),
      body: ListenableBuilder(
        listenable: Listenable.merge([_store, AuthSessionNotifier.instance]),
        builder: (context, _) {
          if (_loading) return const Center(child: CircularProgressIndicator());
          if (_failed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.onboardingLoadFailed),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _load,
                      child: Text(l10n.onboardingRetry),
                    ),
                  ],
                ),
              ),
            );
          }
          final entries = _store.entries;
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: .08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        size: 40,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.practiceHistoryEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.practiceHistoryDeviceNote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          final locale = Localizations.localeOf(context).toLanguageTag();
          final number = NumberFormat.decimalPattern(locale);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: entries.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.practiceHistoryDeviceNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
              final entry = entries[index - 1];
              final progress = l10n.practiceHistoryProgress(
                number.format(entry.completedCues),
                number.format(entry.totalCues),
              );
              final kind = entry.mediaItem.isAudioOnly
                  ? l10n.mediaKindAudio
                  : l10n.mediaKindVideo;
              return Material(
                color: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: .65),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child: entry.mediaItem.coverUrl.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: entry.mediaItem.coverUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) =>
                                          _placeholder(entry),
                                    )
                                  : _placeholder(entry),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.mediaItem.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$kind · ${DateFormat.yMMMd(locale).add_jm().format(entry.lastPracticedAt.toLocal())}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.removeFromListLabel,
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: _removing ? null : () => _remove(entry),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      LinearProgressIndicator(
                        value: entry.progress,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(6),
                        backgroundColor: colors.primary.withValues(alpha: .1),
                        semanticsLabel: progress,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        progress,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FilledButton.tonalIcon(
                          onPressed: () => _resume(entry),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: Text(l10n.continueLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _placeholder(PracticeHistoryEntry entry) => ColoredBox(
    color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
    child: Icon(
      entry.mediaItem.isAudioOnly
          ? Icons.headphones_rounded
          : Icons.play_circle_outline_rounded,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}
