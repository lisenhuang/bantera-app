import 'dart:async';
import 'ai_recording_countdown.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../infrastructure/ai/ai_voice_stream.dart';
import '../../../core/auth_session_notifier.dart';
import '../../../core/ai_callback_notifier.dart';
import '../../../core/dm_call_notifier.dart';
import '../../../core/user_profile_notifier.dart';
import '../../../core/word_activity_notifier.dart';
import '../../../infrastructure/ai/ai_spoken_words.dart';
import '../../../domain/models/models.dart';
import '../../../infrastructure/ai/ai_api_client.dart';
import '../../../infrastructure/ai/ai_device_data.dart';
import '../../../infrastructure/ai/ai_history_store.dart';
import '../../../infrastructure/translation_service.dart';

class AiChatController extends ChangeNotifier {
  AiChatController({this.callKitManaged = false})
    : owner = AuthSessionNotifier.instance.session!.cacheKey,
      store = AiHistoryStore(AuthSessionNotifier.instance.session!.cacheKey) {
    AuthSessionNotifier.instance.addListener(_accountChanged);
    DmCallNotifier.instance.addListener(_humanCallChanged);
  }
  @visibleForTesting
  AiChatController.forTesting(this.store, {this.callKitManaged = false})
    : owner = 'test',
      _testing = true;
  final bool callKitManaged;
  bool _testing = false;
  static const audio = MethodChannel('bantera/ai_audio');
  static const callActivity = MethodChannel('bantera/ai_call_activity');
  DateTime? _callEndsAt;
  bool _renewRequested = false;
  int _renewals = 0;
  static const microphone = EventChannel('bantera/ai_audio/input');
  final String owner;
  final AiHistoryStore store;
  AiApiClient _api = AiApiClient();
  final AudioRecorder _recorder = AudioRecorder();
  WebSocket? _socket;
  StreamSubscription? _socketEvents, _micEvents;
  Timer? _countdown, _connectTimeout;
  int recordingRemaining = AiRecordingCountdown.limitSeconds;
  late final _recordTimer = AiRecordingCountdown(
    onTick: (remaining) {
      if (recordingRemaining == remaining) return;
      recordingRemaining = remaining;
      changed();
    },
    onExpired: () => unawaited(sendRecording()),
  );
  final Stopwatch _elapsed = Stopwatch();
  bool loaded = false,
      busy = false,
      recording = false,
      calling = false,
      connected = false,
      farewell = false,
      muted = false,
      speaker = true,
      failed = false,
      _disposed = false;
  int remaining = 540, _epoch = 0;
  String draftUser = '', draftModel = '';
  AiVoiceStream? _voiceStream;
  AiMessage? _recordMessage;
  StreamSubscription<Uint8List>? _recordEvents;
  final BytesBuilder _recordPcm = BytesBuilder(copy: false);
  bool _replyAudioStarted = false;
  final BytesBuilder _input = BytesBuilder(copy: false),
      _output = BytesBuilder(copy: false);
  bool _speech = false;
  DateTime? _lastClock;
  Future<void> _events = Future.value(), _translations = Future.value();
  // A one-shot event for new voice-message replies only. History and live-call
  // turns must never replay automatically when rebuilt or translated.
  AiMessage? _playbackRequest;
  AiMessage? takePlaybackRequest() {
    final message = _playbackRequest;
    _playbackRequest = null;
    return message;
  }

  void requestReplyPlayback(AiMessage message) {
    if (!available ||
        calling ||
        message.role != 'model' ||
        message.audio == null) {
      return;
    }
    _playbackRequest = message;
    changed();
  }

  final Set<String> translating = {},
      translationFailed = {},
      visibleTranslations = {};
  bool privacyNoticeVisible = false;

  Future<void> dismissPrivacyNotice() async {
    privacyNoticeVisible = false;
    changed();
    try {
      await store.dismissPrivacyNotice();
    } catch (_) {
      // Keep the notice dismissed for this visit if local preferences fail.
    }
  }

  bool get available =>
      !_disposed &&
      (_testing || AuthSessionNotifier.instance.session?.cacheKey == owner);
  List<AiMessage> get messages => store.messages;
  void changed() {
    if (available) notifyListeners();
  }

