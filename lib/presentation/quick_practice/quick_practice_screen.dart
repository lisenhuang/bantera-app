import 'practice_record_control.dart';
import 'practice_recording_layout.dart';
import 'practice_pronunciation_controller.dart';
import 'practice_pronunciation_text.dart';
import '../../core/practice_review_service.dart';
import 'practice_level_celebration.dart';
import '../../core/apple_system_version.dart';
import '../discover/discover_screen.dart';
import '../../infrastructure/learning_language_catalog.dart';
import 'practice_transcript_feedback.dart';
import 'practice_header.dart';
import 'saved_practice_screen.dart';
import 'saved_practice_confirmation.dart';
import '../../infrastructure/saved_practice_store.dart';
import 'practice_level_menu.dart';
import 'practice_word_flight.dart';
import 'practice_translation_controller.dart';
import 'practice_translation_dialogs.dart';
import 'practice_word_text.dart';
import '../practice/subtitle_word_tokens.dart';
import '../chats/ai/ai_chat_screen.dart';
import '../../infrastructure/ai/ai_word_explanation.dart';
import '../../infrastructure/translation_service.dart';
import '../chats/chat_audio_waveform.dart';
import '../../infrastructure/quick_practice_audio_cache.dart';
import '../../infrastructure/last_snapshot_cache.dart';
import 'dart:convert';
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
import '../../core/auth_session_notifier.dart';
import '../../core/dm_call_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/practice_audio_route.dart';
import '../../infrastructure/video_processing_service.dart';
import '../../l10n/app_localizations.dart';

class QuickPracticeScreen extends StatefulWidget {
  const QuickPracticeScreen({
    super.key,
    required this.active,
    required this.goalTabAnchor,
  }) : previewExercise = null,
       previewFeedback = null,
       previewPlayer = null,
       previewSavedStore = null,
       previewApi = null,
       previewPronunciation = null,
       previewTranslation = null;
  @visibleForTesting
  const QuickPracticeScreen.preview({
    super.key,
    required this.previewExercise,
    this.previewFeedback,
    this.active = true,
    this.previewPlayer,
    this.previewSavedStore,
    this.previewApi,
    this.previewPronunciation,
    this.previewTranslation,
  }) : goalTabAnchor = null;
  final PracticePronunciationController? previewPronunciation;
  final PracticeTranslationController? previewTranslation;
  final bool active;
  final GlobalKey? goalTabAnchor;
  final Map<String, dynamic>? previewExercise;
  final Map<String, dynamic>? previewFeedback;
  final AudioPlayer? previewPlayer;
  final SavedPracticeStore? previewSavedStore;
  final Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)?
  previewApi;
  @override
  State<QuickPracticeScreen> createState() => _QuickPracticeScreenState();
}

