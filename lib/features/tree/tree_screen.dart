import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/helpers/helper_data.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:graphview/GraphView.dart';

class TreeScreen extends StatefulWidget {
  const TreeScreen({super.key});

  @override
  State<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen>
    with SingleTickerProviderStateMixin {
  final Graph graph = Graph()..isTree = true;
  late final BuchheimWalkerConfiguration builder;

  final Map<String, bool> _expandedNodes = {};
  final Map<String, Map<String, dynamic>> _nodeDataMap = {};
  bool _initialized = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animController.forward();

    builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = 40
      ..levelSeparation = 80
      ..subtreeSeparation = 20
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT;

    // Initialize all nodes as expanded
    _initializeExpandedNodes();
    _buildGraph();
  }

  void _initializeExpandedNodes() {
    final familyData = HelperData.demoFamilyList;
    if (familyData.isEmpty) return;

    void traverse(Map<String, dynamic> node) {
      final name = node['name'] as String;
      _expandedNodes[name] = false; // Start collapsed
      _nodeDataMap[name] = node;
      final children = node['children'] as List<dynamic>;
      for (final child in children) {
        traverse(child as Map<String, dynamic>);
      }
    }

    traverse(familyData[0]);
    _initialized = true;
  }

  void _buildGraph() {
    graph.nodes.clear();
    graph.edges.clear();
    _nodeDataMap.clear();

    final familyData = HelperData.demoFamilyList;
    if (familyData.isEmpty) return;

    void addNode(Map<String, dynamic> nodeData, Node? parentNode) {
      final name = nodeData['name'] as String;
      final currentNode = Node.Id(name);
      _nodeDataMap[name] = nodeData;

      if (parentNode != null) {
        graph.addEdge(parentNode, currentNode);
      }

      // Only add children if this node is expanded
      final isExpanded = _expandedNodes[name] == true;
      if (isExpanded) {
        final children = nodeData['children'] as List<dynamic>;
        for (final child in children) {
          addNode(child as Map<String, dynamic>, currentNode);
        }
      }
    }

    addNode(familyData[0], null);

    // If root is not expanded, still show the root node
    final rootNodeName = familyData[0]['name'] as String;
    if (_expandedNodes[rootNodeName] != true) {
      graph.addNode(Node.Id(rootNodeName));
    }
  }

  void _toggleNode(String nodeName) {
    setState(() {
      _expandedNodes[nodeName] = !(_expandedNodes[nodeName] ?? true);
      _animController.reset();
      _buildGraph();
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: InteractiveViewer(
            boundaryMargin: EdgeInsets.only(right:  200.r),
            constrained: false,
            minScale: 0.5,
            maxScale: 2.5,
            child: Stack(
      children: [
        Assets.icons.treeHome.svg(),
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2,left: 44.w),
          child: GraphView(
            graph: graph,
            algorithm: BuchheimWalkerAlgorithm(
              builder,
              TreeEdgeRenderer(builder),
            ),
            paint: Paint()
              ..color = const Color(0xFFC5CDE6)
              ..strokeWidth = 1.5
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              final id = node.key!.value as String;
              final isRoot = _nodeDataMap[id] == null ||
                  (_nodeDataMap[id]!['level'] == 0);
              return _buildNodeWidget(id, isRoot);
            },
          ),
        ),
      ],
            ),
          ),
    );
  }

  Widget _buildNodeWidget(String label, bool isRoot) {
    final nodeData = _nodeDataMap[label];
    final hasChildren =
        nodeData != null && (nodeData['children'] as List).isNotEmpty;
    final isExpanded = _expandedNodes[label] ?? true;

    return GestureDetector(
      onTap: hasChildren ? () => _toggleNode(label) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isRoot ? const Color(0xFF3D6BCE) : const Color(0xFFC5CDE6),
            width: isRoot ? 1.5 : 1.0,
          ),
          boxShadow: isRoot
              ? [
                  BoxShadow(
                    color: const Color(0xFF3D6BCE).withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isRoot ? FontWeight.w600 : FontWeight.w400,
                color: const Color(0xFF1A2540),
              ),
            ),
            if (hasChildren) ...[
              SizedBox(width: 8.w),
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  color: isRoot
                      ? const Color(0xFF3D6BCE)
                      : const Color(0xFFE8EDFA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_left_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 14.sp,
                  color: isRoot ? Colors.white : const Color(0xFF3D6BCE),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
