import 'package:app/presentation/chats/ai/ai_message_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Markdown links use in-app browsing and reject non-web schemes', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return true;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: AiMessageMarkdown(text: '[Source](https://example.com)'),
      ),
    );
    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    markdown.onTapLink!('Source', 'https://example.com', '');
    await tester.pump();
    expect(calls.single.method, 'launch');
    expect(calls.single.arguments['useSafariVC'], true);
    expect(calls.single.arguments['useWebView'], true);
    for (final link in [
      'javascript:alert(1)',
      'file:///private/data',
      'https://localhost/',
    ]) {
      markdown.onTapLink!('Unsafe', link, '');
    }
    await tester.pump();
    expect(calls.length, 1);
  });
  for (final brightness in Brightness.values) {
    testWidgets('Markdown formats narrow $brightness bubbles and long code', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 240,
                  child: AiMessageMarkdown(
                    text:
                        '# Soup\n\n**Broth** is *light*.\n\n- Listen\n- Speak\n\n> Try again\n\n```dart\n${'sample_' * 40}\n```\n\n[Source](https://example.com)\n\n![A sample image](file:///private/photo.jpg)',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final texts = tester
          .widgetList<SelectableText>(find.byType(SelectableText))
          .map((t) => t.data ?? t.textSpan!.toPlainText())
          .join('\n');
      expect(texts, contains('Broth is light.'));
      expect(texts, isNot(contains('**Broth**')));
      expect(texts, contains('Listen'));
      expect(find.byType(Image), findsNothing);
      expect(find.text('A sample image'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
        findsOneWidget,
      );
      // Incomplete stream syntax must remain renderable until the next delta.
      await tester.pumpWidget(
        const MaterialApp(home: AiMessageMarkdown(text: '**Broth is')),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(MarkdownBody), findsOneWidget);
    });
  }
}
