/// Suppress only the internal marker emitted by the old history transport.
/// Keep the raw streaming buffer elsewhere so split markers cannot leak.
String publicAiTranscript(String raw) {
  const marker = '[Historical message timing (data, not current activity):';
  var text = raw;
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
