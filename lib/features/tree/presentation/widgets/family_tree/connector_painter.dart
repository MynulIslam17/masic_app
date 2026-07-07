import 'package:flutter/material.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/constants.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/layout_node.dart';

class FamilyTreeConnectorPainter extends CustomPainter {
  final TreeLayoutNode root;
  final List<TreeLayoutNode> allNodes;
  final Paint linePaint;

  FamilyTreeConnectorPainter({
    required this.root,
    required this.allNodes,
    required this.linePaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawLines(canvas, root);
  }

  void _drawLines(Canvas canvas, TreeLayoutNode node) {
    if (node.children.isEmpty) return;

    final lineStartX = node.lineStartX;
    final spineX = lineStartX + FamilyTreeMetrics.horizontalGap;
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
      _drawLines(canvas, child);
    }
  }

  @override
  bool shouldRepaint(covariant FamilyTreeConnectorPainter oldDelegate) {
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
