import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/auth_api_error_localizations.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/generation_job_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/ai_audio_constants.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/video_processing_service.dart';
import '../profile/edit_profile_screen.dart';
import '../shared/locale_flag.dart';
import 'uploaded_video_detail_screen.dart';

String _localizedScenarioLabel(AppLocalizations l10n, AiScenario scenario) {
  return switch (scenario.id) {
    'latest_news' => l10n.aiScenarioLatestNews,
    'coffee_shop' => l10n.aiScenarioCoffeeShop,
    'airport_reunion' => l10n.aiScenarioAirportReunion,
    'grocery_store' => l10n.aiScenarioGroceryStore,
    'doctor_visit' => l10n.aiScenarioDoctorVisit,
    'job_interview' => l10n.aiScenarioJobInterview,
    'new_neighbour' => l10n.aiScenarioNewNeighbour,
    'tech_support' => l10n.aiScenarioTechSupport,
    'birthday_surprise' => l10n.aiScenarioBirthdaySurprise,
    'gym_tips' => l10n.aiScenarioGymTips,
    'weather_smalltalk' => l10n.aiScenarioWeatherSmalltalk,
    'restaurant_order' => l10n.aiScenarioRestaurantOrder,
    'book_rec' => l10n.aiScenarioBookRecommendation,
    'bus_delay' => l10n.aiScenarioBusDelay,
    'movie_debate' => l10n.aiScenarioMovieDebate,
    'custom' => l10n.aiScenarioCustom,
    _ => scenario.label,
  };
}

class GenerateAiAudioScreen extends StatefulWidget {
  const GenerateAiAudioScreen({
    super.key,
    this.onYourMediaChanged,
    this.onGenerationStarted,
  });

  /// Called when a new upload exists on the server (before opening detail).
  /// Used so the Create hub "Your Media" list can refetch.
  final VoidCallback? onYourMediaChanged;
  final void Function(String jobId)? onGenerationStarted;

  @override
  State<GenerateAiAudioScreen> createState() => _GenerateAiAudioScreenState();
}

class _GenerateAiAudioScreenState extends State<GenerateAiAudioScreen> {
  bool _isLoadingLocales = true;

  TranscriptionLocaleOption? _selectedLocale;
  AiScenario? _selectedScenario;
  final TextEditingController _customScenarioController =
      TextEditingController();
  int _durationSeconds = 60;

  _GenerationStep _step = _GenerationStep.idle;
  String? _errorMessage;
  bool _ownershipAcknowledged = false;

  bool get _isGenerating => _step != _GenerationStep.idle;

  static const _durationOptions = [60, 120, 180, 240];

