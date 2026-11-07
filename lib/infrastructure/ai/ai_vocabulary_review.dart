part of 'ai_vocabulary.dart';

/// V3 review state shares the notebook's atomic file and per-account queue.
/// Tool selection is not delivery. Delivery is acknowledged only by the app.
extension AiVocabularyReview on AiVocabulary {
  Future<Map<String, dynamic>?> reviewState() => _serial(() async {
    final data = await _read(await _file());
    _check();
    return data['reviewSession'] == null
        ? null
        : Map<String, dynamic>.from(data['reviewSession'] as Map);
  });

  Future<Map<String, dynamic>> reviewTool(
    Map<String, dynamic> args, {
    required String turnId,
    required String input,
  }) => _serial(() async {
    final file = await _file();
    final data = await _read(file);
    _check();
    final words = _words(data);
    final byId = {for (final w in words) w.id: w};
    var session = data['reviewSession'] == null
        ? null
        : Map<String, dynamic>.from(data['reviewSession'] as Map);
    final action = AiVocabulary._text(args, 'action', 40, required: true);
    final now = _now().toUtc();
    Map<String, dynamic> error(String code) => {
      'ok': false,
      'error': code,
      'reviewVersion': 3,
      'instruction':
          'Do not invent a question or claim completion. Read review_status.',
    };
    if (action == 'review_conversation') {
      if (session != null &&
          session['state'] != 'cancelled' &&
          session['paused'] != true) {
        return error('review_session_active');
      }
      return {'ok': true, 'reviewVersion': 3, 'normalConversation': true};
    }
    var created = false;
    if (action == 'review_start') {
      if (session == null ||
          session['state'] == 'cancelled' ||
          (args['explicitChange'] == true &&
              args['sessionId'] == session['id'])) {
        final scope = AiVocabulary._text(args, 'scope', 20, required: true);
        final style = AiVocabulary._text(args, 'style', 30, required: true);
        if (!['due', 'all', 'recent', 'new'].contains(scope) ||
            !['guess_expression', 'explain_meaning'].contains(style)) {
          return error('invalid_review_options');
        }
        final language = AiVocabulary._text(
          args,
          'language',
          100,
        ).toLowerCase();
        var pool = words
            .where(
              (w) => language.isEmpty || w.language.toLowerCase() == language,
            )
            .toList();
        pool = switch (scope) {
          'due' => pool.where((w) => !w.dueAt.isAfter(now)).toList(),
          'new' => pool.where((w) => w.reviews == 0).toList(),
          'recent' => pool.take(20).toList(),
          _ => pool,
        };
        created = true;
        session = {
          'version': 1,
          'id': const Uuid().v4(),
          'scope': scope,
          'language': language,
          'style': style,
          'cutoff': now.toIso8601String(),
          'pool': pool.map((w) => w.id).toList(),
          'completed': <String>[],
          'skipped': <String>[],
          'removed': <String>[],
          'state': 'active',
        };
      }
      // A repeated start without explicitChange resumes the saved scope/style.
    }
    if (session == null) return error('review_session_required');
    if (!created &&
        args['sessionId'] != null &&
        args['sessionId'] != session['id']) {
      return error('stale_review_session');
    }
    final s = session;
    final pool = List<String>.from(s['pool'] as List);
    final completed = List<String>.from(s['completed'] as List);
    final skipped = List<String>.from(s['skipped'] as List);
    final removed = List<String>.from(s['removed'] as List);
    final language = s['language'] as String;
    for (final id in pool) {
      if ((!byId.containsKey(id) ||
              (language.isNotEmpty &&
                  byId[id]!.language.toLowerCase() != language)) &&
          !removed.contains(id)) {
        removed.add(id);
      }
    }
    s['removed'] = removed;
    var current = s['current'] as Map?;
    if (current != null) {
      final word = byId[current['id']];
      if (word == null ||
          removed.contains(current['id']) ||
          current['revision'] != _reviewRevision(word)) {
        // A changed clue/answer must be delivered again before it can be graded.
        s.remove('current');
        s.remove('pending');
        current = null;
      }
    }
    if (action == 'review_pause') {
      if (args['explicitChange'] != true) {
        return error('explicit_pause_required');
      }
      s['paused'] = true;
      s.remove('pending');
      data['reviewSession'] = s;
      await _write(file, data);
      return {
        'ok': true,
        'reviewVersion': 3,
        'normalConversation': true,
        'state': 'paused',
      };
    }
    s['paused'] = false;
    if (action == 'review_cancel') {
      s['state'] = 'cancelled';
      s.remove('current');
      s.remove('pending');
      data['reviewSession'] = s;
      await _write(file, data);
      return {
        'ok': true,
        'reviewVersion': 3,
        'normalConversation': true,
        'state': 'cancelled',
      };
    }
    if (s['state'] == 'cancelled') return error('review_session_cancelled');
    if (action == 'review_skip' || action == 'review_repeat') {
      final id = AiVocabulary._text(args, 'id', 100, required: true);
      if (!pool.contains(id) || removed.contains(id) || !byId.containsKey(id)) {
        return error('word_not_in_session');
      }
      if (action == 'review_skip') {
        if (current?['id'] != id) return error('not_current_item');
        if (!skipped.contains(id)) skipped.add(id);
        s['skipped'] = skipped;
        s.remove('current');
        s.remove('pending');
        current = null;
      } else {
        if (args['explicitChange'] != true) {
          return error('explicit_repeat_required');
        }
        skipped.remove(id);
        completed.remove(id);
        s['skipped'] = skipped;
        s['completed'] = completed;
        s['current'] = current = _reviewCurrent(byId[id]!, turnId);
      }
    }
    if (action == 'review_feedback') {
      if (current == null ||
          args['id'] != current['id'] ||
          args['questionId'] != current['questionId']) {
        return error('not_current_item');
      }
      if (current['phase'] != 'attempted' ||
          (current['answer'] as String? ?? '').trim().isEmpty) {
        return error('answer_required');
      }
      current['answerTurn'] = turnId;
      final verdict = AiVocabulary._text(args, 'verdict', 20, required: true);
      if (!['accepted', 'corrective'].contains(verdict)) {
        return error('invalid_verdict');
      }
      final w = byId[current['id']]!;
      final feedback =
          '${verdict == 'accepted' ? 'That works.' : 'Let’s review it.'} ${w.word}: ${w.meaning}';
      s['pending'] = {
        'token': const Uuid().v4(),
        'turn': turnId,
        'kind': 'feedback',
        'questionId': current['questionId'],
        'id': current['id'],
        'text': feedback,
      };
    } else if ([
      'review_start',
      'review_next',
      'review_repeat',
    ].contains(action)) {
      // Unanswered and interrupted questions are re-delivered, never consumed.
      if (current == null) {
        final remaining = pool
            .where(
              (id) =>
                  !completed.contains(id) &&
                  !skipped.contains(id) &&
                  !removed.contains(id),
            )
            .toList();
        if (remaining.isNotEmpty) {
          final chosen = byId[remaining[_random.nextInt(remaining.length)]]!;
          s['current'] = current = _reviewCurrent(chosen, turnId);
        }
      }
      if (current != null) {
        if (current['phase'] == 'attempted') {
          return await _reviewSaveResult(file, data, s, words);
        }
        final word = byId[current['id']]!;
        // Both expressions and phrases are indivisible saved entries.
        final question = s['style'] == 'guess_expression'
            ? 'Which saved word or phrase means: ${_reviewClue(word)}?'
            : 'What does “${word.word}” mean?';
        s['pending'] = {
          'token': const Uuid().v4(),
          'turn': turnId,
          'kind': 'question',
          'questionId': current['questionId'],
          'id': word.id,
          'text': question,
        };
      }
    } else if (!['review_status', 'review_skip'].contains(action)) {
      return error('unsupported_review_action');
    }
    return _reviewSaveResult(file, data, s, words);
  });

