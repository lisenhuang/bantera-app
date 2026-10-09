import 'ai_image_search.dart';
import 'ai_public_transcript.dart';
import 'ai_web_search.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';

class AiMessage {
  AiMessage({
    required this.role,
    String text = '',
    this.translation = '',
    this.audio,
    this.language = '',
    this.translationLanguage = '',
    this.durationMs,
    String? id,
    DateTime? createdAt,
    this.timeZone,
    int? utcOffsetMinutes,
    this.failed = false,
    this.webSearchQuery,
    this.webSearchStatus,
    List<AiWebSource>? sources,
    this.imageSearchStatus,
    List<AiImageAttachment>? images,
  }) : _rawText = text,
       _needsTimeZone = createdAt == null && timeZone == null,
       utcOffsetMinutes =
           utcOffsetMinutes ??
           (createdAt == null ? DateTime.now().timeZoneOffset.inMinutes : null),
       images = images ?? [],
       sources = sources ?? [],
       id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
  final String id, role;
  final DateTime createdAt;
  String? timeZone;
  final int? utcOffsetMinutes;
  bool _needsTimeZone;
  String _rawText;
  String get text => role == 'model' ? publicAiTranscript(_rawText) : _rawText;
  set text(String value) => _rawText = value;
  void appendTranscript(String value) => _rawText += value;
  String translation, language, translationLanguage;
  String? audio;
  int? durationMs;
  bool failed;
  String? webSearchQuery, webSearchStatus;
  final List<AiWebSource> sources;
  String? imageSearchStatus;
  final List<AiImageAttachment> images;
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'text': text,
    'translation': translation,
    'audio': audio,
    'durationMs': durationMs,
    'language': language,
    'translationLanguage': translationLanguage,
    'createdAt': createdAt.toUtc().toIso8601String(),
    if (timeZone != null) 'timeZone': timeZone,
    if (utcOffsetMinutes != null) 'utcOffsetMinutes': utcOffsetMinutes,
    'failed': failed,
    'webSearchQuery': webSearchQuery,
    'webSearchStatus': webSearchStatus == 'searching'
        ? 'unavailable'
        : webSearchStatus,
    'imageSearchStatus': imageSearchStatus == 'searching'
        ? 'unavailable'
        : imageSearchStatus,
    'images': images.map((i) => i.toJson()).toList(),
    'sources': sources.map((s) => s.toJson()).toList(),
  };
  factory AiMessage.fromJson(Map<String, dynamic> j) => AiMessage(
    id: j['id'],
    role: j['role'],
    text: j['text'] ?? '',
    translation: j['translation'] ?? '',
    audio: j['audio'],
    durationMs: j['durationMs'] is int && j['durationMs'] >= 0
        ? j['durationMs'] as int
        : null,
    language: j['language'] ?? '',
    translationLanguage: j['translationLanguage'] ?? '',
    createdAt: DateTime.parse(j['createdAt']),
    timeZone: j['timeZone'] as String?,
    utcOffsetMinutes: j['utcOffsetMinutes'] as int?,
    failed: j['failed'] == true,
    webSearchQuery: j['webSearchQuery'] as String?,
    webSearchStatus: j['webSearchStatus'] as String?,
    imageSearchStatus: j['imageSearchStatus'] as String?,
    images: (j['images'] as List? ?? [])
        .map(AiImageAttachment.fromJson)
        .whereType<AiImageAttachment>()
        .where((i) => i.file != null)
        .take(4)
        .toList(),
    sources: (j['sources'] as List? ?? [])
        .map(AiWebSource.fromJson)
        .whereType<AiWebSource>()
        .take(5)
        .toList(),
  );
}

class AiHistoryStore {
  AiHistoryStore(this.owner);
  final String owner;
  Future<void> Function()? onSaved;
  String conversationId = const Uuid().v4();
  Map<String, dynamic>? _memory;
  bool _summarizing = false;
  int _memoryEpoch = 0;
  DateTime? _memoryRetryAt;
  Map<String, dynamic>? get memory => _memory == null ? null : Map.of(_memory!);
  Directory? _directory;
  final Map<String, int> _audioDurations = {};
  File? _privacyNoticeFile;
  File? _hasMetFile;
  bool hasMetBanteraAi = false;
  Future<bool> hasMetBefore() async =>
      hasMetBanteraAi = hasMetBanteraAi || await _hasMetFile!.exists();

