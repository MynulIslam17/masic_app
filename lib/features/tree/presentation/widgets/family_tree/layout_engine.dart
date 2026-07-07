import 'dart:math' as math;

import 'package:masic_generation/features/tree/presentation/widgets/family_tree/constants.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/layout_node.dart';

class _WalkerData {
  TreeLayoutNode? ancestor;
  TreeLayoutNode? thread;
  int number = 0;
  int depth = 0;
  double prelim = 0;
  double modifier = 0;
  double shift = 0;
  double change = 0;
}

/// Buchheim-Walker layout adapted from graphview's LEFT_RIGHT tree algorithm.
class TreeLayoutEngine {
  final Map<TreeLayoutNode, _WalkerData> _data = {};
  final Map<TreeLayoutNode, TreeLayoutNode?> _parents = {};

  void run(TreeLayoutNode root) {
    _data.clear();
    _parents.clear();
    _initData(root, null);
    _firstWalk(root, null, 0, 0);
    _secondWalk(root, 0);
    _assignDepthX(root, 0);
    _normalizeY(collectTreeNodes(root));
  }

  void _initData(TreeLayoutNode node, TreeLayoutNode? parent) {
    _data[node] = _WalkerData()..ancestor = node;
    _parents[node] = parent;
    for (final child in node.children) {
      _initData(child, node);
    }
  }

  _WalkerData _wd(TreeLayoutNode node) => _data[node]!;

  double _prelim(TreeLayoutNode? node) =>
      node == null ? 0 : _wd(node).prelim;

  double _modifier(TreeLayoutNode? node) =>
      node == null ? 0 : _wd(node).modifier;

  double _siblingSpacing(TreeLayoutNode left) =>
      FamilyTreeMetrics.verticalGap + left.renderedHeight;

  TreeLayoutNode? _leftSibling(TreeLayoutNode node, TreeLayoutNode parent) {
    final index = parent.children.indexOf(node);
    if (index <= 0) return null;
    return parent.children[index - 1];
  }

  TreeLayoutNode? _nextRight(TreeLayoutNode? node) {
    if (node != null && node.children.isNotEmpty) {
      return node.children.last;
    }
    return node == null ? null : _wd(node).thread;
  }

  TreeLayoutNode? _nextLeft(TreeLayoutNode? node) {
    if (node != null && node.children.isNotEmpty) {
      return node.children.first;
    }
    return node == null ? null : _wd(node).thread;
  }

  void _firstWalk(
    TreeLayoutNode node,
    TreeLayoutNode? parent,
    int depth,
    int number,
  ) {
    final data = _wd(node);
    data.depth = depth;
    data.number = number;

    if (node.children.isEmpty) {
      if (parent != null) {
        final left = _leftSibling(node, parent);
        if (left != null) {
          data.prelim = _prelim(left) + _siblingSpacing(left);
        }
      }
      return;
    }

    final leftMost = node.children.first;
    final rightMost = node.children.last;
    var defaultAncestor = leftMost;

    var childNumber = 1;
    for (final child in node.children) {
      _firstWalk(child, node, depth + 1, childNumber++);
      defaultAncestor = _apportion(child, node, defaultAncestor);
    }

    _executeShifts(node);

    final midpoint = 0.5 *
        ((_prelim(leftMost) + _prelim(rightMost) + rightMost.renderedHeight) -
            node.renderedHeight);

    if (parent != null) {
      final left = _leftSibling(node, parent);
      if (left != null) {
        data.prelim = _prelim(left) + _siblingSpacing(left);
        data.modifier = data.prelim - midpoint;
      } else {
        data.prelim = midpoint;
      }
    } else {
      data.prelim = midpoint;
    }
  }

  void _secondWalk(TreeLayoutNode node, double modifier) {
    node.y = _prelim(node) + modifier;
    final nodeModifier = _modifier(node);
    for (final child in node.children) {
      _secondWalk(child, modifier + nodeModifier);
    }
  }

