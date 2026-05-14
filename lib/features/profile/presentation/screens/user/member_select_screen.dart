import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/presentation/widgets/member_card.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class MemberSelectScreen extends StatelessWidget {
  const MemberSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Select for announcement',
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
      body: SingleChildScrollView(
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
                CustomText(
                  textAlign: TextAlign.start,
                  fontSize: 12.sp,
                  text: 'Total user : 02',
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
                      return MemberCard(user: user);
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CustomButton(
            onPressed: () {
              Get.toNamed(AppRoutes.createAnnouncementsScreen);
            },
            label: 'Submit',
          ),
        ),
      ),
    );
  }
}
