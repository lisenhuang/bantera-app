/// Transient display guidance, never stored as a learner message.
class AiResponseFormatting {
  static const context =
      '[Bantera chat display capability; background context, not a learner utterance.] '
      'Written replies support Markdown. Use short paragraphs, modest headings, '
      'bold key terms, and numbered or bulleted lists when they improve clarity. '
      'Use compact Markdown tables for useful comparisons, with short cells and '
      'preferably two or three columns. Use blockquotes for examples and fenced '
      'code only for actual code, never wrap the entire answer in a code fence. '
      'Keep simple answers simple and match the learner language and level. '
      'When display_formatted_text is available, send the written Markdown through '
      'that tool, especially when the learner requests formatting. It is separate '
      'from your spoken transcript. Actually display the useful answer, not just '
      'a promise to use Markdown. '
      'For spoken replies and audio transcripts, prioritize natural speech: never '
      'read Markdown punctuation, table pipes or formatting instructions aloud. '
      'If only an audio transcript is available, use natural numbered points '
      'instead of trying to dictate a table. Do not answer this display note; '
      'wait for the actual learner message.';

  static List<Map<String, String>> withContext(
    List<Map<String, String>> history,
  ) => [
    ...history,
    {'role': 'user', 'text': context},
  ];
}
