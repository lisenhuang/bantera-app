import 'package:flutter/material.dart';
import 'adaptive_layout.dart';
import 'adaptive_viewport_state.dart';

/// Keep custom Flutter pages and overlays clear of side system UI as the
/// window resizes or moves between the Duo's inner and outer displays.
/// Individual scaffolds still own their top, bottom and keyboard insets.
class AppViewport extends StatelessWidget {
  const AppViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AdaptiveLayoutHost(
    child: ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListenableBuilder(
        listenable: adaptiveViewportState,
        builder: (context, _) {
          final edge = AdaptiveLayoutScope.of(context).edge;
          final rail = adaptiveViewportState.usesEdgeRail;
          return SafeArea(
            top: false,
            bottom: false,
            left: !(rail && edge == NavigationEdge.left),
            right: !(rail && edge == NavigationEdge.right),
            child: child,
          );
        },
      ),
    ),
  );
}
