import '../../../infrastructure/ai/ai_search_capabilities.dart';
import '../../../infrastructure/ai/ai_image_search.dart';
import '../../../infrastructure/ai/ai_web_search.dart';
import 'dart:async';
import '../chat_recording_countdown.dart';
import 'ai_voice_reply_state.dart';
import 'ai_listening_progress.dart';
import '../../../domain/activity/listening_word_tracker.dart';
import '../../../core/chat_session_notifier.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
  AiChatController({this.callKitManaged = false, this.callbackId})
    : owner = AuthSessionNotifier.instance.session!.cacheKey,
      store = AiHistoryStore(AuthSessionNotifier.instance.session!.cacheKey) {
    AuthSessionNotifier.instance.addListener(_accountChanged);
    DmCallNotifier.instance.addListener(_humanCallChanged);
  }
  @visibleForTesting
  AiChatController.forTesting(
    this.store, {
    this.callKitManaged = false,
    this.callbackId,
    AudioRecorder? recorder,
    AiApiClient? api,
    AiImageSearch? imageSearch,
    Future<Map<String, dynamic>> Function()? voiceMetadata,
  }) : owner = 'test',
       _testing = true {
    if (recorder != null) _recorder = recorder;
    if (api != null) _api = api;
    if (imageSearch != null) _imageSearch = imageSearch;
    _voiceMetadata = voiceMetadata;
  }
  final bool callKitManaged;
  final String? callbackId;
  bool _testing = false;
  static const audio = MethodChannel('bantera/ai_audio');
  static const callActivity = MethodChannel('bantera/ai_call_activity');
  DateTime? _callEndsAt;
  bool _renewRequested = false;
  int _renewals = 0;
  bool _speakerChanging = false;
  static const microphone = EventChannel('bantera/ai_audio/input');
  final String owner;
  final AiHistoryStore store;
  final _webSearch = AiWebSearch();
  AiImageSearch _imageSearch = AiImageSearch();
  AiApiClient _api = AiApiClient();
  AudioRecorder _recorder = AudioRecorder();
  Future<Map<String, dynamic>> Function()? _voiceMetadata;
  WebSocket? _socket;
  StreamSubscription? _socketEvents, _micEvents;
  Timer? _countdown, _connectTimeout;
  Future<void> _screenAwakeUpdates = Future.value();

  // Serialize platform updates so ending a call during startup cannot leave
  // auto-lock disabled after a slow enable operation completes.
  void _keepScreenAwake(bool enabled) {
    _screenAwakeUpdates = _screenAwakeUpdates.then((_) async {
      try {
        await WakelockPlus.toggle(enable: enabled);
      } catch (_) {
        // A display setting failure must not prevent starting/ending audio.
      }
    });
  }

  int recordingRemaining = ChatRecordingCountdown.limitSeconds;
  late final _recordTimer = ChatRecordingCountdown(
    onTick: (remaining) {
      if (recordingRemaining == remaining) return;
      recordingRemaining = remaining;
      changed();
    },
    onExpired: () => unawaited(sendRecording()),
  );
  final Stopwatch _elapsed = Stopwatch();
  final _callListening = AiListeningProgress();
  Timer? _listeningTimer;
  int _queuedFrames = 0, _modelStartFrame = 0;
  Future<void> _listeningWrites = Future.value();
  Future<void> recordListened(int words, String language) async {
    if (_testing || !available || words <= 0) return;
    try {
      await WordActivityNotifier.instance.record(
        listened: words,
        language: language,
        ownerId: AuthSessionNotifier.instance.session?.userId,
      );
    } catch (_) {}
  }

  Future<void> _pollListening({bool discard = false}) {
    final next = _listeningWrites.then((_) async {
      try {
        final frames = await audio.invokeMethod<int>('playedFrames') ?? 0;
        for (final entry in _callListening.advance(frames).entries) {
          await recordListened(entry.value, entry.key);
        }
        if (discard) {
          _callListening.clear();
          _queuedFrames = frames;
          _modelStartFrame = frames;
        }
      } catch (_) {
        if (discard) _callListening.clear();
      }
    });
    _listeningWrites = next.catchError((Object _) {});
    return next;
  }

  Timer? _reminderTimer;
  StreamSubscription? _reminderEvents;
  bool _syncingReminders = false;
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
  AiVoiceStream? _voiceStream, _receivingStream;
  Completer<void>? _replyFinished;
  bool _recordStarting = false, _waitingToSend = false;
  Future<void> _replyAudioWork = Future.value();
  int _replyPlayedFrames = 0;
  bool get canRecord =>
      available &&
      loaded &&
      !recording &&
      !_recordStarting &&
      !_waitingToSend &&
      !calling &&
      (_testing || !DmCallNotifier.instance.isActive);
  AiMessage? _recordMessage;
  StreamSubscription<Uint8List>? _recordEvents;
  final BytesBuilder _recordPcm = BytesBuilder(copy: false);
  bool _replyAudioStarted = false, _replyPlaybackUnavailable = false;
  final voiceReply = AiVoiceReplyState();
  AiMessage? _liveModelMessage;
  bool get sendingVoice => busy && !voiceReply.received;
  bool isReceiving(AiMessage message) =>
      identical(voiceReply.message, message) ||
      identical(_liveModelMessage, message);
  final BytesBuilder _input = BytesBuilder(copy: false),
      _output = BytesBuilder(copy: false);
  bool _speech = false;
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
  List<AiMessage> get messages => [
    ...store.messages,
    ?voiceReply.message,
    ?_liveModelMessage,
  ];
  void changed() {
    if (available) notifyListeners();
  }

  Future<void> _refreshMemory() async {
    if (_testing || !available) return;
    await store.refreshMemory(
      (previous, turns) => _api.summarize(owner, previous, turns),
      active: () => available,
    );
  }

  Future<void> initialize() async {
    if (loaded) return;
    try {
      await store.load();
      if (!available) return;
      privacyNoticeVisible = !store.privacyNoticeDismissed;
      loaded = true;
      _api.conversationId = () => store.conversationId;
      store.onSaved = _refreshMemory;
      unawaited(_refreshMemory());
      if (!_testing) {
        _reminderTimer = Timer.periodic(
          const Duration(seconds: 30),
          (_) => unawaited(syncReminders()),
        );
        _reminderEvents = ChatSessionNotifier.instance.realtimeEvents.listen((
          event,
        ) {
          if (event['type'] == 'ai.reminder') unawaited(syncReminders());
        });
        unawaited(syncReminders());
      }
    } catch (_) {
      failed = true;
    }
    changed();
  }

  Future<void> syncReminders() async {
    if (_testing ||
        !available ||
        !loaded ||
        busy ||
        recording ||
        calling ||
        _syncingReminders) {
      return;
    }
    _syncingReminders = true;
    final epoch = _epoch;
    try {
      final list = await _api.reminderRequest(owner, 'GET') as List;
      for (final item in list.whereType<Map>()) {
        if (!available || epoch != _epoch || busy || recording || calling) {
          return;
        }
        if (item['delivery'] != 'message' || item['status'] != 'ready') {
          continue;
        }
        final id = item['id'] as String;
        if (!store.messages.any((m) => m.id == id)) {
          final reply =
              await _api.reminderRequest(owner, 'GET', '/$id/audio') as Map;
          if (!available || epoch != _epoch) return;
          final name = await store.saveAudio(
            base64Decode(reply['audio'] as String),
          );
          if (!available || epoch != _epoch) return;
          store.messages.add(
            AiMessage(
              id: id,
              role: 'model',
              text: reply['text'] as String? ?? '',
              audio: name,
              language: reply['language'] as String? ?? '',
              createdAt: DateTime.parse(reply['createdAt'] as String),
            ),
          );
          store.messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          await store.save();
          changed();
        }
        // Acknowledge only after durable local storage; retries reuse the same ID.
        await _api.reminderRequest(owner, 'POST', '/$id/received');
      }
    } catch (_) {
      // Offline/older servers are retried on foreground refresh without breaking chat.
    } finally {
      _syncingReminders = false;
    }
  }

  void _accountChanged() {
    if (!available) {
      _epoch++;
      _webSearch.cancel();
      _imageSearch.cancel();
      _api.close();
      unawaited(_receivingStream?.close());
      unawaited(_stopReplyPlayback());
      unawaited(endCall());
      unawaited(cancelRecording());
    }
  }

  void _humanCallChanged() {
    if (DmCallNotifier.instance.isActive) {
      _replyPlaybackUnavailable = true;
      unawaited(_stopReplyPlayback());
      unawaited(endCall());
      unawaited(cancelRecording());
    }
  }

  Future<void> record() async {
    if (!canRecord) return;
    _recordStarting = true;
    final epoch = _epoch;
    try {
      // Stop only output. The committed socket continues to receive and save.
      _playbackRequest = null;
      _replyPlaybackUnavailable = true;
      await _stopReplyPlayback();
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
      // While the previous answer downloads, buffer the next recording locally.
      // Its new session is opened after that reply, with complete chat context.
      if (!busy) _voiceStream = _openVoiceStream(message, epoch);
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
    } finally {
      _recordStarting = false;
      changed();
    }
  }

  Future<void> _stopReplyPlayback() {
    final work = _replyAudioWork.then((_) async {
      if (!_replyAudioStarted) return;
      try {
        _replyPlayedFrames = await audio.invokeMethod<int>('playedFrames') ?? 0;
      } catch (_) {}
      try {
        await audio.invokeMethod<void>('stop');
      } finally {
        _replyAudioStarted = false;
      }
    });
    _replyAudioWork = work.catchError((Object _) {});
    return work;
  }

  AiVoiceStream _openVoiceStream(AiMessage message, int epoch) {
    late final AiVoiceStream stream;
    stream = AiVoiceStream(
      connect: () async => _api.voice(
        owner,
        store.context(excluding: message.id),
        message.id,
        hasMetBanteraAi: await store.hasMetBefore(),
      ),
      onToolCall: (call) async {
        if (!available || epoch != _epoch || !busy) {
          return {'unavailable': true};
        }
        return _search(
          call,
          voiceReply.ensure(message.language),
          () => available && epoch == _epoch && busy,
        );
      },
      onAudio: (bytes) async {
        if (!available || epoch != _epoch || !busy) return;
        voiceReply.addAudio(bytes.length, message.language);
        changed();
        _replyAudioWork = _replyAudioWork.then((_) async {
          if (!_replyPlaybackUnavailable) {
            try {
              if (!_replyAudioStarted) {
                await audio.invokeMethod<void>('startPlayback');
                _replyAudioStarted = true;
              }
              if (!_replyPlaybackUnavailable) {
                await audio.invokeMethod<void>('feed', bytes);
              }
            } catch (error) {
              // Playback is optional; receiving and saving the reply is not.
              // A system interruption must not destroy streamed audio/captions.
              _replyPlaybackUnavailable = true;
              _reportVoiceFailure(
                message,
                stream,
                'playback_failed',
                'playback',
                0,
                error: error,
              );
            }
          }
        });
        await _replyAudioWork;
        if (!store.hasMetBanteraAi) {
          unawaited(store.markMet().catchError((Object _) {}));
        }
      },
      onTranscript: (role, text) {
        if (!available || epoch != _epoch || !busy) return;
        if (role == 'user') {
          message.text += text;
        } else {
          voiceReply.addTranscript(text, message.language);
        }
        changed();
      },
      onReset: () async {
        voiceReply.resetAttempt();
        message.text = '';
        changed();
        if (_replyAudioStarted && !_replyPlaybackUnavailable) {
          try {
            await audio.invokeMethod<void>('clear');
          } catch (_) {
            _replyPlaybackUnavailable = true;
          }
        }
      },
    );
    return stream;
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
    changed();
  }

  Future<void> sendRecording() async {
    if (!recording) return;
    final epoch = _epoch;
    var stream = _voiceStream;
    final message = _recordMessage;
    _recordMessage = null;
    final previousReply = _replyFinished?.future;
    final elapsed = Stopwatch()..start();
    var phase = 'save';
    var savedReply = false;
    var ownsReply = false;
    _recordTimer.cancel();
    recording = false;
    _waitingToSend = true;
    changed();
    try {
      await _recorder.stop();
      await _recordEvents?.cancel();
      _recordEvents = null;
      // Keep uploading the recorder's final flush until stop has completed.
      if (identical(_voiceStream, stream)) _voiceStream = null;
      if (message == null || !available || epoch != _epoch) return;
      final pcm = _recordPcm.takeBytes();
      if (pcm.length < 320) return;
      await previousReply;
      if (!available || epoch != _epoch) return;
      busy = true;
      ownsReply = true;
      _replyFinished = Completer<void>();
      _replyPlaybackUnavailable = false;
      _replyPlayedFrames = 0;
      voiceReply.clear();
      if (stream == null) {
        stream = _openVoiceStream(message, epoch);
        stream.add(pcm);
      }
      _receivingStream = stream;
      _waitingToSend = false;
      changed();
      message.audio = await store.saveAudio(aiWave(pcm, 16000));
      if (!available || epoch != _epoch) return;
      store.messages.add(message);
      await store.save();
      changed();
      phase = 'reply';
      Map<String, dynamic>? reply;
      {
        try {
          reply = await stream.send(
            await (_voiceMetadata?.call() ??
                AiApiClient.metadata(
                  hasMetBanteraAi: await store.hasMetBefore(),
                )),
          );
        } catch (error) {
          if (stream.committed) rethrow;
          _reportVoiceFailure(
            message,
            stream,
            error is AiVoiceFailure ? error.code : 'connect_failed',
            'send',
            elapsed.elapsedMilliseconds,
          );
        }
      }
      if (!available || epoch != _epoch) return;
      if (reply == null) {
        // Older deployed servers and failed pre-send connections retain the safe
        // upload path. Never resubmit automatically once a stream was committed.
        await stream.close();
        await _reply(message);
      } else {
        phase = 'save';
        await _saveReply(message, reply, epoch, autoplay: false);
        savedReply = true;
        phase = 'playback';
        if (stream.outputBytes > 0) {
          if (_replyAudioStarted && !_replyPlaybackUnavailable) {
            try {
              await audio
                  .invokeMethod<void>('drain')
                  .timeout(const Duration(seconds: 95));
            } catch (error) {
              _replyPlaybackUnavailable = true;
              _reportVoiceFailure(
                message,
                stream,
                'playback_drain_failed',
                'playback',
                elapsed.elapsedMilliseconds,
                error: error,
              );
            }
          }
          if (available && epoch == _epoch) {
            // Count only the audio actually rendered, including an interruption.
            try {
              final played = _replyAudioStarted
                  ? await audio.invokeMethod<int>('playedFrames') ?? 0
                  : _replyPlayedFrames;
              final total = stream.outputBytes ~/ 2;
              if (total > 0) {
                await recordListened(
                  (activityWordCount(reply['outputText'] as String? ?? '') *
                          (played / total).clamp(0.0, 1.0))
                      .floor(),
                  message.language,
                );
              }
            } catch (_) {
              /* A playback statistic must not fail a saved reply. */
            }
          }
        }
      }
    } catch (error) {
      // Freeze the stream before snapshotting partial audio or writing history.
      try {
        await stream?.close();
      } catch (_) {}
      if (message != null) {
        _reportVoiceFailure(
          message,
          stream,
          error is AiVoiceFailure
              ? error.code
              : phase == 'playback'
              ? 'playback_drain_failed'
              : phase == 'save'
              ? 'save_failed'
              : 'send_failed',
          phase,
          elapsed.elapsedMilliseconds,
          error: error,
        );
      }
      if (ownsReply && available && epoch == _epoch) {
        final partialReply = voiceReply.message;
        final hasPartialReply =
            partialReply != null &&
            (partialReply.text.isNotEmpty ||
                partialReply.images.isNotEmpty ||
                (stream?.outputBytes ?? 0) > 0);
        failed = !savedReply && !hasPartialReply;
        if (message != null && store.messages.contains(message)) {
          message.failed = !savedReply && !hasPartialReply;
          // Keep the portion already heard. Failed model messages are excluded
          // from future model context and never offered as input for Retry.
          if (!savedReply && voiceReply.message != null) {
            String? audioName;
            try {
              final partial = stream?.partialAudio;
              if (partial != null) audioName = await store.saveAudio(partial);
            } catch (_) {
              /* Still retain the partial caption in memory. */
            }
            if (available && epoch == _epoch) {
              final partial = voiceReply.interrupted(audioName);
              if (partial != null) store.messages.add(partial);
            }
          }
          try {
            await store.save();
          } catch (_) {
            /* Retain visible messages. */
          }
        }
      }
    } finally {
      try {
        await stream?.close();
      } catch (_) {
        if (message != null) {
          _reportVoiceFailure(
            message,
            stream,
            'cleanup_failed',
            'cleanup',
            elapsed.elapsedMilliseconds,
          );
        }
      }
      if (identical(_voiceStream, stream)) _voiceStream = null;
      if (ownsReply) {
        _receivingStream = null;
        try {
          await _stopReplyPlayback();
        } catch (_) {}
        voiceReply.clear();
        busy = false;
        final finished = _replyFinished;
        _replyFinished = null;
        finished?.complete();
        _streamPendingRecording(epoch);
      } else {
        _waitingToSend = false;
      }
      changed();
    }
  }

  void _streamPendingRecording(int epoch) {
    final message = _recordMessage;
    if (available &&
        epoch == _epoch &&
        recording &&
        message != null &&
        _voiceStream == null) {
      _voiceStream = _openVoiceStream(message, epoch);
      _voiceStream!.add(_recordPcm.toBytes());
    }
  }

  void _reportVoiceFailure(
    AiMessage message,
    AiVoiceStream? stream,
    String code,
    String phase,
    int elapsedMs, {
    Object? error,
  }) {
    if (_testing || AuthSessionNotifier.instance.session?.cacheKey != owner) {
      return;
    }
    final detail = error == null ? null : AiVoiceFailure.from(code, error);
    unawaited(
      _api.reportVoiceFailure(owner, {
        'requestId': message.id,
        'code': code,
        'phase': phase,
        'inputBytes': stream?.inputBytes ?? 0,
        'outputBytes': stream?.outputBytes ?? 0,
        'elapsedMs': elapsedMs.clamp(0, 3600000),
        'committed': stream?.committed ?? false,
        'closeCode': stream?.closeCode,
        'errorType': detail?.errorType,
        'nativeCode': detail?.nativeCode,
      }),
    );
  }

  Future<void> retry(AiMessage message) async {
    if (busy ||
        recording ||
        _recordStarting ||
        _waitingToSend ||
        calling ||
        !available ||
        message.audio == null ||
        message.role != 'user') {
      return;
    }
    busy = true;
    _replyFinished = Completer<void>();
    _replyPlaybackUnavailable = false;
    final epoch = _epoch;
    failed = false;
    changed();
    try {
      await _reply(message);
    } finally {
      voiceReply.clear();
      busy = false;
      final finished = _replyFinished;
      _replyFinished = null;
      finished?.complete();
      _streamPendingRecording(epoch);
      changed();
    }
  }

  Future<void> _reply(AiMessage message) async {
    if (message.audio == null) return;
    final epoch = _epoch;
    final elapsed = Stopwatch()..start();
    var phase = 'reply';
    try {
      final reply = await _api.reply(
        owner: owner,
        history: store.context(excluding: message.id),
        audioPath: store.path(message.audio!),
        requestId: message.id,
        hasMetBanteraAi: await store.hasMetBefore(),
      );
      if (!available || epoch != _epoch) return;
      phase = 'save';
      await _saveReply(message, reply, epoch);
    } catch (error) {
      _reportVoiceFailure(
        message,
        null,
        phase == 'save' ? 'save_failed' : 'send_failed',
        phase,
        elapsed.elapsedMilliseconds,
        error: error,
      );
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
    final inputText = reply['inputText'] as String?;
    if (inputText != null && inputText.trim().isNotEmpty) {
      message.text = inputText;
    }
    // Credit the completed input independently of storing/playing the reply.
    unawaited(_countSpeech(message));
    final name = await store.saveAudio(base64Decode(reply['audio'] as String));
    if (!available || epoch != _epoch) return;
    final answer = voiceReply.complete(
      reply['outputText'] as String? ?? '',
      name,
      message.language,
    );
    store.messages.add(answer);
    await store.save();
    if (autoplay &&
        !_replyPlaybackUnavailable &&
        !recording &&
        !_recordStarting) {
      requestReplyPlayback(answer);
    }
    changed();
  }

  Future<void> _countSpeech(AiMessage message) async {
    // A completed utterance still counts if the call ends or this screen closes
    // while on-device language detection is finishing. Account changes do not.
    if (_testing ||
        AuthSessionNotifier.instance.session?.cacheKey != owner ||
        message.role != 'user') {
      return;
    }
    final userId = AuthSessionNotifier.instance.session?.userId;
    if (userId == null) return;
    final count = await AiSpokenWords.count(message.text, message.language);
    if (AuthSessionNotifier.instance.session?.cacheKey != owner || count == 0) {
      return;
    }
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
    if (_recordStarting ||
        _waitingToSend ||
        !available ||
        !loaded ||
        busy ||
        recording ||
        calling ||
        DmCallNotifier.instance.isActive) {
      return;
    }
    calling = true;
    if (!callKitManaged) _keepScreenAwake(true);
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
      final microphonePermission = callKitManaged
          ? await Permission.microphone.status
          : await Permission.microphone.request();
      if (!microphonePermission.isGranted) {
        throw StateError('Microphone denied');
      }
      if (!available || epoch != _epoch) return;
      _micEvents = microphone.receiveBroadcastStream().listen(
        (event) => _microphoneEvent(event, epoch),
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
      _callListening.clear();
      _queuedFrames = 0;
      _modelStartFrame = 0;
      _listeningTimer?.cancel();
      _listeningTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => unawaited(_pollListening()),
      );
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
      callbackId: callbackId,
      hasMetBanteraAi: await store.hasMetBefore(),
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
      await _saveTurn();
      await _pollListening(discard: true);
      await audio.invokeMethod<void>('clear');
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

  // Only captured PCM belongs in an active live turn. A background clock
  // clientContent packet interrupts Gemini even with turnComplete:false.
  // Initial/reconnect requests and each separate voice message still carry time;
  // the server's get_current_time tool provides the current clock during calls.
  void _microphoneEvent(dynamic event, int epoch) {
    if (event is Map) {
      if (available &&
          epoch == _epoch &&
          event['type'] == 'route' &&
          event['speaker'] is bool) {
        updateSpeakerRoute(event['speaker'] as bool);
      }
      return;
    }
    if (!connected || farewell || muted || !available || epoch != _epoch) {
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
    }
    if (_speech && _input.length < 16000 * 2 * 60) _input.add(bytes);
    _socket?.add(bytes);
  }

  @visibleForTesting
  void microphoneForTesting(dynamic event, WebSocket socket) {
    assert(_testing);
    _socket = socket;
    _microphoneEvent(event, _epoch);
  }

  @visibleForTesting
  Future<void> receiveCallEventForTesting(dynamic event) {
    assert(_testing);
    return _event(event, _epoch);
  }

  AiMessage _liveBubble() => _liveModelMessage ??= AiMessage(
    role: 'model',
    language: UserProfileNotifier.instance.learningLanguage ?? '',
  );

  Future<void> _event(dynamic event, int epoch) async {
    if (event is List<int>) {
      if (_output.length + event.length > 24000 * 2 * 90) {
        throw StateError('Audio too long');
      }
      _output.add(event);
      _liveBubble().durationMs = _output.length * 1000 ~/ 48000;
      changed();
      _queuedFrames += event.length ~/ 2;
      await audio.invokeMethod<void>('feed', Uint8List.fromList(event));
      if (!store.hasMetBanteraAi) {
        unawaited(store.markMet().catchError((Object _) {}));
      }
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
        if (const {
          'session_expired',
          'quota_exceeded',
          'response_timeout',
        }.contains(data['reason'])) {
          _renewRequested = true;
        }
      case 'error':
        failed = true;
        unawaited(endCall());
      case 'transcript':
        if (data['role'] == 'user') {
          draftUser += data['text'] as String? ?? '';
        } else {
          draftModel += data['text'] as String? ?? '';
          if (draftModel.isNotEmpty) _liveBubble().text = draftModel;
        }
      case 'turnComplete':
        await _saveTurn();
      case 'interrupted':
        await _saveModel();
        await _pollListening(discard: true);
        await audio.invokeMethod<void>('clear');
      case 'farewell':
        farewell = true;
        unawaited(_updateCallActivity());
        await _saveTurn();
        await _pollListening(discard: true);
        await audio.invokeMethod<void>('clear');
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

  Future<Map<String, dynamic>> _search(
    Map<String, dynamic> call,
    AiMessage message,
    bool Function() active,
  ) async {
    if (!active()) return {'unavailable': true};
    if (call['name'] != 'search_web') return {'unavailable': true};
    final args = call['args'];
    final query = args is Map ? args['query'] : null;
    if (query is! String || query.length > 240) return {'unavailable': true};
    final imageQuery = AiSearchCapabilities.imageQuery(query);
    if (imageQuery != null) return _findImages(imageQuery, message, active);
    message.webSearchQuery = query;
    message.webSearchStatus = 'searching';
    changed();
    final result = await _webSearch.search(query);
    if (!active()) return {'unavailable': true};
    message.webSearchStatus = result['unavailable'] == true
        ? 'unavailable'
        : 'complete';
    for (final item in result['results'] as List? ?? []) {
      final source = AiWebSource.fromJson(item);
      if (source != null &&
          message.sources.length < 5 &&
          !message.sources.any((s) => s.url == source.url)) {
        message.sources.add(source);
      }
    }
    changed();
    if (store.messages.contains(message)) await store.save();
    return result;
  }

  Future<Map<String, dynamic>> _findImages(
    String query,
    AiMessage message,
    bool Function() active,
  ) async {
    if (query.trim().isEmpty ||
        query.length > 240 ||
        message.images.length >= 4) {
      return {'unavailable': true};
    }
    message.imageSearchStatus = 'searching';
    changed();
    final delivered = <AiImageAttachment>[];
    try {
      final downloads = await _imageSearch.search(query);
      for (final download in downloads) {
        if (!active() || message.images.length >= 4) break;
        if (message.images.any(
          (i) => i.sourceUrl == download.image.sourceUrl,
        )) {
          continue;
        }
        final file = await store.saveImage(
          download.bytes,
          download.image.mime,
          active,
        );
        if (file == null || !active()) break;
        final image = download.image.saved(file);
        message.images.add(image);
        delivered.add(image);
      }
    } catch (_) {
      // An unavailable picture must not terminate the audio reply.
    } finally {
      message.imageSearchStatus = delivered.isEmpty
          ? 'unavailable'
          : 'complete';
      if (active()) {
        changed();
        if (store.messages.contains(message)) await store.save();
      }
    }
    return {
      'provider': 'Device web image search',
      'untrusted': true,
      'delivered': delivered.isNotEmpty && active(),
      'unavailable': delivered.isEmpty || !active(),
      'images': active()
          ? delivered.map((i) => i.toJson(local: false)).toList()
          : [],
    };
  }

  Future<void> _tools(List<Map> calls, int epoch) async {
    final destination = _socket;
    final responses = <Map<String, dynamic>>[];
    for (final call in calls) {
      Map<String, dynamic> result;
      try {
        result = call['name'] == 'search_web'
            ? await _search(
                Map<String, dynamic>.from(call),
                _liveBubble(),
                () =>
                    available &&
                    epoch == _epoch &&
                    calling &&
                    identical(_socket, destination),
              )
            : await AiDeviceData.read(
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
    final startFrame = _modelStartFrame;
    _modelStartFrame = _queuedFrames;
    draftModel = '';
    if (text.isNotEmpty ||
        pcm.isNotEmpty ||
        _liveModelMessage?.webSearchQuery != null ||
        _liveModelMessage?.imageSearchStatus != null) {
      final message = _liveBubble();
      message.text = text;
      message.durationMs = pcm.length * 1000 ~/ 48000;
      // Transfer the visible bubble synchronously before any disk/platform work.
      // Interruption or a slow/failed save must not remove the partial response.
      _liveModelMessage = null;
      store.messages.add(message);
      changed();
      if (pcm.isNotEmpty) {
        message.audio = await store.saveAudio(aiWave(pcm, 24000));
        _callListening.add(
          startFrame,
          _modelStartFrame,
          activityWordCount(text),
          message.language,
        );
      }
      await store.save();
      changed();
    }
  }

  // Route notifications describe the hardware; do not write them back and
  // fight the CallKit route picker (or a connected Bluetooth headset).
  void updateSpeakerRoute(bool enabled) {
    if (speaker == enabled) return;
    speaker = enabled;
    unawaited(_updateCallActivity());
    changed();
  }

  Future<void> setSpeaker() async {
    if (_speakerChanging || !calling) return;
    _speakerChanging = true;
    final epoch = _epoch;
    final requested = !speaker;
    try {
      final actual = await audio.invokeMethod<bool>('speaker', requested);
      if (available && calling && epoch == _epoch) {
        // iOS reports the real hardware route; older/Android bridges return null.
        updateSpeakerRoute(actual ?? requested);
      }
    } catch (_) {
      // Keep the last confirmed route; a failed switch must not end the call.
    } finally {
      _speakerChanging = false;
    }
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
    _keepScreenAwake(false);
    unawaited(_endCallActivity());
    AiCallbackNotifier.instance.aiActive = false;
    connected = false;
    _epoch++;
    _webSearch.cancel();
    _imageSearch.cancel();
    _elapsed.stop();
    _countdown?.cancel();
    _connectTimeout?.cancel();
    final socket = _socket;
    _socket = null;
    await _socketEvents?.cancel();
    _socketEvents = null;
    unawaited(socket?.close() ?? Future.value());
    _listeningTimer?.cancel();
    if (loaded) await _saveTurn();
    await _pollListening(discard: true);
    await _micEvents?.cancel();
    _micEvents = null;
    try {
      await audio.invokeMethod<void>('stop');
    } catch (_) {}
    changed();
  }

  Future<void> clear() async {
    _playbackRequest = null;
    _epoch++;
    _webSearch.cancel();
    _imageSearch.cancel();
    _api.close();
    _api = AiApiClient()..conversationId = () => store.conversationId;
    await _receivingStream?.close();
    await _replyFinished?.future;
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
    _replyPlaybackUnavailable = true;
    if (loaded && busy) {
      // Leaving is not a failed send. Keep captions already shown, and the
      // received audio, before invalidating callbacks or closing the socket.
      final partial = voiceReply.interrupted(null, failed: false);
      final bytes = _receivingStream?.partialAudio;
      if (partial != null &&
          (partial.text.isNotEmpty ||
              partial.images.isNotEmpty ||
              bytes != null)) {
        if (!store.messages.contains(partial)) store.messages.add(partial);
      }
      unawaited(
        store
            .save(audioMessage: partial, audioBytes: bytes)
            .catchError((Object _) {}),
      );
    }
    if (_testing) {
      unawaited(_receivingStream?.close());
      _disposed = true;
      super.dispose();
      return;
    }
    _disposed = true;
    _reminderTimer?.cancel();
    unawaited(_reminderEvents?.cancel());
    _epoch++;
    _webSearch.cancel();
    _imageSearch.cancel();
    _api.close();
    unawaited(_receivingStream?.close());
    unawaited(_stopReplyPlayback());
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
