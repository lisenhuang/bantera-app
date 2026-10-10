import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Small, bounded, device-only cache. No audio codec is bundled with the app.
class AudioWaveform {
  static const _channel = MethodChannel('bantera/audio_waveform');
  static final _cache = <String, Future<List<double>>>{};
  static Future<void> _queue = Future.value();

  static Future<List<double>> load(String path) async {
    final stat = await File(path).stat();
    if (stat.size <= 0 || stat.size > 32 * 1024 * 1024) return [];
    final key = '$path:${stat.size}:${stat.modified.microsecondsSinceEpoch}';
    final existing = _cache.remove(key);
    if (existing != null) {
      _cache[key] = existing;
      return existing;
    }
    // Serial decoding avoids a screenful of messages competing with live audio.
    final task = _queue.then((_) async {
      try {
        final wav = await compute(_readWaveform, path);
        if (wav != null) return wav;
        final values = await _channel.invokeListMethod<num>('extract', {
          'path': path,
        });
        return values?.map((n) => n.toDouble().clamp(0.0, 1.0)).toList() ??
            <double>[];
      } catch (_) {
        return <
          double
        >[]; // Playback still works when a file cannot be analysed.
      }
    });
    _queue = task.then((_) {});
    _cache[key] = task;
    while (_cache.length > 128) {
      _cache.remove(_cache.keys.first);
    }
    return task;
  }
}

Future<List<double>?> _readWaveform(String path) async {
  final file = File(path);
  final handle = await file.open();
  try {
    final header = await handle.read(12);
    if (header.length != 12 ||
        String.fromCharCodes(header.take(4)) != 'RIFF' ||
        String.fromCharCodes(header.skip(8)) != 'WAVE') {
      return null;
    }
  } finally {
    await handle.close();
  }
  return wavePeaks(await file.readAsBytes());
}

/// Peak amplitude in 64 time buckets from PCM16 WAV, including stereo and RIFF padding.
List<double> wavePeaks(Uint8List bytes) {
  if (bytes.length < 12) return [];
  final data = ByteData.sublistView(bytes);
  var channels = 0, bits = 0, format = 0;
  for (var offset = 12; offset + 8 <= bytes.length;) {
    final tag = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final size = data.getUint32(offset + 4, Endian.little);
    final start = offset + 8;
    if (size > bytes.length - start) return [];
    if (tag == 'fmt ' && size >= 16) {
      format = data.getUint16(start, Endian.little);
      channels = data.getUint16(start + 2, Endian.little);
      bits = data.getUint16(start + 14, Endian.little);
    } else if (tag == 'data') {
      if (format != 1 || bits != 16 || channels < 1 || channels > 8) return [];
      final frames = size ~/ (channels * 2);
      if (frames == 0) return [];
      final peaks = List<double>.filled(64, 0);
      for (var frame = 0; frame < frames; frame++) {
        final bucket = frame * 64 ~/ frames;
        for (var c = 0; c < channels; c++) {
          final level =
              data
                  .getInt16(start + (frame * channels + c) * 2, Endian.little)
                  .abs() /
              32768;
          peaks[bucket] = math.max(peaks[bucket], level);
        }
      }
      return peaks;
    }
    offset = start + size + (size & 1);
  }
  return [];
}
