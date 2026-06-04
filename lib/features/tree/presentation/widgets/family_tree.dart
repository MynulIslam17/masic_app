import 'package:flutter/material.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/features/tree/data/models/tree_model.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
import 'package:flutter_task/features/tree/presentation/widgets/Tree_card.dart';
import 'package:get/get.dart' hide Node;
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
  final BuchheimWalkerConfiguration _config = BuchheimWalkerConfiguration();

  final Map<String, Meta> _meta = {};
  final Map<String, Node> _nodeMap = {};
  final GlobalKey _graphKey = GlobalKey();
  Size _graphSize = const Size(1500, 800);

  @override
  void initState() {
    super.initState();
    _config
      ..siblingSeparation = 8
      ..levelSeparation = 40
      ..subtreeSeparation = 8
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT
      ..useCurvedConnections = false;
    _buildGraph();

    WidgetsBinding.instance.addPostFrameCallback(_measureGraph);
  }

  void _measureGraph(_) {
    final ctx = _graphKey.currentContext;
    if (ctx != null) {
      final size = ctx.size;
      if (size != null && size != _graphSize) {
        setState(() => _graphSize = size);
      }
    }
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

    final screenW = MediaQuery.sizeOf(context).width;
    final screenH = MediaQuery.sizeOf(context).height;
    final treeLeftOffset = -screenW * 0.12;
    final graphLeftOffset = screenW * 0.12;

    final totalW = (graphLeftOffset + _graphSize.width + 100).clamp(
      screenW * 2,
      double.infinity,
    );
    final totalH = (_graphSize.height + 200).clamp(screenH, double.infinity);
    final treeTopOffset = (totalH - screenH) / 2;
    final graphTopOffset = (totalH - _graphSize.height) / 2;

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.only(right: 200),
      minScale: 0.1,
      maxScale: 5,
      constrained: false,
      child: SizedBox(
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
              child: Obx(() {
                final collapsedNodes = TreeController.to.collapsedNodes;
                final visibleGraph = _buildVisibleGraph(collapsedNodes);

                return Container(
                  key: _graphKey,
                  child: GraphView(
                    graph: visibleGraph,
                    algorithm: BuchheimWalkerAlgorithm(
                      _config,
                      TreeEdgeRenderer(_config),
                    ),
                    animated: false,
                    paint: linePaint,
                    builder: (Node node) {
                      final id = node.key!.value as String;
                      final meta = _meta[id];
                      if (meta == null) return const SizedBox.shrink();
                      return NodeCard(
                        meta: meta,
                        isExpanded: !collapsedNodes.contains(id),
                        onToggle: meta.hasChildren
                            ? () => TreeController.to.toggleNode(id)
                            : null,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Graph _buildVisibleGraph(Set<String> collapsedNodes) {
    final visibleGraph = Graph()..isTree = true;

    void addVisible(Node parent, List<Children> children) {
      final parentId = parent.key!.value as String;

      if (collapsedNodes.contains(parentId)) return;

      for (final c in children) {
        final id = c.sId ?? c.linkedUser?.sId ?? '';
        final node = _nodeMap[id];
        if (node == null) continue;

        visibleGraph.addNode(node);
        visibleGraph.addEdge(parent, node);

        if (c.children?.isNotEmpty == true) {
          addVisible(node, c.children!);
        }
      }
    }

    final rootId = widget.root.sId ?? widget.root.linkedUser?.sId ?? 'root';
    final rootNode = _nodeMap[rootId];
    if (rootNode != null) {
      visibleGraph.addNode(rootNode);
      addVisible(rootNode, widget.root.children ?? []);
    }

    return visibleGraph;
  }

  void _buildGraph() {
    final rootId = widget.root.sId ?? widget.root.linkedUser?.sId ?? 'root';

    final rootNode = _makeNode(
      id: rootId,
      label: _label(widget.root.label, widget.root.linkedUser?.name),
      memberId: widget.root.sId ?? '',
      isRoot: true,
      hasChildren: false,
      onDelete: widget.onToggleEdit
          ? () => TreeController.to.deleteUser(rootId)
          : null,
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
}
