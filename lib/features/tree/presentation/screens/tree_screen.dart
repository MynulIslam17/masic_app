import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/custom_loader.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
import 'package:flutter_task/features/tree/presentation/widgets/Tree_card.dart';
import 'package:get/get.dart' hide Node;
import 'package:graphview/GraphView.dart';

class TreeScreen extends StatelessWidget {
  const TreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Obx(() {
          final controller = TreeController.to;

          switch (controller.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return const Center(child: CustomLoader());

            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Failed to load data. Please try again.',
                onRefresh: () async => await controller.loadData(),
              );

            case LoadingState.loaded:
              final model = controller.treeData;
              if (model == null) {
                return const Center(child: CustomLoader());
              }

              if (controller.nodeInfoMap.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.initFromModel(model);
                });
                return const Center(child: CustomLoader());
              }

              final rootId = model.root?.sId ?? '';
              final _ = controller.graphVersion.value;

              return InteractiveViewer(
                boundaryMargin: EdgeInsets.only(right: 200.r, bottom: 140.h),
                constrained: false,
                minScale: 0.5,
                maxScale: 2.5,
                child: Stack(
                  children: [
                    Assets.icons.treeHome.svg(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 2,
                        left: 44.w,
                      ),
                      child: GraphView(
                        graph: controller.graph,
                        algorithm: BuchheimWalkerAlgorithm(
                          controller.builder,
                          TreeEdgeRenderer(controller.builder),
                        ),
                        paint: Paint()
                          ..color = const Color(0xFFC5CDE6)
                          ..strokeWidth = 1.5
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          final id = node.key!.value as String;
                          final info = controller.nodeInfoMap[id];
                          final isRoot = id == rootId;
                          final hasChildren =
                              info != null && info.children.isNotEmpty;
                          final isExpanded =
                              controller.expandedNodes[id] ?? false;

                          return TreeCard(
                            label: info?.label ?? id,
                            id: id,
                            isRoot: isRoot,
                            hasChildren: hasChildren,
                            isExpanded: isExpanded,
                            onToggle: hasChildren
                                ? () => controller.toggleNode(id, model)
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
          }
        }),
      ),
    );
  }
}