class _QuickPracticeScreenState extends State<QuickPracticeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final _player = widget.previewPlayer ?? AudioPlayer();
  double _playbackSpeed = 1.0;
  bool _paused = false, _audioCommandBusy = false;
  late final _recorder = AudioRecorder();
  late final AnimationController _pulse;
  StreamSubscription<void>? _completion;
  StreamSubscription<Duration>? _position, _duration;
  int _audioWords = 0, _audioCredited = 0, _audioDurationMs = 0;
  String? _audioOwner, _audioLocale;
  String _playbackEvent = '';
  final _microphoneAnchor = GlobalKey();
  final _wordFlight = PracticeWordFlight();
  late final _translations =
      widget.previewTranslation ?? PracticeTranslationController();
  late final _pronunciation =
      widget.previewPronunciation ?? PracticePronunciationController();
  String _translationTarget = '';

  final _autoplay = PracticePlaybackIntent();
  final _cueProgress = ValueNotifier<double>(0);
  QuickPracticeAudioCache? _audioCache;
  String? _loadingAudio;
  int _audioGeneration = 0;
  bool _confirmingNext = false;
  bool _translationRevealed = false;
  String? _currentLevel, _practiceLevel;
  Map<String, dynamic>? _levelStates;
  String? _highestUnlockedLevel;

  void _readLevelStates(Map<String, dynamic>? data) {
    _levelStates = (data?['levelStates'] as Map?)?.cast<String, dynamic>();
    _highestUnlockedLevel = data?['highestUnlockedLevel'] as String?;
  }

  ({String before, String after})? _pendingLevelUp;
  bool _celebratingLevel = false;
  Map<String, dynamic>? _savedSource;
  ({
    Map<String, dynamic>? exercise,
    Map<String, dynamic>? feedback,
    String? currentLevel,
    String? practiceLevel,
    bool translationRevealed,
  })?
  _beforeSaved;
  String? get _exerciseLocale {
    final locale = _exercise?['locale'] as String? ?? _locale;
    return locale != null && supportsAudioDialogueLanguage(locale)
        ? locale
        : null;
  }

  Set<String> _savedIds = {};
  SavedPracticeStore get _savedStore =>
      widget.previewSavedStore ?? SavedPracticeStore.instance;
  bool _saving = false, _savedLoaded = false;
  int _savedGeneration = 0;
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (widget.previewExercise == null) {
      practiceInteractionBusy.value =
          _busy ||
          _recording ||
          (_playing != null && !_paused) ||
          _loadingAudio != null ||
          _confirmingNext ||
          _celebratingLevel ||
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
  ({Object exercise, String part, SubtitleWordToken token})? _selectedWord;
  bool _loading = false, _recording = false, _busy = false, _allowed = false;
  bool _pinRecordingLayout = false;
  bool _validatingCachedPractice = false;
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
      !_validatingCachedPractice &&
      !_callActive &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    _pronunciation.addListener(_pronunciationChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncPronunciation();
    });
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.previewExercise != null) {
      _exercise = widget.previewExercise;
      _readLevelStates(_exercise);
      _currentLevel =
          _exercise?['currentLevel'] as String? ??
          _exercise?['level'] as String?;
      _practiceLevel = _exercise?['level'] as String?;
      _translationRevealed =
          (_exercise?['level'] == 'A0' ||
          _exercise?['translationUsed'] == true);
      _feedback = widget.previewFeedback;
      final previewLocale = _exercise?['locale'] as String? ?? 'en-NZ';
      _locale = supportsAudioDialogueLanguage(previewLocale)
          ? previewLocale
          : null;
      _allowed = true;
      if (widget.previewSavedStore != null) {
        _owner = AuthSessionNotifier.instance.session?.cacheKey;
        unawaited(_refreshSaved());
      }
      if (widget.previewPlayer != null) _listenToPlayer();
      return;
    }
    _translations.addListener(_translationsChanged);
    WidgetsBinding.instance.addObserver(this);
    UserProfileNotifier.instance.addListener(_profileChanged);
    AuthSessionNotifier.instance.addListener(_profileChanged);
    AiConsent.instance.addListener(_consentChanged);
    DmCallNotifier.instance.addListener(_callChanged);
    AiCallbackNotifier.instance.addListener(_callChanged);
    _listenToPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _profileChanged());
  }

  void _listenToPlayer() {
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
      if (mounted) {
        setState(() {
          _playing = null;
          _paused = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant QuickPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPronunciation();
    if (!widget.active) {
      _poll?.cancel();
      unawaited(_stopAudio());
    } else if (!oldWidget.active) {
      unawaited(_refreshCompleted());
      if (_exercise == null && _allowed) {
        _waitingSince = null;
        unawaited(_restoreAndLoad());
      }
      _requestTranslations();
      unawaited(_showPendingLevelUp());
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
    final target = [profile.nativeLanguage, l.localeName]
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
    _pendingLevelUp = null;
    _epoch++;
    _poll?.cancel();
    unawaited(_stopAudio());
    unawaited(_audioCache?.dispose());
    _audioCache = null;
    setState(() {
      _beforeSaved = null;
      _savedSource = null;
      _currentLevel = null;
      _readLevelStates(null);
      _practiceLevel = null;
      _owner = owner;
      _savedIds = {};
      _savedLoaded = false;
      _locale = locale;
      _exercise = null;
      _validatingCachedPractice = false;
      _selectedWord = null;
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
    _syncPronunciation();
    unawaited(_checkConsent());
    unawaited(_refreshCompleted());
    unawaited(_refreshSaved());
  }

  Future<void> _refreshSaved() async {
    final owner = _owner;
    final generation = ++_savedGeneration;
    if (owner == null) return;
    try {
      final entries = await _savedStore.load(owner);
      if (!mounted || owner != _owner || generation != _savedGeneration) return;
      setState(() {
        _savedIds = entries.map((entry) => entry['id'] as String).toSet();
        _savedLoaded = true;
      });
    } catch (_) {
      if (mounted && owner == _owner && generation == _savedGeneration) {
        _notice(l.quickSavedError);
      }
    }
  }

  Future<void> _toggleSaved() async {
    final owner = _owner, exercise = _savedSource ?? _exercise;
    if (owner == null || exercise == null || _saving || !_savedLoaded) return;
    final epoch = _epoch;
    final id = exercise['id'] as String;
    final saved = !_savedIds.contains(id);
    setState(() => _saving = true);
    try {
      if (!saved) {
        final confirmed = await confirmSavedPracticeRemoval(
          context,
          cue: exercise['cue'] as String,
        );
        if (!confirmed || !mounted || owner != _owner || epoch != _epoch) {
          return;
        }
      }
      await _savedStore.setSaved(
        owner: owner,
        exercise: {...exercise, 'locale': _exerciseLocale},
        saved: saved,
      );
      if (mounted && owner == _owner) {
        await _refreshSaved();
        if (mounted && owner == _owner) {
          _notice(saved ? l.quickSaved : l.quickUnsave);
        }
      }
    } catch (_) {
      if (mounted && owner == _owner) _notice(l.quickSavedError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openSavedPractice() async {
    final owner = _owner;
    if (owner == null || _recording || _busy || _confirmingNext) return;
    await _stopAudio();
    if (!mounted || owner != _owner) return;
    final selected = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/practice/saved'),
        builder: (_) => SavedPracticeScreen(owner: owner, store: _savedStore),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || owner != _owner) return;
    await _refreshSaved();
    if (selected != null && mounted && owner == _owner && _allowed) {
      await _reviewSaved(selected);
    }
  }

  Future<void> _reviewSaved(Map<String, dynamic> entry) async {
    final epoch = ++_epoch;
    _poll?.cancel();
    _autoplay.cancel();
    setState(() {
      _busy = true;
      _loading = false;
    });
    try {
      final response = await _api('${entry['id']}/review', {});
      if (!mounted || epoch != _epoch || !_allowed) return;
      await _stopAudio();
      await _discardReplay();
      if (!mounted || epoch != _epoch || !_allowed) return;
      _beforeSaved ??= (
        exercise: _exercise,
        feedback: _feedback,
        currentLevel: _currentLevel,
        practiceLevel: _practiceLevel,
        translationRevealed: _translationRevealed,
      );
      _translations.clear();
      setState(() {
        _savedSource = entry;
        _validatingCachedPractice = false;
        _exercise = response;
        _feedback = null;
        _selectedWord = null;
        _readLevelStates(response);
        _currentLevel = response['currentLevel'] as String?;
        _practiceLevel = response['level'] as String?;
        _translationRevealed = response['level'] == 'A0';
        _error = null;
      });
      _prepareExerciseAudio();
      unawaited(_refreshCompleted());
    } catch (_) {
      if (mounted && epoch == _epoch) _notice(l.quickSavedError);
    } finally {
      if (mounted && epoch == _epoch) {
        setState(() => _busy = false);
        _requestTranslations();
        if (_exercise == null && widget.active) unawaited(_load());
      }
    }
  }

  void _prepareExerciseAudio() {
    unawaited(_audioCache?.dispose());
    final cache = _audioCache = QuickPracticeAudioCache();
    _cueProgress.value = 0;
    final exercise = _exercise;
    if (exercise == null) return;
    for (final url in [
      exercise['cueAudioUrl'] as String,
      ...(exercise['choices'] as List).map((c) => c['audioUrl'] as String),
    ]) {
      unawaited(cache.prepare(url));
    }
  }

  Future<void> _refreshCompleted({String? exerciseId}) async {
    if (widget.previewExercise != null) return;
    _completionDayTimer?.cancel();
    final generation = ++_completionGeneration, epoch = _epoch;
    final owner = AuthSessionNotifier.instance.session?.userId;
    final locale = _exerciseLocale;
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

  String? get _practiceCacheScope =>
      _owner == null || _locale == null ? null : jsonEncode([_owner, _locale]);

  Future<void> _restoreLastPractice() async {
    final scope = _practiceCacheScope, epoch = _epoch;
    if (scope == null ||
        !_allowed ||
        _exercise != null ||
        widget.previewExercise != null) {
      return;
    }
    final cached =
        LastSnapshotCache.practice.peek(scope) ??
        await LastSnapshotCache.practice.read(scope);
    if (!mounted ||
        epoch != _epoch ||
        scope != _practiceCacheScope ||
        !_allowed ||
        _exercise != null ||
        cached == null) {
      return;
    }
    setState(() {
      _exercise = cached;
      _validatingCachedPractice = true;
      _readLevelStates(cached);
      _currentLevel =
          cached['currentLevel'] as String? ?? cached['level'] as String?;
      _practiceLevel =
          cached['practiceLevel'] as String? ?? cached['level'] as String?;
      _translationRevealed =
          cached['level'] == 'A0' || cached['translationUsed'] == true;
    });
  }

  void _cachePractice(Map<String, dynamic> exercise) {
    final scope = _practiceCacheScope;
    if (scope != null &&
        _savedSource == null &&
        widget.previewExercise == null) {
      unawaited(LastSnapshotCache.practice.save(scope, exercise));
    }
  }

  Future<void> _restoreAndLoad() async {
    final epoch = _epoch;
    await _restoreLastPractice();
    if (mounted && epoch == _epoch && _allowed) await _load();
  }

  Future<void> _checkConsent() async {
    final epoch = _epoch, owner = _owner;
    if (owner == null) return;
    final allowed = await AiConsent.instance.isAllowed(owner);
    if (!mounted || epoch != _epoch) return;
    setState(() => _allowed = allowed);
    if (allowed && widget.active && _exercise == null) {
      await _restoreLastPractice();
      if (mounted && epoch == _epoch && _allowed) await _load();
    }
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
      _syncPronunciation();
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
    _syncPronunciation();
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
    await _restoreLastPractice();
    if (mounted && _allowed) await _load();
  }

  Future<Map<String, dynamic>> _api(
    String path,
    Map<String, dynamic> payload,
  ) async {
    if (widget.previewApi != null) return widget.previewApi!(path, payload);
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
    final epoch = _epoch, requestId = _requestId;
    _waitingSince ??= DateTime.now();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api('next', {
        'requestId': requestId,
        'locale': _locale,
        'previousId': _previousId,
        'deferLevelScoring': true,
        'useSelectedLevel': true,
        'supportsA0': true,
      });
      if (!mounted || epoch != _epoch || requestId != _requestId) return;
      final earnedLevel =
          response['currentLevel'] as String? ?? response['level'] as String?;
      if (_savedSource == null &&
          PracticeLevelPromotion.earned(_currentLevel, earnedLevel)) {
        _pendingLevelUp = (before: _currentLevel!, after: earnedLevel!);
      }
      _readLevelStates(response);
      _currentLevel = earnedLevel;
      _practiceLevel =
          response['practiceLevel'] as String? ?? response['level'] as String?;
      if (response['status'] == 'ready') {
        _cachePractice(response);
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
          _validatingCachedPractice = false;
          _selectedWord = null;
          _translationRevealed =
              (response['level'] == 'A0' ||
              response['translationUsed'] == true);
          _feedback = null;
          _loading = false;
          _waitingSince = null;
        });
        _requestTranslations();
        if (_pendingLevelUp == null &&
            _autoplay.take(_requestId) &&
            _canUseAudio) {
          unawaited(_play('cue', response['cueAudioUrl'] as String));
        }
      } else {
        if (_validatingCachedPractice) {
          final scope = _practiceCacheScope;
          if (scope != null) unawaited(LastSnapshotCache.practice.clear(scope));
          setState(() {
            _exercise = null;
            _validatingCachedPractice = false;
          });
        }
        setState(() => _loading = false);
        if (DateTime.now().difference(_waitingSince!) >
            const Duration(minutes: 3)) {
          setState(() => _error = l.quickUnavailable);
        } else if (widget.active) {
          _poll = Timer(const Duration(seconds: 4), _load);
        }
      }
      unawaited(_showPendingLevelUp());
    } catch (_) {
      if (mounted && epoch == _epoch && requestId == _requestId) {
        setState(() {
          _loading = false;
          _error = l.quickUnavailable;
        });
      }
    }
  }

  Future<void> _play(String id, String url) async {
    if (!_canUseAudio || _recording || _busy || _audioCommandBusy) return;
    setState(() => _audioCommandBusy = true);
    _autoplay.cancel();
    final generation = ++_audioGeneration;
    final epoch = _epoch;
    bool current() =>
        _canUseAudio && epoch == _epoch && generation == _audioGeneration;
    try {
      if (_playing == id) {
        if (_paused) {
          await PracticeAudioRoute.prepare();
          if (!current()) return;
          await _player.setPlaybackRate(_playbackSpeed);
          if (!current()) return;
          await _player.resume();
          if (!current()) {
            await _player.stop();
            return;
          }
          if (current()) setState(() => _paused = false);
        } else {
          await _player.pause();
          if (current() && _playing == id) setState(() => _paused = true);
        }
        return;
      }
      setState(() {
        _playing = null;
        _paused = false;
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
      _audioLocale = _exerciseLocale;
      _playbackEvent = const Uuid().v4();
      if (id == 'cue') _cueProgress.value = 0;
      setState(() {
        _playing = id;
        _loadingAudio = null;
      });
      await _player.setSource(
        path == null ? UrlSource(url) : DeviceFileSource(path),
      );
      if (!current()) return;
      await _player.setPlaybackRate(_playbackSpeed);
      if (!current()) return;
      await _player.resume();
      if (!current()) {
        await _player.stop();
        return;
      }
    } catch (_) {
      if (current()) {
        setState(() {
          _playing = null;
          _paused = false;
          _loadingAudio = null;
        });
        _notice(l.practiceAudioError);
      }
    } finally {
      if (mounted) setState(() => _audioCommandBusy = false);
    }
  }

  Future<void> _selectPlaybackSpeed(double next) async {
    if (_audioCommandBusy || _recording || _busy || !_canUseAudio) return;
    if (!PracticeHeader.speeds.contains(next) || next == _playbackSpeed) return;
    setState(() => _audioCommandBusy = true);
    try {
      if (_playing != null) await _player.setPlaybackRate(next);
      if (mounted) setState(() => _playbackSpeed = next);
    } catch (_) {
      if (mounted) _notice(l.practiceAudioError);
    } finally {
      if (mounted) setState(() => _audioCommandBusy = false);
    }
  }

  Future<void> _showPendingLevelUp() async {
    final promotion = _pendingLevelUp;
    if (promotion == null ||
        _celebratingLevel ||
        !_canUseAudio ||
        _busy ||
        _recording ||
        _confirmingNext ||
        _loading ||
        _savedSource != null ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    final epoch = _epoch, owner = _owner;
    final route = ModalRoute.of(context);
    _pendingLevelUp = null;
    setState(() => _celebratingLevel = true);
    await _stopAudio();
    bool safe() =>
        mounted &&
        _canUseAudio &&
        _epoch == epoch &&
        _owner == owner &&
        !_recording &&
        route?.isCurrent == true;
    if (!safe()) {
      if (mounted) setState(() => _celebratingLevel = false);
      return;
    }
    if (!mounted) return;
    await PracticeReviewService.instance.requestAfterCelebration(
      dismissed: showPracticeLevelCelebration(
        context,
        before: promotion.before,
        after: promotion.after,
      ),
      isSafe: safe,
    );
    if (mounted) setState(() => _celebratingLevel = false);
  }

  void _translationsChanged() {
    if (mounted) setState(() {});
  }

  void _requestTranslations({bool retry = false}) {
    _syncPronunciation();
    final exercise = _exercise;
    if (!supportsBuiltInTranslation ||
        widget.previewExercise != null ||
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
        owner: _owner,
        chooseTarget: _chooseTranslationTarget,
        confirmDownload: _confirmTranslationDownload,
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

  Future<TranslationLocaleOption?> _chooseTranslationTarget(
    List<TranslationLocaleOption> options,
  ) async {
    if (!mounted || !_canUseAudio) return null;
    final selected = await showModalBottomSheet<TranslationLocaleOption>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => PracticeTranslationLanguageSheet(options: options),
    );
    await WidgetsBinding.instance.endOfFrame;
    return selected;
  }

  Future<void> _changeTranslationLanguage() async {
    final owner = _owner;
    final source = _exerciseLocale;
    final epoch = _epoch;
    // PopupMenuButton completes before MainScaffold rebuilds active=true.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted ||
        epoch != _epoch ||
        owner != _owner ||
        owner == null ||
        source == null ||
        !_canUseAudio ||
        _busy ||
        _recording ||
        _confirmingNext) {
      return;
    }
    bool current() => _canUseAudio && _owner == owner && _epoch == epoch;
    final resumeAfterPicker = _translations.loading;
    setState(() => _busy = true);
    var changed = false;
    try {
      changed = await _translations.changeTarget(
        source: source,
        owner: owner,
        canStart: current,
        chooseTarget: (options) async {
          if (!mounted || !current()) return null;
          final selected = await showModalBottomSheet<TranslationLocaleOption>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            showDragHandle: true,
            constraints: const BoxConstraints(maxWidth: 560),
            builder: (_) => PracticeTranslationLanguageSheet(
              options: options,
              fallback: false,
              selectedLocale: _translations.targetLocale,
            ),
          );
          await WidgetsBinding.instance.endOfFrame;
          return selected;
        },
      );
    } catch (error) {
      if (mounted && current()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is TranslationException && error.code == 'no_languages'
                  ? l.practiceNoTranslationLanguagesFound
                  : l.practiceCouldNotSaveTranslationLanguage,
            ),
          ),
        );
      }
    } finally {
      if (mounted && _epoch == epoch) setState(() => _busy = false);
    }
    if ((changed || resumeAfterPicker) && current()) _requestTranslations();
  }

  Future<bool> _confirmTranslationDownload() async {
    if (!mounted || !_canUseAudio) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.quickTranslationDownloadTitle),
        content: Text(l.quickTranslationDownloadBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.practiceTranslationDownload),
          ),
        ],
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    return confirmed == true;
  }

  String get _translationStatus => _translations.preparing
      ? l.quickTranslationPreparing
      : switch (_translations.issue) {
          PracticeTranslationIssue.noLanguages =>
            l.practiceNoTranslationLanguagesFound,
          PracticeTranslationIssue.selectionCancelled =>
            l.quickTranslationChoosePrompt,
          PracticeTranslationIssue.downloadCancelled =>
            l.quickTranslationDownloadNeeded,
          _ =>
            _translations.failed
                ? l.practiceTranslationUnavailableForCue
                : l.practiceTranslating,
        };

  Widget _translationLine(String id) {
    if (!supportsBuiltInTranslation || !_translationRevealed) {
      return const SizedBox.shrink();
    }
    final text =
        widget.previewExercise?['translations']?[id] as String? ??
        _translations.translations[id];
    final target = (_translations.targetLocale ?? _translationTarget)
        .toLowerCase()
        .split(RegExp('[-_]'))
        .first;
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text ?? _translationStatus,
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
    if (!supportsBuiltInTranslation ||
        _translationRevealed ||
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
      final marked = await PracticeTranslationController.markUsed(() async {
        if (widget.previewExercise == null && _savedSource == null) {
          await _api('$id/translation', {});
        }
      });
      if (!marked) return;
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
    if (widget.previewExercise != null && widget.previewPlayer == null) return;
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
        _pinRecordingLayout = false;
        _recording = false;
        _playing = null;
        _paused = false;
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

  Future<void> _startRecording(bool Function() stillWanted) async {
    if (_busy || _recording || _exercise == null || !stillWanted()) return;
    if (!_canUseAudio) {
      _notice(l.quickCallActive);
      return;
    }
    final generation = ++_audioGeneration;
    _autoplay.cancel();
    final epoch = _epoch;
    bool current() =>
        stillWanted() &&
        _canUseAudio &&
        epoch == _epoch &&
        generation == _audioGeneration;
    setState(() {
      _pinRecordingLayout = true;
      _busy = true;
      _loadingAudio = null;
    });
    try {
      await AiConsent.instance.requireCurrent();
      if (!current()) return;
      final permission = await Permission.microphone.request();
      if (!current()) return;
      if (!permission.isGranted) {
        if (mounted) {
          _notice(l.compareMicrophoneDeniedPermanent);
          setState(() => _error = l.compareMicrophoneDeniedPermanent);
        }
        return;
      }
      await _player.stop();
      if (!current()) return;
      if (mounted) {
        setState(() {
          _playing = null;
          _paused = false;
        });
      }
      final directory = await getTemporaryDirectory();
      if (!current()) return;
      final path = '${directory.path}/practice-${const Uuid().v4()}.m4a';
      _recordPath = path;
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
      if (!current()) {
        await _recorder.cancel();
        if (_recordPath == path) _recordPath = null;
        try {
          await File(path).delete();
        } catch (_) {}
        return;
      }
      await _discardReplay();
      if (!current()) {
        await _recorder.cancel();
        if (_recordPath == path) _recordPath = null;
        try {
          await File(path).delete();
        } catch (_) {}
        return;
      }
      HapticFeedback.lightImpact();
      setState(() {
        _recording = true;
        _playing = null;
      });
      if (mounted && !MediaQuery.of(context).disableAnimations) {
        _pulse.repeat(reverse: true);
      }
      _recordLimit = Timer(const Duration(seconds: 30), _submit);
    } catch (_) {
      if (mounted && epoch == _epoch) _notice(l.compareCouldNotStartRecording);
    } finally {
      if (mounted && epoch == _epoch) {
        setState(() {
          _busy = false;
          if (!_recording) _pinRecordingLayout = false;
        });
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
      _pinRecordingLayout = false;
      _feedback = null;
      _error = null;
      _busy = true;
      _recording = false;
    });
    String? heard;
    var spoken = 0;
    final creditOwner = AuthSessionNotifier.instance.session?.userId;
    final creditLocale = _exerciseLocale;
    final speechEventId = 'practice-speak:${const Uuid().v4()}';
    var credited = false;
    var creditOwnedByAnimation = false;
    Future<void> creditSpeech() async {
      if (credited || spoken <= 0) return;
      try {
        await WordActivityNotifier.instance.record(
          spoken: spoken,
          ownerId: creditOwner,
          language: creditLocale,
          speechEventId: speechEventId,
        );
        credited = true;
      } catch (_) {
        // The finally path can retry the same idempotent event after a save failure.
      }
    }

    List<String> uncertain = [];
    try {
      await _recorder.stop();
      if (path == null) throw StateError('Missing recording');
      if (!mounted || epoch != _epoch || _exercise?['id'] != exerciseId) return;
      _replayPath = path;
      final transcript = await VideoProcessingService.instance
          .transcribeRecordedAudio(
            inputFile: File(path),
            localeIdentifier: _exerciseLocale!,
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
      // The backend owns grading. A stale client normalizer must not veto an
      // answer before the current server rules can judge its raw transcript.
      final answerPath = _savedSource == null ? 'answer' : 'review/answer';
      final result = await _api('$exerciseId/$answerPath', {
        'attemptId': const Uuid().v4(),
        'transcript': transcript.transcriptText,
        'recognition': uncertain.isEmpty
            ? null
            : 'Uncertain words: ${uncertain.join(', ')}',
      });
      if (!mounted || epoch != _epoch) return;
      setState(
        () => _feedback = {
          ...result,
          'transcript': transcript.transcriptText,
          'uncertainWords': uncertain,
        },
      );
      // Celebration owns its credit sequence, but never the recording busy state.
      // No delayed animation completion may overwrite feedback or a new recording.
      final goalTabAnchor = widget.goalTabAnchor;
      if (spoken > 0 && _canUseAudio && goalTabAnchor != null) {
        creditOwnedByAnimation = true;
        unawaited(() async {
          try {
            await _wordFlight.show(
              context,
              _microphoneAnchor,
              goalTabAnchor,
              outcome: result['outcome'] as String?,
              onParticlesArrived: creditSpeech,
            );
          } catch (_) {
            // Decorative failures must not change a confirmed answer.
          } finally {
            await creditSpeech();
          }
        }());
      }
      if (result['outcome'] == 'correct') {
        HapticFeedback.mediumImpact();
        unawaited(
          _refreshCompleted(
            exerciseId: (_savedSource?['id'] ?? exerciseId) as String,
          ),
        );
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
      // Release the mic before decorative work or storage finishes. Keeping this
      // before any await prevents an old submission from clearing a new one's busy state.
      if (mounted && epoch == _epoch) {
        setState(() => _busy = false);
        _requestTranslations();
      }
      // All recognized speaking counts, including incorrect/unclear replies
      // and answer-request failures. The animation saves credit when particles arrive.
      if (!creditOwnedByAnimation) await creditSpeech();
      if (path != null && path != _replayPath) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
    }
  }

  Future<void> _openLongerDialogues() async {
    if (_recording || _busy || _confirmingNext) return;
    await _stopAudio();
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/practice/dialogues'),
        builder: (_) => const DiscoverScreen(),
      ),
    );
  }

  Future<void> _selectLevel(String selected) async {
    if (_savedSource != null ||
        _recording ||
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
        highestUnlockedLevel: _highestUnlockedLevel,
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
          _translationRevealed = selected == 'A0';
          _feedback = null;
        });
        return;
      }
      final state = await _api('level', {
        'supportsA0': true,
        'locale': _locale,
        'level': selected,
      });
      if (!mounted || epoch != _epoch) return;
      _readLevelStates(state);
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
        unawaited(_showPendingLevelUp());
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
      if (_savedSource == null && _feedback?['outcome'] != 'correct') {
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
        unawaited(_showPendingLevelUp());
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
    final beforeSaved = _beforeSaved;
    if (beforeSaved != null) {
      setState(() {
        _exercise = beforeSaved.exercise;
        _readLevelStates(_exercise);
        _feedback = beforeSaved.feedback;
        _currentLevel = beforeSaved.currentLevel;
        _practiceLevel = beforeSaved.practiceLevel;
        _translationRevealed = beforeSaved.translationRevealed;
        _selectedWord = null;
        _savedSource = null;
        _beforeSaved = null;
        _error = null;
        _waitingSince = null;
      });
      _prepareExerciseAudio();
      unawaited(_refreshCompleted());
      if (_exercise == null) await _load();
      return;
    }
    final scope = _practiceCacheScope;
    if (scope != null) unawaited(LastSnapshotCache.practice.clear(scope));
    setState(() {
      _loading = false;
      _validatingCachedPractice = false;
      _previousId = _exercise?['id'] as String?;
      _requestId = const Uuid().v4();
      if (autoplay) _autoplay.next(_requestId);
      _exercise = null;
      _selectedWord = null;
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
    _pronunciation.removeListener(_pronunciationChanged);
    _pronunciation.dispose();
    _translations.removeListener(_translationsChanged);
    _translations.dispose();
    _autoplay.cancel();
    _audioGeneration++;
    _cueProgress.dispose();
    unawaited(_audioCache?.dispose());
    _completion?.cancel();
    _position?.cancel();
    _duration?.cancel();
    if (widget.previewExercise != null) {
      widget.previewPlayer?.dispose();
      _pulse.dispose();
      super.dispose();
      return;
    }
    _epoch++;
    _poll?.cancel();
    _recordLimit?.cancel();
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
      'A0',
      'A1',
      'A2',
      'B1',
      'B2',
      'C1',
      'C2',
    ].contains(level);
    return Scaffold(
      appBar: PracticeHeader(
        playbackSpeed: _playbackSpeed,
        onSpeedSelected: _recording || _busy || _audioCommandBusy || _callActive
            ? null
            : _selectPlaybackSpeed,
        isSaved: _savedIds.contains((_savedSource ?? exercise)?['id']),
        onSavePractice:
            exercise == null ||
                !_savedLoaded ||
                _saving ||
                _recording ||
                _busy ||
                _confirmingNext
            ? null
            : _toggleSaved,
        onSavedPractice:
            _owner == null || _saving || _recording || _busy || _confirmingNext
            ? null
            : _openSavedPractice,
        onLongerDialogues: _recording || _busy || _confirmingNext
            ? null
            : _openLongerDialogues,
        showTranslationLanguage: supportsBuiltInTranslation,
        onTranslationLanguage:
            supportsBuiltInTranslation &&
                _owner != null &&
                _exerciseLocale != null &&
                !_callActive &&
                !_recording &&
                !_busy &&
                !_confirmingNext
            ? _changeTranslationLanguage
            : null,
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
              child: PracticeRecordingLayout(
                pinned: _pinRecordingLayout,
                children: [
                  const SizedBox(height: 8),
                  if (showLevel)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PracticeLevelMenu(
                          level: level as String,
                          currentLevel: _currentLevel ?? level,
                          levelStates: _levelStates,
                          highestUnlockedLevel: _highestUnlockedLevel,
                          onSelected:
                              _savedSource != null ||
                                  _recording ||
                                  _busy ||
                                  _confirmingNext ||
                                  _loading
                              ? null
                              : _selectLevel,
                        ),
                        if (supportsPracticePronunciation(_exerciseLocale))
                          MergeSemantics(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 48),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      l.practicePronunciation,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(color: c.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch.adaptive(
                                    key: const ValueKey(
                                      'practice-pronunciation-toggle',
                                    ),
                                    value: _pronunciation.enabled,
                                    activeTrackColor: c.primary,
                                    onChanged:
                                        _pronunciation.saving ||
                                            _recording ||
                                            _busy
                                        ? null
                                        : (_) => _togglePronunciation(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (supportsPracticePronunciation(_exerciseLocale) &&
                      _pronunciation.enabled &&
                      _pronunciation.status != 'ready')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          _pronunciation.status == 'preparing'
                              ? l.practicePronunciationPreparing
                              : l.practicePronunciationUnavailable,
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: c.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  if (_pronunciation.enabled &&
                      _pronunciation.status == 'unavailable')
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: _pronunciation.retry,
                        child: Text(l.compareTryAgain),
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
                  if (!_allowed || _exerciseLocale == null)
                    _empty(
                      icon: CupertinoIcons.waveform,
                      title: _exerciseLocale == null
                          ? l.quickChooseLanguage
                          : l.quickInstruction,
                      detail: l.quickSpeakHint,
                      action: _exerciseLocale == null ? null : _start,
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
                            ],
                          ),
                          const SizedBox(height: 18),
                          _wordText(
                            'cue',
                            exercise['cue'] as String,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                              letterSpacing: -.4,
                            ),
                          ),
                          _translationLine('cue'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _playButton(
                                'cue',
                                exercise['cueAudioUrl'] as String,
                                c.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ValueListenableBuilder<double>(
                                  valueListenable: _cueProgress,
                                  builder: (context, progress, _) =>
                                      ChatAudioWaveform(
                                        animateProgress: true,
                                        progress: progress,
                                        receiving: false,
                                        audioKey:
                                            exercise['cueAudioUrl'] as String,
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (supportsBuiltInTranslation && !_translationRevealed)
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
                    if (level == 'A0')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          exercise['reviewMode'] == true
                              ? l.quickReviewLevelBody(_currentLevel ?? level)
                              : l.quickA0Hint,
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
                    PracticeRecordControl(
                      enabled: _canUseAudio && !_confirmingNext,
                      recording: _recording,
                      busy: _busy,
                      pulse: _pulse,
                      microphoneAnchor: _microphoneAnchor,
                      onStart: _startRecording,
                      onCheck: _submit,
                      onCancel: _stopAudio,
                    ),
                    const SizedBox(height: 18),
                    if (_feedback != null) _result(),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: TextStyle(color: c.error)),
                      ),
                    if (_validatingCachedPractice && _error != null)
                      TextButton(
                        onPressed: _loading ? null : _load,
                        child: Text(l.compareTryAgain),
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
      ['ar', 'he', 'fa', 'ur'].contains(_exerciseLocale?.split('-').first)
      ? TextDirection.rtl
      : TextDirection.ltr;
  Widget _playButton(String id, String url, Color color) =>
      IconButton.filledTonal(
        key: ValueKey('practice-play-$id'),
        onPressed: _recording || _busy || _audioCommandBusy
            ? null
            : () => _play(id, url),
        tooltip: _playing == id
            ? (_paused ? l.quickResumeAudio : l.quickPauseAudio)
            : l.practiceListenCarefully,
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
                _playing == id && !_paused
                    ? CupertinoIcons.pause_fill
                    : CupertinoIcons.speaker_2_fill,
                size: 20,
              ),
      );
  Widget _wordText(String part, String sentence, {TextStyle? style}) {
    final selection = _selectedWord;
    final plain = PracticeWordText(
      sentence,
      style: style,
      textDirection: _textDirection,
      selectedWord:
          selection?.part == part && identical(selection?.exercise, _exercise)
          ? selection?.token
          : null,
      onSelect: (token) {
        final exercise = _exercise;
        if (exercise == null ||
            _busy ||
            _recording ||
            _confirmingNext ||
            _callActive) {
          return;
        }
        setState(
          () => _selectedWord = (exercise: exercise, part: part, token: token),
        );
      },
      onWord: (token) => _explainWord(token, sentence),
    );
    final pronunciation = _pronunciation.data;
    final segments = part == 'cue'
        ? (pronunciation?['cue'])
        : (pronunciation?['choices'] as List?)?.elementAtOrNull(
            int.tryParse(part.replaceFirst('option', '')) ?? -1,
          );
    return PracticePronunciationText(
      sentence,
      locale: _exerciseLocale ?? '',
      segments:
          _pronunciation.enabled &&
              _pronunciation.status == 'ready' &&
              segments is List
          ? segments
          : const [],
      style: style,
      textDirection: _textDirection,
      selectedWord: plain.selectedWord,
      onSelect: plain.onSelect,
      onWord: plain.onWord,
    );
  }

  Future<void> _togglePronunciation() async {
    final saved = await _pronunciation.setEnabled(!_pronunciation.enabled);
    if (!saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.practicePronunciationSaveFailed)),
      );
    }
  }

  void _pronunciationChanged() {
    if (mounted) setState(() {});
  }

  void _syncPronunciation() {
    _pronunciation.configure(
      owner: _owner ?? (widget.previewExercise != null ? 'preview' : null),
      locale: _exerciseLocale,
      id: _exercise?['id'] as String?,
      embedded: (_exercise?['pronunciation'] as Map?)?.cast<String, dynamic>(),
      active:
          widget.active &&
          _allowed &&
          !_validatingCachedPractice &&
          (widget.previewExercise != null ||
              WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed),
      fetch: (id) => _api('$id/pronunciation', {}),
    );
  }

  bool _explainingWord = false;
  Future<void> _explainWord(SubtitleWordToken token, String sentence) async {
    if (_explainingWord ||
        _busy ||
        _recording ||
        _confirmingNext ||
        _callActive) {
      return;
    }
    final owner = AuthSessionNotifier.instance.session?.cacheKey;
    final exercise = _exercise;
    _explainingWord = true;
    try {
      await _stopAudio();
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: Text(l.practiceExplainTitle(token.text)),
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: sentence.substring(0, token.start)),
                TextSpan(
                  text: sentence.substring(token.start, token.end),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
                ),
                TextSpan(text: sentence.substring(token.end)),
              ],
            ),
            textDirection: _textDirection,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.practiceExplainAction),
            ),
          ],
        ),
      );
      if (confirmed != true ||
          !mounted ||
          owner == null ||
          _exercise != exercise ||
          AuthSessionNotifier.instance.session?.cacheKey != owner ||
          _callActive) {
        return;
      }
      await openAiWordExplanation(
        context,
        AiWordExplanation(
          owner: owner,
          selection: token.text,
          sentence: sentence,
          start: token.start,
          end: token.end,
          language: _exerciseLocale ?? '',
          displayText: l.practiceExplainMessage(token.text, sentence),
        ),
      );
    } finally {
      _explainingWord = false;
    }
  }

  Widget _choice(int index, Map<String, dynamic> choice) {
    final c = Theme.of(context).colorScheme;
    final selected = _feedback?['choice'] == index;
    final correct = _feedback?['outcome'] == 'correct';
    final accent = correct ? const Color(0xFF008266) : const Color(0xFFB96A17);
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(22),
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
            _playButton(
              'option$index',
              choice['audioUrl'] as String,
              c.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _wordText(
                    'option$index',
                    choice['text'] as String,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(height: 1.4),
                  ),
                  _translationLine('option$index'),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(
                correct
                    ? CupertinoIcons.checkmark
                    : CupertinoIcons.arrow_uturn_left,
                size: 18,
                color: accent,
              ),
            ],
          ],
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
              replaying: _playing == 'recording' && !_paused,
              replayPaused: _playing == 'recording' && _paused,
              replayLoading: _loadingAudio == 'recording',
              transcript: _feedback!['transcript'] as String? ?? '',
              choices: (_exercise!['choices'] as List)
                  .map((c) => c['text'] as String)
                  .toList(),
              locale: _exerciseLocale ?? 'en',
              choice: _feedback!['choice'] as int?,
              textEquivalent: _feedback!['textEquivalent'] == true,
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
