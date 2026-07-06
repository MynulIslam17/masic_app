import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/features/tree/data/models/tree_model.dart';
import 'package:masic_generation/features/tree/presentation/controllers/tree_controller.dart';
import 'package:masic_generation/features/tree/presentation/widgets/Tree_card.dart';
import 'package:get/get.dart';

const double _kNodeWidthBase = 128.0;
const double _kNodeHeight = 40.0;
const double _kButtonExtraWidth = 34.0;
const double _kTwoButtonsExtraWidth = 68.0;
const double _kVerticalGap = 0.0;
const double _kHorizontalGap = 8.0;
const double _kStubLength = 24.0;

class _LayoutNode {
  final String id;
  final Meta meta;
  final List<_LayoutNode> children;
  final double width;
  final double height;
  final GlobalKey nodeKey;
  double x = 0;
  double y = 0;
  double renderedWidth;
  double renderedHeight;

  _LayoutNode({
    required this.id,
    required this.meta,
    required this.children,
    required this.width,
    required this.height,
    required this.nodeKey,
    required this.renderedWidth,
    required this.renderedHeight,
  });

  double get centerY => y + renderedHeight * 0.5;

  double get lineStartX => x + renderedWidth;
}

class _TreePainter extends CustomPainter {
  final _LayoutNode root;
  final List<_LayoutNode> allNodes;
  final Paint linePaint;

