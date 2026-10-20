import '../../infrastructure/learning_language_catalog.dart';
import 'practice_transcript_feedback.dart';
import 'practice_header.dart';
import 'practice_level_menu.dart';
import 'practice_word_flight.dart';
import 'practice_translation_controller.dart';
import '../profile/daily_word_goal_section.dart';
import '../../domain/activity/word_activity.dart';
import '../chats/chat_audio_waveform.dart';
import '../../infrastructure/quick_practice_audio_cache.dart';
import '../../domain/practice/practice_playback_intent.dart';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../../core/ai_callback_notifier.dart';
import '../../core/ai_consent.dart';
import '../../core/daily_goal_celebration.dart';
import '../../core/practice_completion_store.dart';
import '../../core/word_activity_notifier.dart';
import '../../domain/activity/listening_word_tracker.dart';
import '../../domain/practice/practice_answer_matcher.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/dm_call_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/practice_audio_route.dart';
import '../../infrastructure/video_processing_service.dart';
import '../../l10n/app_localizations.dart';

class QuickPracticeScreen extends StatefulWidget {
  const QuickPracticeScreen({super.key, required this.active})
    : previewExercise = null,
      previewFeedback = null;
  @visibleForTesting
  const QuickPracticeScreen.preview({
    super.key,
    required this.previewExercise,
    this.previewFeedback,
    this.active = true,
  });
  final bool active;
  final Map<String, dynamic>? previewExercise;
  final Map<String, dynamic>? previewFeedback;
  @override
  State<QuickPracticeScreen> createState() => _QuickPracticeScreenState();
}

