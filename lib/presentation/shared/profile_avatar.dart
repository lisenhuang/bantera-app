import 'dart:io';

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.radius,
    this.imageUrl,
    this.imagePath,
  });

  final double radius;
  final String? imageUrl;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final hasLocalImage = imagePath != null && imagePath!.trim().isNotEmpty;
    final imageProvider = hasLocalImage
        ? FileImage(File(imagePath!)) as ImageProvider<Object>
        : hasImage
        ? NetworkImage(imageUrl!)
        : null;

    return CircleAvatar(
      radius: radius,
      foregroundImage: imageProvider,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.12),
      child: imageProvider != null
          ? null
          : Icon(
              Icons.person,
              size: radius,
              color: Theme.of(context).colorScheme.primary,
            ),
    );
  }
}
