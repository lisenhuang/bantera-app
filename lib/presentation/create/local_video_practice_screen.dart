import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/settings_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../../infrastructure/translation_service.dart';
import '../../infrastructure/video_processing_service.dart';
import '../practice/practice_player_screen.dart';

class LocalVideoPracticeScreen extends StatefulWidget {
  const LocalVideoPracticeScreen({super.key});

  @override
  State<LocalVideoPracticeScreen> createState() =>
      _LocalVideoPracticeScreenState();
}

class _LocalVideoPracticeScreenState extends State<LocalVideoPracticeScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedVideo;
  int? _selectedVideoBytes;
  int? _selectedVideoDurationMs;
  List<TranscriptionLocaleOption> _supportedLocales = const [];
  TranscriptionLocaleOption? _selectedLocale;

  bool _isLoadingLocales = true;
  bool _isPreparing = false;
  String? _errorMessage;
  String? _prepareStatus;

  @override
  void initState() {
    super.initState();
    _loadSupportedLocales();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Practice Local Video')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Choose a video from Photos, pick the spoken language, then let iPhone transcribe it in the background before cue-by-cue practice.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Choose video', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isPreparing ? null : _pickVideo,
                  icon: const Icon(Icons.video_library_outlined),
                  label: Text(
                    _selectedVideo == null
                        ? 'Choose from Photos'
                        : 'Choose a Different Video',
                  ),
                ),
                if (_selectedVideo != null) ...[
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Selected file', value: _selectedVideo!.name),
                  if (_selectedVideoBytes != null)
                    _InfoRow(
                      label: 'Size',
                      value: _formatBytes(_selectedVideoBytes!),
                    ),
                  if (_selectedVideoDurationMs != null)
                    _InfoRow(
                      label: 'Duration',
                      value: _formatDuration(_selectedVideoDurationMs!),
                    ),
                  if (_isLongVideo) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        'This video is longer than 3 minutes, so Bantera may need longer to prepare the transcript and translation.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2. Transcription language',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (_isLoadingLocales)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _supportedLocales.isEmpty || _isPreparing
                        ? null
                        : _showLanguagePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.translate_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedLocale == null
                                  ? 'Choose the spoken language'
                                  : _languageLabel(_selectedLocale!),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                  ),
                if (!_isLoadingLocales && _supportedLocales.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Bantera remembers your last language choice and keeps transcription hidden by default once practice starts.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('3. Practice', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _canPractice ? _startPractice : null,
                  icon: const Icon(Icons.headphones_rounded),
                  label: Text(_isPreparing ? 'Preparing...' : 'Start Practice'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Bantera transcribes on device first, then opens the cue-by-cue listening page without uploading anything.',
                  style: theme.textTheme.bodySmall,
                ),
                if (_isPreparing && _prepareStatus != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _prepareStatus!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool get _canPractice =>
      !_isPreparing &&
      !_isLoadingLocales &&
      _selectedVideo != null &&
      _selectedLocale != null;
  bool get _isLongVideo => (_selectedVideoDurationMs ?? 0) > 180000;

  Widget _buildSectionCard(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }

  Future<void> _loadSupportedLocales() async {
    setState(() {
      _isLoadingLocales = true;
      _errorMessage = null;
    });

    try {
      final locales = await VideoProcessingService.instance
          .fetchSupportedLocales();
      final selected = _preferredLocale(locales);
      if (!mounted) {
        return;
      }

      setState(() {
        _supportedLocales = locales;
        _selectedLocale = selected;
        _isLoadingLocales = false;
      });
    } on VideoProcessingException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingLocales = false;
        _errorMessage = error.message;
      });
    }
  }

  Future<void> _pickVideo() async {
    _clearError();
    final picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (picked == null || !mounted) {
      return;
    }

    final bytes = await File(picked.path).length();
    final durationMs = await _loadVideoDurationMs(picked.path);
    setState(() {
      _selectedVideo = picked;
      _selectedVideoBytes = bytes;
      _selectedVideoDurationMs = durationMs;
    });
  }

  Future<void> _startPractice() async {
    final selectedVideo = _selectedVideo;
    final selectedLocale = _selectedLocale;
    if (selectedVideo == null || selectedLocale == null) {
      return;
    }

    _clearError();
    setState(() {
      _isPreparing = true;
      _prepareStatus = _isLongVideo
          ? 'This is a longer video, so Bantera may need extra time to transcribe and prepare it.'
          : 'Transcribing on device and preparing practice cues...';
    });

    try {
      final localPracticeId = LocalPracticeRepository.instance.createDraftId();
      final prepared = await VideoProcessingService.instance
          .prepareVideoForUpload(
            inputFile: File(selectedVideo.path),
            localeIdentifier: selectedLocale.identifier,
          );
      if (!mounted) {
        return;
      }

      final translatedCueTexts = await _prepareTranslationIfNeeded(
        prepared,
        localPracticeId: localPracticeId,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _prepareStatus = 'Saving this video to your on-device practice library...';
      });

      final savedVideo = await LocalPracticeRepository.instance
          .savePreparedSession(
            id: localPracticeId,
            title: _displayTitle(selectedVideo.name),
            prepared: prepared,
            translatedCueTexts: translatedCueTexts,
            translatedLanguage: translatedCueTexts.isEmpty
                ? null
                : UserProfileNotifier.instance.translationLanguage,
          );
      if (!mounted) {
        return;
      }

      final mediaItem = savedVideo.toMediaItem(
        creator: _currentCreator(),
      );

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PracticePlayerScreen(mediaItem: mediaItem),
        ),
      );
    } on VideoProcessingException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } on LocalPracticeRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreparing = false;
          _prepareStatus = null;
        });
      }
    }
  }

  User _currentCreator() {
    final profile = UserProfileNotifier.instance;
    final session = AuthSessionNotifier.instance.session;

    return User(
      id: session?.cacheKey ?? 'local-user',
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl ?? '',
      firstLanguage: '',
      learningLanguage: '',
      level: '',
    );
  }

  Future<Map<String, String>> _prepareTranslationIfNeeded(
    PreparedVideoUpload prepared, {
    required String localPracticeId,
  }) async {
    final translationLanguage = UserProfileNotifier.instance.translationLanguage
        ?.trim();
    if (translationLanguage == null || translationLanguage.isEmpty) {
      return const {};
    }

    final cues = prepared.transcriptCues
        .map(
          (cue) => Cue(
            id: '$localPracticeId-cue-${cue.index}',
            startTimeMs: cue.startMs,
            endTimeMs: cue.endMs,
            originalText: cue.text,
            translatedText: '',
          ),
        )
        .toList();

    if (cues.isEmpty) {
      return const {};
    }

    if (mounted) {
      setState(() {
        _prepareStatus = _isLongVideo
            ? 'Transcription finished. Bantera is also preparing translation for your saved language, so this longer video may take a bit more time.'
            : 'Transcription finished. Preparing translation for your saved language...';
      });
    }

    try {
      return await TranslationService.instance.translateCues(
        sourceLocaleIdentifier: prepared.transcriptLanguage,
        targetLocaleIdentifier: translationLanguage,
        cues: cues,
      );
    } on TranslationException {
      return const {};
    }
  }

  Future<int?> _loadVideoDurationMs(String path) async {
    final controller = VideoPlayerController.file(File(path));
    try {
      await controller.initialize();
      return controller.value.duration.inMilliseconds;
    } catch (_) {
      return null;
    } finally {
      await controller.dispose();
    }
  }

  Future<void> _showLanguagePicker() async {
    final selected = await showModalBottomSheet<TranscriptionLocaleOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _LanguagePickerSheet(
          locales: _supportedLocales,
          selected: _selectedLocale,
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    SettingsNotifier.instance.setLastTranscriptionLocale(selected.identifier);
    setState(() {
      _selectedLocale = selected;
    });
  }

  void _clearError() {
    if (_errorMessage == null) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });
  }

  TranscriptionLocaleOption? _preferredLocale(
    List<TranscriptionLocaleOption> locales,
  ) {
    final savedIdentifier = SettingsNotifier.instance.lastTranscriptionLocale
        ?.toLowerCase();
    if (savedIdentifier != null && savedIdentifier.isNotEmpty) {
      for (final locale in locales) {
        if (locale.identifier.toLowerCase() == savedIdentifier) {
          return locale;
        }
      }

      final savedLanguage = savedIdentifier.split('-').first;
      for (final locale in locales) {
        final localeLanguage = locale.identifier.toLowerCase().split('-').first;
        if (localeLanguage == savedLanguage) {
          return locale;
        }
      }
    }

    return _bestMatchingLocale(locales);
  }

  TranscriptionLocaleOption? _bestMatchingLocale(
    List<TranscriptionLocaleOption> locales,
  ) {
    if (locales.isEmpty) {
      return null;
    }

    final systemTag = WidgetsBinding.instance.platformDispatcher.locale
        .toLanguageTag()
        .toLowerCase();
    final exact = locales.where(
      (locale) => locale.identifier.toLowerCase() == systemTag,
    );
    if (exact.isNotEmpty) {
      return exact.first;
    }

    final systemLanguage = systemTag.split('-').first;
    for (final locale in locales) {
      final localeLanguage = locale.identifier.toLowerCase().split('-').first;
      if (localeLanguage == systemLanguage) {
        return locale;
      }
    }

    return locales.firstWhere(
      (locale) => locale.identifier.toLowerCase().startsWith('en'),
      orElse: () => locales.first,
    );
  }

  static String _displayTitle(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return fileName;
    }
    return fileName.substring(0, dotIndex);
  }

  static String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  static String _formatDuration(int milliseconds) {
    final totalSeconds = milliseconds ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String _languageLabel(TranscriptionLocaleOption locale) {
    return '${_flagPrefixForIdentifier(locale.identifier)} ${locale.displayName} (${locale.identifier})';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet({required this.locales, required this.selected});

  final List<TranscriptionLocaleOption> locales;
  final TranscriptionLocaleOption? selected;

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.locales.where((locale) {
      final haystack = '${locale.displayName} ${locale.identifier}'
          .toLowerCase();
      return haystack.contains(_query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Audio Language',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search languages',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final locale = results[index];
                    final selected =
                        locale.identifier == widget.selected?.identifier;
                    return ListTile(
                      leading: selected
                          ? const Icon(Icons.check, size: 18)
                          : const SizedBox(width: 18),
                      title: Text(
                        _LocalVideoPracticeScreenState._languageLabel(locale),
                      ),
                      subtitle: Text(locale.identifier),
                      trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: locale.isInstalled
                                    ? Colors.green.withValues(alpha: 0.08)
                                    : Colors.orange.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!locale.isInstalled) ...[
                                    Icon(Icons.download_rounded,
                                        size: 13,
                                        color: Colors.orange.shade700),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    locale.isInstalled
                                        ? 'Installed'
                                        : 'Download',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: locale.isInstalled
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                      onTap: () => Navigator.of(context).pop(locale),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _flagPrefixForIdentifier(String identifier) {
  final region = _regionCodeFromIdentifier(identifier);
  if (region == null) {
    return '🌐';
  }
  if (_isNumericRegion(region)) {
    return '🌎';
  }
  if (region.length != 2 || !_isAlphaRegion(region)) {
    return '🏳️';
  }

  final upper = region.toUpperCase();
  return String.fromCharCodes(
    upper.codeUnits.map((unit) => 0x1F1E6 + unit - 0x41),
  );
}

String? _regionCodeFromIdentifier(String identifier) {
  final components = identifier
      .replaceAll('_', '-')
      .split('-')
      .where((component) => component.isNotEmpty)
      .toList();

  if (components.isEmpty) {
    return null;
  }

  var candidateIndex = 1;
  if (components.length > 2 && _isScriptSubtag(components[1])) {
    candidateIndex = 2;
  }

  if (candidateIndex < components.length &&
      _isRegionSubtag(components[candidateIndex])) {
    return components[candidateIndex].toUpperCase();
  }

  for (final component in components.skip(1)) {
    if (_isRegionSubtag(component)) {
      return component.toUpperCase();
    }
  }

  return _defaultRegionForLanguageCode(components.first.toLowerCase());
}

bool _isRegionSubtag(String value) {
  return (value.length == 2 && _isAlphaRegion(value)) ||
      (value.length == 3 && _isNumericRegion(value));
}

bool _isScriptSubtag(String value) {
  return value.length == 4 && _isAlphaRegion(value);
}

bool _isAlphaRegion(String value) {
  final codeUnits = value.codeUnits;
  return codeUnits.every(
    (unit) => (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A),
  );
}

bool _isNumericRegion(String value) {
  final codeUnits = value.codeUnits;
  return codeUnits.every((unit) => unit >= 0x30 && unit <= 0x39);
}

String? _defaultRegionForLanguageCode(String languageCode) {
  const defaults = <String, String>{
    'ar': 'SA',
    'ca': 'ES',
    'cs': 'CZ',
    'da': 'DK',
    'de': 'DE',
    'el': 'GR',
    'en': 'US',
    'es': 'ES',
    'fi': 'FI',
    'fr': 'FR',
    'he': 'IL',
    'hi': 'IN',
    'hr': 'HR',
    'hu': 'HU',
    'id': 'ID',
    'it': 'IT',
    'ja': 'JP',
    'ko': 'KR',
    'ms': 'MY',
    'nl': 'NL',
    'no': 'NO',
    'pl': 'PL',
    'pt': 'BR',
    'ro': 'RO',
    'ru': 'RU',
    'sk': 'SK',
    'sv': 'SE',
    'th': 'TH',
    'tr': 'TR',
    'uk': 'UA',
    'vi': 'VN',
    'yue': 'HK',
    'zh': 'CN',
  };

  return defaults[languageCode];
}
