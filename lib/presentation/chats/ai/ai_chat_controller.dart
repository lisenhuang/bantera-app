import '../../../core/apple_system_version.dart';
import '../../../core/ai_consent.dart';
import '../../../infrastructure/ai/ai_image_input.dart';
import '../../../infrastructure/ai/ai_vocabulary.dart';
import '../../../infrastructure/ai/ai_emoji_tool.dart';
import '../../../infrastructure/ai/ai_search_capabilities.dart';
import '../../../infrastructure/ai/ai_image_search.dart';
import '../../../infrastructure/ai/ai_web_search.dart';
import '../../../infrastructure/ai/ai_video_search.dart';
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
import '../../../infrastructure/ai/ai_formatted_text_tool.dart';
import '../../../infrastructure/translation_service.dart';

class _VoiceReplyJob {
  _VoiceReplyJob(this.input, this.epoch);
  final AiMessage input;
  final int epoch;
  final state = AiVoiceReplyState();
  final finished = Completer<void>();
  AiVoiceStream? stream;
  bool playbackAllowed = true;
  int playedFrames = 0;
  AiMessage? savedMessage;
  bool paused = false;
}

class AiChatController extends ChangeNotifier {
  static AiChatController? _chatSession;
  static AiChatController forChat() {
    final current = _chatSession;
    if (current != null &&
        current.available &&
        (current._viewAttached || current.busy || current._waitingToSend)) {
      return current;
    }
    current?.dispose();
    return _chatSession = AiChatController();
  }

  bool _viewAttached = true;
  void attachChat() {
    _viewAttached = true;
  }

  Future<void> detachChat() async {
    _viewAttached = false;
    _playbackRequest = null;
    _replyPlaybackUnavailable = true;
    for (final job in _replies) {
      job.playbackAllowed = false;
    }
    await _stopReplyPlayback();
    await cancelRecording();
    await endCall();
  }