  Map<String, dynamic> _reviewCurrent(VocabularyWord word, String turn) => {
    'id': word.id,
    'questionId': const Uuid().v4(),
    'revision': _reviewRevision(word),
    'phase': 'selected',
    'selectedTurn': turn,
  };

  String _reviewClue(VocabularyWord word) => word.meaning.replaceAll(
    RegExp(
      '(?<![\\p{L}\\p{N}])${RegExp.escape(word.word)}(?![\\p{L}\\p{N}])',
      unicode: true,
      caseSensitive: false,
    ),
    '…',
  );

  String _reviewRevision(VocabularyWord w) =>
      jsonEncode([w.word, w.meaning, w.example, w.language]);

  Future<Map<String, dynamic>> _reviewSaveResult(
    File file,
    Map<String, dynamic> data,
    Map<String, dynamic> s,
    List<VocabularyWord> words,
  ) async {
    final completed = List<String>.from(s['completed']);
    final skipped = List<String>.from(s['skipped']);
    final removed = List<String>.from(s['removed']);
    final remaining = (s['pool'] as List)
        .where(
          (id) =>
              !completed.contains(id) &&
              !skipped.contains(id) &&
              !removed.contains(id),
        )
        .length;
    String? message;
    if (words.isEmpty) {
      s['state'] = 'empty_notebook';
      message = 'Your vocabulary list is empty.';
    } else if ((s['pool'] as List).isEmpty) {
      s['state'] = s['scope'] == 'due' ? 'none_due' : 'no_matches';
      message = s['scope'] == 'due'
          ? 'You have no words due for review right now.'
          : 'No saved vocabulary matches this selection.';
    } else if (remaining == 0 && skipped.isEmpty && removed.isEmpty) {
      s['state'] = 'completed';
      message = s['scope'] == 'due'
          ? 'Your due review is finished for this session.'
          : 'Your vocabulary review is finished for this session.';
    } else if (remaining == 0) {
      s['state'] = 'unfinished';
      message =
          'This session has ${skipped.length} skipped and ${removed.length} removed entries. Not every entry was reviewed.';
    } else {
      s['state'] = 'active';
    }
    data['reviewSession'] = s;
    await _write(file, data);
    final current = s['current'] as Map?;
    final attempted = current?['phase'] == 'attempted';
    final word = words.where((w) => w.id == current?['id']).firstOrNull;
    return {
      'ok': true, 'reviewVersion': 3, 'sessionId': s['id'], 'state': s['state'],
      'scope': s['scope'], 'style': s['style'], 'language': s['language'],
      'dueCutoff': s['cutoff'],
      'remaining': remaining,
      'completed': completed.length,
      'skipped': skipped.length, 'removed': removed.length,
      'currentId': current?['id'],
      'questionId': current?['questionId'],
      'phase': current?['phase'],
      // Expected answers are withheld until an actual subsequent input turn.
      if (attempted && word != null) 'answerReference': word.toJson(),
      if (attempted) 'learnerAnswer': current?['answer'],
      if (s['pending'] != null) 'delivery': s['pending'],
      'message': ?message,
      'instruction':
          'Use only this session. Read the delivery text verbatim, with no extra quiz or answer. '
          'If phase is attempted, give fair feedback using answerReference; accept equivalent meanings. '
          'Do not claim completion unless state is completed. New due entries after dueCutoff belong to a new explicitly requested session.',
    };
  }

