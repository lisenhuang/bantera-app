import 'package:flutter/scheduler.dart';
import 'dart:ui' show DisplayFeature, DisplayFeatureType, DisplayFeatureState;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

enum NavigationEdge { horizontal, left, right }

@immutable
class AdaptiveLayoutData {
  const AdaptiveLayoutData({
    this.edge = NavigationEdge.horizontal,
    this.regions = const [],
    this.halfOpen = false,
    this.statusBarBottom = 0,
  });
  final NavigationEdge edge;
  final List<DisplayFeature> regions;
  final bool halfOpen;
  final double statusBarBottom;

  factory AdaptiveLayoutData.fromMap(Map<dynamic, dynamic> value) {
    final halfOpen = value['hingeStatus'] == 2;
    return AdaptiveLayoutData(
      edge: switch (value['edge']) {
        'left' => NavigationEdge.left,
        'right' => NavigationEdge.right,
        _ => NavigationEdge.horizontal,
      },
      halfOpen: halfOpen,
      statusBarBottom: (value['statusBarBottom'] as num?)?.toDouble() ?? 0,
      regions: [
        for (final raw in (value['regions'] as List? ?? []))
          if (raw is Map)
            DisplayFeature(
              bounds: Rect.fromLTWH(
                (raw['x'] as num).toDouble(),
                (raw['y'] as num).toDouble(),
                (raw['width'] as num).toDouble(),
                (raw['height'] as num).toDouble(),
              ),
              type: raw['kind'] == 'division'
                  ? DisplayFeatureType.fold
                  : DisplayFeatureType.cutout,
              state: raw['kind'] == 'division'
                  ? (halfOpen
                        ? DisplayFeatureState.postureHalfOpened
                        : DisplayFeatureState.postureFlat)
                  : DisplayFeatureState.unknown,
            ),
      ],
    );
  }
}

/// One listener for the current UIKit window, never a device-name heuristic.
class AdaptiveLayoutHost extends StatefulWidget {
  const AdaptiveLayoutHost({super.key, required this.child});
  final Widget child;
  @override
  State<AdaptiveLayoutHost> createState() => _AdaptiveLayoutHostState();
}

class _AdaptiveLayoutHostState extends State<AdaptiveLayoutHost>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('bantera/adaptive_layout');
  AdaptiveLayoutData _data = const AdaptiveLayoutData();
  bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_supported) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'layoutChanged') _receive(call.arguments);
      });
      unawaited(_refresh());
    }
  }

  void _receive(dynamic value) {
    if (mounted && value is Map) {
      setState(() => _data = AdaptiveLayoutData.fromMap(value));
    }
  }

  Future<void> _refresh() async {
    if (!_supported) return;
    try {
      _receive(await _channel.invokeMapMethod<String, dynamic>('getLayout'));
    } on PlatformException {
      /* Keep the last known layout on transient errors. */
    } on MissingPluginException {
      /* Older OS and Flutter test hosts. */
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_supported) _channel.setMethodCallHandler(null);
    super.dispose();
  }

  MediaQueryData _media(BuildContext context) {
    final media = MediaQuery.of(context);
    var top = media.padding.top;
    final usable = Rect.fromLTRB(
      media.padding.left,
      0,
      media.size.width - media.padding.right,
      media.size.height,
    );
    for (final feature in _data.regions) {
      final rect = feature.bounds;
      if (feature.type == DisplayFeatureType.cutout &&
          rect.overlaps(usable) &&
          rect.top <= top + 1 &&
          rect.bottom < media.size.height / 3) {
        top = rect.bottom > top ? rect.bottom : top;
      }
    }
    return media.copyWith(
      padding: media.padding.copyWith(top: top),
      viewPadding: media.viewPadding.copyWith(
        top: top > media.viewPadding.top ? top : media.viewPadding.top,
      ),
      displayFeatures: [...media.displayFeatures, ..._data.regions],
    );
  }

  @override
  Widget build(BuildContext context) => AdaptiveLayoutScope(
    data: _data,
    child: MediaQuery(data: _media(context), child: widget.child),
  );
}

class AdaptiveLayoutScope extends InheritedWidget {
  const AdaptiveLayoutScope({
    super.key,
    required this.data,
    required super.child,
  });
  final AdaptiveLayoutData data;
  static AdaptiveLayoutData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveLayoutScope>()?.data ??
      const AdaptiveLayoutData();
  @override
  bool updateShouldNotify(AdaptiveLayoutScope oldWidget) =>
      data != oldWidget.data;
}

