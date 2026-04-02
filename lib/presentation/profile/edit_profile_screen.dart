import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/user_profile_notifier.dart';
import '../../infrastructure/profile_image_optimizer.dart';
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

  UserProfileNotifier get _profile => UserProfileNotifier.instance;

  @override
  void initState() {
    super.initState();
    _nameController.text = _profile.profile?.name ?? _profile.displayName;
    _seededInitialName = _profile.profile != null;
    if (_profile.profile == null) {
      _profile.loadProfile(force: true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _profile.isSavingName ? null : _saveName,
                    child: Text(
                      _profile.isSavingName ? 'Saving...' : 'Save Name',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
}
