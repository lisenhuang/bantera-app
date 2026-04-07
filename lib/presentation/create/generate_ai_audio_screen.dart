import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/ai_audio_constants.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/video_processing_service.dart';
import '../profile/edit_profile_screen.dart';
import 'uploaded_video_detail_screen.dart';

class GenerateAiAudioScreen extends StatefulWidget {
  const GenerateAiAudioScreen({super.key});

  @override
  State<GenerateAiAudioScreen> createState() => _GenerateAiAudioScreenState();
}

class _GenerateAiAudioScreenState extends State<GenerateAiAudioScreen> {
  List<TranscriptionLocaleOption> _locales = const [];
  bool _isLoadingLocales = true;
  String? _localesError;

  TranscriptionLocaleOption? _selectedLocale;
  AiScenario? _selectedScenario;
  final TextEditingController _customScenarioController = TextEditingController();
  int _durationSeconds = 60;

  _GenerationStep _step = _GenerationStep.idle;
  String? _errorMessage;

  bool get _isGenerating => _step != _GenerationStep.idle;

  static const _durationOptions = [60, 120, 180, 240];

  bool get _canGenerate {
    final learningLang =
        UserProfileNotifier.instance.learningLanguage?.trim() ?? '';
    if (learningLang.isEmpty) return false;
    if (_selectedLocale == null) return false;
    if ((_selectedScenario?.isCustom ?? false) &&
        _customScenarioController.text.trim().isEmpty) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadLocales();
  }

  @override
  void dispose() {
    _customScenarioController.dispose();
    super.dispose();
  }