  bool get _canGenerate {
    final learningLang =
        UserProfileNotifier.instance.learningLanguage?.trim() ?? '';
    if (learningLang.isEmpty) return false;
    if (_selectedLocale == null) return false;
    if ((_selectedScenario?.isCustom ?? false) &&
        _customScenarioController.text.trim().isEmpty) {
      return false;
    }
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
      final locales = await VideoProcessingService.instance
          .fetchLearningLanguageOptions();
      if (!mounted) return;

      // AI generation must follow the saved learning language exactly. If the
      // current language source cannot resolve it, generation stays disabled.
      final learningLang =
          UserProfileNotifier.instance.learningLanguage?.trim() ?? '';

      final defaultLocale = _matchLearningLanguage(locales, learningLang);

      AiScenario? restoredScenario;
      try {
        final file = await _prefsFile();
        if (await file.exists()) {
          final prefs =
              jsonDecode(await file.readAsString()) as Map<String, dynamic>;
          final lastScenarioId = prefs['lastScenarioId'] as String?;
          if (lastScenarioId != null) {
            restoredScenario = kAiScenarios
                .where((s) => s.id == lastScenarioId)
                .firstOrNull;
          }
        }
      } catch (_) {}

      setState(() {
        _errorMessage = null;
        _isLoadingLocales = false;
        if (defaultLocale != null) _selectedLocale = defaultLocale;
        if (restoredScenario != null) _selectedScenario = restoredScenario;
      });
    } on VideoProcessingException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoadingLocales = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
          _isLoadingLocales = false;
        });
      }
    }
  }

  Future<void> _confirmLeaveWhileGenerating(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Generate in background?'),
          content: const Text(
            'Audio generation can continue in the background. You can come back later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel generation'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Generate in background'),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _savePrefs() async {
    try {
      final file = await _prefsFile();
      await file.writeAsString(
        jsonEncode({
          if (_selectedScenario != null)
            'lastScenarioId': _selectedScenario!.id,
        }),
      );
    } catch (_) {}
  }

  TranscriptionLocaleOption? _matchLearningLanguage(
    List<TranscriptionLocaleOption> locales,
    String learningLanguage,
  ) {
    final normalizedLearning = _normalizeLocaleIdentifier(learningLanguage);
    if (normalizedLearning.isEmpty) return null;

    final exact = locales
        .where(
          (l) => _normalizeLocaleIdentifier(l.identifier) == normalizedLearning,
        )
        .firstOrNull;
    if (exact != null) return exact;

    final learningPrimary = _primaryLanguageCode(normalizedLearning);
    if (learningPrimary == null) return null;

    return locales
        .where((l) => _primaryLanguageCode(l.identifier) == learningPrimary)
        .firstOrNull;
  }

  static String _normalizeLocaleIdentifier(String identifier) {
    return identifier.trim().replaceAll('_', '-').toLowerCase();
  }

  static String? _primaryLanguageCode(String identifier) {
    final normalized = _normalizeLocaleIdentifier(identifier);
    if (normalized.isEmpty) return null;
    return normalized.split('-').first;
  }

  Future<void> _onGenerateTapped() async {
    if (_ownershipAcknowledged) {
      await _generate();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final d = AppLocalizations.of(ctx)!;
        bool dialogAcknowledged = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(d.aiGenOwnershipConfirmTitle),
              content: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => setDialogState(
                  () => dialogAcknowledged = !dialogAcknowledged,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: dialogAcknowledged,
                      onChanged: (v) =>
                          setDialogState(() => dialogAcknowledged = v ?? false),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: Text(d.aiGenOwnershipCheckbox)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(d.aiGenOwnershipConfirmCancel),
                ),
                FilledButton(
                  onPressed: dialogAcknowledged
                      ? () => Navigator.pop(ctx, true)
                      : null,
                  child: Text(d.aiGenOwnershipConfirmGenerate),
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed == true && mounted) {
      await _generate();
    }
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
    try {
      final nativeLanguageCode = UserProfileNotifier.instance.nativeLanguage;
      await AuthApiClient.instance.generateAiAudioStreamingV2(
        accessToken: session.accessToken,
        language: locale.displayName,
        languageCode: locale.identifier,
        scenarioId: _selectedScenario?.id,
        scenario: scenarioText,
        durationSeconds: _durationSeconds,
        nativeLanguageCode: nativeLanguageCode,
        onStarted: (jobId) {
          GenerationJobNotifier.instance.start(jobId);
          widget.onGenerationStarted?.call(jobId);
        },
        onDialogueDone: () {
          if (mounted) setState(() => _step = _GenerationStep.generatingAudio);
        },
        onAudioGenerated: () {
          if (mounted) setState(() => _step = _GenerationStep.aligningAudio);
        },
        onAligning: () {
          if (mounted) setState(() => _step = _GenerationStep.aligningAudio);
        },
        onDone: (v, _) {
          video = v;
        },
      );

      if (!mounted || video == null) return;
      GenerationJobNotifier.instance.clear();
      widget.onYourMediaChanged?.call();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UploadedVideoDetailScreen(video: video!),
        ),
      );
    } on SessionExpiredException {
      // User is being signed out — do nothing.
    } on VideoProcessingException catch (e) {
      GenerationJobNotifier.instance.clear();
      if (mounted) setState(() => _errorMessage = e.message);
    } on AuthApiException catch (e) {
      GenerationJobNotifier.instance.clear();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _errorMessage = localizeAuthApiError(l10n, e));
      }
    } catch (e) {
      GenerationJobNotifier.instance.clear();
      if (mounted) {
        setState(
          () => _errorMessage = 'Something went wrong. Please try again.',
        );
      }
    } finally {
      unawaited(WakelockPlus.disable());
      if (mounted) setState(() => _step = _GenerationStep.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_isGenerating,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !_isGenerating) return;
        unawaited(_confirmLeaveWhileGenerating(context));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.generateWithAiTitle)),
        body: _isGenerating
            ? _buildLoadingState(l10n)
            : _buildForm(theme, colorScheme, l10n),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    final steps = [
      (
        step: _GenerationStep.writingDialogue,
        label: l10n.aiGenStepWritingDialogue,
      ),
      (
        step: _GenerationStep.generatingAudio,
        label: l10n.aiGenStepGeneratingAudio,
      ),
      (step: _GenerationStep.aligningAudio, label: l10n.aiGenStepAligningAudio),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aiGenLoadingTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 24,
                            )
                          : isActive
                          ? const CircularProgressIndicator(strokeWidth: 2.5)
                          : const Icon(
                              Icons.radio_button_unchecked,
                              color: Colors.grey,
                              size: 24,
                            ),
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
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              l10n.aiGenLoadingSubtitle,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
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
          Text(l10n.aiGenLanguageSection, style: theme.textTheme.titleSmall),
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
                        l10n.aiGenSetLearningLanguagePrompt,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colorScheme.primary),
                  ],
                ),
              ),
            )
          else if (_isLoadingLocales)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.aiGenLoadingLanguage,
                    style: const TextStyle(fontSize: 14),
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
                    _selectedLocale!.effectiveFlagEmoji,
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
                l10n.aiGenLanguageUnsupported(learningLang),
                style: TextStyle(color: colorScheme.error, fontSize: 13),
              ),
            ),

          const SizedBox(height: 24),

          // Scenario picker
          Text(l10n.aiGenScenarioSection, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            l10n.aiGenScenarioOptionalHint,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kAiScenarios.map((scenario) {
              final isSelected = _selectedScenario?.id == scenario.id;
              return ChoiceChip(
                label: Text(
                  '${scenario.emoji} ${_localizedScenarioLabel(l10n, scenario)}',
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(
                    () => _selectedScenario = isSelected ? null : scenario,
                  );
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
              decoration: InputDecoration(
                hintText: l10n.aiGenCustomScenarioHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],

          const SizedBox(height: 24),

          // Duration picker
          Text(l10n.aiGenDurationSection, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: _durationOptions.map((s) {
              return ButtonSegment<int>(
                value: s,
                label: Text(l10n.aiGenDurationMinutes(s ~/ 60)),
              );
            }).toList(),
            selected: {_durationSeconds},
            onSelectionChanged: (val) =>
                setState(() => _durationSeconds = val.first),
          ),

          const SizedBox(height: 24),

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
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Ownership notice + acknowledgement checkbox
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiGenOwnershipNotice,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => setState(
                    () => _ownershipAcknowledged = !_ownershipAcknowledged,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _ownershipAcknowledged,
                        onChanged: (v) =>
                            setState(() => _ownershipAcknowledged = v ?? false),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          l10n.aiGenOwnershipCheckbox,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Generate button
          FilledButton.icon(
            onPressed: _canGenerate ? _onGenerateTapped : null,
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.aiGenGenerateButton),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

enum _GenerationStep { idle, writingDialogue, generatingAudio, aligningAudio }
