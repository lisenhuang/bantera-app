import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/user_profile_notifier.dart';
import '../../infrastructure/profile_image_optimizer.dart';
import '../../infrastructure/video_processing_service.dart';
import '../shared/locale_flag.dart';
import '../shared/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _seededInitialName = false;
  List<TranscriptionLocaleOption>? _localeOptions;
  bool _loadingLocales = false;
  String? _localeLoadError;

  UserProfileNotifier get _profile => UserProfileNotifier.instance;

  @override
  void initState() {
    super.initState();
    _nameController.text = _profile.profile?.name ?? _profile.displayName;
    _seededInitialName = _profile.profile != null;
    if (_profile.profile == null) {
      _profile.loadProfile(force: true);
    }
    _loadLocales();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadLocales() async {
    setState(() {
      _loadingLocales = true;
      _localeLoadError = null;
    });
    try {
      final options =
          await VideoProcessingService.instance.fetchSupportedLocales();
      if (mounted) {
        setState(() {
          _localeOptions = options;
          _loadingLocales = false;
        });
      }
    } on VideoProcessingException catch (e) {
      if (mounted) {
        setState(() {
          _localeLoadError = e.message;
          _loadingLocales = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _localeLoadError = 'Could not load language list.';
          _loadingLocales = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _profile,
          builder: (context, _) {
            final profile = _profile.profile;
            if (!_seededInitialName &&
                profile != null &&
                profile.name.trim().isNotEmpty &&
                _nameController.text.trim().isEmpty) {
              _nameController.text = profile.name;
              _seededInitialName = true;
            }

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ProfileAvatar(
                        radius: 48,
                        imageUrl: _profile.avatarUrl,
                        imagePath: _profile.avatarImagePath,
                      ),
                      if (_profile.isUploadingImage)
                        const SizedBox(
                          width: 112,
                          height: 112,
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _profile.isUploadingImage ? null : _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _profile.isUploadingImage
                          ? 'Uploading...'
                          : 'Change Profile Image',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'How should Bantera show your name?',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: _validateName,
                    onFieldSubmitted: (_) => _saveName(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _profile.isSavingProfile ? null : _saveName,
                    child: Text(
                      _profile.isSavingProfile ? 'Saving...' : 'Save Name',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Languages'),
                const SizedBox(height: 12),
                _buildLanguageTile(
                  context,
                  label: 'My Native Language',
                  subtitle: 'Your native or first language',
                  icon: Icons.record_voice_over_outlined,
                  currentIdentifier: _profile.nativeLanguage,
                  onTap: _profile.isSavingProfile
                      ? null
                      : () => _showLanguagePicker(
                            title: 'My Native Language',
                            currentIdentifier: _profile.nativeLanguage,
                            onSelected: _saveNativeLanguage,
                          ),
                ),
                const SizedBox(height: 12),
                _buildLanguageTile(
                  context,
                  label: 'Learning Language',
                  subtitle: 'The language you want to practice',
                  icon: Icons.school_outlined,
                  currentIdentifier: _profile.learningLanguage,
                  onTap: _profile.isSavingProfile
                      ? null
                      : () => _showLanguagePicker(
                            title: 'Learning Language',
                            currentIdentifier: _profile.learningLanguage,
                            onSelected: _saveLearningLanguage,
                            showClearOption: false,
                          ),
                ),
                if (_profile.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      _profile.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required String? currentIdentifier,
    required VoidCallback? onTap,
  }) {
    final displayName = _displayNameForIdentifier(currentIdentifier);
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
        onTap: _loadingLocales ? null : onTap,
      ),
    );
  }

  String? _displayNameForIdentifier(String? identifier) {
    if (identifier == null || identifier.isEmpty) {
      return null;
    }
    final options = _localeOptions;
    if (options != null) {
      final match = options
          .where((o) => o.identifier == identifier)
          .firstOrNull;
      if (match != null) {
        return match.displayName;
      }
    }
    return identifier;
  }

  Future<void> _showLanguagePicker({
    required String title,
    required String? currentIdentifier,
    required Future<void> Function(TranscriptionLocaleOption) onSelected,
    bool showClearOption = true,
  }) async {
    final options = _localeOptions;
    if (options == null) {
      if (_localeLoadError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_localeLoadError!)),
        );
      }
      return;
    }

    // "zh-TW" is hidden from the Learning Language picker because iOS
    // transcription treats it as Traditional Chinese, which overlaps with
    // zh-Hans/zh-HK in practice.  It remains available for Native Language.
    final filteredOptions = title == 'Learning Language'
        ? options.where((o) => o.identifier != 'zh-TW').toList()
        : options;

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
          currentIdentifier: currentIdentifier,
          showClearOption: showClearOption,
          onSelected: (option) {
            Navigator.of(context).pop();
            onSelected(option);
          },
        );
      },
    );
  }

  String? _validateName(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Enter a name.';
    }
    if (normalized.length > 80) {
      return 'Use 80 characters or fewer.';
    }
    return null;
  }

  Future<void> _pickImage() async {
    _profile.clearError();
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
      requestFullMetadata: false,
    );
    if (picked == null) {
      return;
    }

    final file = await ProfileImageOptimizer.optimize(File(picked.path));
    final updated = await _profile.uploadAvatar(file);
    if (!mounted || !updated) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile image updated.')));
  }

  Future<void> _saveName() async {
    FocusScope.of(context).unfocus();
    _profile.clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updated = await _profile.updateName(_nameController.text);
    if (!mounted || !updated) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Name updated.')));
  }

  Future<void> _saveNativeLanguage(TranscriptionLocaleOption option) async {
    _profile.clearError();
    final clearing = option.identifier.isEmpty;
    final updated = await _profile.updateNativeLanguage(option.identifier);
    if (!mounted || !updated) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          clearing
              ? 'Native language cleared.'
              : 'Native language set to ${option.displayName}.',
        ),
      ),
    );
  }

  Future<void> _saveLearningLanguage(TranscriptionLocaleOption option) async {
    _profile.clearError();
    final clearing = option.identifier.isEmpty;
    final updated = await _profile.updateLearningLanguage(option.identifier);
    if (!mounted || !updated) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          clearing
              ? 'Learning language cleared.'
              : 'Learning language set to ${option.displayName}.',
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
                  hintText: 'Search languages…',
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
                title: const Text('None'),
                subtitle: const Text('Clear selection'),
                onTap: () => widget.onSelected(
                  const TranscriptionLocaleOption(
                    identifier: '',
                    displayName: 'None',
                    isInstalled: false,
                  ),
                ),
              ),
              const Divider(height: 1),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('No languages found.'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final option = _filtered[index];
                        final isSelected =
                            option.identifier == widget.currentIdentifier;
                        final flag = flagEmojiForLocale(option.identifier);
                        return ListTile(
                          leading: Text(
                            flag,
                            style: const TextStyle(fontSize: 28),
                          ),
                          title: Text(option.displayName),
                          subtitle: Text(
                            option.identifier,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => widget.onSelected(option),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