  void _assignDepthX(TreeLayoutNode node, double x) {
    node.x = x;
    final childX = x +
        node.renderedWidth +
        FamilyTreeMetrics.horizontalGap +
        FamilyTreeMetrics.stubLength;
    for (final child in node.children) {
      _assignDepthX(child, childX);
    }
  }

  void _executeShifts(TreeLayoutNode node) {
    var shift = 0.0;
    var change = 0.0;
    var current = node.children.last;

    while (true) {
      final data = _wd(current);
      data.prelim += shift;
      data.modifier += shift;
      change += data.change;
      shift += data.shift + change;

      final left = _leftSibling(current, node);
      if (left == null) break;
      current = left;
    }
  }

  TreeLayoutNode _apportion(
    TreeLayoutNode node,
    TreeLayoutNode parent,
    TreeLayoutNode defaultAncestor,
  ) {
    var ancestor = defaultAncestor;
    final leftSibling = _leftSibling(node, parent);
    if (leftSibling == null) return ancestor;

    var innerRight = _modifier(node);
    var outerRight = _modifier(node);
    var innerLeft = _modifier(leftSibling);
    var outerLeft = _modifier(parent.children.first);

    var nextRight = _nextRight(leftSibling);
    var nextLeft = _nextLeft(node);
    var innerRightNode = node;
    var outerRightNode = node;
    var innerLeftNode = leftSibling;
    var outerLeftNode = parent.children.first;

    while (nextRight != null && nextLeft != null) {
      innerLeftNode = _nextLeft(innerLeftNode)!;
      innerRightNode = _nextRight(innerRightNode)!;
      outerLeftNode = _nextLeft(outerLeftNode)!;
      outerRightNode = _nextRight(outerRightNode)!;
      _wd(outerRightNode).ancestor = node;

      final shift = _prelim(nextRight) +
          innerLeft -
          (_prelim(nextLeft) + innerRight) +
          _siblingSpacing(nextRight);

      if (shift > 0) {
        _moveSubtree(_resolveAncestor(nextRight, node, ancestor), node, shift);
        innerRight += shift;
        outerRight += shift;
      }

      innerLeft += _modifier(innerLeftNode);
      innerRight += _modifier(innerRightNode);
      outerLeft += _modifier(outerLeftNode);
      outerRight += _modifier(outerRightNode);

      nextRight = _nextRight(nextRight);
      nextLeft = _nextLeft(nextLeft);
    }

    if (nextRight != null && _nextRight(outerRightNode) == null) {
      _wd(outerRightNode).thread = nextRight;
      _wd(outerRightNode).modifier += innerLeft - outerRight;
    }

    if (nextLeft != null && _nextLeft(outerLeftNode) == null) {
      _wd(outerLeftNode).thread = nextLeft;
      _wd(outerLeftNode).modifier += innerRight - outerLeft;
      ancestor = node;
    }

    return ancestor;
  }

  TreeLayoutNode _resolveAncestor(
    TreeLayoutNode node,
    TreeLayoutNode child,
    TreeLayoutNode defaultAncestor,
  ) {
    final candidate = _wd(node).ancestor ?? node;
    if (identical(_parents[candidate], _parents[child])) {
      return candidate;
    }
    return defaultAncestor;
  }

  void _moveSubtree(
    TreeLayoutNode? leftNode,
    TreeLayoutNode rightNode,
    double shift,
  ) {
    if (leftNode == null) return;

    final leftData = _wd(leftNode);
    final rightData = _wd(rightNode);
    final subtrees = rightData.number - leftData.number;
    if (subtrees <= 0) return;

    rightData.change -= shift / subtrees;
    rightData.shift += shift;
    leftData.change += shift / subtrees;
    rightData.prelim += shift;
    rightData.modifier += shift;
  }

  void _normalizeY(List<TreeLayoutNode> nodes) {
    var minY = double.infinity;
    for (final node in nodes) {
      minY = math.min(minY, node.y);
    }
    if (minY >= 0) return;

    final offset = -minY;
    for (final node in nodes) {
      node.y += offset;
    }
  }
}
