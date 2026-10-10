import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../infrastructure/audio_waveform.dart';

class ChatAudioWaveform extends StatefulWidget {
  const ChatAudioWaveform({
    super.key,
    required this.progress,
    required this.receiving,
    this.audioKey,
    this.loadAudioPath,
  });
  final double progress;
  final bool receiving;
  final String? audioKey;
  final Future<String> Function()? loadAudioPath;
  @override
  State<ChatAudioWaveform> createState() => _ChatAudioWaveformState();
}

class _ChatAudioWaveformState extends State<ChatAudioWaveform> {
  List<double> _peaks = const [];
  int _request = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ChatAudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioKey != widget.audioKey ||
        (oldWidget.loadAudioPath == null && widget.loadAudioPath != null)) {
      _load();
    }
  }

  Future<void> _load() async {
    final request = ++_request;
    _peaks = const [];
    final load = widget.loadAudioPath;
    if (load == null) return;
    try {
      final path = await load();
      if (!mounted || request != _request) return;
      final peaks = await AudioWaveform.load(path);
      if (mounted && request == _request) setState(() => _peaks = peaks);
    } catch (_) {
      /* Keep the ordinary progress track on download failure. */
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 32,
      child: _peaks.isEmpty
          ? Center(
              child: LinearProgressIndicator(
                value: widget.receiving
                    ? null
                    : widget.progress.clamp(0.0, 1.0),
                minHeight: 4,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: colors.outlineVariant,
                color: colors.primary,
              ),
            )
          : Semantics(
              value: '${(widget.progress.clamp(0.0, 1.0) * 100).round()}%',
              child: CustomPaint(
                painter: AudioWaveformPainter(
                  _peaks,
                  widget.progress,
                  colors.primary,
                  colors.outlineVariant,
                ),
              ),
            ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  AudioWaveformPainter(this.peaks, this.progress, this.played, this.remaining);
  final List<double> peaks;
  final double progress;
  final Color played, remaining;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || peaks.isEmpty) return;
    final bars = math.max(1, math.min(peaks.length, (size.width / 4).floor()));
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    void draw(Color color) {
      paint.color = color;
      for (var bar = 0; bar < bars; bar++) {
        var peak = 0.0;
        for (
          var p = bar * peaks.length ~/ bars;
          p < (bar + 1) * peaks.length ~/ bars;
          p++
        ) {
          peak = math.max(peak, peaks[p]);
        }
        // Square-root scaling keeps quiet speech visible without fabricating peaks.
        final height = 3 + math.sqrt(peak.clamp(0.0, 1.0)) * (size.height - 5);
        final x = (bar + .5) * size.width / bars;
        canvas.drawLine(
          Offset(x, (size.height - height) / 2),
          Offset(x, (size.height + height) / 2),
          paint,
        );
      }
    }

    draw(remaining);
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width * progress.clamp(0.0, 1.0), size.height),
    );
    draw(played);
    canvas.restore();
  }

  @override
  bool shouldRepaint(AudioWaveformPainter old) =>
      old.peaks != peaks ||
      old.progress != progress ||
      old.played != played ||
      old.remaining != remaining;
}
