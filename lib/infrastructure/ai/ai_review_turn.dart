import 'ai_vocabulary.dart';

/// The model may inspect the notebook on any turn. Only an actual review
/// operation opts that turn into device-authored review output. Persisted review
/// progress is resumable data, not a global conversation lock.
class AiReviewTurn {
  AiReviewTurn(this.vocabulary, this.id);
  final AiVocabulary vocabulary;
  final String id;
  bool enabled = false;
  bool normalConversation = false;
  int? protocolVersion;
  bool _ordinaryOutputStarted = false;

  void configure(int? version) {
    protocolVersion = version;
    enabled = version == 3 || version == 4;
  }

  /// Once ordinary speech has escaped, a late tool cannot retroactively turn
  /// it into a validated quiz. The next turn can start the requested review.
  void outputStarted() {
    if (!holdOutput) _ordinaryOutputStarted = true;
  }

  bool _reviewRequested = false;
  String input = '';
  String? _text, _token;
  bool get holdOutput =>
      enabled &&
      !normalConversation &&
      (protocolVersion != 4 || _reviewRequested);
  static const unavailable =
      'Your vocabulary could not be loaded. Please try again.';
  static const notReady =
      'The vocabulary review could not continue. Please try again.';
  static const _notebookActions = {
    'stats',
    'latest',
    'list',
    'add',
    'update',
    'remove',
    'review_suggestions',
  };

  void addInput(String text) {
    input += text;
  }

  Future<Map<String, dynamic>> tool(Map<String, dynamic> args) async {
    final action = args['action'];
    if (!enabled) return vocabulary.execute(args);
    final statusOnly = action == 'review_status';
    final leaveReview = action == 'review_pause' || action == 'review_cancel';
    final ordinary = action == 'review_conversation';
    final reviewOperation =
        action is String &&
        !statusOnly &&
        !leaveReview &&
        !ordinary &&
        ((action.startsWith('review_') && action != 'review_suggestions') ||
            action == 'quiz' ||
            action == 'review');
    if (reviewOperation && protocolVersion == 4 && _ordinaryOutputStarted) {
      return {
        'ok': false,
        'error': 'review_requires_new_turn',
        'instruction':
            'Ordinary speech already started this turn. Do not start, advance or grade a review now. Ask the learner to continue in the next turn, then call the review tool before speaking. Do not retry this review action in this turn.',
      };
    }
    if (reviewOperation) {
      _reviewRequested = true;
      normalConversation = false;
    }
    try {
      if (_notebookActions.contains(action)) {
        await allowOrdinaryReply();
        return await vocabulary.execute(args);
      }
      if (ordinary && _reviewRequested) {
        // A late bookkeeping call must not release unvalidated review speech.
        return {
          'ok': false,
          'error': 'review_output_pending',
          'instruction':
              'Finish the current review delivery, or use an explicit pause/cancel request.',
        };
      }
      if (action == 'review_answer') {
        await vocabulary.reviewInput(id, input);
        args = {...args, 'action': 'review_status'};
      }
      if (action is! String || !action.startsWith('review_')) {
        if (action == 'quiz' || action == 'review') {
          return {'ok': false, 'error': 'use_review_session_v3'};
        }
        return await vocabulary.execute(args);
      }
      final result = await vocabulary.reviewTool(
        args,
        turnId: id,
        input: input,
      );
      // Merely looking at progress must never change the output mode, discard a
      // valid current delivery, or reuse a previous turn's pending delivery.
      if (statusOnly) return result;
      if (result['normalConversation'] == true) {
        _reviewRequested = false;
        normalConversation = true;
        _text = null;
        _token = null;
      } else if (reviewOperation && result['ok'] == true) {
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
      // Notebook/status failures are tool failures, not failed quiz deliveries.
      // Keep any already-established review output and its validation token.
      if (reviewOperation) {
        normalConversation = false;
        _text = unavailable;
        _token = null;
      }
      return {'ok': false, 'state': 'storage_error', 'message': unavailable};
    }
  }

  /// With no explicit review operation this is ordinary conversation, even if
  /// the model looked at review status or a previous review was left unfinished.
  Future<void> allowOrdinaryReply() async {
    if (!enabled || normalConversation || _reviewRequested) return;
    // Failure to read/pause a notebook must not block an unrelated reply.
    normalConversation = true;
    _text = null;
    _token = null;
    try {
      await vocabulary.reviewTool(
        {'action': 'review_conversation'},
        turnId: id,
        input: input,
      );
    } catch (_) {
      // A later explicit review still reports and guards its storage failure.
    }
  }

  /// Search and presentation tools are ordinary actions. They cannot override
  /// a review operation this turn already attempted; explicit pause/cancel can.
  Future<void> authorizeOrdinaryTool(String name) async {
    if ({
      'search_web',
      'display_formatted_text',
      'send_emojis',
    }.contains(name)) {
      await allowOrdinaryReply();
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
    _ordinaryOutputStarted = false;
    normalConversation = false;
    _reviewRequested = false;
    _text = null;
    _token = null;
  }
}
