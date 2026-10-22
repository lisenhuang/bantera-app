import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Local fallback choices, separated by account and learning language.
class PracticeTranslationPreferences {
  PracticeTranslationPreferences({required this.file});
  static final instance = PracticeTranslationPreferences(
    file: () async => File(
      '${(await getApplicationSupportDirectory()).path}/practice_translation_languages.json',
    ),
  );
  final Future<File> Function() file;
  Future<void> _queue = Future.value();

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<Map<String, dynamic>> _read(File target) async {
    if (!await target.exists()) return {};
    try {
      return Map<String, dynamic>.from(
        jsonDecode(await target.readAsString()) as Map,
      );
    } on FormatException {
      return {};
    }
  }

  Future<String?> load(String owner, String language) => _serial(() async {
    final data = await _read(await file());
    return data[jsonEncode([owner, language])] as String?;
  });

  Future<void> save(String owner, String language, String target) =>
      _serial(() async {
        final destination = await file();
        final data = await _read(destination);
        data[jsonEncode([owner, language])] = target;
        await destination.parent.create(recursive: true);
        final temporary = File('${destination.path}.tmp');
        await temporary.writeAsString(jsonEncode(data), flush: true);
        await temporary.rename(destination.path);
      });
}