  Future<void> initialize() async {
    if (loaded) return;
    try {
      await store.load();
      if (!available) return;
      privacyNoticeVisible = !store.privacyNoticeDismissed;
      loaded = true;
    } catch (_) {
      failed = true;
    }
    changed();
  }

  void _accountChanged() {
    if (!available) {
      _epoch++;
      _api.close();
      unawaited(endCall());
      unawaited(cancelRecording());
    }
  }

  void _humanCallChanged() {
    if (DmCallNotifier.instance.isActive) {
      unawaited(endCall());
      unawaited(cancelRecording());
    }
  }

  Future<void> record() async {
    if (!available ||
        !loaded ||
        busy ||
        calling ||
        DmCallNotifier.instance.isActive) {
      return;
    }
    final epoch = _epoch;
    if (!await _recorder.hasPermission() || epoch != _epoch || !available) {
      failed = true;
      changed();
      return;
    }
    final message = AiMessage(
      role: 'user',
      language: UserProfileNotifier.instance.learningLanguage ?? '',
    );
    _recordMessage = message;
    _recordPcm.clear();
    _voiceStream = AiVoiceStream(
      connect: () => _api.voice(owner, store.context(), message.id),
      onAudio: (bytes) async {
        if (!available || epoch != _epoch || !busy) return;
        if (!_replyAudioStarted) {
          await audio.invokeMethod<void>('startPlayback');
          _replyAudioStarted = true;
        }
        await audio.invokeMethod<void>('feed', bytes);
      },
      onReset: () async {
        if (_replyAudioStarted) await audio.invokeMethod<void>('clear');
      },
    );
    try {
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      _recordEvents = stream.listen(
        (bytes) {
          final room = 16000 * 2 * 180 - _recordPcm.length;
          if (room <= 0) return;
          final count = bytes.length.clamp(0, room) & ~1;
          if (count == 0) return;
          final chunk = Uint8List.fromList(bytes.sublist(0, count));
          _recordPcm.add(chunk);
          _voiceStream?.add(chunk);
        },
        onError: (Object _) {
          failed = true;
          unawaited(cancelRecording());
        },
      );
    } catch (_) {
      await cancelRecording();
      rethrow;
    }
    if (!available || epoch != _epoch) {
      await cancelRecording();
      return;
    }
    recording = true;
    failed = false;
    changed();
    _recordTimer.start();
  }

  Future<void> cancelRecording() async {
    if (!recording && _recordMessage == null && _voiceStream == null) return;
    _recordTimer.cancel();
    recording = false;
    final stream = _voiceStream;
    _voiceStream = null;
    _recordMessage = null;
    await _recorder.cancel();
    await _recordEvents?.cancel();
    _recordEvents = null;
    _recordPcm.clear();
    await stream?.close();
    if (_replyAudioStarted) {
      _replyAudioStarted = false;
      await audio.invokeMethod<void>('stop');
    }
    changed();
  }

  Future<void> sendRecording() async {
    if (!recording) return;
    final epoch = _epoch;
    final stream = _voiceStream;
    final message = _recordMessage;
    _recordTimer.cancel();
    recording = false;
    busy = true;
    changed();
    try {
      await _recorder.stop();
      await _recordEvents?.cancel();
      _recordEvents = null;
      if (message == null || !available || epoch != _epoch) return;
      final pcm = _recordPcm.takeBytes();
      if (pcm.length < 320) return;
      message.audio = await store.saveAudio(aiWave(pcm, 16000));
      if (!available || epoch != _epoch) return;
      store.messages.add(message);
      await store.save();
      changed();
      Map<String, dynamic>? reply;
      if (stream != null) {
        try {
          reply = await stream.send(await AiApiClient.metadata());
        } catch (_) {
          if (stream.committed) rethrow;
        }
      }
      if (!available || epoch != _epoch) return;
      if (reply == null) {
        // Older deployed servers and failed pre-send connections retain the safe
        // upload path. Never resubmit automatically once a stream was committed.
        await stream?.close();
        await _reply(message);
      } else {
        await _saveReply(message, reply, epoch, autoplay: false);
        if (_replyAudioStarted) {
          await audio
              .invokeMethod<void>('drain')
              .timeout(const Duration(seconds: 95));
        }
      }
    } catch (_) {
      if (available && epoch == _epoch) {
        failed = true;
        if (message != null && store.messages.contains(message)) {
          message.failed = true;
          await store.save();
        }
      }
    } finally {
      await stream?.close();
      if (identical(_voiceStream, stream)) _voiceStream = null;
      _recordMessage = null;
      if (_replyAudioStarted) {
        _replyAudioStarted = false;
        await audio.invokeMethod<void>('stop');
      }
      busy = false;
      changed();
    }
  }

