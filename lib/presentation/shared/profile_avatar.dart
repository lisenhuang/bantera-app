import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../infrastructure/avatar_image_cache.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({
    super.key,
    required this.radius,
    this.imageUrl,
    this.imagePath,
    this.refreshToken = 0,
  });

  final double radius;
  final String? imageUrl;
  final String? imagePath;
  final int refreshToken;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  AvatarImageEntry? _entry;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.imagePath != widget.imagePath ||
        oldWidget.refreshToken != widget.refreshToken) {
      _load(force: oldWidget.refreshToken != widget.refreshToken);
    }
  }

  void _load({bool force = false}) {
    _entry?.removeListener(_updated);
    final url = widget.imageUrl?.trim();
    _entry =
        widget.imagePath?.trim().isNotEmpty == true ||
            url == null ||
            url.isEmpty
        ? null
        : AvatarImageCache.instance.entry(url);
    _entry?.addListener(_updated);
    if (_entry != null) {
      unawaited(AvatarImageCache.instance.refresh(url!, force: force));
    }
  }

  void _updated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _entry?.removeListener(_updated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius;
    final bytes = _entry?.value;
    final hasLocalImage = widget.imagePath?.trim().isNotEmpty == true;
    final placeholder = Icon(
      Icons.person,
      size: radius,
      color: Theme.of(context).colorScheme.primary,
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.12),
      child: ClipOval(
        child: SizedBox.square(
          dimension: radius * 2,
          child: hasLocalImage
              ? Image.file(
                  File(widget.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder,
                )
              : bytes != null
              ? Image.memory(
                  bytes,
                  key: ValueKey(widget.imageUrl),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  cacheWidth:
                      (radius * 2 * MediaQuery.devicePixelRatioOf(context))
                          .ceil(),
                  errorBuilder: (_, _, _) => placeholder,
                )
              : placeholder,
        ),
      ),
    );
  }
}
