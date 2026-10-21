import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/user_profile_notifier.dart';
import '../../core/auth_session_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../infrastructure/profile_image_optimizer.dart';
import '../shared/profile_avatar.dart';
import 'edit_profile_name_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  UserProfileNotifier get _profile => UserProfileNotifier.instance;

  @override
  void initState() {
    super.initState();
    if (_profile.profile == null) _profile.loadProfile(force: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context)!.editProfile)),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: _profile,
        builder: (context, _) {
          final l10n = AppLocalizations.of(context)!;
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Align(
                    alignment: const Alignment(0, -.15),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        key: const ValueKey('profile-identity'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            button: true,
                            label: l10n.editProfileChangeImage,
                            child: InkWell(
                              onTap: _profile.isUploadingImage
                                  ? null
                                  : _pickImage,
                              customBorder: const CircleBorder(),
                              child: SizedBox.square(
                                dimension: 144,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ProfileAvatar(
                                      radius: 64,
                                      imageUrl: _profile.avatarUrl,
                                      imagePath: _profile.avatarImagePath,
                                    ),
                                    if (_profile.isUploadingImage)
                                      const Positioned.fill(
                                        child: CircularProgressIndicator(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _profile.isUploadingImage
                                ? null
                                : _pickImage,
                            icon: const Icon(
                              Icons.photo_camera_outlined,
                              size: 20,
                            ),
                            label: Text(
                              _profile.isUploadingImage
                                  ? l10n.editProfileUploading
                                  : l10n.editProfileChangeImage,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              title: Text(
                                l10n.editProfileNameLabel,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _profile.displayName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                              ),
                              onTap: _profile.isSavingProfile
                                  ? null
                                  : _showEditName,
                            ),
                          ),
                          if (_profile.localizedError(l10n)
                              case final error?) ...[
                            const SizedBox(height: 20),
                            Text(
                              error,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  String? _validateName(AppLocalizations l10n, String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return l10n.editProfileEnterName;
    }
    if (normalized.length > 80) {
      return l10n.editProfileNameMaxLength;
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.editProfileImageUpdated),
      ),
    );
  }

  Future<void> _showEditName() async {
    final l10n = AppLocalizations.of(context)!;
    final owner = AuthSessionNotifier.instance.session?.cacheKey;
    _profile.clearError();
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditProfileNameDialog(
        initialName: _profile.profile?.name ?? _profile.displayName,
        validateName: (value) => _validateName(l10n, value),
        onSave: (name) async {
          if (!mounted ||
              AuthSessionNotifier.instance.session?.cacheKey != owner) {
            return false;
          }
          _profile.clearError();
          return _profile.updateName(name);
        },
        errorMessage: () => _profile.localizedError(l10n),
      ),
    );
    if (!mounted ||
        updated != true ||
        AuthSessionNotifier.instance.session?.cacheKey != owner) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.editProfileNameUpdated)));
  }
}