  Future<void> retry(AiMessage message) async {
    if (busy || calling || !available || message.audio == null) return;
    busy = true;
    failed = false;
    changed();
    try {
      await _reply(message);
    } finally {
      busy = false;
      changed();
    }
  }

  Future<void> _reply(AiMessage message) async {
    if (message.audio == null) return;
    final epoch = _epoch;
    try {
      final reply = await _api.reply(
        owner: owner,
        history: store.context(excluding: message.id),
        audioPath: store.path(message.audio!),
        requestId: message.id,
      );
      if (!available || epoch != _epoch) return;
      await _saveReply(message, reply, epoch);
    } catch (_) {
      if (available && epoch == _epoch) {
        message.failed = true;
        failed = true;
        await store.save();
      }
    }
    changed();
  }

  Future<void> _saveReply(
    AiMessage message,
    Map<String, dynamic> reply,
    int epoch, {
    bool autoplay = true,
  }) async {
    if (!available || epoch != _epoch) return;
    message.failed = false;
    message.text = reply['inputText'] as String? ?? message.text;
    final name = await store.saveAudio(base64Decode(reply['audio'] as String));
    if (!available || epoch != _epoch) return;
    final answer = AiMessage(
      role: 'model',
      text: reply['outputText'] as String? ?? '',
      audio: name,
      language: message.language,
    );
    store.messages.add(answer);
    await store.save();
    if (autoplay) requestReplyPlayback(answer);
    unawaited(_countSpeech(message));
    changed();
  }

  Future<void> _countSpeech(AiMessage message) async {
    if (_testing || !available || message.role != 'user') return;
    final epoch = _epoch;
    final userId = AuthSessionNotifier.instance.session?.userId;
    if (userId == null) return;
    final count = await AiSpokenWords.count(message.text, message.language);
    if (!available || epoch != _epoch || count == 0) return;
    try {
      await WordActivityNotifier.instance.record(
        spoken: count,
        language: message.language,
        ownerId: userId,
        at: message.createdAt,
        speechEventId: 'ai-spoken:${message.id}',
      );
    } catch (_) {
      // Word-count persistence must never make an otherwise successful chat fail.
    }
  }

  void translate(AiMessage message, {bool force = false}) {
    if (!Platform.isIOS ||
        message.text.trim().isEmpty ||
        translating.contains(message.id)) {
      return;
    }
    final target = UserProfileNotifier.instance.nativeLanguage ?? '';
    if (target.isEmpty ||
        message.language.isEmpty ||
        target == message.language) {
      return;
    }
    visibleTranslations.add(message.id);
    if (!force &&
        message.translation.isNotEmpty &&
        message.translationLanguage == target) {
      changed();
      return;
    }
    final epoch = _epoch;
    translating.add(message.id);
    translationFailed.remove(message.id);
    changed();
    _translations = _translations.catchError((Object _) {}).then((_) async {
      if (!available || epoch != _epoch || !messages.contains(message)) {
        translating.remove(message.id);
        return;
      }
      try {
        Future<Map<String, String>> perform() =>
            TranslationService.instance.translateCues(
              sourceLocaleIdentifier: message.language,
              targetLocaleIdentifier: target,
              cues: [
                Cue(
                  id: message.id,
                  startTimeMs: 0,
                  endTimeMs: 0,
                  originalText: message.text,
                  translatedText: '',
                ),
              ],
            );
        Map<String, String> result;
        try {
          result = await perform();
        } on TranslationException catch (e) {
          if (e.code != 'translation_assets_not_installed') rethrow;
          await TranslationService.instance.prepareTranslationAssets(
            sourceLocaleIdentifier: message.language,
            targetLocaleIdentifier: target,
          );
          result = await perform();
        }
        if (!available || epoch != _epoch || !messages.contains(message)) {
          return;
        }
        message.translation = result[message.id] ?? '';
        message.translationLanguage = target;
        if (message.translation.isEmpty) translationFailed.add(message.id);
        await store.save();
      } catch (_) {
        if (available && epoch == _epoch) translationFailed.add(message.id);
      } finally {
        translating.remove(message.id);
        changed();
      }
    });
  }

