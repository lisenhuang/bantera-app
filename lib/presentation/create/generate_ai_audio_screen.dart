import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/auth_session_notifier.dart';
import '../../domain/ai_audio_constants.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/video_processing_service.dart';
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
  int _durationSeconds = 120;

  _GenerationStep _step = _GenerationStep.idle;
  String? _errorMessage;

  bool get _isGenerating => _step != _GenerationStep.idle;

  static const _durationOptions = [60, 120, 180, 240];

  bool get _canGenerate =>
      _selectedLocale != null &&
      (!(_selectedScenario?.isCustom ?? false) ||
          _customScenarioController.text.trim().isNotEmpty);

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

      // Restore last selections from prefs
      TranscriptionLocaleOption? restoredLocale;
      AiScenario? restoredScenario;
      try {
        final file = await _prefsFile();
        if (await file.exists()) {
          final prefs = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
          final lastId = prefs['lastLanguageIdentifier'] as String?;
          if (lastId != null) {
            restoredLocale = locales.where((l) => l.identifier == lastId).firstOrNull;
          }
          final lastScenarioId = prefs['lastScenarioId'] as String?;
          if (lastScenarioId != null) {
            restoredScenario = kAiScenarios.where((s) => s.id == lastScenarioId).firstOrNull;
          }
        }
      } catch (_) {}

      setState(() {
        _locales = locales;
        _isLoadingLocales = false;
        if (restoredLocale != null) _selectedLocale = restoredLocale;
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

    try {
      final dialogue = await AuthApiClient.instance.generateAiDialogue(
        accessToken: session.accessToken,
        language: locale.displayName,
        languageCode: locale.identifier,
        scenario: scenarioText,
        durationSeconds: _durationSeconds,
      );

      if (!mounted) return;
      setState(() => _step = _GenerationStep.generatingAudio);

      final video = await AuthApiClient.instance.synthesiseAiAudio(
        accessToken: session.accessToken,
        dialogue: dialogue,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UploadedVideoDetailScreen(video: video),
        ),
      );
    } on AuthApiException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _step = _GenerationStep.idle);
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
      (step: _GenerationStep.writingDialogue, label: 'Writing dialogue'),
      (step: _GenerationStep.generatingAudio, label: 'Generating audio'),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Language picker
        Text('Language', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (_isLoadingLocales)
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
                Text('Loading available languages…', style: TextStyle(fontSize: 14)),
              ],
            ),
          )
        else if (_localesError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _localesError!,
              style: TextStyle(color: colorScheme.error, fontSize: 13),
            ),
          )
        else
          DropdownButton<TranscriptionLocaleOption>(
            value: _selectedLocale,
            hint: const Text('Select a language'),
            isExpanded: true,
            underline: Container(height: 1, color: Colors.grey.shade400),
            items: _locales.map((locale) {
              return DropdownMenuItem(
                value: locale,
                child: Text('${_flagEmoji(locale.identifier)}  ${locale.displayName}'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => _selectedLocale = val);
              _savePrefs();
            },
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
    );
  }
}

enum _GenerationStep { idle, writingDialogue, generatingAudio }
