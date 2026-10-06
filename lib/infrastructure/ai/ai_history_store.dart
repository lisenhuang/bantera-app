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
    String? id,
    DateTime? createdAt,
    this.failed = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
  final String id, role;
  final DateTime createdAt;
  String text, translation, language, translationLanguage;
  String? audio;
  bool failed;
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'text': text,
    'translation': translation,
    'audio': audio,
    'language': language,
    'translationLanguage': translationLanguage,
    'createdAt': createdAt.toIso8601String(),
    'failed': failed,
  };
  factory AiMessage.fromJson(Map<String, dynamic> j) => AiMessage(
    id: j['id'],
    role: j['role'],
    text: j['text'] ?? '',
    translation: j['translation'] ?? '',
    audio: j['audio'],
    language: j['language'] ?? '',
    translationLanguage: j['translationLanguage'] ?? '',
    createdAt: DateTime.parse(j['createdAt']),
    failed: j['failed'] == true,
  );
}

class AiHistoryStore {
  AiHistoryStore(this.owner);
  final String owner;
  Directory? _directory;
  File? _privacyNoticeFile;
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
    _directory = Directory('$root/$key');
    await _directory!.create(recursive: true);
    final file = File('${_directory!.path}/history.json');
    if (await file.exists()) {
      final list = jsonDecode(await file.readAsString()) as List;
      messages.addAll(
        list.map((v) => AiMessage.fromJson(Map<String, dynamic>.from(v))),
      );
    }
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
    return name;
  }

  Future<void> save() {
    final contents = jsonEncode(messages.map((m) => m.toJson()).toList());
    return _enqueue(() async {
      final file = File('${_directory!.path}/history.json.tmp');
      await file.writeAsString(contents, flush: true);
      await file.rename('${_directory!.path}/history.json');
    });
  }

  Future<void> clear() {
    messages.clear();
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
