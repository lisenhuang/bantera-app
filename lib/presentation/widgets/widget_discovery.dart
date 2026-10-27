import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/widget_discovery_service.dart';
import '../../l10n/app_localizations.dart';

Future<void> showWidgetGuide(
  BuildContext context,
  WidgetDiscoveryService service,
) async {
  await Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => const WidgetGuideScreen()));
  await service.refresh();
}

class WidgetSuggestion extends StatefulWidget {
  const WidgetSuggestion({super.key, this.settings = false, this.service});
  final bool settings;
  final WidgetDiscoveryService? service;

  @override
  State<WidgetSuggestion> createState() => _WidgetSuggestionState();
}

class _WidgetSuggestionState extends State<WidgetSuggestion> {
  WidgetDiscoveryService get service =>
      widget.service ?? WidgetDiscoveryService.instance;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(service.initialize().then((_) => service.refresh()));
  }

  Future<void> _dismiss() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.widgetHideTitle),
        content: Text(l.widgetHideBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.widgetDontShowAgain),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await service.dismissGoal();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.widgetSaveFailed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: service,
    builder: (context, _) {
      if (!(widget.settings ? service.showSettings : service.showGoal)) {
        return const SizedBox.shrink();
      }
      final l = AppLocalizations.of(context)!;
      final theme = Theme.of(context);
      if (widget.settings) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(
                Icons.widgets_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(l.widgetAdd),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showWidgetGuide(context, service),
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              theme.colorScheme.primary.withValues(alpha: .07),
              theme.colorScheme.surface,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: .2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.widgets_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                l.widgetSuggestionTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.widgetSuggestionBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () => showWidgetGuide(context, service),
                    child: Text(l.widgetHowTo),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                    onPressed: _saving ? null : _dismiss,
                    child: Text(l.widgetNotNow),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class WidgetGuideScreen extends StatefulWidget {
  const WidgetGuideScreen({super.key});
  @override
  State<WidgetGuideScreen> createState() => _WidgetGuideScreenState();
}

class _WidgetGuideScreenState extends State<WidgetGuideScreen> {
  String _size = 'medium';
  bool _isPad = false;
  Future<Uint8List?>? _preview;
  String? _signature;

  @override
  void initState() {
    super.initState();
    unawaited(() async {
      try {
        final pad = await WidgetDiscoveryService.channel.invokeMethod<bool>(
          'isPad',
        );
        if (mounted) setState(() => _isPad = pad == true);
      } catch (_) {}
    }());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPreview();
  }

  void _loadPreview({bool force = false}) {
    final l = AppLocalizations.of(context)!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final signature = '${l.localeName}:$dark:$_size';
    if (!force && signature == _signature) return;
    _signature = signature;
    _preview = WidgetDiscoveryService.channel
        .invokeMethod<Uint8List>('preview', {
          'size': _size,
          'dark': dark,
          'locale': l.localeName,
          'labels': {
            'today': l.wordActivityToday,
            'spoken': l.wordActivitySpeaking,
            'listened': l.wordActivityListening,
            'words': l.wordActivityWords,
            'chat': 'Bantera AI',
            'level': l.audioLevelSection,
            'language': l.editProfileLearningLanguage,
            'position': l.leaderboardYourPosition,
            'period': l.leaderboardScope,
          },
        })
        .timeout(const Duration(seconds: 8))
        .catchError((Object _) => null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sizes = {
      'small': l.widgetSmall,
      'medium': l.widgetMedium,
      'large': l.widgetLarge,
      if (_isPad) 'extraLarge': l.widgetExtraLarge,
    };
    final steps = [
      l.widgetStepHold,
      l.widgetStepEdit,
      l.widgetStepSearch,
      l.widgetStepAdd,
    ];
    final icons = [
      Icons.touch_app_outlined,
      Icons.add_box_outlined,
      Icons.search,
      Icons.check_circle_outline,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.widgetAdd)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.widgetSuggestionTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l.widgetSuggestionBody),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: .3,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final entry in sizes.entries)
                              ChoiceChip(
                                label: Text(entry.value),
                                selected: _size == entry.key,
                                onSelected: (_) => setState(() {
                                  _size = entry.key;
                                  _loadPreview();
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<Uint8List?>(
                          future: _preview,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const SizedBox(
                                height: 170,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.data == null) {
                              return TextButton.icon(
                                onPressed: () =>
                                    setState(() => _loadPreview(force: true)),
                                icon: const Icon(Icons.refresh),
                                label: Text(l.widgetPreviewRetry),
                              );
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.memory(
                                snapshot.data!,
                                width: _size == 'small'
                                    ? 170
                                    : _size == 'large'
                                    ? 300
                                    : 520,
                                semanticLabel: l.widgetPreviewDescription,
                                gaplessPlayback: false,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.widgetPreviewDescription,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (var i = 0; i < steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExcludeSemantics(
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                icons[i],
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              '${i + 1}. ${steps[i]}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(l.widgetLocalNote, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
