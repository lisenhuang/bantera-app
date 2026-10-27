import 'dart:ui' show DisplayFeatureType;
import 'package:flutter/material.dart';
import 'adaptive_layout.dart';

Offset? adaptiveOverlayAnchor(BuildContext context) {
  final layout = AdaptiveLayoutScope.of(context);
  for (final feature in layout.regions) {
    if (feature.type != DisplayFeatureType.fold) continue;
    final r = feature.bounds;
    // Book: trailing pane. Tabletop: upper pane. Avoid the reserved band itself.
    return r.height > r.width ? Offset(r.right + 1, 0) : Offset(0, 0);
  }
  return null;
}

Future<T?> showBanteraDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  bool useSafeArea = true,
  RouteSettings? routeSettings,
  Color? barrierColor,
  String? barrierLabel,
}) => showDialog<T>(
  context: context,
  builder: builder,
  barrierDismissible: barrierDismissible,
  useRootNavigator: useRootNavigator,
  useSafeArea: useSafeArea,
  routeSettings: routeSettings,
  barrierColor: barrierColor,
  barrierLabel: barrierLabel,
  anchorPoint: adaptiveOverlayAnchor(context),
);
Future<T?> showAdaptiveBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = true,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  Color? backgroundColor,
  Color? barrierColor,
  ShapeBorder? shape,
  BoxConstraints? constraints,
  RouteSettings? routeSettings,
  Clip? clipBehavior,
}) => showModalBottomSheet<T>(
  context: context,
  builder: builder,
  isScrollControlled: isScrollControlled,
  useSafeArea: useSafeArea,
  useRootNavigator: useRootNavigator,
  isDismissible: isDismissible,
  enableDrag: enableDrag,
  showDragHandle: showDragHandle,
  backgroundColor: backgroundColor,
  barrierColor: barrierColor,
  shape: shape,
  constraints: constraints ?? const BoxConstraints(maxWidth: 640),
  routeSettings: routeSettings,
  clipBehavior: clipBehavior,
  anchorPoint: adaptiveOverlayAnchor(context),
);
