import 'package:flutter/material.dart';

/// Keep custom Flutter pages and overlays clear of side system UI as the
/// window resizes or moves between the Duo's inner and outer displays.
/// Individual scaffolds still own their top, bottom and keyboard insets.
class AppViewport extends StatelessWidget {
  const AppViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SafeArea(top: false, bottom: false, child: child),
  );
}
