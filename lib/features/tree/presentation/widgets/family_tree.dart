import 'package:flutter/material.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/features/tree/data/models/tree_model.dart';
import 'package:masic_generation/features/tree/presentation/controllers/tree_controller.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/background.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/graph_canvas.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/layout_builder.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/layout_engine.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/layout_node.dart';
import 'package:get/get.dart';

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
  late FamilyTreeLayoutBuilder _layoutBuilder;
  List<TreeLayoutNode> _allNodes = [];
  String? _lastCollapsedKey;
  bool _pendingMeasure = true;

  @override
  void initState() {
    super.initState();
    _layoutBuilder = FamilyTreeLayoutBuilder(
      root: widget.root,
      onToggleEdit: widget.onToggleEdit,
    );
  }

  @override
  void didUpdateWidget(covariant FamilyTreeGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.root != widget.root ||
        oldWidget.onToggleEdit != widget.onToggleEdit) {
      _layoutBuilder = FamilyTreeLayoutBuilder(
        root: widget.root,
        onToggleEdit: widget.onToggleEdit,
      );
      _pendingMeasure = true;
    }
  }

  void _scheduleMeasureIfNeeded(String collapsedKey) {
    if (!_pendingMeasure && _lastCollapsedKey == collapsedKey) return;

    _lastCollapsedKey = collapsedKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final changed = _layoutBuilder.measureNodes(_allNodes);
      _pendingMeasure = false;
      if (changed) setState(() {});
    });
  }

  void _onToggleNode(String nodeId) {
    TreeController.to.toggleNode(nodeId);
    _pendingMeasure = true;
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

        final layoutRoot = _layoutBuilder.buildLayoutTree(collapsedNodes);
        TreeLayoutEngine().run(layoutRoot);

        final allNodes = collectTreeNodes(layoutRoot);
        _allNodes = allNodes;
        _layoutBuilder.pruneMeasurementCache(allNodes.map((n) => n.id).toSet());

        final graphSize = computeTreeGraphSize(allNodes);
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
                child: FamilyTreeBackground(
                  screenWidth: screenW,
                  screenHeight: screenH,
                ),
              ),
              Positioned(
                left: graphLeftOffset,
                top: graphTopOffset,
                child: FamilyTreeGraphCanvas(
                  root: layoutRoot,
                  nodes: allNodes,
                  graphSize: graphSize,
                  linePaint: linePaint,
                  collapsedNodes: collapsedNodes,
                  onToggleNode: _onToggleNode,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
