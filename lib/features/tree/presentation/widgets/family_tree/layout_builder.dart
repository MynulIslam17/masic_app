import 'package:flutter/material.dart';
import 'package:masic_generation/features/tree/data/models/tree_model.dart';
import 'package:masic_generation/features/tree/presentation/controllers/tree_controller.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/constants.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/layout_node.dart';

class FamilyTreeLayoutBuilder {
  final Root root;
  final bool onToggleEdit;

  final Map<String, Meta> meta = {};
  final Map<String, GlobalKey> nodeKeys = {};
  final Map<String, double> renderedWidths = {};
  final Map<String, double> renderedHeights = {};

  FamilyTreeLayoutBuilder({
    required this.root,
    required this.onToggleEdit,
  }) {
    rebuildMeta();
  }

  void rebuildMeta() {
    meta.clear();

    final rootId = root.sId ?? root.linkedUser?.sId ?? 'root';
    meta[rootId] = Meta(
      id: rootId,
      memberId: root.sId ?? '',
      label: _label(root.label, root.linkedUser?.name),
      isRoot: true,
      hasChildren: false,
      onDelete: onToggleEdit
          ? () => TreeController.to.deleteUser(rootId)
          : null,
    );

    _walkChildrenMeta(root.children ?? []);
  }

  void resetMeasurement() {
    nodeKeys.clear();
    renderedWidths.clear();
    renderedHeights.clear();
  }

  void pruneMeasurementCache(Set<String> visibleIds) {
    nodeKeys.removeWhere((id, _) => !visibleIds.contains(id));
    renderedWidths.removeWhere((id, _) => !visibleIds.contains(id));
    renderedHeights.removeWhere((id, _) => !visibleIds.contains(id));
  }

  bool measureNodes(List<TreeLayoutNode> nodes) {
    var changed = false;

    for (final node in nodes) {
      final ctx = node.nodeKey.currentContext;
      if (ctx == null) continue;

      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;

      final actualW = box.size.width;
      final actualH = box.size.height;

      if ((actualW - node.renderedWidth).abs() > 0.5) {
        node.renderedWidth = actualW;
        renderedWidths[node.id] = actualW;
        changed = true;
      }
      if ((actualH - node.renderedHeight).abs() > 0.5) {
        node.renderedHeight = actualH;
        renderedHeights[node.id] = actualH;
        changed = true;
      }
    }

    return changed;
  }

  TreeLayoutNode buildLayoutTree(Set<String> collapsedNodes) {
    final rootId = root.sId ?? root.linkedUser?.sId ?? 'root';
    final rootMeta = meta[rootId];

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
      childrenData: root.children,
      collapsedNodes: collapsedNodes,
    );
  }

  static String _label(String? a, String? b) =>
      a?.isNotEmpty == true ? a! : (b ?? '');

  double _estimateRenderedWidth(Meta meta) {
    var width = FamilyTreeMetrics.nodeWidthBase;
    if (meta.hasChildren && meta.onDelete != null) {
      width += FamilyTreeMetrics.twoButtonsExtraWidth;
    } else if (meta.hasChildren || meta.onDelete != null) {
      width += FamilyTreeMetrics.buttonExtraWidth;
    }
    return width;
  }

  GlobalKey _keyFor(String id) => nodeKeys.putIfAbsent(id, GlobalKey.new);

  TreeLayoutNode _makeLayoutNode({
    required String id,
    required Meta meta,
    required List<TreeLayoutNode> children,
  }) {
    final estimated = _estimateRenderedWidth(meta);
    return TreeLayoutNode(
      id: id,
      meta: meta,
      children: children,
      width: estimated,
      height: FamilyTreeMetrics.nodeHeight,
      nodeKey: _keyFor(id),
      renderedWidth: renderedWidths[id] ?? estimated,
      renderedHeight: renderedHeights[id] ?? FamilyTreeMetrics.nodeHeight,
    );
  }

  TreeLayoutNode _buildLayoutNode({
    required String id,
    required Meta meta,
    required List<Children>? childrenData,
    required Set<String> collapsedNodes,
  }) {
    final childLayouts = <TreeLayoutNode>[];

    if (!collapsedNodes.contains(id) && childrenData != null) {
      for (final child in childrenData) {
        final childId = child.sId ?? child.linkedUser?.sId ?? '';
        if (childId.isEmpty) continue;

        final childMeta = this.meta[childId];
        if (childMeta == null) continue;

        childLayouts.add(
          _buildLayoutNode(
            id: childId,
            meta: childMeta,
            childrenData: child.children,
            collapsedNodes: collapsedNodes,
          ),
        );
      }
    }

    return _makeLayoutNode(id: id, meta: meta, children: childLayouts);
  }

  void _walkChildrenMeta(List<Children> list) {
    for (final child in list) {
      final id = child.sId ?? child.linkedUser?.sId ?? UniqueKey().toString();
      final hasKids = child.children?.isNotEmpty == true;

      meta[id] = Meta(
        id: id,
        memberId: child.sId ?? '',
        label: _label(child.label, child.linkedUser?.name),
        hasChildren: hasKids,
        onDelete: onToggleEdit
            ? () => TreeController.to.deleteUser(id)
            : null,
      );

      if (hasKids) _walkChildrenMeta(child.children!);
    }
  }
}
