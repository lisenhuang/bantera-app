import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Device-local onboarding only. Contains no user or exercise data.
class PracticeSpeakingHintStore {
  const PracticeSpeakingHintStore({this.file});
  final File? file;

  Future<File> get _file async =>
      file ??
      File(
        '${(await getApplicationSupportDirectory()).path}/practice-speaking-hint-dismissed-v1',
      );

  Future<bool> isDismissed() async {
    final target = await _file;
    return await target.exists() && await target.readAsString() == 'true';
  }

  Future<void> dismiss() async {
    final target = await _file;
    await target.parent.create(recursive: true);
    await target.writeAsString('true', flush: true);
  }
}
