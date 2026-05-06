import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:flutter_task/features/announcement/presentation/widgets/announcement_card.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AnnouncementController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Announcements'),
      body: RefreshIndicator(
        onRefresh: controller.retry,
        child: SingleChildScrollView(
          controller: controller.scrollController,
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
                  Expanded(
                    child: CustomText(
                      textAlign: TextAlign.start,
                      fontSize: 12.sp,
                      text: 'Total events : ${controller.announcements.length}',
                    ),
                  ),
                  CustomButton(
                    height: 38.h,
                    elevation: true,
                    borderWidth: 3,
                    bordersColor: Color(0xffB0B0B0),
                    foregroundColor: AppColors.primaryColor,
                    backgroundColor: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    width: 174.w,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => CustomDialog(
                          title: "Select announcement type",
                          rightButtonLabel: 'For all',
                          leftButtonLabel: 'Group',
                          leftButtonBgColor: AppColors.primaryColor,
                          leftButtonLabelColor: Colors.white,
                          rightButtonLabelColor: AppColors.primaryColor,
                          titleColor: AppColors.primaryColor,
                          onTapLeftButton: () {
                            Get.back();
                            Get.toNamed(AppRoutes.memberSelectScreen);
                          },
                          onTapRightButton: () {
                            Get.back();
                            ProfileController.to.selectedUserIds.clear();
                            Get.toNamed(AppRoutes.createAnnouncementsScreen);
                          },
                          description:
                              'Please select one which type of announcement you want to upload',
                        ),
                      );
                    },
                    label: 'Create announcements',
                  ),
                ],
              ),

              /// ============ > Events List < ============
              SizedBox(height: 24.h),
              Obx(() {
                switch (controller.loadingState) {
                  case LoadingState.initial:
                  case LoadingState.loading:
                    return CustomLoader();

                  case LoadingState.offline:
                  case LoadingState.error:
                    return CustomText(text: '');

                  case LoadingState.loaded:
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.announcements.length,
                      itemBuilder: (context, index) {
                        final announcement = controller.announcements[index];
                        return AnnouncementCard(announcement: announcement);
                      },
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
    );
  }
}
