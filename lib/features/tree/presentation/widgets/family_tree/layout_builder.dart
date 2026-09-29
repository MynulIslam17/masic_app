import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masic_generation/core/helpers/localized_name_helper.dart';
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

    final rootChildren = root.layoutChildren;
    final rootId = root.nodeId;
    meta[rootId] = Meta(
      id: rootId,
      memberId: root.sId ?? root.linkedUser?.sId ?? '',
      label: _memberLabel(root.label, root.linkedUser),
      name: root.linkedUser?.name,
      arabicName: root.linkedUser?.arabicName,
      isRoot: true,
      hasChildren: rootChildren.isNotEmpty,
      onDelete: onToggleEdit
          ? () => TreeController.to.deleteUser(rootId)
          : null,
    );

    _walkChildrenMeta(rootChildren);
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

  TreeLayoutNode buildLayoutTree(Set<String> expandedNodes) {
    final rootId = root.nodeId;
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
      childrenData: root.layoutChildren,
      expandedNodes: expandedNodes,
    );
  }

  static String _memberLabel(String? label, LinkedUser? linkedUser) =>
      LocalizedNameHelper.display(
        name: linkedUser?.name,
        arabicName: linkedUser?.arabicName,
        fallback: label,
      );

  double _estimateRenderedWidth(Meta meta) {
    final rawText = 28.0 + (meta.label.length * 7.4);
    final textWidth = math.min(FamilyTreeMetrics.maxNameWidth, rawText);
    var width = math.max(FamilyTreeMetrics.nodeWidthBase, textWidth);
    if (meta.hasChildren && meta.onDelete != null) {
      width += FamilyTreeMetrics.twoButtonsExtraWidth;
    } else if (meta.hasChildren || meta.onDelete != null) {
      width += FamilyTreeMetrics.buttonExtraWidth;
    }
    return width;
  }

  double _estimateRenderedHeight(Meta meta) {
    final rawText = 28.0 + (meta.label.length * 7.4);
    if (rawText > FamilyTreeMetrics.maxNameWidth) {
      return FamilyTreeMetrics.nodeHeight + FamilyTreeMetrics.extraLineHeight;
    }
    return FamilyTreeMetrics.nodeHeight;
  }

  GlobalKey _keyFor(String id) => nodeKeys.putIfAbsent(id, GlobalKey.new);

  TreeLayoutNode _makeLayoutNode({
    required String id,
    required Meta meta,
    required List<TreeLayoutNode> children,
  }) {
    final estimated = _estimateRenderedWidth(meta);
    final estimatedH = _estimateRenderedHeight(meta);
    return TreeLayoutNode(
      id: id,
      meta: meta,
      children: children,
      width: estimated,
      height: estimatedH,
      nodeKey: _keyFor(id),
      renderedWidth: renderedWidths[id] ?? estimated,
      renderedHeight: renderedHeights[id] ?? estimatedH,
    );
  }

  TreeLayoutNode _buildLayoutNode({
    required String id,
    required Meta meta,
    required List<Children> childrenData,
    required Set<String> expandedNodes,
  }) {
    final childLayouts = <TreeLayoutNode>[];

    if (expandedNodes.contains(id)) {
      for (final child in childrenData) {
        final childId = child.nodeId;
        if (childId.isEmpty) continue;

        final childMeta = this.meta[childId];
        if (childMeta == null) continue;

        childLayouts.add(
          _buildLayoutNode(
            id: childId,
            meta: childMeta,
            childrenData: child.layoutChildren,
            expandedNodes: expandedNodes,
          ),
        );
      }
    }

    return _makeLayoutNode(id: id, meta: meta, children: childLayouts);
  }

  void _walkChildrenMeta(List<Children> list) {
    for (final child in list) {
      final id = child.nodeId;
      if (id.isEmpty) continue;

      final kids = child.layoutChildren;

      meta[id] = Meta(
        id: id,
        memberId: child.sId ?? child.linkedUser?.sId ?? '',
        label: _memberLabel(child.label, child.linkedUser),
        name: child.linkedUser?.name,
        arabicName: child.linkedUser?.arabicName,
        hasChildren: kids.isNotEmpty,
        onDelete: onToggleEdit
            ? () => TreeController.to.deleteUser(id)
            : null,
      );

      if (kids.isNotEmpty) _walkChildrenMeta(kids);
    }
  }
}