  _TreePainter({
    required this.root,
    required this.allNodes,
    required this.linePaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    drawLines(canvas, root);
  }

  void drawLines(Canvas canvas, _LayoutNode node) {
    if (node.children.isEmpty) return;

    final lineStartX = node.lineStartX;
    final spineX = lineStartX + _kHorizontalGap;
    final parentCenterY = node.centerY;

    final firstChild = node.children.first;
    final lastChild = node.children.last;

    canvas.drawLine(
      Offset(lineStartX, parentCenterY),
      Offset(spineX, parentCenterY),
      linePaint,
    );
    canvas.drawLine(
      Offset(spineX, firstChild.centerY),
      Offset(spineX, lastChild.centerY),
      linePaint,
    );

    for (final child in node.children) {
      canvas.drawLine(
        Offset(spineX, child.centerY),
        Offset(child.x, child.centerY),
        linePaint,
      );
      drawLines(canvas, child);
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    if (oldDelegate.allNodes.length != allNodes.length) return true;

    for (var i = 0; i < allNodes.length; i++) {
      final oldNode = oldDelegate.allNodes[i];
      final node = allNodes[i];
      if (oldNode.id != node.id) return true;
      if ((oldNode.renderedWidth - node.renderedWidth).abs() > 0.5) return true;
      if ((oldNode.renderedHeight - node.renderedHeight).abs() > 0.5) {
        return true;
      }
      if (oldNode.x != node.x || oldNode.y != node.y) return true;
    }

    return false;
  }
}

class FamilyTreeGraph extends StatefulWidget {
  final Root root;
  final bool onToggleEdit;

  const FamilyTreeGraph({
    super.key,
    required this.root,
    this.onToggleEdit = false,
  });

  @override
  State<FamilyTreeGraph> createState() => _FamilyTreeGraphState();
}

class _FamilyTreeGraphState extends State<FamilyTreeGraph> {
  final Map<String, Meta> _meta = {};
  final Map<String, GlobalKey> _nodeKeys = {};
  final Map<String, double> _renderedWidths = {};
  final Map<String, double> _renderedHeights = {};
  List<_LayoutNode> _allNodes = [];
  String? _lastCollapsedKey;
  bool _pendingMeasure = true;

  @override
  void initState() {
    super.initState();
    _buildMetaMap();
  }

  @override
  void didUpdateWidget(covariant FamilyTreeGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.root != widget.root ||
        oldWidget.onToggleEdit != widget.onToggleEdit) {
      _nodeKeys.clear();
      _renderedWidths.clear();
      _renderedHeights.clear();
      _pendingMeasure = true;
      _buildMetaMap();
    }
  }

  static String _label(String? a, String? b) =>
      a?.isNotEmpty == true ? a! : (b ?? '');

  double _estimateRenderedWidth(Meta meta) {
    var width = _kNodeWidthBase;
    if (meta.hasChildren && meta.onDelete != null) {
      width += _kTwoButtonsExtraWidth;
    } else if (meta.hasChildren || meta.onDelete != null) {
      width += _kButtonExtraWidth;
    }
    return width;
  }

  GlobalKey _keyFor(String id) => _nodeKeys.putIfAbsent(id, GlobalKey.new);

  void _measureAndRepaint() {
    if (!mounted) return;

    var changed = false;
    for (final node in _allNodes) {
      final ctx = node.nodeKey.currentContext;
      if (ctx == null) continue;

      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;

      final actualW = box.size.width;
      final actualH = box.size.height;

      if ((actualW - node.renderedWidth).abs() > 0.5) {
        node.renderedWidth = actualW;
        _renderedWidths[node.id] = actualW;
        changed = true;
      }
      if ((actualH - node.renderedHeight).abs() > 0.5) {
        node.renderedHeight = actualH;
        _renderedHeights[node.id] = actualH;
        changed = true;
      }
    }

    _pendingMeasure = false;

    if (changed && mounted) setState(() {});
  }

  void _scheduleMeasureIfNeeded(String collapsedKey) {
    if (!_pendingMeasure && _lastCollapsedKey == collapsedKey) return;

    _lastCollapsedKey = collapsedKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureAndRepaint();
    });
  }

  void _pruneMeasurementCache(Set<String> visibleIds) {
    _nodeKeys.removeWhere((id, _) => !visibleIds.contains(id));
    _renderedWidths.removeWhere((id, _) => !visibleIds.contains(id));
    _renderedHeights.removeWhere((id, _) => !visibleIds.contains(id));
  }

  void _buildMetaMap() {
    _meta.clear();

    final rootId = widget.root.sId ?? widget.root.linkedUser?.sId ?? 'root';
    _meta[rootId] = Meta(
      id: rootId,
      memberId: widget.root.sId ?? '',
      label: _label(widget.root.label, widget.root.linkedUser?.name),
      isRoot: true,
      hasChildren: false,
      onDelete: widget.onToggleEdit
          ? () => TreeController.to.deleteUser(rootId)
          : null,
    );

    _walkChildrenMeta(widget.root.children ?? []);
  }

  void _walkChildrenMeta(List<Children> list) {
    for (final c in list) {
      final id = c.sId ?? c.linkedUser?.sId ?? UniqueKey().toString();
      final hasKids = c.children?.isNotEmpty == true;

      _meta[id] = Meta(
        id: id,
        memberId: c.sId ?? '',
        label: _label(c.label, c.linkedUser?.name),
        hasChildren: hasKids,
        onDelete: widget.onToggleEdit
            ? () => TreeController.to.deleteUser(id)
            : null,
      );

      if (hasKids) _walkChildrenMeta(c.children!);
    }
  }

  double _subtreeHeight(_LayoutNode node) {
    if (node.children.isEmpty) return node.renderedHeight;

    var total = 0.0;
    for (var i = 0; i < node.children.length; i++) {
      total += _subtreeHeight(node.children[i]);
      if (i < node.children.length - 1) {
        total += _kVerticalGap;
      }
    }
    return total;
  }

  void _assignPositions(_LayoutNode node, double startX, double startY) {
    node.x = startX;

    if (node.children.isEmpty) {
      node.y = startY;
      return;
    }

    final childX = startX + node.renderedWidth + _kHorizontalGap + _kStubLength;
    var currentY = startY;

    for (var i = 0; i < node.children.length; i++) {
      final child = node.children[i];
      _assignPositions(child, childX, currentY);
      currentY += _subtreeHeight(child);
      if (i < node.children.length - 1) {
        currentY += _kVerticalGap;
      }
    }

    final childrenBlockHeight = currentY - startY;
    node.y = startY + (childrenBlockHeight - node.renderedHeight) / 2;
  }

  _LayoutNode _buildLayoutTree(Set<String> collapsedNodes) {
    final rootId = widget.root.sId ?? widget.root.linkedUser?.sId ?? 'root';
    final rootMeta = _meta[rootId];

    if (rootMeta == null) {
      return _makeLayoutNode(
        id: rootId,
        meta: Meta(id: rootId, memberId: '', label: ''),
        children: [],
      );
    }

    return _buildLayoutNode(
      id: rootId,
      meta: rootMeta,
      childrenData: widget.root.children,
      collapsedNodes: collapsedNodes,
    );
  }

  _LayoutNode _makeLayoutNode({
    required String id,
    required Meta meta,
    required List<_LayoutNode> children,
  }) {
    final estimated = _estimateRenderedWidth(meta);
    return _LayoutNode(
      id: id,
      meta: meta,
      children: children,
      width: estimated,
      height: _kNodeHeight,
      nodeKey: _keyFor(id),
      renderedWidth: _renderedWidths[id] ?? estimated,
      renderedHeight: _renderedHeights[id] ?? _kNodeHeight,
    );
  }

  _LayoutNode _buildLayoutNode({
    required String id,
    required Meta meta,
    required List<Children>? childrenData,
    required Set<String> collapsedNodes,
  }) {
    final childLayouts = <_LayoutNode>[];

    if (!collapsedNodes.contains(id) && childrenData != null) {
      for (final c in childrenData) {
        final childId = c.sId ?? c.linkedUser?.sId ?? '';
        if (childId.isEmpty) continue;

        final childMeta = _meta[childId];
        if (childMeta == null) continue;

        childLayouts.add(
          _buildLayoutNode(
            id: childId,
            meta: childMeta,
            childrenData: c.children,
            collapsedNodes: collapsedNodes,
          ),
        );
      }
    }

    return _makeLayoutNode(id: id, meta: meta, children: childLayouts);
  }

  void _collectNodes(_LayoutNode node, List<_LayoutNode> out) {
    out.add(node);
    for (final child in node.children) {
      _collectNodes(child, out);
    }
  }

  Size _computeGraphSize(List<_LayoutNode> nodes) {
    if (nodes.isEmpty) return const Size(_kNodeWidthBase, _kNodeHeight);

    var maxRight = 0.0;
    var maxBottom = 0.0;
    for (final node in nodes) {
      maxRight = math.max(maxRight, node.x + node.renderedWidth);
      maxBottom = math.max(maxBottom, node.y + node.renderedHeight);
    }
    return Size(maxRight, maxBottom);
  }

  @override
  Widget build(BuildContext context) {
    final linePaint = Paint()
      ..color = AppColors.primaryColor.withValues(alpha: 0.28)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final screenW = MediaQuery.sizeOf(context).width;
    final screenH = MediaQuery.sizeOf(context).height;
    final treeLeftOffset = -screenW * 0.12;
    final graphLeftOffset = screenW * 0.08;

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.only(right: 200),
      minScale: 0.1,
      maxScale: 5,
      constrained: false,
      child: Obx(() {
        final collapsedNodes = TreeController.to.collapsedNodes;
        final collapsedKey = (collapsedNodes.toList()..sort()).join(',');

        final layoutRoot = _buildLayoutTree(collapsedNodes);
        _assignPositions(layoutRoot, 0, 0);

        final allNodes = <_LayoutNode>[];
        _collectNodes(layoutRoot, allNodes);
        _allNodes = allNodes;
        _pruneMeasurementCache(allNodes.map((n) => n.id).toSet());

        final graphSize = _computeGraphSize(allNodes);

        _scheduleMeasureIfNeeded(collapsedKey);

        final totalW = (graphLeftOffset + graphSize.width + 48).clamp(
          screenW * 2,
          double.infinity,
        );
        final totalH = (graphSize.height + 80).clamp(screenH, double.infinity);
        final treeTopOffset = (totalH - screenH) / 2;
        final graphTopOffset = (totalH - graphSize.height) / 2;

        return SizedBox(
          width: totalW,
          height: totalH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: treeLeftOffset,
                top: treeTopOffset,
                child: SizedBox(
                  width: screenW,
                  height: screenH,
                  child: Assets.icons.treeHome.svg(fit: BoxFit.contain),
                ),
              ),
              Positioned(
                left: graphLeftOffset,
                top: graphTopOffset,
                child: SizedBox(
                  width: graphSize.width,
                  height: graphSize.height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      RepaintBoundary(
                        child: CustomPaint(
                          size: graphSize,
                          painter: _TreePainter(
                            root: layoutRoot,
                            allNodes: allNodes,
                            linePaint: linePaint,
                          ),
                        ),
                      ),
                      ...allNodes.map(
                        (node) => Positioned(
                          left: node.x,
                          top: node.y,
                          child: RepaintBoundary(
                            child: NodeCard(
                              key: node.nodeKey,
                              meta: node.meta,
                              isExpanded: !collapsedNodes.contains(node.id),
                              onToggle: node.meta.hasChildren
                                  ? () {
                                      TreeController.to.toggleNode(node.id);
                                      _pendingMeasure = true;
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
