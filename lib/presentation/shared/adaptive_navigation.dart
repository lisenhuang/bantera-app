import 'package:flutter/material.dart';
import 'adaptive_layout.dart';
import 'adaptive_viewport_state.dart';

class AdaptiveMainNavigation extends StatefulWidget {
  const AdaptiveMainNavigation({
    super.key,
    required this.body,
    this.visible = true,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });
  final Widget body;
  final bool visible;
  final List<BottomNavigationBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  @override
  State<AdaptiveMainNavigation> createState() => _AdaptiveMainNavigationState();
}

class _AdaptiveMainNavigationState extends State<AdaptiveMainNavigation> {
  @override
  void initState() {
    super.initState();
    adaptiveViewportState.update(
      mounted: true,
      navigationVisible: widget.visible,
    );
  }

  @override
  void didUpdateWidget(AdaptiveMainNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      adaptiveViewportState.update(navigationVisible: widget.visible);
    }
  }

  @override
  void dispose() {
    adaptiveViewportState.update(mounted: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final selectedIndex = widget.selectedIndex;
    final onSelected = widget.onSelected;
    final edge = AdaptiveLayoutScope.of(context).edge;
    final visible = widget.visible;
    final vertical = edge != NavigationEdge.horizontal;
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final barSize = vertical
        ? (80.0 * scale.clamp(1, 1.5))
        : 72.0 + (scale - 1).clamp(0, 2) * 20;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Stack(
      children: [
        Positioned(
          left: visible && edge == NavigationEdge.left ? barSize : 0,
          right: visible && edge == NavigationEdge.right ? barSize : 0,
          top: 0,
          bottom: !visible || vertical ? 0 : barSize + bottom,
          child: MediaQuery.removePadding(
            context: context,
            removeLeft: visible && edge == NavigationEdge.left,
            removeRight: visible && edge == NavigationEdge.right,
            // Horizontal tabs already occupy the bottom system safe area.
            // Nested chat Scaffolds/SafeAreas must not reserve it again.
            removeBottom: visible && !vertical,
            child: widget.body,
          ),
        ),
        if (visible)
          Positioned(
            left: edge == NavigationEdge.right ? null : 0,
            right: edge == NavigationEdge.left ? null : 0,
            top: vertical ? 0 : null,
            bottom: 0,
            width: vertical ? barSize : null,
            height: vertical ? null : barSize + bottom,
            child: Material(
              color: theme.colorScheme.surface,
              child: SafeArea(
                top: vertical,
                left: !vertical,
                right: !vertical,
                minimum: EdgeInsets.only(
                  top: vertical
                      ? AdaptiveLayoutScope.of(context).statusBarBottom
                      : 0,
                ),
                child: Flex(
                  direction: vertical ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Flexible(
                        flex: 1,
                        fit: vertical ? FlexFit.loose : FlexFit.tight,
                        child: Semantics(
                          selected: selectedIndex == i,
                          button: true,
                          label: items[i].label,
                          child: Tooltip(
                            message: items[i].label ?? '',
                            excludeFromSemantics: true,
                            child: InkWell(
                              onTap: () => onSelected(i),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: vertical ? 72 : 48,
                                  minWidth: vertical ? barSize : 48,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 6,
                                  ),
                                  child: IconTheme(
                                    data: IconThemeData(
                                      color: selectedIndex == i
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        items[i].icon,
                                        ExcludeSemantics(
                                          child: Text(
                                            items[i].label ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: selectedIndex == i
                                                      ? theme
                                                            .colorScheme
                                                            .primary
                                                      : theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
