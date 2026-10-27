import 'package:flutter/scheduler.dart';
import 'dart:ui' show DisplayFeature, DisplayFeatureType;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Places controls below content, with an actual horizontal division as the
/// tabletop boundary. Children retain identity across every arrangement.
class AdaptivePlayerFrame extends MultiChildRenderObjectWidget {
  AdaptivePlayerFrame({
    super.key,
    required Widget content,
    required Widget controls,
    required this.regions,
  }) : super(children: [content, controls]);
  final List<DisplayFeature> regions;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderAdaptivePlayerFrame(regions);
  @override
  void updateRenderObject(
    BuildContext context,
    RenderAdaptivePlayerFrame renderObject,
  ) => renderObject.regions = regions;
}

class _PlayerData extends ContainerBoxParentData<RenderBox> {}

class RenderAdaptivePlayerFrame extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PlayerData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PlayerData> {
  RenderAdaptivePlayerFrame(this._regions);
  List<DisplayFeature> _regions;
  set regions(List<DisplayFeature> value) {
    _regions = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    child.parentData = _PlayerData();
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
    size = constraints.biggest;
    final content = firstChild!, controls = lastChild!;
    final origin = _origin;
    Rect? horizontal, vertical;
    for (final f in _regions) {
      if (f.type != DisplayFeatureType.fold) continue;
      final rect = f.bounds.shift(-origin);
      if (rect.width > rect.height &&
          rect.top > 120 &&
          rect.bottom < size.height - 100) {
        horizontal = rect;
      }
      if (rect.height > rect.width && rect.left > 280) vertical = rect;
    }
    controls.layout(
      BoxConstraints(
        maxWidth: vertical?.left ?? size.width,
        maxHeight: horizontal == null
            ? size.height * .55
            : size.height - horizontal.bottom,
      ),
      parentUsesSize: true,
    );
    final contentHeight =
        horizontal?.top ?? (size.height - controls.size.height);
    content.layout(
      BoxConstraints.tight(Size(size.width, contentHeight)),
      parentUsesSize: true,
    );
    (content.parentData! as _PlayerData).offset = Offset.zero;
    (controls.parentData! as _PlayerData).offset = Offset(
      vertical == null ? (size.width - controls.size.width) / 2 : 0,
      horizontal?.bottom ?? contentHeight,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_regions.isNotEmpty) _refreshOrigin();
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
