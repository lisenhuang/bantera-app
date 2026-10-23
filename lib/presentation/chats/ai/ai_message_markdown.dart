import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/ai/ai_web_search.dart';

/// Non-scrolling Markdown that grows with streamed text in the conversation.
class AiMessageMarkdown extends StatelessWidget {
  const AiMessageMarkdown({
    super.key,
    required this.text,
    this.selectable = true,
  });

  final String text;
  final bool selectable;

  Future<void> _openLink(String? href) async {
    final uri = AiWebSource.safeUrl(href ?? '');
    if (uri == null) return;
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      );
    } catch (_) {
      // Keep the selectable URL available if the browser cannot open it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final body = theme.textTheme.bodyLarge!.copyWith(
      color: colors.onSurface,
      height: 1.5,
    );
    return MarkdownBody(
      data: text,
      selectable: selectable,
      fitContent: false,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: body,
        blockSpacing: 12,
        tableHead: body.copyWith(fontWeight: FontWeight.w600),
        tableBody: body,
        tableColumnWidth: FixedColumnWidth(
          MediaQuery.textScalerOf(context).scale(160).clamp(160, 280),
        ),
        tableBorder: TableBorder.all(color: colors.outlineVariant),
        tableCellsPadding: const EdgeInsets.all(12),
        tableHeadCellsPadding: const EdgeInsets.all(12),
        tableHeadCellsDecoration: BoxDecoration(
          color: colors.surfaceContainerLow,
        ),
        tablePadding: const EdgeInsets.only(bottom: 8),
        tableScrollbarThumbVisibility: true,
        listBullet: body,
        blockquote: body,
        h1: body.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
        h2: body.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        h3: body.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        a: body.copyWith(
          color: colors.primary,
          decoration: TextDecoration.underline,
        ),
        code: body.copyWith(fontFamily: 'monospace', fontSize: 14),
        codeblockDecoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.primary, width: 3)),
        ),
      ),
      onTapLink: (_, href, _) => _openLink(href),
      // Images use the existing downloaded image cards. Never fetch arbitrary
      // network or local-file images just because the model wrote Markdown.
      imageBuilder: (_, _, alt) => Text(alt ?? '', style: body),
    );
  }
}