  /// Called by transport for real input, never offered as a model tool.
  Future<void> reviewInput(String turn, String text) => _serial(() async {
    if (text.trim().isEmpty) return;
    final file = await _file();
    final data = await _read(file);
    _check();
    final s = data['reviewSession'] as Map?;
    final current = s?['current'] as Map?;
    if (current == null ||
        !['delivered', 'attempted'].contains(current['phase']) ||
        current['deliveredTurn'] == turn) {
      return;
    }
    if (current['answerTurn'] != turn) s!.remove('pending');
    current['phase'] = 'attempted';
    current['answerTurn'] = turn;
    current['answer'] = text.substring(0, text.length.clamp(0, 8000));
    await _write(file, data);
  });

  Future<bool> reviewDeliveryValid(String turn, String token) => _serial(
    () async {
      final data = await _read(await _file());
      _check();
      final s = data['reviewSession'] as Map?;
      final p = s?['pending'] as Map?, c = s?['current'] as Map?;
      if (p == null || c == null || p['turn'] != turn || p['token'] != token) {
        return false;
      }
      final word = _words(data).where((w) => w.id == c['id']).firstOrNull;
      return word != null && _reviewRevision(word) == c['revision'];
    },
  );

  /// Compare-and-commit protects retries, deleted/edited items and racing turns.
  Future<bool> reviewDelivered(String turn, String token) => _serial(() async {
    final file = await _file();
    final data = await _read(file);
    _check();
    final s = data['reviewSession'] as Map?;
    final pending = s?['pending'] as Map?;
    final current = s?['current'] as Map?;
    if (s == null ||
        pending == null ||
        current == null ||
        pending['turn'] != turn ||
        pending['token'] != token ||
        pending['questionId'] != current['questionId']) {
      return false;
    }
    final words = _words(data);
    final index = words.indexWhere((w) => w.id == current['id']);
    if (index < 0 || _reviewRevision(words[index]) != current['revision']) {
      return false;
    }
    if (pending['kind'] == 'question') {
      current['phase'] = 'delivered';
      current['deliveredTurn'] = turn;
    } else {
      if (current['phase'] != 'attempted' || current['answerTurn'] != turn) {
        return false;
      }
      final w = words[index], now = _now().toUtc();
      final repeated =
          w.reviewedAt != null &&
          now.difference(w.reviewedAt!) < const Duration(minutes: 1);
      words[index] = VocabularyWord(
        id: w.id,
        word: w.word,
        meaning: w.meaning,
        language: w.language,
        learnedAt: w.learnedAt,
        updatedAt: now,
        timeZone: w.timeZone,
        example: w.example,
        reviewedAt: now,
        reviews: w.reviews + (repeated ? 0 : 1),
      );
      data['items'] = words.map((w) => w.toJson()).toList();
      final completed = List<String>.from(s['completed']);
      if (!completed.contains(w.id)) completed.add(w.id);
      s['completed'] = completed;
      s.remove('current');
    }
    s.remove('pending');
    await _reviewSaveResult(file, data, Map<String, dynamic>.from(s), words);
    return true;
  });
}