class _QuickPracticeScreenState extends State<QuickPracticeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final _player = AudioPlayer();
  late final _recorder = AudioRecorder();
  late final AnimationController _pulse;
  StreamSubscription<void>? _completion;
  StreamSubscription<Duration>? _position, _duration;
  int _audioWords = 0, _audioCredited = 0, _audioDurationMs = 0;
  String? _audioOwner, _audioLocale;
  String _playbackEvent = '';
  final _microphoneAnchor = GlobalKey();
  final _goalAnchor = GlobalKey();
  final _wordFlight = PracticeWordFlight();
  final _translations = PracticeTranslationController();
  String _translationTarget = '';

  final _autoplay = PracticePlaybackIntent();
  final _cueProgress = ValueNotifier<double>(0);
  QuickPracticeAudioCache? _audioCache;
  String? _loadingAudio;
  int _audioGeneration = 0;
  bool _confirmingNext = false, _goalSettingsOpen = false;
  bool _translationRevealed = false;
  String? _currentLevel, _practiceLevel;
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (widget.previewExercise == null) {
      practiceInteractionBusy.value =
          _busy ||
          _recording ||
          _playing != null ||
          _loadingAudio != null ||
          _confirmingNext ||
          _goalSettingsOpen ||
          _translations.loading;
    }
  }

  void _creditListening(int total) {
    final delta = total - _audioCredited;
    if (delta <= 0 || _audioOwner == null) return;
    _audioCredited = total;
    unawaited(
      WordActivityNotifier.instance
          .record(
            listened: delta,
            ownerId: _audioOwner,
            language: _audioLocale,
            speechEventId: 'practice-listen:$_playbackEvent:$total',
          )
          .catchError((_) {}),
    );
  }

  Timer? _poll, _recordLimit;
  Timer? _completionDayTimer;
  int _completionGeneration = 0;
  Map<String, dynamic>? _exercise, _feedback;
  String? _owner, _locale, _error, _recordPath, _replayPath, _playing;
  String _requestId = const Uuid().v4();
  String? _previousId;
  bool _loading = false, _recording = false, _busy = false, _allowed = false;
  int _epoch = 0;
  DateTime? _waitingSince;
  AppLocalizations get l => AppLocalizations.of(context)!;
  bool get _callActive =>
      DmCallNotifier.instance.isActive ||
      AiCallbackNotifier.instance.aiActive ||
      AiCallbackNotifier.instance.ringing;
  bool get _canUseAudio =>
      mounted &&
      widget.active &&
      !_goalSettingsOpen &&
      !_callActive &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.previewExercise != null) {
      _exercise = widget.previewExercise;
      _currentLevel =
          _exercise?['currentLevel'] as String? ??
          _exercise?['level'] as String?;
      _practiceLevel = _exercise?['level'] as String?;
      _translationRevealed = _exercise?['translationUsed'] == true;
      _feedback = widget.previewFeedback;
      final previewLocale = _exercise?['locale'] as String? ?? 'en-NZ';
      _locale = supportsAudioDialogueLanguage(previewLocale)
          ? previewLocale
          : null;
      _allowed = true;
      return;
    }
    _translations.addListener(_translationsChanged);
    WidgetsBinding.instance.addObserver(this);
    UserProfileNotifier.instance.addListener(_profileChanged);
    AuthSessionNotifier.instance.addListener(_profileChanged);
    AiConsent.instance.addListener(_consentChanged);
    DmCallNotifier.instance.addListener(_callChanged);
    AiCallbackNotifier.instance.addListener(_callChanged);
    _duration = _player.onDurationChanged.listen(
      (duration) => _audioDurationMs = duration.inMilliseconds,
    );
    _position = _player.onPositionChanged.listen((position) {
      if (_playing != null &&
          _audioDurationMs > 0 &&
          _player.state == PlayerState.playing) {
        if (_playing == 'cue') {
          _cueProgress.value = (position.inMilliseconds / _audioDurationMs)
              .clamp(0.0, 1.0);
        }
        _creditListening(
          (_audioWords * position.inMilliseconds / _audioDurationMs)
              .floor()
              .clamp(0, _audioWords),
        );
      }
    });
    _completion = _player.onPlayerComplete.listen((_) {
      if (_playing == 'cue') _cueProgress.value = 1;
      if (_playing != null) _creditListening(_audioWords);
      if (mounted) setState(() => _playing = null);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _profileChanged());
  }

  @override
  void didUpdateWidget(covariant QuickPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active) {
      _poll?.cancel();
      unawaited(_stopAudio());
    } else if (!oldWidget.active) {
      unawaited(_refreshCompleted());
      if (_exercise == null && _allowed) {
        _waitingSince = null;
        unawaited(_load());
      }
      _requestTranslations();
    }
  }

  void _profileChanged() {
    final owner = AuthSessionNotifier.instance.session?.cacheKey;
    final savedLocale = UserProfileNotifier.instance.learningLanguage;
    final locale =
        savedLocale != null && supportsAudioDialogueLanguage(savedLocale)
        ? savedLocale
        : null;
    final profile = UserProfileNotifier.instance;
    final target =
        [profile.translationLanguage, profile.nativeLanguage, l.localeName]
            .whereType<String>()
            .map((value) => value.trim())
            .firstWhere((value) => value.isNotEmpty);
    if (_owner == owner && _locale == locale) {
      if (_translationTarget != target) {
        _translationTarget = target;
        _translations.clear();
        _requestTranslations();
      }
      return;
    }
    _translationTarget = target;
    unawaited(_discardReplay());
    _translations.clear();
    _epoch++;
    _poll?.cancel();
    unawaited(_stopAudio());
    unawaited(_audioCache?.dispose());
    _audioCache = null;
    setState(() {
      _currentLevel = null;
      _practiceLevel = null;
      _owner = owner;
      _locale = locale;
      _exercise = null;
      _translationRevealed = false;
      _feedback = null;
      _requestId = const Uuid().v4();
      _previousId = null;
      _error = null;
      _loading = false;
      _busy = false;
      _waitingSince = null;
      _allowed = false;
    });
    unawaited(_checkConsent());
    unawaited(_refreshCompleted());
  }

  Future<void> _refreshCompleted({String? exerciseId}) async {
    if (widget.previewExercise != null) return;
    _completionDayTimer?.cancel();
    final generation = ++_completionGeneration, epoch = _epoch;
    final owner = AuthSessionNotifier.instance.session?.userId;
    final locale = _locale;
    if (owner == null || locale == null) return;
    try {
      await PracticeCompletionStore.instance.today(
        owner: owner,
        language: locale,
        completedExercise: exerciseId,
      );
      if (!mounted || epoch != _epoch || generation != _completionGeneration) {
        return;
      }
    } catch (_) {
      // Storage failure must not change the answer result or interrupt audio.
    } finally {
      if (mounted && epoch == _epoch && generation == _completionGeneration) {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day + 1);
        _completionDayTimer = Timer(
          midnight.difference(now),
          () => unawaited(_refreshCompleted()),
        );
      }
    }
  }

  Future<void> _checkConsent() async {
    final epoch = _epoch, owner = _owner;
    if (owner == null) return;
    final allowed = await AiConsent.instance.isAllowed(owner);
    if (!mounted || epoch != _epoch) return;
    setState(() => _allowed = allowed);
    if (allowed && widget.active && _exercise == null) await _load();
  }

  void _consentChanged() {
    if (_owner != null && !AiConsent.instance.isKnownAllowed(_owner!)) {
      _epoch++;
      unawaited(_discardReplay());
      _poll?.cancel();
      unawaited(_stopAudio());
      setState(() {
        _allowed = false;
        _loading = false;
        _busy = false;
      });
    }
  }

  void _callChanged() {
    if (_callActive) {
      unawaited(_stopAudio());
    } else {
      _requestTranslations();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _poll?.cancel();
      unawaited(_stopAudio());
    } else if (widget.active && _allowed) {
      unawaited(_refreshCompleted());
      if (_exercise == null) {
        _waitingSince = null;
        unawaited(_load());
      }
      _requestTranslations();
    }
  }

  Future<void> _start() async {
    if (!await AiConsent.instance.request() || !mounted) return;
    setState(() {
      _allowed = true;
      _waitingSince = null;
      _error = null;
    });
    await _load();
  }

  Future<Map<String, dynamic>> _api(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final token = AuthSessionNotifier.instance.session?.accessToken;
    if (token == null) throw const AiConsentRequired();
    return AuthApiClient.instance.quickPractice(
      path: path,
      payload: payload,
      accessToken: token,
    );
  }

  Future<void> _load() async {
    if (widget.previewExercise != null) return;
    if (_loading || !_allowed || _locale == null || !widget.active) return;
    final epoch = _epoch;
    _waitingSince ??= DateTime.now();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api('next', {
        'requestId': _requestId,
        'locale': _locale,
        'previousId': _previousId,
        'deferLevelScoring': true,
        'useSelectedLevel': true,
      });
      if (!mounted || epoch != _epoch) return;
      _currentLevel =
          response['currentLevel'] as String? ?? response['level'] as String?;
      _practiceLevel =
          response['practiceLevel'] as String? ?? response['level'] as String?;
      if (response['status'] == 'ready') {
        unawaited(_audioCache?.dispose());
        final cache = _audioCache = QuickPracticeAudioCache();
        _cueProgress.value = 0;
        for (final url in [
          response['cueAudioUrl'] as String,
          ...(response['choices'] as List).map((c) => c['audioUrl'] as String),
        ]) {
          unawaited(cache.prepare(url));
        }
        setState(() {
          _exercise = response;
          _translationRevealed = response['translationUsed'] == true;
          _feedback = null;
          _loading = false;
          _waitingSince = null;
        });
        _requestTranslations();
        if (_autoplay.take(_requestId) && _canUseAudio) {
          unawaited(_play('cue', response['cueAudioUrl'] as String));
        }
      } else {
        setState(() => _loading = false);
        if (DateTime.now().difference(_waitingSince!) >
            const Duration(minutes: 3)) {
          setState(() => _error = l.quickUnavailable);
        } else if (widget.active) {
          _poll = Timer(const Duration(seconds: 4), _load);
        }
      }
    } catch (_) {
      if (mounted && epoch == _epoch) {
        setState(() {
          _loading = false;
          _error = l.quickUnavailable;
        });
      }
    }
  }

  Future<void> _play(String id, String url) async {
    if (!_canUseAudio || _recording || _busy) return;
    _autoplay.cancel();
    final generation = ++_audioGeneration;
    final epoch = _epoch;
    bool current() =>
        _canUseAudio && epoch == _epoch && generation == _audioGeneration;
    try {
      if (_playing == id || _loadingAudio == id) {
        setState(() {
          _playing = null;
          _loadingAudio = null;
        });
        await _player.stop();
        return;
      }
      setState(() {
        _playing = null;
        _loadingAudio = id;
      });
      await _player.stop();
      final path = id == 'recording'
          ? _replayPath
          : await _audioCache?.prepare(url);
      if (id == 'recording' && path == null) return;
      if (!current()) return;
      await PracticeAudioRoute.prepare();
      if (!current()) return;
      _audioWords = activityWordCount(
        id == 'recording'
            ? (_feedback?['transcript'] as String? ?? '')
            : id == 'cue'
            ? _exercise!['cue'] as String
            : ((_exercise!['choices'] as List)[int.parse(id.substring(6))]
                      as Map)['text']
                  as String,
      );
      _audioCredited = 0;
      _audioDurationMs = 0;
      _audioOwner = AuthSessionNotifier.instance.session?.userId;
      _audioLocale = _locale;
      _playbackEvent = const Uuid().v4();
      if (id == 'cue') _cueProgress.value = 0;
      setState(() {
        _playing = id;
        _loadingAudio = null;
      });
      await _player.play(
        path == null ? UrlSource(url) : DeviceFileSource(path),
      );
    } catch (_) {
      if (current()) {
        setState(() {
          _playing = null;
          _loadingAudio = null;
        });
        _notice(l.practiceAudioError);
      }
    }
  }

  void _translationsChanged() {
    if (mounted) setState(() {});
  }

  void _requestTranslations({bool retry = false}) {
    final exercise = _exercise;
    if (widget.previewExercise != null ||
        exercise == null ||
        !_translationRevealed ||
        !_allowed ||
        !_canUseAudio ||
        _recording ||
        _busy ||
        _confirmingNext) {
      return;
    }
    unawaited(
      _translations.load(
        source: exercise['locale'] as String? ?? _locale ?? '',
        target: _translationTarget,
        texts: {
          'cue': exercise['cue'] as String,
          for (var i = 0; i < (exercise['choices'] as List).length; i++)
            'option$i': (exercise['choices'] as List)[i]['text'] as String,
        },
        canStart: () =>
            _canUseAudio && !_recording && !_busy && !_confirmingNext,
        retry: retry,
      ),
    );
  }

  Widget _translationLine(String id) {
    if (!_translationRevealed) return const SizedBox.shrink();
    final text =
        widget.previewExercise?['translations']?[id] as String? ??
        _translations.translations[id];
    final failed = _translations.failed && text == null;
    final target = _translationTarget.toLowerCase().split(RegExp('[-_]')).first;
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text ??
                  (failed
                      ? l.practiceTranslationUnavailableForCue
                      : l.practiceTranslating),
              key: ValueKey('practice-translation-$id'),
              textDirection: text == null
                  ? null
                  : (['ar', 'he', 'fa', 'ur'].contains(target)
                        ? TextDirection.rtl
                        : TextDirection.ltr),
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFBDBDC7)
                    : const Color(0xFF60616C),
              ),
            ),
          ),
          if (_translations.failed && id == 'cue')
            IconButton(
              onPressed: _recording || _busy
                  ? null
                  : () => _requestTranslations(retry: true),
              tooltip: l.compareTryAgain,
              icon: const Icon(Icons.refresh, size: 18),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _revealTranslations() async {
    if (_translationRevealed ||
        _busy ||
        _recording ||
        _confirmingNext ||
        _exercise == null) {
      return;
    }
    final epoch = _epoch, id = _exercise!['id'];
    setState(() => _busy = true);
    try {
      await _stopAudio();
      if (!mounted || epoch != _epoch) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.quickShowTranslation),
          content: Text(l.quickTranslationHint),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              key: const ValueKey('practice-confirm-translation'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l.quickShowTranslation),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted ||
          epoch != _epoch ||
          _exercise?['id'] != id ||
          !widget.active) {
        return;
      }
      // Persist exclusion before revealing any hint. It survives relaunches and
      // excludes answers already given during this unfinished exercise.
      if (widget.previewExercise == null) await _api('$id/translation', {});
      if (!mounted || epoch != _epoch || _exercise?['id'] != id) return;
      setState(() => _translationRevealed = true);
    } catch (_) {
      if (mounted && epoch == _epoch) _notice(l.quickUnavailable);
    } finally {
      if (mounted && epoch == _epoch) {
        setState(() => _busy = false);
        _requestTranslations();
      }
    }
  }

  Future<void> _stopAudio() async {
    _wordFlight.cancel();
    _autoplay.cancel();
    _audioGeneration++;
    if (widget.previewExercise != null) return;
    _recordLimit?.cancel();
    try {
      await _player.stop();
      if (_recording) await _recorder.cancel();
    } catch (_) {}
    _pulse.stop();
    final path = _recordPath;
    _recordPath = null;
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _recording = false;
        _playing = null;
        _loadingAudio = null;
      });
    }
  }

  Future<void> _discardReplay() async {
    final path = _replayPath;
    _replayPath = null;
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  Future<void> _record() async {
    if (_busy || _exercise == null) return;
    if (_recording) {
      await _submit();
      return;
    }
    if (!_canUseAudio) {
      _notice(l.quickCallActive);
      return;
    }
    _audioGeneration++;
    _autoplay.cancel();
    final epoch = _epoch;
    setState(() {
      _busy = true;
      _loadingAudio = null;
    });
    try {
      await AiConsent.instance.requireCurrent();
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        if (mounted) {
          _notice(l.compareMicrophoneDeniedPermanent);
          setState(() => _error = l.compareMicrophoneDeniedPermanent);
        }
        return;
      }
      await _player.stop();
      final directory = await getTemporaryDirectory();
      if (!_canUseAudio || epoch != _epoch) return;
      final path = '${directory.path}/practice-${const Uuid().v4()}.wav';
      _recordPath = path;
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      if (!_canUseAudio || epoch != _epoch) {
        await _recorder.cancel();
        return;
      }
      await _discardReplay();
      if (!mounted || epoch != _epoch) return;
      HapticFeedback.lightImpact();
      setState(() {
        _recording = true;
        _playing = null;
        _feedback = null;
        _error = null;
      });
      if (mounted && !MediaQuery.of(context).disableAnimations) {
        _pulse.repeat(reverse: true);
      }
      _recordLimit = Timer(const Duration(seconds: 30), _submit);
    } catch (_) {
      if (mounted && epoch == _epoch) _notice(l.compareCouldNotStartRecording);
    } finally {
      if (mounted && epoch == _epoch) {
        setState(() => _busy = false);
        _requestTranslations();
      }
    }
  }

  Future<void> _submit() async {
    if (_busy || !_recording) return;
    final epoch = _epoch, exerciseId = _exercise!['id'];
    final path = _recordPath;
    _recordPath = null;
    _recordLimit?.cancel();
    _pulse.stop();
    setState(() {
      _busy = true;
      _recording = false;
    });
    String? heard;
    var spoken = 0;
    final creditOwner = AuthSessionNotifier.instance.session?.userId;
    final creditLocale = _locale;
    List<String> uncertain = [];
    try {
      await _recorder.stop();
      if (path == null) throw StateError('Missing recording');
      if (!mounted || epoch != _epoch || _exercise?['id'] != exerciseId) return;
      _replayPath = path;
      final transcript = await VideoProcessingService.instance
          .transcribeRecordedAudio(
            inputFile: File(path),
            localeIdentifier: _locale!,
            allowAutoCorrection: false,
          );
      heard = transcript.transcriptText;
      if (!mounted || epoch != _epoch || !widget.active) return;
      spoken = activityWordCount(transcript.transcriptText);
      uncertain = transcript.words
          .where((w) => w.confidence > 0 && w.confidence < .5)
          .map((w) => w.text)
          .take(20)
          .toList();
      final choices = (_exercise!['choices'] as List)
          .map((choice) => choice['text'] as String)
          .toList();
      final selected = PracticeAnswerMatcher.match(
        transcript.transcriptText,
        choices,
        _locale!,
        uncertainWords: uncertain,
      );
      if (selected == null) {
        setState(
          () => _feedback = {
            'outcome': 'unclear',
            'transcript': transcript.transcriptText,
            'uncertainWords': uncertain,
          },
        );
        return;
      }
      final result = await _api('$exerciseId/answer', {
        'attemptId': const Uuid().v4(),
        'transcript': transcript.transcriptText,
        'recognition': uncertain.isEmpty
            ? null
            : 'Uncertain words: ${uncertain.join(', ')}',
      });
      if (!mounted || epoch != _epoch) return;
      // The same anchor holds the progress ring or the Set goal button.
      if (spoken > 0 && _canUseAudio) {
        await _wordFlight.show(
          context,
          _microphoneAnchor,
          _goalAnchor,
          outcome: result['outcome'] as String?,
        );
      }
      if (!mounted || epoch != _epoch) return;
      setState(
        () => _feedback = {
          ...result,
          'transcript': transcript.transcriptText,
          'uncertainWords': uncertain,
        },
      );
      if (result['outcome'] == 'correct') {
        HapticFeedback.mediumImpact();
        await _refreshCompleted(exerciseId: exerciseId as String);
      }
    } on AuthApiException catch (error) {
      if (!mounted || epoch != _epoch) return;
      if (error.code == 'practice_retired' || error.statusCode == 404) {
        // A server content refresh invalidated the current clip. Fetch a fresh
        // exercise instead of asking the learner to repeat an obsolete answer.
        await _advance();
      } else {
        setState(
          () => _feedback = {
            'outcome': 'unclear',
            'transcript': heard ?? '',
            'uncertainWords': uncertain,
          },
        );
      }
    } catch (_) {
      if (mounted && epoch == _epoch) {
        setState(
          () => _feedback = {
            'outcome': 'unclear',
            'transcript': heard ?? '',
            'uncertainWords': uncertain,
          },
        );
      }
    } finally {
      // All recognized speaking counts, including incorrect/unclear replies
      // and answer-request failures. Only the confirmed correct result animates.
      if (spoken > 0) {
        await WordActivityNotifier.instance
            .record(
              spoken: spoken,
              ownerId: creditOwner,
              language: creditLocale,
              speechEventId: 'practice-speak:${const Uuid().v4()}',
            )
            .catchError((_) {});
      }
      if (path != null && path != _replayPath) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
      if (mounted && epoch == _epoch) {
        setState(() => _busy = false);
        _requestTranslations();
      }
    }
  }

  Future<void> _showGoalSettings() async {
    if (_goalSettingsOpen || _recording || _busy || _confirmingNext) return;
    setState(() => _goalSettingsOpen = true);
    await _stopAudio();
    if (!mounted) return;
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const DailyWordGoalScreen()),
      );
    } finally {
      if (mounted) {
        setState(() => _goalSettingsOpen = false);
        _requestTranslations();
      }
    }
  }

  Future<void> _selectLevel(String selected) async {
    if (_recording ||
        _busy ||
        _confirmingNext ||
        _loading ||
        _currentLevel == null) {
      return;
    }
    if (selected == (_exercise?['level'] ?? _practiceLevel)) return;
    final epoch = _epoch;
    setState(() => _confirmingNext = true);
    _poll?.cancel();
    await _stopAudio();
    if (!mounted || epoch != _epoch) return;
    try {
      final confirmed = await confirmPracticeLevel(
        context,
        selected: selected,
        current: _currentLevel!,
      );
      if (!confirmed || !mounted || epoch != _epoch) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !widget.active || epoch != _epoch) return;
      if (widget.previewExercise != null) {
        setState(() {
          _practiceLevel = selected;
          _exercise = {
            ..._exercise!,
            'level': selected,
            'reviewMode': selected != _currentLevel,
          };
          _feedback = null;
        });
        return;
      }
      final state = await _api('level', {'locale': _locale, 'level': selected});
      if (!mounted || epoch != _epoch) return;
      _currentLevel = state['currentLevel'] as String;
      _practiceLevel = state['practiceLevel'] as String;
      await _advance(autoplay: true);
    } on AuthApiException catch (error) {
      if (mounted && epoch == _epoch) {
        _notice(
          error.code == 'practice_level_locked'
              ? l.quickLevelLocked
              : l.quickUnavailable,
        );
      }
    } catch (_) {
      if (mounted && epoch == _epoch) _notice(l.quickUnavailable);
    } finally {
      if (mounted) {
        setState(() => _confirmingNext = false);
        _requestTranslations();
        if (_exercise == null && widget.active && epoch == _epoch) {
          unawaited(_load());
        }
      }
    }
  }

  Future<void> _next() async {
    if (_confirmingNext || _busy || _recording || _exercise == null) return;
    final epoch = _epoch, exercise = _exercise;
    setState(() => _confirmingNext = true);
    try {
      await _stopAudio();
      if (!mounted || epoch != _epoch) return;
      if (_feedback?['outcome'] != 'correct') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.quickSkipTitle),
            content: Text(l.quickSkipMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.quickSkipAction),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        // MainScaffold deactivates Practice while this dialog covers it.
        // Navigator.pop completes before the parent rebuild supplies active=true.
        // Wait for that rebuild, then still reject a real tab/account change.
        await WidgetsBinding.instance.endOfFrame;
      }
      if (!mounted ||
          epoch != _epoch ||
          exercise != _exercise ||
          !widget.active) {
        return;
      }
      await _advance(autoplay: true);
    } finally {
      if (mounted) {
        setState(() => _confirmingNext = false);
        _requestTranslations();
      }
    }
  }

  Future<void> _advance({bool autoplay = false}) async {
    final epoch = _epoch;
    await _stopAudio();
    if (!mounted || epoch != _epoch) return;
    await _discardReplay();
    if (!mounted || epoch != _epoch) return;
    _translations.clear();
    setState(() {
      _previousId = _exercise?['id'] as String?;
      _requestId = const Uuid().v4();
      if (autoplay) _autoplay.next(_requestId);
      _exercise = null;
      _translationRevealed = false;
      _feedback = null;
      _waitingSince = null;
      _error = null;
    });
    await _load();
  }

  @override
  void dispose() {
    _wordFlight.cancel();
    unawaited(_discardReplay());
    _completionDayTimer?.cancel();
    _completionGeneration++;
    _translations.removeListener(_translationsChanged);
    _translations.dispose();
    _autoplay.cancel();
    _audioGeneration++;
    _cueProgress.dispose();
    unawaited(_audioCache?.dispose());
    if (widget.previewExercise != null) {
      _pulse.dispose();
      super.dispose();
      return;
    }
    _epoch++;
    _poll?.cancel();
    _recordLimit?.cancel();
    _completion?.cancel();
    _position?.cancel();
    _duration?.cancel();
    practiceInteractionBusy.value = false;
    WidgetsBinding.instance.removeObserver(this);
    UserProfileNotifier.instance.removeListener(_profileChanged);
    AuthSessionNotifier.instance.removeListener(_profileChanged);
    AiConsent.instance.removeListener(_consentChanged);
    DmCallNotifier.instance.removeListener(_callChanged);
    AiCallbackNotifier.instance.removeListener(_callChanged);
    _player.dispose();
    _recorder.dispose();
    _pulse.dispose();
    final path = _recordPath;
    if (path != null) {
      unawaited(File(path).delete().catchError((_) => File(path)));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), c = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final exercise = _exercise;
    final level = exercise?['level'] ?? _practiceLevel;
    final hasCorrectAnswer =
        exercise != null && _feedback?['outcome'] == 'correct';
    final showLevel = const [
      'A1',
      'A2',
      'B1',
      'B2',
      'C1',
      'C2',
    ].contains(level);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: widget.previewExercise != null
            ? PracticeHeader(
                goalAnchor: _goalAnchor,
                goal: null,
                today: const WordTotals(),
                level: showLevel ? level as String : null,
                currentLevel: _currentLevel,
                onLevelSelected:
                    _recording || _busy || _confirmingNext || _loading
                    ? null
                    : _selectLevel,
                onGoalPressed: _showGoalSettings,
              )
            : ListenableBuilder(
                listenable: WordActivityNotifier.instance,
                builder: (context, _) => PracticeHeader(
                  goalAnchor: _goalAnchor,
                  goal: WordActivityNotifier.instance.dailyGoal,
                  today: WordActivityNotifier.instance
                      .summaryFor(_locale)
                      .today,
                  level: showLevel ? level as String : null,
                  currentLevel: _currentLevel,
                  onLevelSelected:
                      _recording || _busy || _confirmingNext || _loading
                      ? null
                      : _selectLevel,
                  onGoalPressed: _recording || _busy || _confirmingNext
                      ? null
                      : _showGoalSettings,
                ),
              ),
      ),
      bottomNavigationBar: hasCorrectAnswer
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(top: BorderSide(color: c.outlineVariant)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const ValueKey('practice-pinned-next'),
                          onPressed:
                              !widget.active ||
                                  _busy ||
                                  _recording ||
                                  _confirmingNext
                              ? null
                              : _next,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  l.quickNext,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    l.quickInstruction,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: c.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (exercise?['reviewMode'] == true &&
                      _currentLevel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l.quickReviewMode(_currentLevel!),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (!_allowed || _locale == null)
                    _empty(
                      icon: CupertinoIcons.waveform,
                      title: _locale == null
                          ? l.quickChooseLanguage
                          : l.quickInstruction,
                      detail: l.quickSpeakHint,
                      action: _locale == null ? null : _start,
                      button: l.quickStart,
                    )
                  else if (exercise == null)
                    _empty(
                      icon: _error == null
                          ? CupertinoIcons.sparkles
                          : CupertinoIcons.wifi_exclamationmark,
                      title: _error ?? l.quickPreparing,
                      detail: '',
                      action: _error == null
                          ? null
                          : () {
                              _waitingSince = null;
                              _load();
                            },
                      button: l.compareTryAgain,
                      loading: _error == null,
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: dark
                              ? [
                                  const Color(0xFF312654),
                                  const Color(0xFF24203C),
                                ]
                              : [
                                  const Color(0xFFEEE8FF),
                                  const Color(0xFFF5F0FF),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: c.primary.withValues(alpha: .12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.chat_bubble_2,
                                color: c.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l.quickCue1,
                                  style: TextStyle(
                                    color: c.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _playButton(
                                'cue',
                                exercise['cueAudioUrl'] as String,
                                c.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            exercise['cue'] as String,
                            textDirection: _textDirection,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                              letterSpacing: -.4,
                            ),
                          ),
                          _translationLine('cue'),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<double>(
                            valueListenable: _cueProgress,
                            builder: (context, progress, _) =>
                                ChatAudioWaveform(
                                  animateProgress: true,
                                  progress: progress,
                                  receiving: false,
                                  audioKey: exercise['cueAudioUrl'] as String,
                                  loadAudioPath: _audioCache == null
                                      ? null
                                      : () async {
                                          final path = await _audioCache!
                                              .prepare(
                                                exercise['cueAudioUrl']
                                                    as String,
                                              );
                                          if (path == null) {
                                            throw StateError(
                                              'Audio unavailable',
                                            );
                                          }
                                          return path;
                                        },
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (!_translationRevealed)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          key: const ValueKey('practice-show-translation'),
                          onPressed: _busy || _recording || _confirmingNext
                              ? null
                              : _revealTranslations,
                          icon: const Icon(Icons.translate, size: 18),
                          label: Text(l.quickShowTranslation),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _translationRevealed
                            ? l.quickTranslationExcluded
                            : l.quickTranslationHint,
                        key: const ValueKey('practice-translation-scoring'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: c.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Text(
                      l.quickCue2,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < 2; i++) ...[
                      _choice(
                        i,
                        Map<String, dynamic>.from(
                          (exercise['choices'] as List)[i],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.primary.withValues(
                            alpha: _recording ? .08 + _pulse.value * .08 : .06,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 76,
                            height: 76,
                            key: _microphoneAnchor,
                            child: FilledButton(
                              key: const ValueKey('practice-record-button'),
                              onPressed: _busy ? null : _record,
                              style: FilledButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                                backgroundColor: _recording
                                    ? c.error
                                    : c.primary,
                              ),
                              child: _busy
                                  ? SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: c.primary,
                                      ),
                                    )
                                  : Icon(
                                      _recording
                                          ? CupertinoIcons.stop_fill
                                          : CupertinoIcons.mic_fill,
                                      size: 30,
                                      semanticLabel: _recording
                                          ? l.practiceStopRecording
                                          : l.quickSpeak,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _busy
                          ? l.quickChecking
                          : _recording
                          ? l.compareStatusRecording
                          : _feedback?['outcome'] == 'correct'
                          ? l.quickAgain
                          : l.quickSpeak,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!_recording && !_busy)
                      Text(
                        l.quickSpeakHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 18),
                    if (_feedback != null) _result(),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: TextStyle(color: c.error)),
                      ),
                    if (_error == l.compareMicrophoneDeniedPermanent)
                      TextButton(
                        onPressed: openAppSettings,
                        child: Text(l.compareOpenIphoneSettings),
                      ),
                    if (!_recording && !_busy && !hasCorrectAnswer)
                      _feedback != null
                          ? FilledButton.icon(
                              onPressed: _confirmingNext ? null : _next,
                              icon: const Icon(
                                CupertinoIcons.arrow_right,
                                size: 18,
                              ),
                              label: Text(l.quickNext),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            )
                          : TextButton(
                              onPressed: _confirmingNext ? null : _next,
                              child: Text(l.quickNext),
                            ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextDirection get _textDirection =>
      ['ar', 'he', 'fa', 'ur'].contains(_locale?.split('-').first)
      ? TextDirection.rtl
      : TextDirection.ltr;
  Widget _playButton(String id, String url, Color color) =>
      IconButton.filledTonal(
        onPressed: _recording || _busy ? null : () => _play(id, url),
        tooltip: _playing == id ? l.practiceStop : l.practiceListenCarefully,
        style: IconButton.styleFrom(
          backgroundColor: color.withValues(alpha: .1),
          foregroundColor: color,
          minimumSize: const Size(48, 48),
        ),
        icon: _loadingAudio == id
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _playing == id
                    ? CupertinoIcons.stop_fill
                    : CupertinoIcons.speaker_2_fill,
                size: 20,
              ),
      );
  Widget _choice(int index, Map<String, dynamic> choice) {
    final c = Theme.of(context).colorScheme;
    final selected = _feedback?['choice'] == index;
    final correct = _feedback?['outcome'] == 'correct';
    final accent = correct ? const Color(0xFF008266) : const Color(0xFFB96A17);
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _notice(l.quickSpeakHint),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? accent : c.outlineVariant.withValues(alpha: .6),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withValues(alpha: .12)
                      : c.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: selected
                    ? Icon(
                        correct
                            ? CupertinoIcons.checkmark
                            : CupertinoIcons.arrow_uturn_left,
                        size: 15,
                        color: accent,
                      )
                    : Text(
                        index == 0 ? 'A' : 'B',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: c.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      choice['text'] as String,
                      textDirection: _textDirection,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(height: 1.4),
                    ),
                    _translationLine('option$index'),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _playButton(
                'option$index',
                choice['audioUrl'] as String,
                c.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _result() {
    final outcome = _feedback!['outcome'];
    final correct = outcome == 'correct', unclear = outcome == 'unclear';
    final c = Theme.of(context).colorScheme;
    final color = correct ? const Color(0xFF008266) : c.primary;
    return Semantics(
      key: const ValueKey('practice-feedback'),
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correct
                  ? l.quickCorrect
                  : unclear
                  ? l.quickUnclear
                  : l.quickIncorrect,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? c.onSurface
                    : color,
              ),
            ),
            PracticeTranscriptFeedback(
              onReplay: _replayPath == null
                  ? null
                  : () => _play('recording', ''),
              replayEnabled: !_busy && !_recording && !_confirmingNext,
              replaying: _playing == 'recording',
              replayLoading: _loadingAudio == 'recording',
              transcript: _feedback!['transcript'] as String? ?? '',
              choices: (_exercise!['choices'] as List)
                  .map((c) => c['text'] as String)
                  .toList(),
              locale: _locale ?? 'en',
              choice: _feedback!['choice'] as int?,
              uncertainWords:
                  (_feedback!['uncertainWords'] as List?)?.cast<String>() ?? [],
            ),
            if ((_feedback!['explanation'] as String? ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _feedback!['explanation'] as String,
                  textDirection: _textDirection,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _empty({
    required IconData icon,
    required String title,
    required String detail,
    VoidCallback? action,
    required String button,
    bool loading = false,
  }) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 44),
      decoration: BoxDecoration(
        color: c.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: .09),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 42, color: c.primary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(detail, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          if (loading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          if (action != null)
            FilledButton(onPressed: action, child: Text(button)),
        ],
      ),
    );
  }
}
