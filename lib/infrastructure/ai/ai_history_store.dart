import 'ai_web_search.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class AiMessage {
  AiMessage({
    required this.role,
    this.text = '',
    this.translation = '',
    this.audio,
    this.language = '',
    this.translationLanguage = '',
    this.durationMs,
    String? id,
    DateTime? createdAt,
    this.failed = false,
    this.webSearchQuery,
    this.webSearchStatus,
    List<AiWebSource>? sources,
  }) : sources = sources ?? [],
       id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
  final String id, role;
  final DateTime createdAt;
  String text, translation, language, translationLanguage;
  String? audio;
  int? durationMs;
  bool failed;
  String? webSearchQuery, webSearchStatus;
  final List<AiWebSource> sources;
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'text': text,
    'translation': translation,
    'audio': audio,
    'durationMs': durationMs,
    'language': language,
    'translationLanguage': translationLanguage,
    'createdAt': createdAt.toIso8601String(),
    'failed': failed,
    'webSearchQuery': webSearchQuery,
    'webSearchStatus': webSearchStatus == 'searching'
        ? 'unavailable'
        : webSearchStatus,
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
    failed: j['failed'] == true,
    webSearchQuery: j['webSearchQuery'] as String?,
    webSearchStatus: j['webSearchStatus'] as String?,
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
        (m.text.trim().isNotEmpty || m.audio != null),
  );
  bool privacyNoticeDismissed = false;

  Future<void> dismissPrivacyNotice() => _enqueue(() async {
    await _privacyNoticeFile!.writeAsString('dismissed', flush: true);
    privacyNoticeDismissed = true;
  });
  Future<void> _writes = Future.value();
  final List<AiMessage> messages = [];
  Future<void> load() async {
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
    final file = File('${_directory!.path}/history.json');
    if (await file.exists()) {
      final list = jsonDecode(await file.readAsString()) as List;
      messages.addAll(
        list.map((v) => AiMessage.fromJson(Map<String, dynamic>.from(v))),
      );
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

  Future<void> save() {
    for (final message in messages) {
      message.durationMs ??= _audioDurations[message.audio];
    }
    final contents = jsonEncode(messages.map((m) => m.toJson()).toList());
    final met = _hasModelReply;
    return _enqueue(() async {
      final file = File('${_directory!.path}/history.json.tmp');
      await file.writeAsString(contents, flush: true);
      await file.rename('${_directory!.path}/history.json');
      if (met && !hasMetBanteraAi) {
        await _hasMetFile!.writeAsString('met', flush: true);
        hasMetBanteraAi = true;
      }
    });
  }

  Future<void> clear() {
    messages.clear();
    _audioDurations.clear();
    return _enqueue(() async {
      if (await _directory!.exists()) await _directory!.delete(recursive: true);
      await _directory!.create(recursive: true);
    });
  }

  Future<void> _enqueue(Future<void> Function() job) {
    final next = _writes.then((_) => job());
    _writes = next.catchError((Object _) {});
    return next;
  }

  // Keep early personal context plus recent turns, bounded independently by the server.
  List<Map<String, String>> context({String? excluding}) =>
      contextFor(messages.where((m) => m.id != excluding).toList());
  static List<Map<String, String>> contextFor(List<AiMessage> messages) {
    final valid = messages
        .where((m) => !m.failed && m.text.trim().isNotEmpty)
        .toList();
    final chosen = valid.length <= 80
        ? valid
        : [...valid.take(20), ...valid.skip(valid.length - 60)];
    final result = <Map<String, String>>[];
    var budget = 70000;
    for (final m in chosen) {
      final text = m.text.substring(0, m.text.length.clamp(0, 2000));
      if (text.length > budget) break;
      budget -= text.length;
      result.add({'role': m.role, 'text': text});
    }
    return result;
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
