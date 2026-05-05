import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/user_profile_notifier.dart';
import '../../infrastructure/profile_image_optimizer.dart';
import '../../infrastructure/video_processing_service.dart';
import '../../l10n/app_localizations.dart';
import '../shared/locale_flag.dart';
import '../shared/profile_avatar.dart';

class LearningLanguageSetupScreen extends StatefulWidget {
  const LearningLanguageSetupScreen({super.key});

  @override
  State<LearningLanguageSetupScreen> createState() =>
      _LearningLanguageSetupScreenState();
}

class _LearningLanguageSetupScreenState
    extends State<LearningLanguageSetupScreen> {
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();

  List<TranscriptionLocaleOption>? _nativeLocales;
  List<TranscriptionLocaleOption>? _learningLocales;
  TranscriptionLocaleOption? _nativeLocale;
  TranscriptionLocaleOption? _learningLocale;
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    final profile = UserProfileNotifier.instance;
    _nameController.text = profile.profile?.name ?? profile.displayName;
    _loadLocales();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadLocales() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        VideoProcessingService.instance.fetchNativeLanguageOptions(),
        VideoProcessingService.instance.fetchLearningLanguageOptions(),
      ]);
      if (!mounted) return;
      final profile = UserProfileNotifier.instance;
      setState(() {
        _nativeLocales = results[0];
        _learningLocales = results[1];
        _nativeLocale = _findLocale(results[0], profile.nativeLanguage);
        _learningLocale = _findLocale(results[1], profile.learningLanguage);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context)!.onboardingLoadFailed;
        _isLoading = false;
      });
    }
  }

  TranscriptionLocaleOption? _findLocale(
    List<TranscriptionLocaleOption> options,
    String? identifier,
  ) {
    final normalized = identifier?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    for (final option in options) {
      if (option.identifier == normalized) return option;
    }
    final lookup = normalizeLocaleIdentifierForLookup(normalized);
    for (final option in options) {
      if (normalizeLocaleIdentifierForLookup(option.identifier) == lookup) {
        return option;
      }
    }
    return null;
  }

  bool get _canContinue {
    final name = _nameController.text.trim();
    return switch (_step) {
      0 => name.isNotEmpty && name.length <= 80,
      1 => _nativeLocale != null,
      2 => _learningLocale != null,
      _ => true,
    };
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_canContinue) return;
    if (_step < 3) {
      setState(() => _step += 1);
      return;
    }
    _finish();
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0 || _isSaving) return;
    setState(() => _step -= 1);
  }

  Future<void> _finish() async {
    final nativeLocale = _nativeLocale;
    final learningLocale = _learningLocale;
    if (nativeLocale == null || learningLocale == null) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final profile = UserProfileNotifier.instance;
    profile.clearError();
    final image = _selectedImage;
    if (image != null) {
      final uploaded = await profile.uploadAvatar(image);
      if (!uploaded) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _error =
              profile.localizedError(AppLocalizations.of(context)!) ??
              AppLocalizations.of(context)!.onboardingFailedSave;
        });
        return;
      }
    }

    final saved = await profile.completeInitialProfile(
      name: _nameController.text,
      nativeLanguage: nativeLocale.identifier,
      learningLanguage: learningLocale.identifier,
    );
    if (!saved) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error =
            profile.localizedError(AppLocalizations.of(context)!) ??
            AppLocalizations.of(context)!.onboardingFailedSave;
      });
      return;
    }

    if (image == null) {
      await profile.requestGeneratedAvatar();
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      requestFullMetadata: false,
    );
    if (picked == null) return;
    final file = await ProfileImageOptimizer.optimize(File(picked.path));
    if (!mounted) return;
    setState(() => _selectedImage = file);
  }

  Future<void> _chooseLanguage({required bool learning}) async {
    final options = learning ? _learningLocales : _nativeLocales;
    if (options == null || options.isEmpty) return;
    final selected = await showModalBottomSheet<TranscriptionLocaleOption>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _LanguagePickerSheet(
        title: learning
            ? AppLocalizations.of(context)!.onboardingLearningLanguageTitle
            : AppLocalizations.of(context)!.onboardingNativeLanguageTitle,
        options: options,
        currentIdentifier: learning
            ? _learningLocale?.identifier
            : _nativeLocale?.identifier,
        showComingSoonFooter: learning,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (learning) {
        _learningLocale = selected;
      } else {
        _nativeLocale = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading || _isSaving
            ? _LoadingState(
                label: _isSaving
                    ? l10n.onboardingSavingProfile
                    : l10n.onboardingLoadingProfile,
              )
            : _error != null && _nativeLocales == null
            ? _ErrorState(message: _error!, onRetry: _loadLocales)
            : Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressHeader(step: _step),
                    const SizedBox(height: 28),
                    Expanded(child: _buildStep(context)),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_step > 0)
                          TextButton(
                            onPressed: _back,
                            child: Text(l10n.onboardingBack),
                          )
                        else
                          const Spacer(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _canContinue ? _next : null,
                            child: Text(
                              _step == 3
                                  ? l10n.onboardingFinish
                                  : l10n.continueLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (_step) {
      0 => _NameStep(
        controller: _nameController,
        onChanged: () => setState(() {}),
      ),
      1 => _LanguageStep(
        title: l10n.onboardingNativeLanguageTitle,
        subtitle: l10n.onboardingNativeLanguageSubtitle,
        option: _nativeLocale,
        onTap: () => _chooseLanguage(learning: false),
      ),
      2 => _LanguageStep(
        title: l10n.onboardingLearningLanguageTitle,
        subtitle: l10n.onboardingLearningLanguageSubtitle,
        option: _learningLocale,
        onTap: () => _chooseLanguage(learning: true),
      ),
      _ => _AvatarStep(
        image: _selectedImage,
        onPickImage: _pickImage,
        onClearImage: () => setState(() => _selectedImage = null),
      ),
    };
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final active = index <= step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.onboardingNameTitle, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(l10n.onboardingNameSubtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 28),
        TextField(
          controller: controller,
          maxLength: 80,
          textInputAction: TextInputAction.done,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: l10n.editProfileNameLabel,
            prefixIcon: const Icon(Icons.person_outline),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.onboardingClearName,
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      onChanged();
                    },
                  ),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep({
    required this.title,
    required this.subtitle,
    required this.option,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final TranscriptionLocaleOption? option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selected = option;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 28),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: selected == null
                ? const Icon(Icons.language)
                : Text(
                    selected.effectiveFlagEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
            title: Text(selected?.displayName ?? l10n.onboardingChooseLanguage),
            subtitle: selected == null ? null : Text(selected.identifier),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _AvatarStep extends StatelessWidget {
  const _AvatarStep({
    required this.image,
    required this.onPickImage,
    required this.onClearImage,
  });

  final File? image;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.onboardingAvatarTitle, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(l10n.onboardingAvatarSubtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 32),
        Center(child: ProfileAvatar(radius: 56, imagePath: image?.path)),
        const SizedBox(height: 18),
        Center(
          child: OutlinedButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              image == null
                  ? l10n.onboardingChoosePhoto
                  : l10n.onboardingChangePhoto,
            ),
          ),
        ),
        if (image != null) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onClearImage,
              child: Text(l10n.onboardingUseGeneratedAvatar),
            ),
          ),
        ],
      ],
    );
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet({
    required this.title,
    required this.options,
    required this.currentIdentifier,
    required this.showComingSoonFooter,
  });

  final String title;
  final List<TranscriptionLocaleOption> options;
  final String? currentIdentifier;
  final bool showComingSoonFooter;

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  final _searchController = TextEditingController();
  late List<TranscriptionLocaleOption> _filtered = widget.options;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.options
          : widget.options
                .where(
                  (option) =>
                      option.displayName.toLowerCase().contains(query) ||
                      option.identifier.toLowerCase().contains(query),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.onboardingSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _searchController.clear,
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(child: Text(l10n.onboardingNoMatching))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final option = _filtered[index];
                        final selected =
                            option.identifier == widget.currentIdentifier;
                        return ListTile(
                          leading: Text(
                            option.effectiveFlagEmoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          title: Text(option.displayName),
                          subtitle: Text(option.identifier),
                          trailing: selected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
            if (widget.showComingSoonFooter) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.languagePickerMoreComingSoon,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.onboardingRetry),
            ),
          ],
        ),
      ),
    );
  }
}
