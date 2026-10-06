import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'ai_history_store.dart';

/// One recording, uploaded while it is captured. A commit is the only message
/// that asks the model to answer. Closing before commit cancels the recording.
class AiVoiceStream {
  AiVoiceStream({
    required Future<WebSocket> Function() connect,
    required this.onAudio,
    required this.onReset,
  }) {
    _ready.future.ignore();
    _reply.future.ignore();
    unawaited(_open(connect));
  }
  final Future<void> Function(Uint8List) onAudio;
  final Future<void> Function() onReset;
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
          _events = _events.then((_) => _event(event)).catchError((Object _) {
            _fail();
          });
        },
        onError: (Object _) => _fail(),
        onDone: () {
          // Drain the ordered audio/transcript events before checking completion.
          _events = _events.then((_) {
            if (!_reply.isCompleted && !_closed) _fail();
          });
        },
      );
    } catch (_) {
      _fail();
    }
  }

  void add(Uint8List pcm) {
    if (_closed || _failed || committed) return;
    if (pcm.isEmpty ||
        pcm.length.isOdd ||
        _bytes + pcm.length > 16000 * 2 * 180) {
      _fail();
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
      if (!committed || _output.length + event.length > 24000 * 2 * 90) {
        throw StateError('Invalid voice reply');
      }
      final bytes = Uint8List.fromList(event);
      _output.add(bytes);
      await onAudio(bytes);
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
        await onReset();
      case 'complete':
        if (!committed || _output.isEmpty || _reply.isCompleted) {
          throw StateError('Invalid voice reply');
        }
        _reply.complete({
          'audio': base64Encode(aiWave(_output.takeBytes(), 24000)),
          'inputText': json['inputText'],
          'outputText': json['outputText'],
        });
      case 'error':
        _fail();
      default:
        throw StateError('Invalid voice reply');
    }
  }

  Future<Map<String, dynamic>> send(Map<String, dynamic> metadata) async {
    await _ready.future.timeout(const Duration(seconds: 25));
    if (_closed || _failed || committed) {
      throw StateError('Voice stream unavailable');
    }
    committed = true;
    _socket!.add(jsonEncode({'type': 'commit', 'metadata': metadata}));
    return _reply.future.timeout(const Duration(seconds: 110));
  }

  void _fail() {
    if (_closed || _failed) return;
    _failed = true;
    _pending.clear();
    if (!_ready.isCompleted) {
      _ready.completeError(StateError('Voice stream unavailable'));
    }
    if (!_reply.isCompleted) {
      _reply.completeError(StateError('Voice stream unavailable'));
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
