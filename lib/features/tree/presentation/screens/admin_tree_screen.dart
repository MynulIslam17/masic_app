
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
                        onTap: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                insetPadding: EdgeInsets.all(20.r),
                                backgroundColor: AppColors.background,
                                title: CustomText(
                                  text: 'Family origin',
                                  color: AppColors.primaryColor,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomText(
                                      textAlign: TextAlign.start,
                                      text:
                                      """The Subai' tribe is an ancient and distinguished Adnanite Arab tribe of Amiri lineage, historically centered in the town of Al-Khurmah. Its tribal presence extends to Ranyah, the lower regions of Wadi Turabah, and the surrounding valleys located east of Taif.
It is traditionally recognized that the Al-Subeaei family in Unaizah descends from Banu Thawr, one of the principal branches of the tribe, whose traditional sheikhs are the Al Shari’ family of Al-Hulaymah, the historic leaders of Banu Thawr.
The Subai' tribe comprises numerous branches and sub-clans, among the most notable are:
• Banu Amir
• Banu Umar
• Al Umair
• Al Qurayshat
• Banu Thawr
• Al Zukur
• Al Rubah
• Al Suwadah""",
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                ),

                                actions: [
                                  CustomButton(
                                    backgroundColor: AppColors.transparent,
                                    foregroundColor: AppColors.primaryColor,
                                    bordersColor: AppColors.primaryColor,
                                    onPressed: (){
                                      Get.back(canPop: true);
                                    },label: 'Close',)
                                ],
                              );
                            },
                          );
                        },
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