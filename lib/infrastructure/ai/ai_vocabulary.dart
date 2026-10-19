import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/user_profile_notifier.dart';

class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.word,
    required this.meaning,
    required this.language,
    required this.learnedAt,
    required this.updatedAt,
    required this.timeZone,
    this.example = '',
    this.reviewedAt,
    this.reviews = 0,
  });
  final String id, word, meaning, language, timeZone, example;
  final DateTime learnedAt, updatedAt;
  final DateTime? reviewedAt;
  final int reviews;
  DateTime get dueAt => (reviewedAt ?? learnedAt).add(
    Duration(days: const [1, 3, 7, 14, 30][reviews.clamp(0, 4)]),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'meaning': meaning,
    'language': language,
    'example': example,
    'learnedAt': learnedAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'timeZone': timeZone,
    'reviewedAt': reviewedAt?.toUtc().toIso8601String(),
    'reviews': reviews,
    'dueAt': dueAt.toUtc().toIso8601String(),
  };
  factory VocabularyWord.fromJson(Map<String, dynamic> j) => VocabularyWord(
    id: j['id'] as String,
    word: j['word'] as String,
    meaning: j['meaning'] as String,
    language: j['language'] as String,
    example: j['example'] as String? ?? '',
    learnedAt: DateTime.parse(j['learnedAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
    timeZone: j['timeZone'] as String,
    reviewedAt: DateTime.tryParse(j['reviewedAt'] ?? ''),
    reviews: j['reviews'] as int? ?? 0,
  );
}

/// Independent of chat history, account isolated and excluded from device backup
/// by the same native storage root as AI audio. Only requested tool results leave
/// the device. Serial read-modify-write prevents UI and simultaneous calls racing.
class AiVocabulary {
  AiVocabulary(
    this.owner, {
    Future<String> Function()? storagePath,
    bool Function()? isActive,
    DateTime Function()? now,
    Future<String> Function()? timeZone,
    String Function()? language,
    Random? random,
  }) : _random = random ?? Random.secure(),
       _storagePath =
           storagePath ??
           (() async => (await const MethodChannel(
             'bantera/ai_audio',
           ).invokeMethod<String>('storagePath'))!),
       _isActive =
           isActive ??
           (() => AuthSessionNotifier.instance.session?.cacheKey == owner),
       _now = now ?? DateTime.now,
       _timeZone =
           timeZone ??
           (() async => (await FlutterTimezone.getLocalTimezone()).identifier),
       _language =
           language ??
           (() => UserProfileNotifier.instance.learningLanguage ?? '');
  static const toolName = 'manage_vocabulary';
  static final changes = ValueNotifier<int>(0);
  static final Map<String, Future<void>> _queues = {};
  final String owner;
  final Random _random;
  final Future<String> Function() _storagePath, _timeZone;
  final bool Function() _isActive;
  final DateTime Function() _now;
  final String Function() _language;
  void _check() {
    if (!_isActive()) throw StateError('Account changed');
  }

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = (_queues[owner] ?? Future<void>.value()).then(
      (_) => action(),
    );
    final settled = result.then<void>((_) {}, onError: (Object _) {});
    _queues[owner] = settled;
    unawaited(
      settled.then((_) {
        if (identical(_queues[owner], settled)) _queues.remove(owner);
      }),
    );
    return result;
  }

  Future<File> _file() async {
    _check();
    final root = await _storagePath();
    _check();
    final key = base64Url.encode(utf8.encode(owner)).replaceAll('=', '');
    return File('$root/$key.vocabulary-v1.json');
  }

  Future<Map<String, dynamic>> _read(File file) async {
    if (!await file.exists()) return {'version': 1, 'items': <dynamic>[]};
    if (await file.length() > 20000000) {
      throw const FormatException('Vocabulary too large');
    }
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    if (data['version'] != 1 || data['items'] is! List) {
      throw const FormatException('Vocabulary format');
    }
    return data;
  }

  Future<void> _write(File file, Map<String, dynamic> data) async {
    _check();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(data), flush: true);
    _check();
    await temporary.rename(file.path);
    changes.value++;
  }

  Future<List<VocabularyWord>> words() => _serial(() async {
    final data = await _read(await _file());
    _check();
    return _words(data);
  });
  List<VocabularyWord> _words(Map<String, dynamic> data) =>
      (data['items'] as List)
          .map((j) => VocabularyWord.fromJson(Map<String, dynamic>.from(j)))
          .toList()
        ..sort((a, b) => b.learnedAt.compareTo(a.learnedAt));
  static String _text(Map args, String key, int max, {bool required = false}) {
    final value = args[key];
    if (value != null && value is! String) {
      throw const FormatException('Invalid field');
    }
    final text = (value as String? ?? '').trim();
    if ((required && text.isEmpty) || text.length > max) {
      throw const FormatException('Invalid field');
    }
    return text;
  }

  Future<Map<String, dynamic>> execute(
    Map<String, dynamic> args,
  ) => _serial(() async {
    final file = await _file();
    final data = await _read(file);
    _check();
    final items = _words(data);
    final now = _now().toUtc();
    final action = _text(args, 'action', 30, required: true);
    if (['stats', 'latest', 'quiz'].contains(action)) {
      final language = _text(args, 'language', 100).toLowerCase();
      final query = _text(args, 'query', 100).toLowerCase();
      final matches = items
          .where(
            (w) =>
                (language.isEmpty || w.language.toLowerCase() == language) &&
                (query.isEmpty ||
                    '${w.word} ${w.meaning}'.toLowerCase().contains(query)),
          )
          .toList();
      final base = <String, dynamic>{
        'ok': true,
        'storage': 'device only',
        'total': items.length,
        'matched': matches.length,
        'now': now.toIso8601String(),
      };
      if (action == 'stats') {
        final languages = <String, int>{};
        for (final word in matches) {
          languages.update(word.language, (n) => n + 1, ifAbsent: () => 1);
        }
        return {
          ...base,
          'unreviewed': matches.where((w) => w.reviews == 0).length,
          'due': matches.where((w) => !w.dueAt.isAfter(now)).length,
          'byLanguage': languages,
        };
      }
      if (action == 'latest') {
        return {...base, 'word': matches.firstOrNull?.toJson()};
      }
      final selection = _text(args, 'selection', 20);
      if (!['', 'recent', 'new', 'due', 'all'].contains(selection)) {
        throw const FormatException('Invalid selection');
      }
      final excluded = args['excludeIds'] ?? <String>[];
      if (excluded is! List ||
          excluded.length > 20 ||
          excluded.any((id) => id is! String || id.length > 100)) {
        throw const FormatException('Invalid exclusions');
      }
      // Choose on the device, across the requested pool, rather than asking
      // the model to pick from the first page of a potentially large notebook.
      final pool = switch (selection) {
        'new' => matches.where((w) => w.reviews == 0).toList(),
        'due' => matches.where((w) => !w.dueAt.isAfter(now)).toList(),
        'all' => matches,
        _ => matches.take(20).toList(),
      }..removeWhere((w) => excluded.contains(w.id));
      _check();
      return {
        ...base,
        'selection': selection.isEmpty ? 'recent' : selection,
        'eligible': pool.length,
        'word': pool.isEmpty
            ? null
            : pool[_random.nextInt(pool.length)].toJson(),
      };
    }
    if (action == 'list' || action == 'review_suggestions') {
      final query = _text(args, 'query', 100).toLowerCase();
      final language = _text(args, 'language', 100);
      final due = action == 'review_suggestions' || args['dueOnly'] == true;
      var matches = items
          .where(
            (w) =>
                (language.isEmpty ||
                    w.language.toLowerCase() == language.toLowerCase()) &&
                (query.isEmpty ||
                    '${w.word} ${w.meaning}'.toLowerCase().contains(query)) &&
                (!due || !w.dueAt.isAfter(now)),
          )
          .toList();
      if (due) matches.sort((a, b) => a.dueAt.compareTo(b.dueAt));
      if (action == 'review_suggestions') {
        final last = DateTime.tryParse(
          data['lastSuggestionAt'] as String? ?? '',
        );
        if (last != null && now.difference(last) < const Duration(hours: 24)) {
          matches = [];
        }
        if (matches.isNotEmpty) {
          data['lastSuggestionAt'] = now.toIso8601String();
          await _write(file, data);
        }
      }
      final offset = args['offset'] is num
          ? (args['offset'] as num).toInt().clamp(0, items.length)
          : 0;
      _check();
      return {
        'ok': true,
        'storage': 'device only',
        'total': items.length,
        'matched': matches.length,
        'offset': offset,
        'latest': items.isEmpty ? null : items.first.toJson(),
        'items': matches
            .skip(offset)
            .take(action == 'review_suggestions' ? 3 : 20)
            .map((w) => w.toJson())
            .toList(),
        if (action == 'review_suggestions') 'suggestReview': matches.isNotEmpty,
        'now': now.toIso8601String(),
      };
    }
    if (!['add', 'update', 'remove', 'review'].contains(action)) {
      return {'ok': false, 'error': 'unsupported_action'};
    }
    final id = _text(args, 'id', 100, required: action != 'add');
    final index = items.indexWhere((w) => w.id == id);
    if (action != 'add' && index < 0) {
      return {'ok': false, 'error': 'word_not_found'};
    }
    final old = index < 0 ? null : items[index];
    if (action == 'remove') {
      items.removeAt(index);
      data['items'] = items.map((w) => w.toJson()).toList();
      await _write(file, data);
      return {
        'ok': true,
        'action': action,
        'word': old!.toJson(),
        'total': items.length,
      };
    }
    final word = action == 'review'
        ? old!.word
        : args.containsKey('word') || action == 'add'
        ? _text(args, 'word', 100, required: true)
        : old!.word;
    final meaning = action == 'review'
        ? old!.meaning
        : args.containsKey('meaning') || action == 'add'
        ? _text(args, 'meaning', 600, required: true)
        : old!.meaning;
    final example = action == 'review'
        ? old!.example
        : args.containsKey('example')
        ? _text(args, 'example', 600)
        : old?.example ?? '';
    final language = action == 'review'
        ? old!.language
        : args.containsKey('language')
        ? _text(args, 'language', 100, required: true)
        : old?.language ?? _language();
    if (language.isEmpty) {
      return {'ok': false, 'error': 'learning_language_required'};
    }
    String normal(String s) =>
        s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final duplicate = items
        .where(
          (w) =>
              w.id != id &&
              normal(w.word) == normal(word) &&
              normal(w.language) == normal(language),
        )
        .firstOrNull;
    if (duplicate != null) {
      return {
        'ok': action == 'add',
        'alreadySaved': true,
        'word': duplicate.toJson(),
        'total': items.length,
      };
    }
    if (action == 'add' && items.length >= 10000) {
      return {'ok': false, 'error': 'vocabulary_full'};
    }
    final reviewed = action == 'review';
    final repeatedReview =
        reviewed &&
        old?.reviewedAt != null &&
        now.difference(old!.reviewedAt!) < const Duration(minutes: 1);
    String zone;
    try {
      zone = await _timeZone();
    } catch (_) {
      zone = _now().timeZoneName;
    }
    _check();
    final item = VocabularyWord(
      id: old?.id ?? const Uuid().v4(),
      word: word,
      meaning: meaning,
      example: example,
      language: language,
      learnedAt: old?.learnedAt ?? now,
      updatedAt: now,
      timeZone: old?.timeZone ?? zone,
      reviewedAt: reviewed ? now : old?.reviewedAt,
      reviews: (old?.reviews ?? 0) + (reviewed && !repeatedReview ? 1 : 0),
    );
    if (index < 0) {
      items.add(item);
    } else {
      items[index] = item;
    }
    data['items'] = items.map((w) => w.toJson()).toList();
    await _write(file, data);
    return {
      'ok': true,
      'action': action,
      'storage': 'device only',
      'word': item.toJson(),
      'total': items.length,
    };
  });
}
