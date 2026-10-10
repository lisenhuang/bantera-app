/// Repair punctuation echoed from JSON context and suppress internal markers.
/// Keep the raw streaming buffer elsewhere so split markers cannot leak.
String publicAiTranscript(String raw) {
  const marker = '[Historical message timing (data, not current activity):';
  // Decode only known punctuation, never arbitrary JSON/control/path escapes.
  // Applying this to the accumulated buffer also handles split Live deltas.
  var text = raw.replaceAllMapped(
    RegExp(
      r'(`{3,}|~{3,})[\s\S]*?(?:\1|$)|(`+)[\s\S]*?\2|\\u(0027|0022|2018|2019|201c|201d)',
      caseSensitive: false,
    ),
    (match) => match[3] == null
        ? match[0]!
        : String.fromCharCode(int.parse(match[3]!, radix: 16)),
  );
  while (true) {
    final start = text.indexOf(marker);
    if (start < 0) break;
    final end = text.indexOf('}]', start + marker.length);
    if (end < 0) return text.substring(0, start).trimRight();
    text =
        '${text.substring(0, start).trimRight()} ${text.substring(end + 2).trimLeft()}';
  }
  // Do not briefly paint a partial marker while transcription is streaming.
  for (var length = marker.length - 1; length > 0; length--) {
    if (text.endsWith(marker.substring(0, length))) {
      return text.substring(0, text.length - length).trimRight();
    }
  }
  return text.trim();
}
