
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/custom_container.dart';
import 'package:flutter_task/core/widgets/custom_loader.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
import 'package:flutter_task/features/tree/presentation/widgets/family_tree.dart';
import 'package:get/get.dart';

class AdminTreeScreen extends StatelessWidget {
  const AdminTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TreeController.to;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: Obx(() {
                switch (ctrl.loadingState) {
                  case LoadingState.initial:
                  case LoadingState.loading:
                    return Stack(children: [
                      Assets.icons.treeHome.svg(fit: BoxFit.cover),
                      const Center(child: CustomLoader()),
                    ]);

                  case LoadingState.offline:
                  case LoadingState.error:
                    return EmptyDataWidget(
                      message: 'Failed to load data. Please try again.',
                      onRefresh: () async => ctrl.loadData(),
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
                    return FamilyTreeGraph(
                      root: treeData.root!,
                      onToggleEdit: true,
                    );
                }
              }),
            ),
            if (AuthController.to.isAdmin())
              Positioned(
                top: 10.h,
                left: 16.w,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: Get.back,
                    child: CustomContainer(
                      paddingAll: 10.r,
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      child: Assets.icons.backButton.svg(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}