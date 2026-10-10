import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../infrastructure/ai/ai_history_store.dart';
import '../../../infrastructure/ai/ai_image_search.dart';
import '../../../infrastructure/ai/ai_web_search.dart';
import '../../../l10n/app_localizations.dart';

class AiImageCards extends StatelessWidget {
  const AiImageCards({super.key, required this.message, required this.path});
  final AiMessage message;
  final String Function(String) path;

  static Future<void> _source(String value) async {
    final uri = AiWebSource.safeUrl(value);
    if (uri == null) return;
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      );
    } catch (_) {}
  }

  Widget _picture(
    BuildContext context,
    AiImageAttachment image, {
    bool expanded = false,
  }) => Image.file(
    File(path(image.file!)),
    fit: BoxFit.contain,
    width: double.infinity,
    height: expanded ? null : 200,
    cacheWidth: 800,
    semanticLabel: image.title,
    errorBuilder: (_, error, stack) => SizedBox(
      height: 100,
      child: Center(
        child: Text(AppLocalizations.of(context)!.aiImagesUnavailable),
      ),
    ),
  );

  void _open(BuildContext context, AiImageAttachment image) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final l = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(l.aiImages),
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.ios_share),
                    tooltip: l.aiImageShare,
                    onPressed: () async {
                      final box = context.findRenderObject() as RenderBox?;
                      try {
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [
                              XFile(path(image.file!), mimeType: image.mime),
                            ],
                            text: [
                              image.title,
                              image.author,
                              image.license,
                              image.sourceUrl,
                            ].where((v) => v.isNotEmpty).join('\n'),
                            sharePositionOrigin: box == null
                                ? null
                                : box.localToGlobal(Offset.zero) & box.size,
                          ),
                        );
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.wordActivityShareFailed)),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Center(
                        child: _picture(context, image, expanded: true),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          image.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          [
                            image.author,
                            image.license.isEmpty
                                ? l.aiImagesRights
                                : image.license,
                          ].where((v) => v.isNotEmpty).join(' · '),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton.icon(
                          onPressed: () => _source(image.sourceUrl),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: Text(image.sourceName),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final searching = message.imageSearchStatus == 'searching';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searching || message.imageSearchStatus == 'unavailable')
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                if (searching)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.image_not_supported_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    searching ? l.aiImagesSearching : l.aiImagesUnavailable,
                  ),
                ),
              ],
            ),
          ),
        for (final image in message.images.where((i) => i.file != null))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _open(context, image),
                    child: _picture(context, image),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Text(
                      image.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Text(
                      [
                        image.author,
                        image.license.isEmpty
                            ? l.aiImagesRights
                            : image.license,
                      ].where((v) => v.isNotEmpty).join(' · '),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _source(image.sourceUrl),
                    child: Text(image.sourceName),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
