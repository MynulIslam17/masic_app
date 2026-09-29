
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/search/search_screen.dart';
import 'package:masic_generation/features/tree/presentation/controllers/tree_controller.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_origin_dialog.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree.dart';
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
                      return Stack(children: [
                        Assets.icons.treeHome.svg(fit: BoxFit.cover),
                        const Center(child: CustomLoader()),
                      ]);
                    }
                    return FamilyTreeGraph(
                      key: ValueKey(treeData.hashCode),
                      root: treeData.root!,
                      onToggleEdit: true,
                    );
                }
              }),
            ),
            if (AuthController.to.isAdmin())
              Positioned(
                top: 10.h,
                right: 16.w,
                child: SafeArea(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          showSearch(
                            context: context,
                            delegate: SearchScreen(
                              hintText: 'Search members . . .',
                              onSearch: ctrl.searchMembers,
                              onResultTap: (result) {
                                Get.toNamed(
                                  AppRoutes.treeDetailsScreen,
                                  arguments: result.model as String,
                                );
                              },
                            ),
                          );
                        },
                        child: CustomContainer(
                          paddingAll: 10.r,
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          child: Assets.icons.search.svg(
                            height: 20.h,
                            width: 20.w,
                          ),
                        ),
                      ),

                      SizedBox(width: 6.w),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => FamilyOriginDialog.show(context),
                        child: CustomContainer(
                          paddingAll: 10.r,
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          child: Assets.icons.origin.svg(
                            height: 20.h,
                            width: 20.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}