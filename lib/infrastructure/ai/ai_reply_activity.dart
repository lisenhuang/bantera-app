/// Observable work only: waiting is not proof of the model's internal reasoning.
enum AiReplyPhase {
  sending,
  waiting,
  vocabulary,
  web,
  images,
  videos,
  replying,
}

class AiReplyActivity {
  AiReplyPhase base = AiReplyPhase.sending;
  final _tools = <Object, AiReplyPhase>{};
  AiReplyPhase get phase => _tools.isEmpty ? base : _tools.values.last;

  Object? beginTool(Map<String, dynamic> call) {
    AiReplyPhase? phase;
    final args = call['args'];
    if (call['name'] == 'search_web') {
      final query = args is Map
          ? (args['query'] as String? ?? '').trim().toLowerCase()
          : '';
      phase = query.startsWith('images:')
          ? AiReplyPhase.images
          : query.startsWith('videos:')
          ? AiReplyPhase.videos
          : AiReplyPhase.web;
    } else if (call['name'] == 'manage_vocabulary' &&
        args is Map &&
        ![
          'review_conversation',
          'review_pause',
          'review_cancel',
        ].contains(args['action'])) {
      phase = AiReplyPhase.vocabulary;
    }
    if (phase == null) return null;
    final token = Object();
    _tools[token] = phase;
    return token;
  }

  void endTool(Object? token) => _tools.remove(token);
}