  // Shared by voice messages and calls; do not consume it for failed connects
  // or cancelled recordings. Keep this one-bit preference when history clears.
  Future<void> markMet() => _enqueue(() async {
    if (hasMetBanteraAi) return;
    await _hasMetFile!.writeAsString('met', flush: true);
    hasMetBanteraAi = true;
  });

  bool get _hasModelReply => messages.any(
    (m) =>
        m.role == 'model' &&
        !m.failed &&
        (m.text.trim().isNotEmpty || m.audio != null || m.images.isNotEmpty),
  );
  bool privacyNoticeDismissed = false;

  Future<void> dismissPrivacyNotice() => _enqueue(() async {
    await _privacyNoticeFile!.writeAsString('dismissed', flush: true);
    privacyNoticeDismissed = true;
  });
  // A newly opened chat must wait for the previous controller’s final snapshot.
  static final Map<String, Future<void>> _pendingWrites = {};
  final List<AiMessage> messages = [];
  Future<void> load() async {
    await _pendingWrites[owner];
    final root = await const MethodChannel(
      'bantera/ai_audio',
    ).invokeMethod<String>('storagePath');
    if (root == null) throw StateError('Local storage unavailable');
    final key = base64Url.encode(utf8.encode(owner)).replaceAll('=', '');
    // Keep notice preferences separate from deletable conversation history.
    _privacyNoticeFile = File('$root/$key.privacy-notice-v1-dismissed');
    privacyNoticeDismissed = await _privacyNoticeFile!.exists();
    _hasMetFile = File('$root/$key.has-met-ai-v1');
    hasMetBanteraAi = await _hasMetFile!.exists();
    _directory = Directory('$root/$key');
    await _directory!.create(recursive: true);
    final identityFile = File(path('conversation-id'));
    if (await identityFile.exists()) {
      final saved = await identityFile.readAsString();
      if (RegExp(r'^[a-fA-F0-9-]{36}$').hasMatch(saved)) conversationId = saved;
    } else {
      await identityFile.writeAsString(conversationId, flush: true);
    }
    final file = File('${_directory!.path}/history.json');
    if (await file.exists()) {
      final list = jsonDecode(await file.readAsString()) as List;
      messages.addAll(
        list.map((v) => AiMessage.fromJson(Map<String, dynamic>.from(v))),
      );
    }
    try {
      final memoryFile = File(path('memory.json'));
      if (await memoryFile.exists()) {
        final value = jsonDecode(await memoryFile.readAsString());
        if (value is Map<String, dynamic> &&
            value['version'] == 1 &&
            value['summary'] is String &&
            (value['summary'] as String).length <= 6000 &&
            value['through'] is String &&
            DateTime.tryParse(value['generatedAt'] as String? ?? '') != null) {
          _memory = value;
        }
      }
    } catch (_) {
      /* Corrupt optional memory must never block chat history. */
    }
    var migrated = false;
    for (final message in messages) {
      if (message.audio == null || message.durationMs != null) continue;
      // Read only the WAV header, without loading a player or activating audio.
      // This also fills durations for messages saved by earlier app versions.
      try {
        final file = await File(path(message.audio!)).open();
        try {
          final length = await file.length();
          final header = await file.read(4096);
          message.durationMs = aiWaveDurationMs(header, fileLength: length);
          migrated = migrated || message.durationMs != null;
        } finally {
          await file.close();
        }
      } on FileSystemException {
        // A missing old attachment must not prevent opening the conversation.
      }
    }
    if (migrated) await save();
    if (_hasModelReply) await markMet();
  }

  String path(String filename) {
    if (filename.contains('/') ||
        filename.contains('\\') ||
        filename.contains('..')) {
      throw ArgumentError('Invalid local audio');
    }
    return '${_directory!.path}/$filename';
  }