/// Keeps the same render/element children in both arrangements. In particular,
/// text selection, recording gestures, scroll controllers and players survive.
class AdaptiveColumns extends MultiChildRenderObjectWidget {
  AdaptiveColumns({
    super.key,
    required Widget first,
    required Widget second,
    this.minimumPaneWidth = 320,
    this.gap = 24,
    this.fillHeight = false,
    this.firstFraction = .5,
    this.singlePane = 0,
    required this.textScale,
    this.regions = const [],
  }) : super(children: [first, second]);
  final double minimumPaneWidth, gap, firstFraction, textScale;
  final bool fillHeight;

  /// In a bounded narrow host, show one pane without unmounting the other.
  final int singlePane;
  final List<DisplayFeature> regions;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderAdaptiveColumns(this);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderAdaptiveColumns renderObject,
  ) => renderObject.config = this;
}

class _PaneData extends ContainerBoxParentData<RenderBox> {
  bool visible = true;
}

class RenderAdaptiveColumns extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PaneData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PaneData> {
  RenderAdaptiveColumns(this._config);
  AdaptiveColumns _config;
  set config(AdaptiveColumns value) {
    _config = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PaneData) child.parentData = _PaneData();
  }

  Offset _origin = Offset.zero;
  void _refreshOrigin() {
    final next = localToGlobal(Offset.zero);
    if (next == _origin) return;
    _origin = next;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (attached) markNeedsLayout();
    });
  }

  @override
  void performLayout() {
    final a = firstChild!, b = lastChild!;
    final width = constraints.maxWidth;
    final minPane =
        _config.minimumPaneWidth * _config.textScale.clamp(1.0, 1.5);
    var left = (width - _config.gap) * _config.firstFraction;
    var gap = _config.gap;
    if (width >= minPane * 2 + gap) {
      left = left.clamp(minPane, width - gap - minPane);
    }
    var foldSplit = false;
    // Reserved frames are window-local points, the same logical units as Flutter.
    final origin = _origin;
    for (final feature in _config.regions) {
      if (feature.type != DisplayFeatureType.fold) continue;
      final rect = feature.bounds.shift(-origin);
      if (rect.height > rect.width &&
          rect.left >= 240 &&
          width - rect.right >= 240) {
        left = rect.left;
        gap = rect.width;
        foldSplit = true;
        break;
      }
    }
    final wide =
        foldSplit || (left >= minPane && width - left - gap >= minPane);
    final bounded = _config.fillHeight && constraints.hasBoundedHeight;
    final ad = a.parentData! as _PaneData, bd = b.parentData! as _PaneData;
    ad.visible = !bounded || wide || _config.singlePane == 0;
    bd.visible = !bounded || wide || _config.singlePane == 1;
    a.layout(
      BoxConstraints.tightFor(
        width: wide ? left : width,
        height: bounded ? constraints.maxHeight : null,
      ),
      parentUsesSize: true,
    );
    b.layout(
      BoxConstraints.tightFor(
        width: wide ? width - left - gap : width,
        height: bounded ? constraints.maxHeight : null,
      ),
      parentUsesSize: true,
    );
    ad.offset = Offset.zero;
    bd.offset = wide
        ? Offset(left + gap, 0)
        : bounded
        ? Offset.zero
        : Offset(0, a.size.height + gap);
    size = constraints.constrain(
      Size(
        width,
        bounded
            ? constraints.maxHeight
            : wide
            ? (a.size.height > b.size.height ? a.size.height : b.size.height)
            : a.size.height + gap + b.size.height,
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_config.regions.isNotEmpty) _refreshOrigin();
    for (final child in [firstChild!, lastChild!]) {
      final data = child.parentData! as _PaneData;
      if (data.visible) context.paintChild(child, offset + data.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final child in [lastChild!, firstChild!]) {
      final data = child.parentData! as _PaneData;
      if (data.visible &&
          result.addWithPaintOffset(
            offset: data.offset,
            position: position,
            hitTest: (result, transformed) =>
                child.hitTest(result, position: transformed),
          )) {
        return true;
      }
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    for (final child in [firstChild!, lastChild!]) {
      if ((child.parentData! as _PaneData).visible) visitor(child);
    }
  }
}
