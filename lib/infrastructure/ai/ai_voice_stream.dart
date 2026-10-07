import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'ai_history_store.dart';

/// One recording, uploaded while it is captured. A commit is the only message
/// that asks the model to answer. Closing before commit cancels the recording.
class AiVoiceFailure implements Exception {
  const AiVoiceFailure(this.code, {this.errorType, this.nativeCode});
  final String code;
  final String? errorType, nativeCode;
  factory AiVoiceFailure.from(String code, Object error) =>
      error is AiVoiceFailure
      ? error
      : AiVoiceFailure(
          code,
          errorType: error.runtimeType.toString(),
          nativeCode:
              error is PlatformException &&
                  RegExp(r'^[A-Za-z0-9_.-]{1,80}$').hasMatch(error.code)
              ? error.code
              : null,
        );
  @override
  String toString() => 'AI voice operation failed ($code)';
}

class AiVoiceStream {
  AiVoiceStream({
    required Future<WebSocket> Function() connect,
    required this.onAudio,
    required this.onReset,
    this.onTranscript,
  }) {
    _ready.future.ignore();
    _reply.future.ignore();
    unawaited(_open(connect));
  }
  final Future<void> Function(Uint8List) onAudio;
  final Future<void> Function() onReset;
  final void Function(String role, String text)? onTranscript;
  final _ready = Completer<void>();
  final _reply = Completer<Map<String, dynamic>>();
  final _pending = <Uint8List>[];
  final _output = BytesBuilder(copy: false);
  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  Future<void> _events = Future.value();
  bool _closed = false, _failed = false, _serverReady = false;
  bool committed = false;
  int _bytes = 0;
  int get inputBytes => _bytes;
  int get outputBytes => _output.length;
  int? get closeCode => _socket?.closeCode;
  Uint8List? get partialAudio =>
      _output.isEmpty ? null : aiWave(_output.toBytes(), 24000);

  Future<void> _open(Future<WebSocket> Function() connect) async {
    try {
      final socket = await connect();
      if (_closed) {
        await socket.close();
        return;
      }
      _socket = socket;
      _subscription = socket.listen(
        (event) {
          _events = _events.then((_) => _event(event)).catchError((
            Object error,
          ) {
            _fail('invalid_frame', error: error);
          });
        },
        onError: (Object error) => _fail('socket_error', error: error),
        onDone: () {
          // Drain the ordered audio/transcript events before checking completion.
          _events = _events.then((_) {
            if (!_reply.isCompleted && !_closed) _fail('socket_closed');
          });
        },
      );
    } catch (error) {
      _fail('connect_failed', error: error);
    }
  }

  void add(Uint8List pcm) {
    if (_closed || _failed || committed) return;
    if (pcm.isEmpty ||
        pcm.length.isOdd ||
        _bytes + pcm.length > 16000 * 2 * 180) {
      _fail('invalid_frame');
      return;
    }
    _bytes += pcm.length;
    // Native recorder chunks can exceed the wire-frame limit.
    for (var offset = 0; offset < pcm.length; offset += 16000) {
      final chunk = Uint8List.fromList(
        pcm.sublist(offset, (offset + 16000).clamp(0, pcm.length)),
      );
      if (_serverReady) {
        _socket!.add(chunk);
      } else {
        _pending.add(chunk);
      }
    }
  }

  Future<void> _event(dynamic event) async {
    if (_closed || _failed) return;
    if (event is List<int>) {
      if (!committed) throw const AiVoiceFailure('invalid_frame');
      if (_output.length + event.length > 24000 * 2 * 90) {
        throw const AiVoiceFailure('reply_audio_limit');
      }
      final bytes = Uint8List.fromList(event);
      _output.add(bytes);
      try {
        await onAudio(bytes);
      } catch (error) {
        throw AiVoiceFailure.from('playback_failed', error);
      }
      return;
    }
    final json = jsonDecode(event as String) as Map<String, dynamic>;
    switch (json['type']) {
      case 'ready':
        if (_serverReady) throw StateError('Duplicate ready');
        _serverReady = true;
        for (final chunk in _pending) {
          _socket!.add(chunk);
        }
        _pending.clear();
        _ready.complete();
      case 'reset':
        _output.clear();
        try {
          await onReset();
        } catch (error) {
          throw AiVoiceFailure.from('playback_failed', error);
        }
      case 'transcript':
        final role = json['role'];
        final text = json['text'];
        if (!committed ||
            (role != 'user' && role != 'model') ||
            text is! String) {
          throw StateError('Invalid voice transcript');
        }
        onTranscript?.call(role as String, text);
      case 'complete':
        if (!committed || _output.isEmpty || _reply.isCompleted) {
          throw const AiVoiceFailure('invalid_frame');
        }
        _reply.complete({
          'audio': base64Encode(aiWave(_output.toBytes(), 24000)),
          'inputText': json['inputText'],
          'outputText': json['outputText'],
        });
      case 'error':
        _fail('server_error');
      default:
        throw const AiVoiceFailure('invalid_frame');
    }
  }

  Future<Map<String, dynamic>> send(Map<String, dynamic> metadata) async {
    await _ready.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () => throw const AiVoiceFailure('ready_timeout'),
    );
    if (_closed || _failed || committed) {
      throw const AiVoiceFailure('send_failed');
    }
    committed = true;
    try {
      _socket!.add(jsonEncode({'type': 'commit', 'metadata': metadata}));
    } catch (_) {
      throw const AiVoiceFailure('send_failed');
    }
    return _reply.future.timeout(
      const Duration(seconds: 110),
      onTimeout: () => throw const AiVoiceFailure('reply_timeout'),
    );
  }

  void _fail(String code, {Object? error}) {
    if (_closed || _failed) return;
    _failed = true;
    final failure = error == null
        ? AiVoiceFailure(code)
        : AiVoiceFailure.from(code, error);
    _pending.clear();
    if (!_ready.isCompleted) {
      _ready.completeError(failure);
    }
    if (!_reply.isCompleted) {
      _reply.completeError(failure);
    }
    unawaited(_socket?.close());
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _pending.clear();
    if (!_ready.isCompleted) _ready.completeError(StateError('Cancelled'));
    if (!_reply.isCompleted) _reply.completeError(StateError('Cancelled'));
    await _subscription?.cancel();
    unawaited(_socket?.close());
    await _events;
  }
}