  AiChatController({this.callKitManaged = false, this.callbackId})
    : owner = AuthSessionNotifier.instance.session!.cacheKey,
      store = AiHistoryStore(AuthSessionNotifier.instance.session!.cacheKey) {
    AuthSessionNotifier.instance.addListener(_accountChanged);
    AiConsent.instance.addListener(_consentChanged);
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
    AiWebSearch? webSearch,
    AiVocabulary? vocabulary,
    Future<Map<String, dynamic>> Function()? voiceMetadata,
  }) : owner = 'test',
       _testing = true {
    if (recorder != null) _recorder = recorder;
    if (api != null) _api = api;
    if (imageSearch != null) _imageSearch = imageSearch;
    if (webSearch != null) _webSearch = webSearch;
    _vocabulary = vocabulary;
    _voiceMetadata = voiceMetadata;
  }
  final bool callKitManaged;
  final String? callbackId;
  bool _testing = false;
  static const audio = MethodChannel('bantera/ai_audio');
  static const callActivity = MethodChannel('bantera/ai_call_activity');
  DateTime? _callEndsAt;
  bool _renewRequested = false;
  bool _callTransportReady = false;
  int _renewals = 0;
  bool _speakerChanging = false;
  static const microphone = EventChannel('bantera/ai_audio/input');
  final String owner;
  final AiHistoryStore store;
  AiVocabulary? _vocabulary;
  AiVocabulary get vocabulary => _vocabulary ??= AiVocabulary(owner);
  AiWebSearch _webSearch = AiWebSearch();
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
  AiVoiceStream? _voiceStream;
  _VoiceReplyJob? _recordJob, _foregroundReply;
  final _replies = <_VoiceReplyJob>[];
  bool _recordStarting = false, _waitingToSend = false;
  Future<void> _replyAudioWork = Future.value();
  bool _deletingMessage = false;
  bool _consentStopping = false;
  bool get canRecord =>
      !_consentStopping &&
      !_deletingMessage &&
      _endingCall == null &&
      available &&
      loaded &&
      !recording &&
      !_recordStarting &&
      !_waitingToSend &&
      _replies.length < 3 &&
      !calling &&
      (_testing ||
          (!DmCallNotifier.instance.isActive &&
              !AiCallbackNotifier.instance.aiActive));
  AiMessage? _recordMessage;
  StreamSubscription<Uint8List>? _recordEvents;
  final BytesBuilder _recordPcm = BytesBuilder(copy: false);
  bool _replyAudioStarted = false, _replyPlaybackUnavailable = false;
  final _idleVoiceReply = AiVoiceReplyState();
  AiVoiceReplyState get voiceReply =>
      _foregroundReply?.state ?? _idleVoiceReply;
  AiMessage? _liveModelMessage;
  bool get sendingVoice =>
      _waitingToSend ||
      _replies.any((j) => !j.state.received) ||
      (busy && _replies.isEmpty && !_idleVoiceReply.received);
  bool isReceiving(AiMessage message) =>
      _replies.any((j) => identical(j.state.message, message)) ||
      identical(_idleVoiceReply.message, message) ||
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

  bool isAutomaticReply(AiMessage message) {
    final job = _foregroundReply;
    // Playback controls belong to the native player, not the completed file.
    // The server may keep sending audio/captions while that player is paused.
    return job != null &&
        _replyAudioStarted &&
        _canPlay(job) &&
        (identical(job.state.message, message) ||
            identical(job.savedMessage, message));
  }

  bool isAutomaticReplyPaused(AiMessage message) =>
      isAutomaticReply(message) && _foregroundReply!.paused;
  bool _togglingReplyPlayback = false;
  Future<void> toggleReplyPlayback(AiMessage message) async {
    final job = _foregroundReply;
    if (_togglingReplyPlayback ||
        job == null ||
        !isAutomaticReply(message) ||
        !_canPlay(job)) {
      return;
    }
    _togglingReplyPlayback = true;
    try {
      final pause = !job.paused;
      await _replyAudioCommand<void>(
        pause ? 'pausePlayback' : 'resumePlayback',
      );
      if (identical(_foregroundReply, job)) job.paused = pause;
    } finally {
      _togglingReplyPlayback = false;
      changed();
    }
  }

  Future<void> stopAutomaticReplyPlayback() async {
    _replyPlaybackUnavailable = true;
    _foregroundReply?.playbackAllowed = false;
    await _stopReplyPlayback();
  }

  Future<void> _drainReplyPlayback(_VoiceReplyJob job) async {
    final timeout = Completer<void>();
    var playingSeconds = 0;
    // Pausing must not turn a fully downloaded reply into a playback timeout.
    final timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!job.paused && ++playingSeconds >= 95 && !timeout.isCompleted) {
        timeout.completeError(TimeoutException('Playback did not finish'));
      }
    });
    try {
      await Future.any([_replyAudioCommand<void>('drain'), timeout.future]);
    } finally {
      timer.cancel();
    }
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
  List<AiMessage> get messages {
    final result = [...store.messages];
    for (final job in _replies) {
      final reply = job.state.message;
      if (reply == null || result.contains(reply)) continue;
      final input = result.indexOf(job.input);
      result.insert(input < 0 ? result.length : input + 1, reply);
    }
    if (_idleVoiceReply.message != null) result.add(_idleVoiceReply.message!);
    if (_liveModelMessage != null) result.add(_liveModelMessage!);
    return result;
  }

  void _insertReply(_VoiceReplyJob job, AiMessage answer) {
    if (store.messages.contains(answer)) return;
    final index = store.messages.indexOf(job.input);
    store.messages.insert(
      index < 0 ? store.messages.length : index + 1,
      answer,
    );
  }

  Future<void> _closeReplies() async {
    await Future.wait([
      for (final job in _replies.toList())
        if (job.stream != null) job.stream!.close(),
    ]);
  }

  bool _jobActive(_VoiceReplyJob job) =>
      available && job.epoch == _epoch && _replies.contains(job);
  bool _canPlay(_VoiceReplyJob job) =>
      _jobActive(job) &&
      identical(_foregroundReply, job) &&
      job.playbackAllowed &&
      _viewAttached &&
      !_replyPlaybackUnavailable &&
      !recording &&
      !_recordStarting;

  void changed() {
    if (available) notifyListeners();
  }

  Future<void> _refreshMemory() async {
    if (_testing || !available || !await AiConsent.instance.isAllowed(owner)) {
      return;
    }
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
      privacyNoticeVisible = false; // Explicit consent replaces the old banner.
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
      _clearDraftImages();
      _epoch++;
      _webSearch.cancel();
      _imageSearch.cancel();
      _api.close();
      unawaited(_closeReplies());
      unawaited(_stopReplyPlayback());
      unawaited(endCall());
      unawaited(cancelRecording());
    }
  }

  void _consentChanged() {
    if (_testing || !available || AiConsent.instance.isKnownAllowed(owner)) {
      return;
    }
    _consentStopping = true;
    _epoch++;
    _webSearch.cancel();
    _imageSearch.cancel();
    _api.close();
    _api = AiApiClient()..conversationId = () => store.conversationId;
    // Invalidate callbacks and stop every outbound stream synchronously; do not
    // wait for playback, storage or another socket to finish closing first.
    unawaited(_socket?.close());
    unawaited(_voiceStream?.close());
    unawaited(_closeReplies());
    unawaited(
      Future.wait([cancelRecording(), endCall()])
          .whenComplete(() {
            _consentStopping = false;
            if (!available) return;
            busy = false;
            changed();
          })
          .catchError((Object _) => <void>[]),
    );
  }

  void _humanCallChanged() {
    if (DmCallNotifier.instance.isActive) {
      _replyPlaybackUnavailable = true;
      unawaited(_stopReplyPlayback());
      unawaited(endCall());
      unawaited(cancelRecording());
    }
  }

  final List<AiImageAttachment> _draftImages = [];
  List<AiImageAttachment> get draftImages => List.unmodifiable(_draftImages);
  bool preparingImages = false;
  bool get canEditImages => canRecord && !preparingImages;

  Future<void> attachImages(List<String> paths) async {
    if (!canEditImages) return;
    preparingImages = true;
    final epoch = _epoch;
    changed();
    try {
      for (final path in paths.take(
        AiImageInput.maxCount - _draftImages.length,
      )) {
        final prepared = await AiImageInput.prepare(path);
        final file = await store.saveImage(
          prepared.bytes,
          prepared.mime,
          () => available && epoch == _epoch && !_disposed,
        );
        if (file == null) return;
        _draftImages.add(
          AiImageAttachment(
            title: 'Image',
            url: '',
            sourceUrl: '',
            author: '',
            license: '',
            mime: prepared.mime,
            file: file,
            userAttached: true,
          ),
        );
      }
    } finally {
      preparingImages = false;
      changed();
    }
  }

  void removeDraftImage(AiImageAttachment image) {
    if (!canEditImages) return;
    _draftImages.remove(image);
    if (image.file != null) {
      unawaited(
        File(
          store.path(image.file!),
        ).delete().then<void>((_) {}).catchError((Object _) {}),
      );
    }
    changed();
  }

  Future<List<Map<String, String>>> _imagePayload(AiMessage message) async {
    return Future.wait(
      message.images
          .where((i) => i.userAttached)
          .map(
            (image) async => {
              'mimeType': image.mime,
              'data': base64Encode(
                await File(store.path(image.file!)).readAsBytes(),
              ),
            },
          ),
    );
  }

  Future<void> record() async {
    if (!canRecord || preparingImages) return;
    if (!_testing && !await AiConsent.instance.request()) return;
    if (!canRecord || preparingImages) return;
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
      message.images.addAll(_draftImages);
      _recordMessage = message;
      _recordPcm.clear();
      // Each recording has an independent transport; older replies keep arriving.
      final job = _VoiceReplyJob(message, epoch);
      _recordJob = job;
      _voiceStream = _openVoiceStream(job);
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

  Future<T?> _replyAudioCommand<T>(String method, [dynamic arguments]) =>
      audio.invokeMethod<T>(
        defaultTargetPlatform == TargetPlatform.iOS && method != 'startPlayback'
            ? 'playback:$method'
            : method,
        arguments,
      );

  Future<void> _stopReplyPlayback() {
    final work = _replyAudioWork.then((_) async {
      if (!_replyAudioStarted) return;
      try {
        final played = await _replyAudioCommand<int>('playedFrames') ?? 0;
        _foregroundReply?.playedFrames = played;
      } catch (_) {}
      try {
        await _replyAudioCommand<void>('stop');
      } finally {
        _replyAudioStarted = false;
      }
    });
    _replyAudioWork = work.catchError((Object _) {});
    return work;
  }

  AiVoiceStream _openVoiceStream(_VoiceReplyJob job) {
    final message = job.input;
    late final AiVoiceStream stream;
    stream = AiVoiceStream(
      requiresImages: message.images.isNotEmpty,
      requiresText: message.textRequest != null,
      connect: () async => _api.voice(
        owner,
        [
          ...store.context(excluding: message.id),
          for (final prior in _replies)
            if (prior != job &&
                (prior.state.message?.displayText.isNotEmpty ?? false))
              {
                'role': 'model',
                'text': prior.state.message!.displayText.substring(
                  0,
                  prior.state.message!.displayText.length.clamp(0, 4000),
                ),
              },
        ],
        message.id,
        hasMetBanteraAi: await store.hasMetBefore(),
        images: await _imagePayload(message),
        textOnly: message.textRequest != null,
      ),
      onToolCall: (call) async {
        if (!_jobActive(job)) {
          return {'unavailable': true};
        }
        if (call['name'] == AiFormattedTextTool.name) {
          return _formattedText(
            call['args'],
            job.savedMessage ?? job.state.ensure(message.language),
          );
        }
        if (call['name'] == AiEmojiTool.name) {
          return _emojis(call['args'], job.state.ensure(message.language));
        }
        if (call['name'] == AiVocabulary.toolName) {
          // A word-explanation confirmation is not permission to save a word.
          if (message.textRequest != null &&
              ![
                'stats',
                'latest',
                'quiz',
              ].contains((call['args'] as Map?)?['action'])) {
            return {
              'confirmationRequired': true,
              'instruction': 'Ask the learner first. Do not save yet.',
            };
          }
          return vocabulary.execute(
            Map<String, dynamic>.from(call['args'] as Map),
            conversationId: store.conversationId,
          );
        }
        return _search(
          call,
          job.state.ensure(message.language),
          () => _jobActive(job),
        );
      },
      onAudio: (bytes) async {
        if (!_jobActive(job)) return;
        job.state.addAudio(bytes.length, message.language);
        changed();
        _replyAudioWork = _replyAudioWork.then((_) async {
          if (_canPlay(job)) {
            try {
              if (!_replyAudioStarted) {
                await _replyAudioCommand<void>('startPlayback');
                _replyAudioStarted = true;
                changed();
              }
              if (_canPlay(job)) {
                await _replyAudioCommand<void>('feed', bytes);
              }
            } catch (error) {
              // Playback is optional; receiving and saving the reply is not.
              // A system interruption must not destroy streamed audio/captions.
              job.playbackAllowed = false;
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
        if (!_jobActive(job)) return;
        if (role == 'user') {
          if (message.textRequest == null) message.text += text;
        } else {
          job.state.addTranscript(text, message.language);
        }
        changed();
      },
      onReset: () async {
        if (!_jobActive(job)) return;
        job.state.resetAttempt();
        if (message.textRequest == null) message.text = '';
        changed();
        if (_replyAudioStarted && _canPlay(job)) {
          try {
            await _replyAudioCommand<void>('clear');
            if (job.paused) {
              await _replyAudioCommand<void>('pausePlayback');
            }
          } catch (_) {
            job.playbackAllowed = false;
          }
        }
      },
    );
    job.stream = stream;
    return stream;
  }

  Future<void> cancelRecording() async {
    if (!recording && _recordMessage == null && _voiceStream == null) return;
    _recordTimer.cancel();
    recording = false;
    final stream = _voiceStream;
    _voiceStream = null;
    _recordMessage = null;
    _recordJob = null;
    await _recorder.cancel();
    await _recordEvents?.cancel();
    _recordEvents = null;
    _recordPcm.clear();
    await stream?.close();
    changed();
  }

  Future<void> sendRecording() async {
    if (!recording) return;
    final job = _recordJob;
    final stream = _voiceStream;
    var preparing = true;
    _recordJob = null;
    _recordMessage = null;
    _recordTimer.cancel();
    recording = false;
    _waitingToSend = true;
    changed();
    try {
      await _recorder.stop();
      await _recordEvents?.cancel();
      _recordEvents = null;
      if (identical(_voiceStream, stream)) _voiceStream = null;
      final pcm = _recordPcm.takeBytes();
      if (job == null ||
          !available ||
          job.epoch != _epoch ||
          pcm.length < 320) {
        await stream?.close();
        return;
      }
      job.input.audio = await store.saveAudio(aiWave(pcm, 16000));
      if (!available || job.epoch != _epoch) {
        await stream?.close();
        return;
      }
      store.messages.add(job.input);
      await store.save();
      _draftImages.removeWhere((image) => job.input.images.contains(image));
      _activateReply(job);
      _waitingToSend = false;
      preparing = false;
      changed();
      await _receiveReply(job);
    } catch (error) {
      await stream?.close();
      if (job != null && available && job.epoch == _epoch) {
        job.input.failed = true;
        failed = true;
        _reportVoiceFailure(
          job.input,
          stream,
          'save_failed',
          'save',
          0,
          error: error,
        );
        try {
          await store.save();
        } catch (_) {}
      }
    } finally {
      if (preparing) _waitingToSend = false;
      changed();
    }
  }

  void _activateReply(_VoiceReplyJob job) {
    _replies.add(job);
    _foregroundReply = job;
    _replyPlaybackUnavailable = !_viewAttached;
    busy = true;
    failed = false;
  }

  Future<void> _receiveReply(_VoiceReplyJob job) async {
    final message = job.input;
    var stream = job.stream;
    final elapsed = Stopwatch()..start();
    var phase = 'reply';
    var saved = false;
    var heardText = '';
    try {
      stream ??= _openVoiceStream(job);
      Future<Map<String, dynamic>> send() async => stream!.send(
        await (_voiceMetadata?.call() ??
            AiApiClient.metadata(hasMetBanteraAi: await store.hasMetBefore())),
        text: message.textRequest,
      );
      Map<String, dynamic> reply;
      try {
        reply = await send();
      } catch (_) {
        if (stream.committed || !_jobActive(job)) rethrow;
        await stream.close();
        stream = _openVoiceStream(job);
        if (message.audio != null) {
          final wave = await File(store.path(message.audio!)).readAsBytes();
          stream.add(Uint8List.sublistView(wave, 44));
        }
        reply = await send();
      }
      if (!_jobActive(job)) return;
      if (reply['noSpeech'] == true) {
        await _discardSilentMessage(message, job);
        return;
      }
      heardText = reply['outputText'] as String? ?? '';
      phase = 'save';
      await _saveReply(message, reply, job.epoch, job: job, autoplay: false);
      saved = true;
      phase = 'playback';
      if (_replyAudioStarted && _canPlay(job)) {
        await _drainReplyPlayback(job);
      }
    } catch (error) {
      try {
        await stream?.close();
      } catch (_) {}
      _reportVoiceFailure(
        message,
        stream,
        error is AiVoiceFailure ? error.code : '${phase}_failed',
        phase,
        elapsed.elapsedMilliseconds,
        error: error,
      );
      if (_jobActive(job)) {
        final partial = saved ? null : job.state.interrupted(null);
        final audioBytes = stream?.partialAudio;
        heardText = partial?.text ?? heardText;
        final hasPartial =
            partial != null &&
            (partial.displayText.isNotEmpty ||
                partial.images.isNotEmpty ||
                partial.emojis.isNotEmpty ||
                audioBytes != null);
        message.failed = !saved && !hasPartial;
        if (identical(_foregroundReply, job)) failed = message.failed;
        if (hasPartial) _insertReply(job, partial);
        try {
          await store.save(
            audioMessage: hasPartial ? partial : null,
            audioBytes: hasPartial ? audioBytes : null,
          );
        } catch (_) {
          /* Keep the visible partial answer. */
        }
      }
    } finally {
      if (_jobActive(job) && stream != null && stream.outputBytes > 0) {
        try {
          final played = identical(_foregroundReply, job) && _replyAudioStarted
              ? await _replyAudioCommand<int>('playedFrames') ?? 0
              : job.playedFrames;
          await recordListened(
            (activityWordCount(heardText) *
                    (played / (stream.outputBytes ~/ 2)).clamp(0.0, 1.0))
                .floor(),
            message.language,
          );
        } catch (_) {
          /* Activity cannot fail a saved reply. */
        }
      }
      try {
        await stream?.close();
      } catch (_) {}
      if (identical(_foregroundReply, job)) {
        try {
          await _stopReplyPlayback();
        } catch (_) {}
        if (identical(_foregroundReply, job)) _foregroundReply = null;
      }
      job.state.clear();
      _replies.remove(job);
      busy = _replies.isNotEmpty;
      if (!job.finished.isCompleted) job.finished.complete();
      changed();
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

  bool get canSendText => canRecord && !busy;

  Future<void> explainWord({
    required String text,
    required String prompt,
    required String language,
  }) async {
    if (!canSendText || prompt.trim().isEmpty || prompt.length > 8000) return;
    final message = AiMessage(
      role: 'user',
      text: text,
      textRequest: prompt,
      language: language,
    );
    // Reserve before any await so duplicate taps cannot submit twice.
    busy = true;
    try {
      store.messages.add(message);
      await store.save();
    } catch (_) {
      message.failed = true;
      failed = true;
      return;
    } finally {
      busy = false;
      changed();
    }
    if (available) await retry(message);
  }

  Future<void> retry(AiMessage message) async {
    if (_deletingMessage ||
        busy ||
        recording ||
        _recordStarting ||
        _waitingToSend ||
        calling ||
        !available ||
        (message.audio == null && message.textRequest == null) ||
        message.role != 'user') {
      return;
    }
    final job = _VoiceReplyJob(message, _epoch);
    _replyPlaybackUnavailable = true;
    await _stopReplyPlayback();
    if (!available || job.epoch != _epoch) return;
    _activateReply(job);
    changed();
    try {
      final stream = _openVoiceStream(job);
      if (message.audio != null && message.textRequest == null) {
        final wave = await File(store.path(message.audio!)).readAsBytes();
        if (wave.length < 44 ||
            String.fromCharCodes(wave.sublist(0, 4)) != 'RIFF') {
          throw const FormatException('Invalid recording');
        }
        stream.add(Uint8List.sublistView(wave, 44));
      }
      await _receiveReply(job);
    } catch (_) {
      await job.stream?.close();
      message.failed = true;
      failed = true;
      _replies.remove(job);
      if (identical(_foregroundReply, job)) _foregroundReply = null;
      busy = _replies.isNotEmpty;
      if (!job.finished.isCompleted) job.finished.complete();
      await store.save();
      changed();
    }
  }

  Future<void> _discardSilentMessage(
    AiMessage message,
    _VoiceReplyJob job,
  ) async {
    // Silence is a cancelled recording, not a failed conversation turn. Do not
    // retain hallucinated captions or credit activity for it.
    store.messages.removeWhere((item) => item.id == message.id);
    if (_draftImages.isEmpty && !recording && !_recordStarting) {
      _draftImages.addAll(message.images);
    }
    job.state.clear();
    failed = false;
    await store.save();
    if (message.audio != null) {
      try {
        await File(store.path(message.audio!)).delete();
      } catch (_) {
        /* An orphaned local file must not surface a chat error. */
      }
    }
    changed();
  }

  Future<void> _saveReply(
    AiMessage message,
    Map<String, dynamic> reply,
    int epoch, {
    required _VoiceReplyJob job,
    bool autoplay = true,
  }) async {
    if (!available || epoch != _epoch) return;
    message.failed = false;
    final inputText = reply['inputText'] as String?;
    if (message.textRequest == null &&
        inputText != null &&
        inputText.trim().isNotEmpty) {
      message.text = inputText;
    }
    // Credit the completed input independently of storing/playing the reply.
    unawaited(_countSpeech(message));
    final name = await store.saveAudio(base64Decode(reply['audio'] as String));
    if (!available || epoch != _epoch) return;
    final answer = job.state.complete(
      reply['outputText'] as String? ?? '',
      name,
      message.language,
    );
    _insertReply(job, answer);
    job.savedMessage = answer;
    await store.save();
    if (autoplay && _canPlay(job) && !recording && !_recordStarting) {
      requestReplyPlayback(answer);
    }
    changed();
  }

  Future<void> _countSpeech(AiMessage message) async {
    // A completed utterance still counts if the call ends or this screen closes
    // while on-device language detection is finishing. Account changes do not.
    if (_testing ||
        message.textRequest != null ||
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
    if (!supportsBuiltInTranslation ||
        !Platform.isIOS ||
        message.displayText.trim().isEmpty ||
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
                  originalText: message.displayText,
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
    if (_consentStopping) return;
    if (!_testing) {
      // A locked-screen callback cannot obtain new consent.
      final allowed = callbackId != null
          ? await AiConsent.instance.isAllowed(owner)
          : await AiConsent.instance.request();
      if (!allowed) return;
    }
    if (_deletingMessage) return;
    if (_endingCall != null ||
        (!callKitManaged && AiCallbackNotifier.instance.aiActive)) {
      return;
    }
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
    _callTransportReady = false;
    farewell = false;
    if (!callKitManaged) muted = false;
    speaker = !callKitManaged;
    remaining = 540;
    _renewals = 0;
    _renewRequested = false;
    failed = false;
    final epoch = ++_epoch;
    _callEndsAt = null;
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
    _callTransportReady = false;
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
    if ((!connected && !_callTransportReady) ||
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

  void _firstCallAudio() {
    if (!calling) return;
    _connectTimeout?.cancel();
    final wasConnected = connected;
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
    if (!wasConnected) unawaited(_updateCallActivity());
  }

  Future<void> _event(dynamic event, int epoch) async {
    if (event is List<int>) {
      if (event.length <= 2) return;
      _firstCallAudio();
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
        // The transport is ready, but the greeting is not yet audible. Keep
        // Connecting and the original startup deadline until real audio arrives.
        _callTransportReady = true;
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
    final videoQuery = AiSearchCapabilities.videoQuery(query);
    if (videoQuery != null) return _findVideos(videoQuery, message, active);
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

  Future<Map<String, dynamic>> _findVideos(
    String query,
    AiMessage message,
    bool Function() active,
  ) async {
    if (query.isEmpty || query.length > 232 || message.videos.length >= 4) {
      return {'unavailable': true};
    }
    message.videoSearchStatus = 'searching';
    changed();
    final delivered = <AiVideoAttachment>[];
    try {
      final result = await _webSearch.search('$query video');
      if (!active()) return {'unavailable': true};
      for (final row in result['results'] as List? ?? []) {
        final video = AiVideoAttachment.fromJson(row);
        if (video == null || message.videos.any((v) => v.url == video.url)) {
          continue;
        }
        message.videos.add(video);
        delivered.add(video);
        if (delivered.length >= 2 || message.videos.length >= 4) break;
      }
      return {
        'provider': result['provider'],
        'untrusted': true,
        'metadataOnly': true,
        'delivered': delivered.isNotEmpty,
        'unavailable': delivered.isEmpty,
        'videos': delivered.map((v) => v.toJson()).toList(),
      };
    } catch (_) {
      return {'unavailable': true};
    } finally {
      message.videoSearchStatus = delivered.isEmpty
          ? 'unavailable'
          : 'complete';
      if (active()) {
        changed();
        if (store.messages.contains(message)) await store.save();
      }
    }
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

  Future<Map<String, dynamic>> _formattedText(
    dynamic args,
    AiMessage message,
  ) async {
    final result = AiFormattedTextTool.deliver(args, message);
    changed();
    if (store.messages.contains(message)) await store.save();
    return result;
  }

  Future<Map<String, dynamic>> _emojis(dynamic args, AiMessage message) async {
    final result = AiEmojiTool.deliver(args, message);
    changed();
    if (store.messages.contains(message)) await store.save();
    return result;
  }

  Future<void> _tools(List<Map> calls, int epoch) async {
    final destination = _socket;
    final responses = <Map<String, dynamic>>[];
    for (final call in calls) {
      Map<String, dynamic> result;
      try {
        if (!available || epoch != _epoch || !identical(_socket, destination)) {
          return;
        }
        result = call['name'] == AiFormattedTextTool.name
            ? await _formattedText(call['args'], _liveBubble())
            : call['name'] == AiEmojiTool.name
            ? await _emojis(call['args'], _liveBubble())
            : call['name'] == AiVocabulary.toolName
            ? await vocabulary.execute(
                Map<String, dynamic>.from(call['args'] as Map),
                conversationId: store.conversationId,
              )
            : call['name'] == 'search_web'
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
        _liveModelMessage?.imageSearchStatus != null ||
        (_liveModelMessage?.emojis.isNotEmpty ?? false) ||
        (_liveModelMessage?.formattedText?.isNotEmpty ?? false)) {
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

  Future<void>? _endingCall;
  Future<void> endCall() {
    if (_endingCall != null) return _endingCall!;
    if (!calling) return Future.value();
    final ending = _endCall();
    _endingCall = ending;
    return ending.whenComplete(() => _endingCall = null);
  }

  Future<void> _endCall() async {
    calling = false;
    _keepScreenAwake(false);
    unawaited(_endCallActivity());
    connected = false;
    _callTransportReady = false;
    _epoch++;
    _webSearch.cancel();
    _imageSearch.cancel();
    _elapsed.stop();
    _countdown?.cancel();
    _connectTimeout?.cancel();
    final socket = _socket;
    _socket = null;
    try {
      await _socketEvents?.cancel();
      _socketEvents = null;
      unawaited(socket?.close() ?? Future.value());
      _listeningTimer?.cancel();
      if (loaded) await _saveTurn();
      await _pollListening(discard: true);
    } finally {
      try {
        await _micEvents?.cancel();
      } finally {
        _micEvents = null;
        try {
          await audio.invokeMethod<void>('stop');
        } catch (_) {}
        if (!callKitManaged) AiCallbackNotifier.instance.aiActive = false;
        changed();
      }
    }
  }

  bool canDeleteMessage(AiMessage message) =>
      loaded &&
      available &&
      !_deletingMessage &&
      !busy &&
      !calling &&
      !recording &&
      !_recordStarting &&
      !_waitingToSend &&
      store.messages.contains(message);

  Future<void> deleteMessage(AiMessage message) async {
    if (!canDeleteMessage(message)) throw StateError('Message is in use');
    _deletingMessage = true;
    if (_playbackRequest?.id == message.id) _playbackRequest = null;
    changed();
    try {
      await store.deleteMessage(message);
      visibleTranslations.remove(message.id);
      translating.remove(message.id);
      translationFailed.remove(message.id);
    } finally {
      _deletingMessage = false;
      changed();
    }
  }

  Future<void> clear() async {
    _playbackRequest = null;
    _epoch++;
    _webSearch.cancel();
    _imageSearch.cancel();
    _api.close();
    _api = AiApiClient()..conversationId = () => store.conversationId;
    final replies = _replies.toList();
    await _closeReplies();
    await Future.wait(replies.map((job) => job.finished.future));
    await cancelRecording();
    await endCall();
    await _events.catchError((Object _) {});
    _draftImages.clear();
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

  void _clearDraftImages() {
    for (final image in _draftImages) {
      if (image.file != null &&
          !store.messages.any(
            (m) => m.images.any((i) => i.file == image.file),
          )) {
        unawaited(
          File(
            store.path(image.file!),
          ).delete().then<void>((_) {}).catchError((Object _) {}),
        );
      }
    }
    _draftImages.clear();
  }

  @override
  void dispose() {
    if (_disposed) return;
    if (identical(_chatSession, this)) _chatSession = null;
    _clearDraftImages();
    _replyPlaybackUnavailable = true;
    for (final job in _replies) {
      final partial = job.state.interrupted(null, failed: false);
      final bytes = job.stream?.partialAudio;
      if (partial != null) _insertReply(job, partial);
      if (loaded) {
        unawaited(
          store
              .save(audioMessage: partial, audioBytes: bytes)
              .catchError((Object _) {}),
        );
      }
    }
    if (_testing) {
      unawaited(_closeReplies());
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
    unawaited(_closeReplies());
    unawaited(_stopReplyPlayback());
    _recordTimer.cancel();
    _elapsed.stop();
    _countdown?.cancel();
    _connectTimeout?.cancel();
    AiConsent.instance.removeListener(_consentChanged);
    AuthSessionNotifier.instance.removeListener(_accountChanged);
    DmCallNotifier.instance.removeListener(_humanCallChanged);
    unawaited(endCall());
    unawaited(cancelRecording().whenComplete(() => _recorder.dispose()));
    super.dispose();
  }
}
