import 'package:flutter/material.dart';

import '../../infrastructure/app_storage_service.dart';
import '../../l10n/app_localizations.dart';

String storageSize(int bytes) {
  if (bytes == 0) return '0 MB';
  if (bytes < 100000) return '< 0.1 MB';
  if (bytes < 1000000000) return '${(bytes / 1000000).toStringAsFixed(1)} MB';
  return '${(bytes / 1000000000).toStringAsFixed(2)} GB';
}

class StorageCacheScreen extends StatefulWidget {
  const StorageCacheScreen({super.key, this.service});
  final AppStorageService? service;
  @override
  State<StorageCacheScreen> createState() => _StorageCacheScreenState();
}

class _StorageCacheScreenState extends State<StorageCacheScreen> {
  AppStorageService? _service;
  StorageUsage? _usage;
  bool _busy = true, _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool clear = false}) async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      _service ??= widget.service ?? await AppStorageService.open();
      final usage = clear
          ? await _service!.clearSafeCache()
          : await _service!.scan();
      if (mounted) {
        setState(() {
          _usage = usage;
          _failed = usage.partial;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.storageClear),
        content: Text(l.storageClearExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.storageClear),
          ),
        ],
      ),
    );
    if (mounted && confirmed == true) await _load(clear: true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context), colors = theme.colorScheme;
    final usage = _usage;
    final labels = [
      l.storageImages,
      l.storageSnapshots,
      l.storageTemporaryAudio,
      l.storageAiChats,
      l.storageDm,
      l.storagePractice,
      l.storageOther,
    ];
    const icons = [
      Icons.image_outlined,
      Icons.cached_rounded,
      Icons.graphic_eq,
      Icons.auto_awesome_outlined,
      Icons.chat_bubble_outline,
      Icons.bookmark_outline,
      Icons.folder_outlined,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l.storageTitle),
        actions: [
          IconButton(
            tooltip: MaterialLocalizations.of(
              context,
            ).refreshIndicatorSemanticLabel,
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _busy && usage == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_busy) const LinearProgressIndicator(),
                if (_failed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l.storageError,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                if (usage != null) ...[
                  Card(
                    color: colors.primaryContainer,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l.storageMeasured,
                            style: TextStyle(color: colors.onPrimaryContainer),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            storageSize(usage.total),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${l.storageClearable}: ${storageSize(usage.safeToClear)}',
                            style: TextStyle(color: colors.onPrimaryContainer),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _busy || usage.safeToClear == 0
                                ? null
                                : _clear,
                            icon: const Icon(Icons.cleaning_services_outlined),
                            label: Text(l.storageClear),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final category in StorageCategory.values) ...[
                          if (category.index != 0) const Divider(height: 1),
                          ListTile(
                            leading: Icon(
                              icons[category.index],
                              color: colors.primary,
                            ),
                            title: Text(labels[category.index]),
                            subtitle: Text(
                              (usage.clearable[category] ?? 0) > 0
                                  ? '${l.storageClearable}: ${storageSize(usage.clearable[category]!)}'
                                  : switch (category) {
                                      StorageCategory.aiChats =>
                                        l.storageManageAi(l.aiClearHistory),
                                      StorageCategory.directMessages =>
                                        l.storageManageDm(l.chatDeleteDm),
                                      StorageCategory.practice =>
                                        l.storageManagePractice,
                                      _ => l.storageKeep,
                                    },
                            ),
                            trailing: Text(
                              storageSize(usage.bytes[category] ?? 0),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(l.storageScope, style: theme.textTheme.bodySmall),
                const SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.privacy_tip_outlined, color: colors.primary),
                        const SizedBox(height: 12),
                        Text(l.storagePrivacy),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