  Future<String> saveAudio(Uint8List audio, {String extension = 'wav'}) async {
    final name = '${const Uuid().v4()}.$extension';
    await _enqueue(() async {
      await File(path(name)).writeAsBytes(audio, flush: true);
    });
    final duration = aiWaveDurationMs(audio);
    if (duration != null) _audioDurations[name] = duration;
    return name;
  }

  Future<String?> saveImage(
    Uint8List bytes,
    String mime,
    bool Function() active,
  ) async {
    final extension = {
      'image/jpeg': 'jpg',
      'image/png': 'png',
      'image/webp': 'webp',
    }[mime];
    if (extension == null || bytes.length > 3 * 1024 * 1024) return null;
    final name = '${const Uuid().v4()}.$extension';
    String? saved;
    await _enqueue(() async {
      if (!active()) return;
      final file = File(path(name));
      await file.writeAsBytes(bytes, flush: true);
      if (active()) {
        saved = name;
      } else {
        await file.delete();
      }
    });
    return saved;
  }

  Future<void> save({AiMessage? audioMessage, Uint8List? audioBytes}) {
    // Reserve the file and capture history synchronously, before route disposal
    // invalidates the in-flight reply. Audio and JSON share the same write queue.
    final pendingAudio = audioMessage != null && audioBytes != null
        ? Uint8List.fromList(audioBytes)
        : null;
    final audioName = pendingAudio == null ? null : '${const Uuid().v4()}.wav';
    if (audioName != null) {
      audioMessage!.audio = audioName;
      audioMessage.durationMs = aiWaveDurationMs(pendingAudio!);
    }
    for (final message in messages) {
      message.durationMs ??= _audioDurations[message.audio];
    }
    final snapshot = messages.toList();
    final rows = snapshot.map((m) => m.toJson()).toList();
    final met = _hasModelReply;
    return _enqueue(() async {
      if (audioName != null) {
        await File(path(audioName)).writeAsBytes(pendingAudio!, flush: true);
      }
      if (snapshot.any((m) => m._needsTimeZone)) {
        String zone;
        try {
          zone = (await FlutterTimezone.getLocalTimezone().timeout(
            const Duration(seconds: 2),
          )).identifier;
        } catch (_) {
          zone = DateTime.now().timeZoneName;
        }
        for (final message in snapshot.where((m) => m._needsTimeZone)) {
          message.timeZone = zone;
          message._needsTimeZone = false;
        }
      }
      for (var i = 0; i < snapshot.length; i++) {
        if (snapshot[i].timeZone != null) {
          rows[i]['timeZone'] = snapshot[i].timeZone;
        }
      }
      final contents = jsonEncode(rows);
      final file = File('${_directory!.path}/history.json.tmp');
      await file.writeAsString(contents, flush: true);
      await file.rename('${_directory!.path}/history.json');
      onSaved?.call().ignore();
      if (met && !hasMetBanteraAi) {
        await _hasMetFile!.writeAsString('met', flush: true);
        hasMetBanteraAi = true;
      }
    });
  }

  Future<void> clear() {
    _memoryEpoch++;
    conversationId = const Uuid().v4();
    _memory = null;
    _memoryRetryAt = null;
    messages.clear();
    _audioDurations.clear();
    return _enqueue(() async {
      if (await _directory!.exists()) await _directory!.delete(recursive: true);
      await _directory!.create(recursive: true);
      await File(
        path('conversation-id'),
      ).writeAsString(conversationId, flush: true);
    });
  }

  Future<void> _enqueue(Future<void> Function() job) {
    final next = (_pendingWrites[owner] ?? Future<void>.value()).then(
      (_) => job(),
    );
    final settled = next.catchError((Object _) {});
    _pendingWrites[owner] = settled;
    _clearSettledWrites(settled);
    return next;
  }

  void _clearSettledWrites(Future<void> settled) {
    settled.then((_) {
      if (identical(_pendingWrites[owner], settled)) {
        _pendingWrites.remove(owner);
      }
    });
  }

