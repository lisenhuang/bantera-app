// Simulator-only review entry point; not imported by the production app.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app/presentation/quick_practice/practice_pronunciation_text.dart';
import 'package:app/presentation/practice/subtitle_word_tokens.dart';
import 'pronunciation_preview_fixtures.dart';

void main() => runApp(const AlignmentPreview());

class AlignmentPreview extends StatefulWidget {
  const AlignmentPreview({super.key});
  @override
  State<AlignmentPreview> createState() => _AlignmentPreviewState();
}

class _AlignmentPreviewState extends State<AlignmentPreview> {
  bool dark = false, large = false;
  String script = 'Chinese';
  SubtitleWordToken? selected;
  final fixtures = (jsonDecode(pronunciationPreviewFixtures) as List)
      .cast<Map<String, dynamic>>();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff704ce6),
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
    ),
    home: Builder(
      builder: (context) {
        final examples = fixtures
            .where(
              (f) =>
                  f['valid'] == true &&
                  (switch (script) {
                    'Chinese' => [
                      'zh-CN',
                      'zh-TW',
                      'zh-HK',
                    ].contains(f['locale']),
                    'RTL' => ['ar-SA', 'he-IL'].contains(f['locale']),
                    _ => [
                      'ja-JP',
                      'ko-KR',
                      'th-TH',
                      'hi-IN',
                      'ru-RU',
                      'uk-UA',
                      'el-GR',
                    ].contains(f['locale']),
                  }),
            )
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pronunciation review'),
            actions: [
              IconButton(
                tooltip: 'Large text',
                icon: const Icon(Icons.text_increase),
                onPressed: () => setState(() => large = !large),
              ),
              IconButton(
                tooltip: 'Theme',
                icon: const Icon(Icons.contrast),
                onPressed: () => setState(() => dark = !dark),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Chinese', label: Text('Chinese')),
                    ButtonSegment(value: 'Other', label: Text('Other')),
                    ButtonSegment(value: 'RTL', label: Text('RTL')),
                  ],
                  selected: {script},
                  onSelectionChanged: (value) => setState(() {
                    script = value.first;
                    selected = null;
                  }),
                ),
              ),
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(large ? 2.3 : 1)),
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (final f in examples)
                            SizedBox(
                              width: constraints.maxWidth > 750
                                  ? (constraints.maxWidth - 60) / 2
                                  : constraints.maxWidth - 40,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        f['locale'],
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                      const SizedBox(height: 14),
                                      PracticePronunciationText(
                                        f['text'],
                                        locale: f['locale'],
                                        segments: f['segments'],
                                        style: const TextStyle(fontSize: 25),
                                        selectedWord: selected,
                                        textDirection: script == 'RTL'
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        onSelect: (word) =>
                                            setState(() => selected = word),
                                        onWord: (word) =>
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(word.text),
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
