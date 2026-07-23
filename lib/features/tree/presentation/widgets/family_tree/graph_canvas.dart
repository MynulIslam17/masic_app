import 'package:flutter/material.dart';
import 'package:masic_generation/features/tree/presentation/widgets/Tree_card.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/connector_painter.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/layout_node.dart';

class FamilyTreeGraphCanvas extends StatelessWidget {
  final TreeLayoutNode root;
  final List<TreeLayoutNode> nodes;
  final Size graphSize;
  final Paint linePaint;
  final Set<String> expandedNodes;
  final ValueChanged<String> onToggleNode;

  const FamilyTreeGraphCanvas({
    super.key,
    required this.root,
    required this.nodes,
    required this.graphSize,
    required this.linePaint,
    required this.expandedNodes,
    required this.onToggleNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: graphSize.width,
      height: graphSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: graphSize,
              painter: FamilyTreeConnectorPainter(
                root: root,
                allNodes: nodes,
                linePaint: linePaint,
              ),
            ),
          ),
          ...nodes.map(_buildNode),
        ],
      ),
    );
  }

  Widget _buildNode(TreeLayoutNode node) {
    return Positioned(
      left: node.x,
      top: node.y,
      child: RepaintBoundary(
        child: NodeCard(
          key: node.nodeKey,
          meta: node.meta,
          isExpanded: expandedNodes.contains(node.id),
          onToggle: node.meta.hasChildren
              ? () => onToggleNode(node.id)
              : null,
        ),
      ),
    );
  }
}
