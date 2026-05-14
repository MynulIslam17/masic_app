import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/features/profile/presentation/widgets/user_card.dart';
import 'package:get/get.dart';

class AllAdminScreen extends StatefulWidget {
  const AllAdminScreen({super.key});

  @override
  State<AllAdminScreen> createState() => _AllAdminScreenState();
}

class _AllAdminScreenState extends State<AllAdminScreen> {


  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_,didPop) {
        controller.setRoleFilter('');
      },
      child: CustomScaffold(
        appBar: CustomAppBar(
          backAction: (){
            controller.setRoleFilter('');
            Get.back(canPop: true);
          },
          title: 'Admins',
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: CustomText(text: 'Filter'),
                    content: Column(children: []),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              icon: Assets.icons.filter.svg(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              children: [
                CustomTextField(
                  validator: (_) => null,
                  prefixIcon: Assets.icons.search.svg(),
                  borderRadio: 100.r,
                  borderColor: AppColors.colorE6E6E6,
                  showShadow: false,
                  controller: controller.searchController,
                  hintText: 'Search here . . .',
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Obx(() {
                        return CustomText(
                          textAlign: TextAlign.start,
                          fontSize: 12.sp,
                          text: 'Total user : ${controller.usersData.length}',
                        );
                      }
                    ),
                  ],
                ),

                /// ============ > Events List < ============
                SizedBox(height: 24.h),
                Obx(() {
                  switch (controller.loadingState) {
                    case LoadingState.initial:
                    case LoadingState.loading:
                      return Center(child: CustomLoader());

                    case LoadingState.offline:
                    case LoadingState.error:
                      return CustomText(text: '');

                    case LoadingState.loaded:
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.usersData.length,
                        itemBuilder: (context, index) {
                          final user = controller.usersData[index];
                          return UserCard(user: user);
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
                      );
                  }
                }),
                Obx(
                      () => controller.isLoadingMore
                      ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(child: CustomLoader()),
                  )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