  Map<String, Object> get _activityState => {
    'endsAt': (_callEndsAt ?? DateTime.now()).millisecondsSinceEpoch,
    'muted': muted,
    'speaker': speaker,
    'phase': !connected
        ? 'connecting'
        : farewell
        ? 'goodbye'
        : 'live',
  };

  Future<void> _startCallActivity(int epoch) async {
    if (!Platform.isIOS || callKitManaged) return;
    callActivity.setMethodCallHandler((call) async {
      if (call.method != 'control' ||
          !available ||
          !calling ||
          epoch != _epoch) {
        return null;
      }
      switch (call.arguments) {
        case 'end':
          await endCall();
        case 'mute':
          if (connected) toggleMute();
        case 'speaker':
          if (connected) await setSpeaker();
      }
      return null;
    });
    try {
      await callActivity.invokeMethod<bool>('start', _activityState);
    } catch (_) {}
  }

  Future<void> _updateCallActivity() async {
    if (!Platform.isIOS || callKitManaged || !calling) return;
    try {
      await callActivity.invokeMethod<void>('update', _activityState);
    } catch (_) {}
  }

  Future<void> _endCallActivity() async {
    if (!Platform.isIOS || callKitManaged) return;
    callActivity.setMethodCallHandler(null);
    try {
      await callActivity.invokeMethod<void>('stop');
    } catch (_) {}
  }

  Future<void> startCall() async {
    if (!available ||
        !loaded ||
        busy ||
        recording ||
        calling ||
        DmCallNotifier.instance.isActive) {
      return;
    }
    calling = true;
    AiCallbackNotifier.instance.aiActive = true;
    connected = false;
    farewell = false;
    if (!callKitManaged) muted = false;
    speaker = !callKitManaged;
    remaining = 540;
    _renewals = 0;
    _renewRequested = false;
    failed = false;
    final epoch = ++_epoch;
    _callEndsAt = DateTime.now().add(const Duration(seconds: 540));
    changed();
    try {
      await _startCallActivity(epoch);
      if (!available || epoch != _epoch) return;
      if (!await Permission.microphone.request().isGranted) {
        throw StateError('Microphone denied');
      }
      if (!available || epoch != _epoch) return;
      _micEvents = microphone.receiveBroadcastStream().listen(
        (event) {
          if (!connected ||
              farewell ||
              muted ||
              !available ||
              epoch != _epoch) {
            return;
          }
          final bytes = Uint8List.fromList((event as List).cast<int>());
          // A lightweight speech gate trims leading silence from the local recording only.
          // Gemini still receives every frame and performs its own VAD.
          final samples = ByteData.sublistView(bytes);
          var peak = 0;
          for (var i = 0; i + 1 < bytes.length; i += 8) {
            final level = samples.getInt16(i, Endian.little).abs();
            if (level > peak) peak = level;
          }
          if (!_speech && peak > 900) {
            _speech = true;
            unawaited(_sendClock(epoch));
          }
          if (_speech && _input.length < 16000 * 2 * 60) _input.add(bytes);
          _socket?.add(bytes);
        },
        onError: (Object _) {
          failed = true;
          unawaited(endCall());
        },
      );
      await audio.invokeMethod<void>('start', {
        'callKitManaged': callKitManaged,
      });
      if (!available || epoch != _epoch) {
        await audio.invokeMethod<void>('stop');
        return;
      }
      await _openCallSocket(epoch);
    } catch (_) {
      if (epoch == _epoch) {
        failed = true;
        await endCall();
      }
    }
  }