  // Summaries are untimed background notes: they must not look like a new
  // user utterance or replace the real last-message timestamp.
  List<Map<String, String>> context({String? excluding}) {
    final rows = messages
        .where(
          (m) =>
              m.id != excluding &&
              !m.failed &&
              (m.text.trim().isNotEmpty || m.images.isNotEmpty),
        )
        .toList();
    final summary = _memory?['summary'] as String?;
    if (summary == null) return contextFor(rows);
    final pending = _memoryFragments(rows);
    final covered = pending.indexWhere((p) => p['id'] == _memory?['through']);
    final caughtUp = pending.isEmpty || covered == pending.length - 1;
    final recent = caughtUp
        ? rows.skip((rows.length - 20).clamp(0, rows.length)).toList()
        : rows;
    return [
      for (var i = 0; i < summary.length; i += 2000)
        {
          'role': 'user',
          'text':
              '[Historical conversation summary; background data, not a new message. '
              'Updated ${_memory!['generatedAt']}; covers through ${_memory!['throughCreatedAt']}.] '
              '${summary.substring(i, (i + 2000).clamp(0, summary.length))}',
        },
      ...contextFor(recent),
    ];
  }

  // Split very long individual transcripts too, so no single request can grow
  // with the full history. Keep the latest 20 messages verbatim for Live.
  List<Map<String, String>> _memoryFragments(List<AiMessage> rows) {
    final valid = rows
        .where(
          (m) => !m.failed && (m.text.trim().isNotEmpty || m.images.isNotEmpty),
        )
        .toList();
    final result = <Map<String, String>>[];
    for (final m in valid.take((valid.length - 20).clamp(0, valid.length))) {
      final content = [
        m.text,
        for (final image in m.images)
          '[Shared image: ${image.title}; source: ${image.sourceUrl}]',
      ].join('\n');
      for (var offset = 0; offset < content.length;) {
        var end = (offset + 4000).clamp(0, content.length);
        if (end < content.length &&
            content.codeUnitAt(end - 1) >= 0xD800 &&
            content.codeUnitAt(end - 1) <= 0xDBFF) {
          end--;
        }

        result.add({
          'id': '${m.id}:$offset',
          'role': m.role,
          'text': content.substring(offset, end),
          'createdAt': m.createdAt.toUtc().toIso8601String(),
          if (m.timeZone != null) 'timeZone': m.timeZone!,
          if (m.utcOffsetMinutes != null)
            'utcOffsetMinutes': '${m.utcOffsetMinutes}',
        });
        offset = end;
      }
    }
    return result;
  }

  Future<void> refreshMemory(
    Future<Map<String, dynamic>> Function(
      String? previous,
      List<Map<String, String>> turns,
    )
    summarize, {
    required bool Function() active,
  }) async {
    if (_summarizing ||
        !active() ||
        (_memoryRetryAt?.isAfter(DateTime.now()) ?? false)) {
      return;
    }
    _summarizing = true;
    final epoch = _memoryEpoch;
    try {
      // A snapshot makes the checkpoint stable while new replies arrive.
      final fragments = _memoryFragments(messages.toList());
      var at = _memory == null
          ? 0
          : fragments.indexWhere((p) => p['id'] == _memory!['through']) + 1;
      if (_memory != null && at == 0 && fragments.isNotEmpty) {
        return; // Do not merge duplicate/unknown history.
      }
      while (at < fragments.length && active() && epoch == _memoryEpoch) {
        final batch = <Map<String, String>>[];
        var size = 0;
        while (at < fragments.length &&
            batch.length < 24 &&
            size + fragments[at]['text']!.length <= 24000) {
          final fragment = fragments[at++];
          size += fragment['text']!.length;
          batch.add(fragment);
        }
        final response = await summarize(_memory?['summary'] as String?, batch);
        final summary = response['summary'];
        if (summary is! String ||
            summary.trim().isEmpty ||
            summary.length > 6000) {
          throw StateError('Invalid memory');
        }
        final next = <String, dynamic>{
          'version': 1,
          'summary': summary,
          'generatedAt': DateTime.now().toUtc().toIso8601String(),
          'through': batch.last['id'],
          'throughCreatedAt': batch.last['createdAt'],
        };
        await _enqueue(() async {
          if (!active() || epoch != _memoryEpoch) return;
          final temporary = File(path('memory.json.tmp'));
          await temporary.writeAsString(jsonEncode(next), flush: true);
          if (!active() || epoch != _memoryEpoch) {
            await temporary.delete();
            return;
          }
          await temporary.rename(path('memory.json'));
          _memory = next; // Replace only after a complete, durable write.
        });
      }
    } catch (_) {
      // Retain the last good summary/checkpoint; do not turn a memory failure
      // into a failed voice response or retry on every playback notification.
      _memoryRetryAt = DateTime.now().add(const Duration(minutes: 5));
    } finally {
      _summarizing = false;
    }
  }

