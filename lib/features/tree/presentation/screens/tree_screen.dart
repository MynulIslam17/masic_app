import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/custom_loader.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
import 'package:flutter_task/features/tree/presentation/widgets/family_tree.dart';
import 'package:get/get.dart';

class TreeScreen extends StatelessWidget {
  const TreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TreeController.to;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Obx(() {
          switch (ctrl.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return Stack(
                children: [
                  Assets.icons.treeHome.svg(fit: BoxFit.cover),
                  const Center(child: CustomLoader()),
                ],
              );
            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Failed to load data. Please try again.',
                onRefresh: () async => await ctrl.loadData(),
              );
            case LoadingState.loaded:
              final treeData = ctrl.treeData;
              if (treeData == null || treeData.root == null) {
                return Stack(
                  children: [
                    Assets.icons.treeHome.svg(fit: BoxFit.cover),
                    const Center(child: CustomLoader()),
                  ],
                );
              }
              final root = treeData.root!;
              final all = root.children ?? [];
              final half = (all.length / 2).ceil();

              return InteractiveViewer(
                constrained: false,
                boundaryMargin:  EdgeInsets.only(right: 200.w),
                minScale: 0.3,
                maxScale: 2.5,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Assets.icons.treeHome.svg(fit: BoxFit.cover),
                    FamilyTree(
                      root: root,
                      topChildren: all.sublist(0, half),
                      botChildren: all.sublist(half),
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