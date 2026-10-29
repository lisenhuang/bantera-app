import '../shared/language_code_label.dart';
import '../shared/selected_language_list.dart';
import 'package:flutter/material.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../infrastructure/region_service.dart';
import '../../infrastructure/video_processing_service.dart';
import '../../l10n/app_localizations.dart';
import '../shared/language_picker_totals.dart';
import '../shared/locale_flag.dart';

/// Native and learning language preferences on Edit Profile.
class ProfileLanguageSettings extends StatefulWidget {
  const ProfileLanguageSettings({super.key});

  @override
  State<ProfileLanguageSettings> createState() =>
      _ProfileLanguageSettingsState();
}

class _ProfileLanguageSettingsState extends State<ProfileLanguageSettings> {
  List<TranscriptionLocaleOption>?
  _localeOptions; // native picker (transcription + translation)
  List<TranscriptionLocaleOption>?
  _learningLocaleOptions; // learning picker (transcription only)
  bool _loadingLocales = false;
  String? _localeLoadError;

  UserProfileNotifier get _profile => UserProfileNotifier.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          _profile.profile == null &&
          AuthSessionNotifier.instance.isAuthenticated) {
        _profile.loadProfile(force: true);
      }
    });
    if (AuthSessionNotifier.instance.isAuthenticated) _loadLocales();
  }

  Future<void> _loadLocales() async {
    setState(() {
      _loadingLocales = true;
      _localeLoadError = null;
    });
    try {
      final results = await Future.wait([
        VideoProcessingService.instance.fetchNativeLanguageOptions(),
        VideoProcessingService.instance.fetchLearningLanguageOptions(),
      ]);
      if (mounted) {
        setState(() {
          _localeOptions = results[0];
          _learningLocaleOptions = results[1];
          _loadingLocales = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _localeLoadError = AppLocalizations.of(
            context,
          )!.editProfileCouldNotLoadLanguages;
          _loadingLocales = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _profile,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context)!;
      return Column(
        children: [
          _buildLanguageTile(
            context,
            label: l10n.editProfileMyNativeLanguage,
            subtitle: l10n.editProfileMyNativeLanguageSubtitle,
            icon: Icons.record_voice_over_outlined,
            currentIdentifier: _profile.nativeLanguage,
            displayOptions: _localeOptions,
            onTap: _profile.isSavingProfile
                ? null
                : () => _showLanguagePicker(
                    title: l10n.editProfileMyNativeLanguage,
                    isLearningPicker: false,
                    currentIdentifier: _profile.nativeLanguage,
                    onSelected: _saveNativeLanguage,
                    showClearOption: false,
                  ),
          ),
          const SizedBox(height: 12),
          _buildLanguageTile(
            context,
            label: l10n.editProfileLearningLanguage,
            subtitle: l10n.editProfileLearningLanguageSubtitle,
            icon: Icons.school_outlined,
            currentIdentifier: _profile.learningLanguage,
            displayOptions: _learningLocaleOptions,
            applyLegacyLearningDefaults: true,
            onTap: _profile.isSavingProfile
                ? null
                : () => _showLanguagePicker(
                    title: l10n.editProfileLearningLanguage,
                    isLearningPicker: true,
                    currentIdentifier: _profile.learningLanguage,
                    onSelected: _saveLearningLanguage,
                    showClearOption: false,
                  ),
          ),
          if (_profile.localizedError(l10n) != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Text(
                _profile.localizedError(l10n)!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
              ),
            ),
          ],
        ],
      );
    },
  );

  Widget _buildLanguageTile(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required String? currentIdentifier,
    required List<TranscriptionLocaleOption>? displayOptions,
    required VoidCallback? onTap,
    bool applyLegacyLearningDefaults = false,
  }) {
    final displayName = _displayNameForIdentifier(
      currentIdentifier,
      displayOptions,
      applyLegacyLearningDefaults: applyLegacyLearningDefaults,
    );
    final flag = currentIdentifier != null
        ? flagEmojiForLocale(currentIdentifier)
        : null;
    final subtitleText = displayName != null
        ? (flag != null ? '$flag  $displayName' : displayName)
        : subtitle;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          subtitleText,
          style: displayName == null
              ? Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey)
              : null,
        ),
        trailing: _loadingLocales
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: _loadingLocales || !AuthSessionNotifier.instance.isAuthenticated
            ? null
            : onTap,
      ),
    );
  }

  String? _displayNameForIdentifier(
    String? identifier,
    List<TranscriptionLocaleOption>? options, {
    bool applyLegacyLearningDefaults = false,
  }) {
    if (identifier == null || identifier.isEmpty) {
      return null;
    }
    if (options != null) {
      final targetIdentifier = applyLegacyLearningDefaults
          ? normalizeLegacyLearningLanguageIdentifier(identifier)
          : identifier;
      final normalizedTarget = normalizeLocaleIdentifierForLookup(
        targetIdentifier,
      );
      final match = options
          .where((o) => o.identifier == identifier)
          .firstOrNull;
      final fallbackMatch =
          match ??
          options
              .where(
                (o) =>
                    normalizeLocaleIdentifierForLookup(o.identifier) ==
                    normalizedTarget,
              )
              .firstOrNull;
      if (fallbackMatch != null) {
        return fallbackMatch.displayName;
      }
    }
    return languageCodeLabel(identifier);
  }

  String? _selectedIdentifierForPicker({
    required bool isLearningPicker,
    required String? currentIdentifier,
  }) {
    if (!isLearningPicker ||
        currentIdentifier == null ||
        currentIdentifier.isEmpty) {
      return currentIdentifier;
    }
    return normalizeLegacyLearningLanguageIdentifier(currentIdentifier);
  }

  Future<void> _showLanguagePicker({
    required String title,
    required bool isLearningPicker,
    required String? currentIdentifier,
    required Future<void> Function(TranscriptionLocaleOption) onSelected,
    bool showClearOption = true,
  }) async {
    // Learning picker uses transcription-only list; native picker uses combined list.
    final options = isLearningPicker ? _learningLocaleOptions : _localeOptions;
    if (options == null) {
      if (_localeLoadError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_localeLoadError!)));
      }
      return;
    }

    final filteredOptions = await RegionService.instance.profileLanguageOptions(
      options,
      isAdmin: AuthSessionNotifier.instance.session?.isAdmin == true,
      currentIsAdmin: () =>
          AuthSessionNotifier.instance.session?.isAdmin == true,
      nativeLanguage: !isLearningPicker,
    );
    if (!mounted) return;
    final selectedIdentifier = _selectedIdentifierForPicker(
      isLearningPicker: isLearningPicker,
      currentIdentifier: currentIdentifier,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _LanguagePickerSheet(
          title: title,
          options: filteredOptions,
          currentIdentifier: selectedIdentifier,
          showClearOption: showClearOption,

          onSelected: (option) {
            Navigator.of(context).pop();
            onSelected(option);
          },
        );
      },
    );
  }

  Future<void> _saveNativeLanguage(TranscriptionLocaleOption option) async {
    _profile.clearError();
    final clearing = option.identifier.isEmpty;
    final updated = await _profile.updateNativeLanguage(option.identifier);
    if (!mounted || !updated) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          clearing
              ? l10n.editProfileNativeLanguageCleared
              : l10n.editProfileNativeLanguageSetTo(option.displayName),
        ),
      ),
    );
  }

  Future<void> _saveLearningLanguage(TranscriptionLocaleOption option) async {
    _profile.clearError();
    final clearing = option.identifier.isEmpty;
    final updated = await _profile.updateLearningLanguage(option.identifier);
    if (!mounted || !updated) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          clearing
              ? l10n.editProfileLearningLanguageCleared
              : l10n.editProfileLearningLanguageSetTo(option.displayName),
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet({
    required this.title,
    required this.options,
    required this.currentIdentifier,
    required this.showClearOption,

    required this.onSelected,
  });

  final String title;
  final List<TranscriptionLocaleOption> options;
  final String? currentIdentifier;
  final bool showClearOption;

  final void Function(TranscriptionLocaleOption) onSelected;

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  final _searchController = TextEditingController();
  List<TranscriptionLocaleOption> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.options;
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
      if (query.isEmpty) {
        _filtered = widget.options;
      } else {
        _filtered = widget.options
            .where(
              (o) =>
                  o.displayName.toLowerCase().contains(query) ||
                  o.identifier.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        final l10n = AppLocalizations.of(context)!;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: l10n.onboardingSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            // "None" clear row — only for pickers that allow clearing (e.g. Native Language).
            if (widget.showClearOption &&
                (widget.currentIdentifier?.isNotEmpty ?? false) &&
                _searchController.text.isEmpty) ...[
              const SizedBox(height: 4),
              ListTile(
                leading: const Text('🚫', style: TextStyle(fontSize: 28)),
                title: Text(l10n.languagePickerNone),
                subtitle: Text(l10n.languagePickerClearSelection),
                onTap: () => widget.onSelected(
                  TranscriptionLocaleOption(
                    identifier: '',
                    displayName: l10n.languagePickerNone,
                    isInstalled: false,
                  ),
                ),
              ),
              const Divider(height: 1),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(child: Text(l10n.languagePickerNoMatchingLanguages))
                  : SelectedLanguageList(
                      controller: scrollController,
                      identifiers: _filtered.map((o) => o.identifier).toList(),
                      selectedIdentifier: widget.currentIdentifier,
                      itemBuilder: (context, index) {
                        final option = _filtered[index];
                        final isSelected =
                            option.identifier == widget.currentIdentifier;
                        final flag = option.effectiveFlagEmoji;
                        return ListTile(
                          leading: Text(
                            flag,
                            style: const TextStyle(fontSize: 28),
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(option.displayName)),
                              if (option.isAdminOnly)
                                const Icon(
                                  Icons.admin_panel_settings_outlined,
                                  size: 18,
                                ),
                            ],
                          ),
                          subtitle: Text(
                            languageCodeLabel(option.identifier),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => widget.onSelected(option),
                        );
                      },
                    ),
            ),
            LanguagePickerTotals(
              identifiers: widget.options.map((option) => option.identifier),
            ),
          ],
        );
      },
    );
  }
}
