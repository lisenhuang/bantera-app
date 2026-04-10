import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/auth_session_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../core/settings_notifier.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/video_processing_service.dart';

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _transcriptController = TextEditingController();

  XFile? _selectedVideo;
  int? _selectedVideoBytes;
  List<TranscriptionLocaleOption> _supportedLocales = const [];
  TranscriptionLocaleOption? _selectedLocale;
  PreparedVideoUpload? _preparedUpload;

  bool _isLoadingLocales = true;
  bool _isPreparing = false;
  bool _isUploading = false;
  bool _isPublic = false;
  String? _errorMessage;
  String? _prepareStatus;

  @override
  void initState() {
    super.initState();
    _loadSupportedLocales();
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    _disposePreparedUpload();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final prepared = _preparedUpload;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.uploadVideoTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Choose a video from Photos, pick the spoken language, then let iPhone transcribe it before upload.',
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
                  onPressed: _isBusy ? null : _pickVideo,
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
                      label: 'Original size',
                      value: _formatBytes(_selectedVideoBytes!),
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
                    onTap: _supportedLocales.isEmpty || _isBusy
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
                          color: colorScheme.outline.withOpacity(0.3),
                        ),
                        color: colorScheme.surfaceContainerHighest.withOpacity(
                          0.35,
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
                    'Installed languages are marked in the picker. Bantera will download the needed speech asset if iOS requires it.',
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
                Text('3. Visibility', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                CupertinoSlidingSegmentedControl<bool>(
                  groupValue: _isPublic,
                  children: const <bool, Widget>{
                    false: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text('Private'),
                    ),
                    true: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text('Public'),
                    ),
                  },
                  onValueChanged: (value) {
                    if (_isBusy || value == null) {
                      return;
                    }
                    _changeVisibility(value);
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  _isPublic
                      ? 'This upload can be viewed by anyone who has the link.'
                      : 'Only you can access this upload right now.',
                  style: theme.textTheme.bodySmall,
                ),
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
                  '4. Prepare transcript',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _canPrepare ? _prepareVideo : null,
                  icon: const Icon(Icons.auto_awesome_motion_outlined),
                  label: Text(
                    _isPreparing ? 'Preparing...' : 'Transcribe Video',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Bantera will transcribe on device and create a smaller upload copy capped at 720p when needed.',
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
          if (prepared != null) ...[
            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prepared upload', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 14),
                  _InfoRow(label: 'Upload file', value: prepared.fileName),
                  _InfoRow(
                    label: 'Upload size',
                    value: _formatBytes(prepared.fileSizeBytes),
                  ),
                  _InfoRow(
                    label: 'Resolution',
                    value: _formatResolution(
                      prepared.videoWidth,
                      prepared.videoHeight,
                    ),
                  ),
                  _InfoRow(
                    label: 'Duration',
                    value: _formatDuration(prepared.durationMs),
                  ),
                  _InfoRow(
                    label: 'Language',
                    value: prepared.transcriptLanguage,
                  ),
                  _InfoRow(
                    label: 'Cue count',
                    value: prepared.transcriptCues.length.toString(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Timed Transcript Preview',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _transcriptController,
                    minLines: 6,
                    maxLines: 12,
                    readOnly: true,
                    enableInteractiveSelection: true,
                    decoration: const InputDecoration(
                      hintText: 'Transcript text will appear here',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _canUpload ? _uploadVideo : null,
            child: Text(_isUploading ? 'Uploading...' : 'Upload Video'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool get _isBusy => _isPreparing || _isUploading;

  bool get _canPrepare =>
      !_isBusy &&
      _selectedVideo != null &&
      _selectedLocale != null &&
      !_isLoadingLocales;

  bool get _canUpload =>
      !_isBusy &&
      _preparedUpload != null &&
      _preparedUpload!.transcriptCues.isNotEmpty &&
      _preparedUpload!.transcriptText.trim().isNotEmpty;

  Widget _buildSectionCard(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withOpacity(0.12)),
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
    await _disposePreparedUpload();
    setState(() {
      _selectedVideo = picked;
      _selectedVideoBytes = bytes;
      _preparedUpload = null;
      _transcriptController.clear();
      _prepareStatus = null;
    });
  }

  Future<void> _prepareVideo() async {
    final selectedVideo = _selectedVideo;
    final selectedLocale = _selectedLocale;
    if (selectedVideo == null || selectedLocale == null) {
      return;
    }

    _clearError();
    setState(() {
      _isPreparing = true;
      _prepareStatus = 'Transcribing audio and preparing the upload file...';
    });

    try {
      final prepared = await VideoProcessingService.instance
          .prepareVideoForUpload(
            inputFile: File(selectedVideo.path),
            localeIdentifier: selectedLocale.identifier,
          );
      if (!mounted) {
        return;
      }

      await _disposePreparedUpload();
      _transcriptController.text = prepared.transcriptText;
      setState(() {
        _preparedUpload = prepared;
      });
    } on VideoProcessingException catch (error) {
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

  Future<void> _uploadVideo() async {
    final prepared = _preparedUpload;
    final session = AuthSessionNotifier.instance.session;
    if (prepared == null ||
        session == null ||
        prepared.transcriptText.trim().isEmpty ||
        prepared.transcriptCues.isEmpty) {
      setState(() {
        _errorMessage = 'Prepare a transcript before uploading.';
      });
      return;
    }

    _clearError();
    setState(() {
      _isUploading = true;
    });

    try {
      final uploaded = await AuthApiClient.instance.uploadVideo(
        accessToken: session.accessToken,
        videoFile: prepared.file,
        transcriptText: prepared.transcriptText,
        transcriptLanguage: prepared.transcriptLanguage,
        transcriptLanguageCode: prepared.transcriptLanguageCode,
        transcriptCues: prepared.transcriptCues,
        isPublic: _isPublic,
        durationMs: prepared.durationMs,
        videoWidth: prepared.videoWidth,
        videoHeight: prepared.videoHeight,
      );

      if (prepared.shouldDeleteAfterUse) {
        await _deleteFileIfExists(prepared.file);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uploaded.isPublic
                ? 'Video uploaded. It is now public.'
                : 'Video uploaded privately.',
          ),
        ),
      );
      Navigator.of(context).pop(uploaded);
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _changeVisibility(bool nextValue) async {
    if (!nextValue) {
      setState(() {
        _isPublic = false;
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Make this upload public?'),
          content: const Text(
            'Anyone with the link will be able to view this video and transcript.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep Private'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Make Public'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isPublic = true;
      });
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

    await _disposePreparedUpload();
    SettingsNotifier.instance.setLastTranscriptionLocale(selected.identifier);
    setState(() {
      _selectedLocale = selected;
      _preparedUpload = null;
      _transcriptController.clear();
    });
  }

  Future<void> _disposePreparedUpload() async {
    final prepared = _preparedUpload;
    _preparedUpload = null;
    if (prepared?.shouldDeleteAfterUse == true) {
      await _deleteFileIfExists(prepared!.file);
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
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
    final exact = locales.where((locale) {
      return locale.identifier.toLowerCase() == systemTag;
    });
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

  static Future<void> _deleteFileIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
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

  static String _formatDuration(int durationMs) {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatResolution(int? width, int? height) {
    if (width == null || height == null) {
      return 'Unknown';
    }
    return '$width×$height';
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
                        _VideoUploadScreenState._languageLabel(locale),
                      ),
                      subtitle: Text(locale.identifier),
                      trailing: locale.isInstalled
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Installed',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.green.shade700),
                              ),
                            )
                          : null,
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
