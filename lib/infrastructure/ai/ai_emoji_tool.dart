import 'ai_history_store.dart';

/// Unicode delivery only: never download assets or interpret text as a command.
class AiEmojiTool {
  static const name = 'send_emojis';

  static bool valid(String value) {
    if (value.isEmpty || value.length > 64) return false;
    var hasEmoji = false;
    var keycap = false;
    for (final rune in value.runes) {
      final base =
          (rune >= 0x1F000 && rune <= 0x1FAFF) ||
          (rune >= 0x2600 && rune <= 0x27BF) ||
          (rune >= 0x2194 && rune <= 0x21FF) ||
          (rune >= 0x2300 && rune <= 0x23FF) ||
          (rune >= 0x2B00 && rune <= 0x2BFF) ||
          const {
            0xA9,
            0xAE,
            0x203C,
            0x2049,
            0x2122,
            0x2139,
            0x3030,
            0x303D,
            0x3297,
            0x3299,
          }.contains(rune);
      if (base) {
        hasEmoji = true;
      } else if (rune == 0x20E3) {
        hasEmoji = true;
        keycap = true;
      } else if (rune == 0x200D ||
          rune == 0xFE0E ||
          rune == 0xFE0F ||
          (rune >= 0xE0020 && rune <= 0xE007F)) {
        // Joiners, presentation selectors and subdivision flag tags.
      } else if (rune == 0x23 ||
          rune == 0x2A ||
          (rune >= 0x30 && rune <= 0x39)) {
        if (!value.runes.contains(0x20E3)) return false;
      } else {
        return false;
      }
    }
    return hasEmoji && (keycap || value.runes.any((r) => r > 0x39));
  }

  static Map<String, dynamic> deliver(dynamic args, AiMessage message) {
    final values = args is Map ? args['emojis'] : null;
    if (values is! List ||
        values.isEmpty ||
        values.length > 12 ||
        values.any((v) => v is! String || !valid(v))) {
      return {'delivered': false, 'unavailable': true};
    }
    final next = {...message.emojis, ...values.cast<String>()}.toList();
    if (next.length > 12) return {'delivered': false, 'unavailable': true};
    message.emojis
      ..clear()
      ..addAll(next);
    return {'delivered': true, 'emojis': values};
  }
}
