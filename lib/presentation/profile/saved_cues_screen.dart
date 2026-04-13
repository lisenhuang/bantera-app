import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/saved_cue_repository.dart';
import '../../l10n/app_localizations.dart';
import '../practice/practice_player_screen.dart';

class SavedCuesScreen extends StatefulWidget {
  const SavedCuesScreen({super.key});

  @override
  State<SavedCuesScreen> createState() => _SavedCuesScreenState();
}

class _SavedCuesScreenState extends State<SavedCuesScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(SavedCueRepository.instance.load());
    SavedCueRepository.instance.addListener(_onRepositoryChanged);
  }

  @override
  void dispose() {
    SavedCueRepository.instance.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _confirmDelete(BuildContext context, SavedCueRecord entry) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.savedCuesDeleteConfirmTitle),
        content: Text(l10n.savedCuesDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.savedCuesDeleteTooltip,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      unawaited(SavedCueRepository.instance.deleteSavedCue(entry));
    }
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.savedCuesDeleteAllConfirmTitle),
        content: Text(l10n.savedCuesDeleteAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.savedCuesDeleteAllTooltip,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      unawaited(SavedCueRepository.instance.deleteAll());
    }
  }

  Widget _coverPlaceholder(bool isAudioOnly) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          isAudioOnly ? Icons.audiotrack : Icons.videocam_outlined,
          size: 24,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = SavedCueRepository.instance.entries;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedCuesTitle),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.delete),
              tooltip: l10n.savedCuesDeleteAllTooltip,
              onPressed: () => _confirmDeleteAll(context),
            ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.savedCuesEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final coverUrl = entry.mediaItem.coverUrl.trim();
                final isAudioOnly = entry.mediaItem.isAudioOnly;
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PracticePlayerScreen(
                          mediaItem: entry.mediaItem,
                          initialCueIndex: entry.cueIndex,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: coverUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: coverUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        _coverPlaceholder(isAudioOnly),
                                  )
                                : _coverPlaceholder(isAudioOnly),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.mediaItem.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                entry.cueText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.delete, size: 18),
                          tooltip: l10n.savedCuesDeleteTooltip,
                          onPressed: () => _confirmDelete(context, entry),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