  static List<Map<String, String>> contextFor(List<AiMessage> messages) {
    final valid = messages
        .where(
          (m) => !m.failed && (m.text.trim().isNotEmpty || m.images.isNotEmpty),
        )
        .toList();
    final chosen = valid.length <= 80
        ? valid
        : [...valid.take(20), ...valid.skip(valid.length - 60)];
    final result = <Map<String, String>>[];
    var budget = 70000;
    // Spend the bounded context budget on the newest turns first so the last
    // interaction cannot disappear behind long, older messages.
    for (final m in chosen.reversed) {
      final content = [
        m.text,
        for (final image in m.images)
          '[Shared image: ${image.title}; source: ${image.sourceUrl}]',
      ].join('\n');
      final text = content.substring(0, content.length.clamp(0, 2000));
      if (text.length > budget) break;
      budget -= text.length;
      result.add({
        'role': m.role,
        'text': text,
        'createdAt': m.createdAt.toUtc().toIso8601String(),
        if (m.timeZone != null) 'timeZone': m.timeZone!,
        if (m.utcOffsetMinutes != null)
          'utcOffsetMinutes': '${m.utcOffsetMinutes}',
      });
    }
    return result.reversed.toList();
  }
}

Uint8List aiWave(Uint8List pcm, int rate) {
  final bytes = Uint8List(44 + pcm.length);
  final data = ByteData.sublistView(bytes);
  void tag(int at, String text) =>
      bytes.setRange(at, at + text.length, ascii.encode(text));
  tag(0, 'RIFF');
  data.setUint32(4, 36 + pcm.length, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, rate, Endian.little);
  data.setUint32(28, rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  data.setUint32(40, pcm.length, Endian.little);
  bytes.setRange(44, bytes.length, pcm);
  return bytes;
}

// Bantera stores voice messages and call turns as PCM WAV. Accept ancillary RIFF
// chunks, validate lengths, and calculate duration from the format's byte rate.
// fileLength lets history migration inspect just a bounded header prefix.
int? aiWaveDurationMs(Uint8List bytes, {int? fileLength}) {
  final length = fileLength ?? bytes.length;
  if (bytes.length < 12) return null;
  bool tag(int offset, String value) {
    if (offset + value.length > bytes.length) return false;
    for (var i = 0; i < value.length; i++) {
      if (bytes[offset + i] != value.codeUnitAt(i)) return false;
    }
    return true;
  }

  if (!tag(0, 'RIFF') || !tag(8, 'WAVE')) return null;
  final data = ByteData.sublistView(bytes);
  final riffEnd = data.getUint32(4, Endian.little) + 8;
  if (riffEnd > length) return null;
  int? byteRate;
  int? audioBytes;
  var offset = 12;
  while (offset + 8 <= bytes.length && offset + 8 <= riffEnd) {
    final size = data.getUint32(offset + 4, Endian.little);
    final start = offset + 8;
    if (start + size > riffEnd) return null;
    if (tag(offset, 'fmt ')) {
      if (size < 16 ||
          start + 16 > bytes.length ||
          data.getUint16(start, Endian.little) != 1) {
        return null;
      }
      byteRate = data.getUint32(start + 8, Endian.little);
    } else if (tag(offset, 'data')) {
      audioBytes = size;
    }
    if (byteRate != null && audioBytes != null) {
      return byteRate > 0 ? audioBytes * 1000 ~/ byteRate : null;
    }
    offset = start + size + (size.isOdd ? 1 : 0);
  }
  return null;
}
