import 'dart:async';

/// Uses elapsed time rather than counting timer ticks, so a delayed UI tick does
/// not extend the recording. Cancellation and expiry both consume the timer.
class AiRecordingCountdown {
  AiRecordingCountdown({
    required this.onTick,
    required this.onExpired,
    int Function()? elapsedMilliseconds,
  }) : _elapsedMilliseconds = elapsedMilliseconds;
  static const limitSeconds = 180;
  final void Function(int) onTick;
  final void Function() onExpired;
  final int Function()? _elapsedMilliseconds;
  final _watch = Stopwatch();
  Timer? _timer;
  void start() {
    cancel();
    _watch
      ..reset()
      ..start();
    onTick(limitSeconds);
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final elapsed =
          _elapsedMilliseconds?.call() ?? _watch.elapsedMilliseconds;
      final remaining = ((limitSeconds * 1000 - elapsed) / 1000).ceil().clamp(
        0,
        limitSeconds,
      );
      onTick(remaining);
      if (remaining == 0) {
        cancel();
        onExpired();
      }
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
  }
}
