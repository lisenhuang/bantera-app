import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PracticeAudioRoute {
  static const _channel = MethodChannel('bantera/media_audio');
  static Future<void> prepare() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await _channel.invokeMethod<void>('preparePlayback');
    }
  }
}