  Future<void> _openCallSocket(int epoch, {bool resuming = false}) async {
    final socket = await _api.call(
      owner,
      store.context(),
      resuming: resuming,
      remainingSeconds: remaining,
    );
    if (!available || epoch != _epoch) {
      await socket.close();
      return;
    }
    _socket = socket;
    _connectTimeout = Timer(const Duration(seconds: 35), () {
      failed = true;
      unawaited(endCall());
    });
    _socketEvents = socket.listen(
      (event) {
        _events = _events
            .then((_) async {
              if (available && epoch == _epoch && identical(_socket, socket)) {
                await _event(event, epoch);
              }
            })
            .catchError((Object _) {
              if (epoch == _epoch) {
                failed = true;
                unawaited(endCall());
              }
            });
      },
      onDone: () => _callSocketClosed(socket, epoch),
      onError: (Object _) => _callSocketClosed(socket, epoch, error: true),
    );
  }

  void _callSocketClosed(WebSocket socket, int epoch, {bool error = false}) {
    _events = _events.then((_) {
      if (epoch != _epoch || !identical(_socket, socket)) return;
      _socket = null; // onError and onDone can both fire; renew only once.
      if (_renewRequested && !farewell && remaining > 0) {
        unawaited(_renewCall(epoch));
      } else {
        if (error || !connected) failed = true;
        unawaited(endCall());
      }
    });
  }

  Future<void> _renewCall(int epoch) async {
    _renewRequested = false;
    if (++_renewals > 2) {
      failed = true;
      await endCall();
      return;
    }
    connected = false;
    unawaited(_updateCallActivity());
    changed();
    try {
      await audio.invokeMethod<void>('clear');
      await _saveTurn();
      await _socketEvents?.cancel();
      _socket = null;
      // Let the previous server request release its per-account call lease.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!available || epoch != _epoch || !calling) return;
      await _openCallSocket(epoch, resuming: true);
    } catch (_) {
      if (epoch == _epoch) {
        failed = true;
        await endCall();
      }
    }
  }

  Future<void> _sendClock(int epoch) async {
    if (_lastClock != null &&
        DateTime.now().difference(_lastClock!).inSeconds < 1) {
      return;
    }
    _lastClock = DateTime.now();
    final clock = await AiApiClient.clock();
    if (epoch == _epoch && connected && !farewell) {
      _socket?.add(jsonEncode({'type': 'clock', 'clock': clock}));
    }
  }

  Future<void> _event(dynamic event, int epoch) async {
    if (event is List<int>) {
      if (_output.length + event.length > 24000 * 2 * 90) {
        throw StateError('Audio too long');
      }
      _output.add(event);
      await audio.invokeMethod<void>('feed', Uint8List.fromList(event));
      return;
    }
    final data = jsonDecode(event as String) as Map<String, dynamic>;
    switch (data['type']) {
      case 'ready':
        _connectTimeout?.cancel();
        connected = true;
        if (!_elapsed.isRunning) {
          _callEndsAt = DateTime.now().add(const Duration(seconds: 540));
          _elapsed
            ..reset()
            ..start();
          _countdown = Timer.periodic(const Duration(milliseconds: 250), (_) {
            remaining = ((540000 - _elapsed.elapsedMilliseconds) / 1000)
                .ceil()
                .clamp(0, 540);
            if (remaining <= 0) unawaited(endCall());
            changed();
          });
        }
        unawaited(_updateCallActivity());
      case 'reconnect':
        if (data['reason'] == 'session_expired') _renewRequested = true;
      case 'transcript':
        if (data['role'] == 'user') {
          draftUser += data['text'] as String? ?? '';
        } else {
          draftModel += data['text'] as String? ?? '';
        }
      case 'turnComplete':
        await _saveTurn();
      case 'interrupted':
        await audio.invokeMethod<void>('clear');
        await _saveModel();
      case 'farewell':
        farewell = true;
        unawaited(_updateCallActivity());
        await audio.invokeMethod<void>('clear');
        await _saveTurn();
      case 'goodbyeComplete':
        await _saveTurn();
        // Do not block the event queue during playback; the hard deadline can still close it.
        unawaited(
          audio
              .invokeMethod<void>('drain')
              .then((_) async {
                if (epoch != _epoch) return;
                _socket?.add(jsonEncode({'type': 'finished'}));
                await endCall();
              })
              .catchError((Object _) {
                unawaited(endCall());
              }),
        );
      case 'toolCall':
        // Read tools run outside the audio queue so local disk/network reads never stall playback.
        unawaited(_tools((data['calls'] as List).cast<Map>(), epoch));
    }
    changed();
  }

