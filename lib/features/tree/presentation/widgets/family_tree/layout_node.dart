import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masic_generation/features/tree/data/models/tree_model.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/constants.dart';

class TreeLayoutNode {
  final String id;
  final Meta meta;
  final List<TreeLayoutNode> children;
  final double width;
  final double height;
  final GlobalKey nodeKey;
  double x = 0;
  double y = 0;
  double renderedWidth;
  double renderedHeight;

  TreeLayoutNode({
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

List<TreeLayoutNode> collectTreeNodes(TreeLayoutNode root) {
  final nodes = <TreeLayoutNode>[];
  void walk(TreeLayoutNode node) {
    nodes.add(node);
    for (final child in node.children) {
      walk(child);
    }
  }

  walk(root);
  return nodes;
}

Size computeTreeGraphSize(List<TreeLayoutNode> nodes) {
  if (nodes.isEmpty) {
    return const Size(
      FamilyTreeMetrics.nodeWidthBase,
      FamilyTreeMetrics.nodeHeight,
    );
  }

  var maxRight = 0.0;
  var maxBottom = 0.0;
  for (final node in nodes) {
    maxRight = math.max(maxRight, node.x + node.renderedWidth);
    maxBottom = math.max(maxBottom, node.y + node.renderedHeight);
  }
  return Size(maxRight, maxBottom);
}
