import 'package:flutter/material.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/features/tree/data/models/tree_model.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
import 'package:flutter_task/features/tree/presentation/widgets/Tree_card.dart';
import 'package:graphview/GraphView.dart';

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
  final Graph _graph = Graph()..isTree = true;
  final GraphViewController _ctrl = GraphViewController();
  final BuchheimWalkerConfiguration _config = BuchheimWalkerConfiguration();

  final Map<String, Meta> _meta = {};
  final Map<String, Node> _nodeMap = {};

  @override
  void initState() {
    super.initState();
    _config
      ..siblingSeparation = 8
      ..levelSeparation = 80
      ..subtreeSeparation = 8
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT
      ..useCurvedConnections = false;
    _buildGraph();
  }

  // ── Graph construction ─────────────────────────────────────────────────────

  void _buildGraph() {
    final rootNode = _makeNode(
      id: widget.root.sId ?? widget.root.linkedUser?.sId ?? 'root',
      label: _label(widget.root.label, widget.root.linkedUser?.name),
      memberId: widget.root.sId ?? '',
      isRoot: true,
    );
    _walkChildren(rootNode, widget.root.children ?? []);
  }

  void _walkChildren(Node parent, List<Children> list) {
    for (final c in list) {
      final id = c.sId ?? c.linkedUser?.sId ?? UniqueKey().toString();
      final hasKids = c.children?.isNotEmpty == true;
      final child = _makeNode(
        id: id,
        label: _label(c.label, c.linkedUser?.name),
        memberId: c.sId ?? '',
        hasChildren: hasKids,
        onDelete: widget.onToggleEdit
            ? () => TreeController.to.deleteUser(id)
            : null,
      );
      _graph.addEdge(parent, child);
      if (hasKids) _walkChildren(child, c.children!);
    }
  }

  Node _makeNode({
    required String id,
    required String label,
    required String memberId,
    bool isRoot = false,
    bool hasChildren = false,
    VoidCallback? onDelete,
  }) {
    final node = Node.Id(id);
    _graph.addNode(node);
    _nodeMap[id] = node;
    _meta[id] = Meta(
      id: id,
      memberId: memberId,
      label: label,
      isRoot: isRoot,
      hasChildren: hasChildren,
      onDelete: onDelete,
    );
    return node;
  }

  static String _label(String? a, String? b) =>
      a?.isNotEmpty == true ? a! : (b ?? '');

  @override
  Widget build(BuildContext context) {
    final linePaint = Paint()
      ..color = AppColors.primaryColor.withOpacity(0.28)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    return Stack(
      children: [
        Assets.icons.treeHome.svg(fit: BoxFit.cover),
        GraphView.builder(
          graph: _graph,
          algorithm: BuchheimWalkerAlgorithm(
            _config,
            TreeEdgeRenderer(_config),
          ),
          controller: _ctrl,
          animated: true,
          toggleAnimationDuration: const Duration(milliseconds: 300),
          paint: linePaint,
          builder: (Node node) {
            final id = node.key!.value as String;
            final meta = _meta[id];
            if (meta == null) return const SizedBox.shrink();
            return NodeCard(
              meta: meta,
              isExpanded: !_ctrl.isNodeCollapsed(node),
              onToggle: meta.hasChildren
                  ? () => _ctrl.toggleNodeExpanded(_graph, node)
                  : null,
            );
          },
        ),
      ],
    );
  }
}
