import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:flutter_task/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AnnouncementsDetailsScreen extends StatelessWidget {
  const AnnouncementsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcementId = Get.arguments as String;
    final controller = AnnouncementController.to;

    return CustomScaffold(
      appBar: CustomAppBar(title: 'Announcements details'),
      body: Obx(() {
        final announcement = controller.announcements.firstWhereOrNull(
              (e) => e.sId == announcementId,
        );
        if (announcement == null) {
          return const Center(child: Text('Announcement not found'));
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNetworkImage(
                borderRadius: 12.r,
                height: 225.h,
                width: double.infinity,
                imageUrl: announcement.bannerUrl,
              ),
              CustomText(
                top: 10.h,
                textAlign: TextAlign.start,
                text: announcement.title ?? 'N/A',
                maxline: 2,
                textOverflow: TextOverflow.ellipsis,
                fontSize: 16.sp,
              ),
              CustomText(
                top: 12.h,
                textAlign: TextAlign.start,
                text: announcement.description ?? 'N/A',
                fontSize: 10.sp,
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(() {
            final announcement = controller.announcements.firstWhereOrNull(
                  (e) => e.sId == announcementId,
            );
            if (announcement == null) return const SizedBox.shrink();
            final status = announcement.status ?? '';
            final isMe = announcement.createdBy?.sId ==
                ProfileController.to.userData?.sId;
            final isAdmin = AuthController.to.isAdmin();

            if (isAdmin && status == 'pending') {
              return Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Obx(() {
                            return CustomDialog(
                              title: "Approve Announcements",
                              titleColor: AppColors.primaryColor,
                              rightButtonLabel: 'Yes, Approve',
                              rightButtonBgColor: AppColors.primaryColor,
                              rightButtonLabelColor: Colors.white,
                              isLoading: controller.updateLoadingState.isLoading,
                              onTapLeftButton: () => Get.back(),
                              onTapRightButton: () => controller.updateStatus(
                                announcement.sId ?? '',
                                'approved',
                              ),
                              description:
                              'Are you sure want to approve your Announcements?',
                            );
                          }),
                        );
                      },
                      label: 'Approved',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      bordersColor: AppColors.errorColor,
                      foregroundColor: AppColors.errorColor,
                      backgroundColor: AppColors.bgColor,
                      label: 'Rejected',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => CustomDialog(
                            title: "Reject Announcements",
                            rightButtonLabel: 'Yes, Reject',
                            onTapLeftButton: () => Get.back(),
                            onTapRightButton: () => controller.updateStatus(
                              announcement.sId ?? '',
                              'declined',
                            ),
                            description:
                            'Are you sure want to reject your Announcements?',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            if (isMe) {
              return CustomButton(
                bordersColor: AppColors.errorColor,
                foregroundColor: AppColors.errorColor,
                backgroundColor: AppColors.bgColor,
                label: 'Delete',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Obx(() {
                        return CustomDialog(
                          title: "Delete Announcements",
                          rightButtonLabel: 'Yes, Delete',
                          onTapLeftButton: () => Get.back(),
                          isLoading: controller.deleteLoadingState.isLoading,
                          onTapRightButton: () => controller.deleteAnnouncement(announcementId),
                          description:
                          'Are you sure want to delete your Announcements?',
                        );
                      }
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          }),
        ),
      ),
    );
  }
}