  Future<void> _tools(List<Map> calls, int epoch) async {
    final destination = _socket;
    final responses = <Map<String, dynamic>>[];
    for (final call in calls) {
      Map<String, dynamic> result;
      try {
        result = await AiDeviceData.read(
          call['name'] as String,
          owner,
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        result = {'unavailable': true};
      }
      responses.add({
        'id': call['id'],
        'name': call['name'],
        'response': {'result': result},
      });
    }
    if (available &&
        epoch == _epoch &&
        !farewell &&
        identical(_socket, destination)) {
      _socket?.add(
        jsonEncode({'type': 'toolResponse', 'responses': responses}),
      );
    }
  }

  Future<void> _saveTurn() async {
    final pcm = _input.takeBytes();
    final text = draftUser.trim();
    draftUser = '';
    _speech = false;
    if (text.isNotEmpty) {
      final message = AiMessage(
        role: 'user',
        text: text,
        language: UserProfileNotifier.instance.learningLanguage ?? '',
      );
      if (pcm.isNotEmpty) {
        message.audio = await store.saveAudio(aiWave(pcm, 16000));
      }
      store.messages.add(message);
      unawaited(_countSpeech(message));
    }
    await _saveModel();
    await store.save();
    changed();
  }

  Future<void> _saveModel() async {
    final pcm = _output.takeBytes();
    final text = draftModel.trim();
    draftModel = '';
    if (text.isNotEmpty || pcm.isNotEmpty) {
      final message = AiMessage(
        role: 'model',
        text: text,
        language: UserProfileNotifier.instance.learningLanguage ?? '',
      );
      if (pcm.isNotEmpty) {
        message.audio = await store.saveAudio(aiWave(pcm, 24000));
      }
      store.messages.add(message);
      await store.save();
      changed();
    }
  }

  // Route notifications describe the hardware; do not write them back and
  // fight the CallKit route picker (or a connected Bluetooth headset).
  void updateSpeakerRoute(bool enabled) {
    if (speaker == enabled) return;
    speaker = enabled;
    changed();
  }

  Future<void> setSpeaker() async {
    speaker = !speaker;
    try {
      await audio.invokeMethod<void>('speaker', speaker);
    } catch (_) {
      speaker = !speaker;
    }
    unawaited(_updateCallActivity());
    changed();
  }

  void toggleMute() => setMuted(!muted);

  void setMuted(bool value) {
    if (muted == value) return;
    muted = value;
    unawaited(_updateCallActivity());
    changed();
  }

  Future<void> endCall() async {
    if (!calling) return;
    calling = false;
    unawaited(_endCallActivity());
    AiCallbackNotifier.instance.aiActive = false;
    connected = false;
    _epoch++;
    _elapsed.stop();
    _countdown?.cancel();
    _connectTimeout?.cancel();
    final socket = _socket;
    _socket = null;
    await _socketEvents?.cancel();
    _socketEvents = null;
    unawaited(socket?.close() ?? Future.value());
    await _micEvents?.cancel();
    _micEvents = null;
    try {
      await audio.invokeMethod<void>('stop');
    } catch (_) {}
    if (loaded) await _saveTurn();
    changed();
  }

  Future<void> clear() async {
    _playbackRequest = null;
    _epoch++;
    _api.close();
    _api = AiApiClient();
    await cancelRecording();
    await endCall();
    await _events.catchError((Object _) {});
    await store.clear();
    failed = false;
    busy = false;
    draftUser = '';
    draftModel = '';
    visibleTranslations.clear();
    translating.clear();
    translationFailed.clear();
    changed();
  }

  @override
  void dispose() {
    if (_testing) {
      _disposed = true;
      super.dispose();
      return;
    }
    _disposed = true;
    _epoch++;
    _api.close();
    _recordTimer.cancel();
    _elapsed.stop();
    _countdown?.cancel();
    _connectTimeout?.cancel();
    AuthSessionNotifier.instance.removeListener(_accountChanged);
    DmCallNotifier.instance.removeListener(_humanCallChanged);
    unawaited(endCall());
    unawaited(cancelRecording().whenComplete(() => _recorder.dispose()));
    super.dispose();
  }
}