  Future<File> _prefsFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/ai_audio_generate_prefs.json');
  }

  Future<void> _loadLocales() async {
    try {
      final locales = await VideoProcessingService.instance.fetchSupportedLocales();
      if (!mounted) return;

      // Determine default locale: learning language takes priority over saved pref.
      final learningLang =
          UserProfileNotifier.instance.learningLanguage?.trim() ?? '';

      TranscriptionLocaleOption? defaultLocale;
      if (learningLang.isNotEmpty) {
        // Exact match first (e.g. "en-US" → "en-US").
        defaultLocale =
            locales.where((l) => l.identifier == learningLang).firstOrNull;
        // Prefix match fallback (e.g. "en" → first "en-*" locale).
        defaultLocale ??= locales
            .where((l) => l.identifier.startsWith('$learningLang-'))
            .firstOrNull;
      }

      // Restore scenario from prefs; locale pref is only a fallback when a
      // learning language IS set but didn't match exactly.
      AiScenario? restoredScenario;
      try {
        final file = await _prefsFile();
        if (await file.exists()) {
          final prefs =
              jsonDecode(await file.readAsString()) as Map<String, dynamic>;
          // Only fall back to the saved locale when the user has a learning
          // language configured (prevents re-enabling the button via old prefs).
          if (defaultLocale == null && learningLang.isNotEmpty) {
            final lastId = prefs['lastLanguageIdentifier'] as String?;
            if (lastId != null) {
              defaultLocale =
                  locales.where((l) => l.identifier == lastId).firstOrNull;
            }
          }
          final lastScenarioId = prefs['lastScenarioId'] as String?;
          if (lastScenarioId != null) {
            restoredScenario =
                kAiScenarios.where((s) => s.id == lastScenarioId).firstOrNull;
          }
        }
      } catch (_) {}

      setState(() {
        _locales = locales;
        _isLoadingLocales = false;
        if (defaultLocale != null) _selectedLocale = defaultLocale;
        if (restoredScenario != null) _selectedScenario = restoredScenario;
      });
    } on VideoProcessingException catch (e) {
      if (mounted) {
        setState(() {
          _localesError = e.message;
          _isLoadingLocales = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _localesError = e.toString();
          _isLoadingLocales = false;
        });
      }
    }
  }

  Future<void> _savePrefs() async {
    try {
      final file = await _prefsFile();
      await file.writeAsString(jsonEncode({
        if (_selectedLocale != null)
          'lastLanguageIdentifier': _selectedLocale!.identifier,
        if (_selectedScenario != null)
          'lastScenarioId': _selectedScenario!.id,
      }));
    } catch (_) {}
  }

  static String _flagEmoji(String identifier) {
    // Extract the 2-letter country code (last segment that is 2 uppercase letters)
    final parts = identifier.split('-');
    String? countryCode;
    for (final part in parts.reversed) {
      if (part.length == 2 && part.toUpperCase() == part) {
        countryCode = part;
        break;
      }
    }
    if (countryCode == null) return '🌐';
    const base = 0x1F1E6;
    final codes = countryCode.codeUnits;
    return String.fromCharCode(base + codes[0] - 0x41) +
        String.fromCharCode(base + codes[1] - 0x41);
  }

  Future<void> _generate() async {
    final locale = _selectedLocale;
    if (locale == null) return;

    final session = AuthSessionNotifier.instance.session;
    if (session == null) return;

    final scenarioText = _selectedScenario == null
        ? ''
        : _selectedScenario!.isCustom
            ? _customScenarioController.text.trim()
            : _selectedScenario!.scenarioText ?? _selectedScenario!.label;

    setState(() {
      _step = _GenerationStep.writingDialogue;
      _errorMessage = null;
    });

    unawaited(WakelockPlus.enable());
    UploadedVideo? video;
    List<String> dialogueLines = [];
    try {
      await AuthApiClient.instance.generateAiAudioStreaming(
        accessToken: session.accessToken,
        language: locale.displayName,
        languageCode: locale.identifier,
        scenario: scenarioText,
        durationSeconds: _durationSeconds,
        onDialogueDone: () {
          if (mounted) setState(() => _step = _GenerationStep.generatingAudio);
        },
        onAudioDone: (v, lines) {
          video = v;
          dialogueLines = lines;
        },
      );

      if (!mounted || video == null) return;
      setState(() => _step = _GenerationStep.transcribing);

      final transcribedVideo = await _transcribeVideo(
        video: video!,
        accessToken: session.accessToken,
        localeIdentifier: locale.identifier,
      );

      if (!mounted) return;
      setState(() => _step = _GenerationStep.correctingTranscript);

      final updatedVideo = await _correctTranscript(
        video: transcribedVideo,
        accessToken: session.accessToken,
        originalLines: dialogueLines,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UploadedVideoDetailScreen(video: updatedVideo),
        ),
      );
    } on AuthApiException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      unawaited(WakelockPlus.disable());
      if (mounted) setState(() => _step = _GenerationStep.idle);
    }
  }

  Future<UploadedVideo> _correctTranscript({
    required UploadedVideo video,
    required String accessToken,
    required List<String> originalLines,
  }) async {
    if (originalLines.isEmpty || video.transcriptCues.isEmpty) return video;
    try {
      return await AuthApiClient.instance.correctVideoTranscript(
        accessToken: accessToken,
        videoId: video.id,
        originalLines: originalLines,
        transcribedCues: video.transcriptCues,
      );
    } catch (_) {
      return video;
    }
  }

  /// Downloads the generated WAV, transcribes it on-device, and PATCHes the
  /// server. Returns the updated video on success, or the original on failure.
  Future<UploadedVideo> _transcribeVideo({
    required UploadedVideo video,
    required String accessToken,
    required String localeIdentifier,
  }) async {
    final videoUrl = video.videoUrl?.trim();
    if (videoUrl == null || videoUrl.isEmpty) return video;

    File? tempFile;
    try {
      final uri = Uri.parse(videoUrl);
      final request = await HttpClient().getUrl(uri);
      request.headers.set('Authorization', 'Bearer $accessToken');
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) return video;

      final tempDir = await getTemporaryDirectory();
      tempFile = File('${tempDir.path}/bantera_gen_transcribe_${video.id}.wav');
      await response.pipe(tempFile.openWrite());

      final result = await VideoProcessingService.instance.transcribeAudioForUpload(
        inputFile: tempFile,
        localeIdentifier: localeIdentifier,
      );
      if (result.transcriptCues.isEmpty) return video;

      final updated = await AuthApiClient.instance.updateVideoTranscript(
        accessToken: accessToken,
        videoId: video.id,
        transcriptText: result.transcriptText,
        transcriptCues: result.transcriptCues,
      );
      return updated;
    } catch (_) {
      // Transcription is best-effort; fall back to estimated cues.
      return video;
    } finally {
      try { await tempFile?.delete(); } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Generate with AI')),
      body: _isGenerating ? _buildLoadingState() : _buildForm(theme, colorScheme),
    );
  }

  Widget _buildLoadingState() {
    final steps = [
      (step: _GenerationStep.writingDialogue,       label: 'Writing dialogue'),
      (step: _GenerationStep.generatingAudio,       label: 'Generating audio'),
      (step: _GenerationStep.transcribing,          label: 'Transcribing'),
      (step: _GenerationStep.correctingTranscript,  label: 'Correcting transcript'),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Creating your audio…',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ...steps.map((s) {
              final isDone = _step.index > s.step.index;
              final isActive = _step == s.step;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: isDone
                          ? const Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 24)
                          : isActive
                              ? const CircularProgressIndicator(strokeWidth: 2.5)
                              : const Icon(Icons.radio_button_unchecked,
                                  color: Colors.grey, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDone
                            ? Colors.green
                            : isActive
                                ? null
                                : Colors.grey,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            const Text(
              'This may take up to a minute.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, ColorScheme colorScheme) {
    final learningLang =
        UserProfileNotifier.instance.learningLanguage?.trim() ?? '';
    final hasLearningLang = learningLang.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Language indicator / prompt
        Text('Language', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (!hasLearningLang)
          // No learning language set — show prompt to go to settings.
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                ),
                color: colorScheme.primary.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Set your learning language to enable generation',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.primary),
                ],
              ),
            ),
          )
        else if (_isLoadingLocales)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text(
                  'Loading language…',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          )
        else if (_selectedLocale != null)
          // Show the matched locale as a read-only chip.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _flagEmoji(_selectedLocale!.identifier),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedLocale!.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          // Language set but no matching locale found in the list.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Language "$learningLang" is not supported for generation.',
              style: TextStyle(color: colorScheme.error, fontSize: 13),
            ),
          ),

        const SizedBox(height: 24),

        // Scenario picker
        Text('Scenario', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Optional — leave unselected for a random scenario.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kAiScenarios.map((scenario) {
            final isSelected = _selectedScenario?.id == scenario.id;
            return ChoiceChip(
              label: Text('${scenario.emoji} ${scenario.label}'),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedScenario = isSelected ? null : scenario);
                _savePrefs();
              },
            );
          }).toList(),
        ),

        // Custom scenario text field
        if (_selectedScenario?.isCustom == true) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _customScenarioController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe your scenario…',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],

        const SizedBox(height: 24),

        // Duration picker
        Text('Duration', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: _durationOptions.map((s) {
            return ButtonSegment<int>(
              value: s,
              label: Text('${s ~/ 60}min'),
            );
          }).toList(),
          selected: {_durationSeconds},
          onSelectionChanged: (val) => setState(() => _durationSeconds = val.first),
        ),

        const SizedBox(height: 32),

        // Error message
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Generate button
        FilledButton.icon(
          onPressed: _canGenerate ? _generate : null,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Generate'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
        ),

        const SizedBox(height: 16),
        Text(
          'AI will write a two-speaker dialogue and synthesise it as audio. '
          'The result will be saved as a public practice audio.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
      ),
    );
  }
}

enum _GenerationStep { idle, writingDialogue, generatingAudio, transcribing, correctingTranscript }
