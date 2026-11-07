import 'ai_vocabulary.dart';

/// Output authorization is negotiated with a V3 server. Ordinary conversation
/// streams after review_conversation. Review output is buffered and replaced by
/// device-authored questions/status/feedback; unmatched speech is never played.
class AiReviewTurn {
  AiReviewTurn(this.vocabulary, this.id);
  final AiVocabulary vocabulary;
  final String id;
  bool enabled = false;
  bool normalConversation = false;
  bool _reviewRequested = false;
  String input = '';
  String? _text, _token;
  bool get holdOutput => enabled && !normalConversation;
  static const unavailable =
      'Your vocabulary could not be loaded. Please try again.';
  static const notReady =
      'The vocabulary review could not continue. Please try again.';

  void addInput(String text) {
    input += text;
  }

  Future<Map<String, dynamic>> tool(Map<String, dynamic> args) async {
    final action = args['action'];
    if (!enabled) return vocabulary.execute(args);
    if (action is String &&
        ((action.startsWith('review_') &&
                ![
                  'review_conversation',
                  'review_pause',
                  'review_cancel',
                  'review_suggestions',
                ].contains(action)) ||
            action == 'quiz' ||
            action == 'review'))
      _reviewRequested = true;
    try {
      if (action == 'review_answer') {
        await vocabulary.reviewInput(id, input);
        args = {...args, 'action': 'review_status'};
      }
      if (action is! String ||
          !action.startsWith('review_') ||
          action == 'review_suggestions') {
        if (action == 'quiz' || action == 'review') {
          return {'ok': false, 'error': 'use_review_session_v3'};
        }
        // Reads/writes never authorize a quiz. Explicit ordinary mode is required.
        return await vocabulary.execute(args);
      }
      final result = await vocabulary.reviewTool(
        args,
        turnId: id,
        input: input,
      );
      normalConversation = result['normalConversation'] == true;
      if (!normalConversation) {
        _text = result['message'] as String?;
        _token = null;
        final delivery = result['delivery'];
        if (delivery is Map && delivery['turn'] == id) {
          _text = delivery['text'] as String?;
          _token = delivery['token'] as String?;
        }
      }
      return result;
    } catch (_) {
      normalConversation = false;
      _text = unavailable;
      _token = null;
      return {'ok': false, 'state': 'storage_error', 'message': unavailable};
    }
  }

  /// Missing model bookkeeping must not turn ordinary chat into a failed quiz.
  /// An actual review tool attempt or an active persisted review remains guarded.
  Future<void> allowOrdinaryReply() async {
    if (!enabled || normalConversation || _reviewRequested) return;
    await tool({'action': 'review_conversation'});
  }

  /// Search is an ordinary conversation action. Pause (never consume or cancel)
  /// an existing review before allowing device-side search and its response.
  Future<void> authorizeOrdinaryTool(String name) async {
    if (!enabled || name != 'search_web' || normalConversation) return;
    final result = await tool({'action': 'review_conversation'});
    if (result['error'] == 'review_session_active') {
      await tool({'action': 'review_pause', 'explicitChange': true});
    }
    if (normalConversation) {
      _text = null;
      _token = null;
    }
  }

  Future<String> finalText() async {
    if (_token != null) {
      try {
        if (!await vocabulary.reviewDeliveryValid(id, _token!)) return notReady;
      } catch (_) {
        return unavailable;
      }
    }
    return _text ?? notReady;
  }

  bool matchesSpeech(String transcript, String expected) {
    String normalize(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
        .trim();
    return normalize(transcript) == normalize(expected);
  }

  Future<String?> delivered() async {
    if (_token == null || !await vocabulary.reviewDelivered(id, _token!)) {
      return null;
    }
    final state = await vocabulary.reviewState();
    if (state?['state'] == 'completed') {
      return state?['scope'] == 'due'
          ? 'Your due review is finished for this session.'
          : 'Your vocabulary review is finished for this session.';
    }
    return null;
  }

  void resetOutput() {
    normalConversation = false;
    _reviewRequested = false;
    _text = null;
    _token = null;
  }
}
