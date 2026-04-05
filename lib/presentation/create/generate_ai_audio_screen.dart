import 'package:flutter/material.dart';

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
  int _durationSeconds = 60;

  bool _isGenerating = false;
  String? _errorMessage;

  static const _durationOptions = [30, 60, 90, 120];

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

  Future<void> _loadLocales() async {
    try {
      final locales = await VideoProcessingService.instance.fetchSupportedLocales();
      if (mounted) {
        setState(() {
          _locales = locales;
          _isLoadingLocales = false;
        });
      }
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
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final video = await AuthApiClient.instance.generateAiAudio(
        accessToken: session.accessToken,
        language: locale.displayName,
        languageCode: locale.identifier,
        scenario: scenarioText,
        durationSeconds: _durationSeconds,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UploadedVideoDetailScreen(video: video),
        ),
      );
    } on AuthApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Generating dialogue and audio…',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 8),
          Text(
            'This may take up to a minute.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
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
                child: Text(locale.displayName),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedLocale = val),
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
              onSelected: (_) => setState(() {
                _selectedScenario = isSelected ? null : scenario;
              }),
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
              label: Text(s < 60 ? '${s}s' : '${s ~/ 60}min'),
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
