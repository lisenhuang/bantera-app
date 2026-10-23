import 'ai_history_store.dart';

/// Display content only. Markdown never executes code or fetches attachments.
class AiFormattedTextTool {
  static const name = 'display_formatted_text';

  static Map<String, dynamic> deliver(dynamic args, AiMessage message) {
    final markdown = readFormattedText(args is Map ? args['markdown'] : null);
    if (message.role != 'model' || markdown == null) {
      return {'delivered': false, 'unavailable': true};
    }
    if (message.formattedText != markdown) {
      message.formattedText = markdown;
      // A cached translation of the transcript is not a translation of this text.
      message.translation = '';
      message.translationLanguage = '';
    }
    return {'delivered': true};
  }
}
