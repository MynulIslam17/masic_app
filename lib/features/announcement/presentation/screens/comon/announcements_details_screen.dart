import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:masic_generation/features/announcement/presentation/widgets/announcement_banner_carousel.dart';
import 'package:masic_generation/features/announcement/presentation/widgets/announcement_decline_dialog.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AnnouncementsDetailsScreen extends StatefulWidget {
  const AnnouncementsDetailsScreen({super.key});

  @override
  State<AnnouncementsDetailsScreen> createState() =>
      _AnnouncementsDetailsScreenState();
}

class _AnnouncementsDetailsScreenState
    extends State<AnnouncementsDetailsScreen> {
  late final String announcementId;
  final controller = AnnouncementController.to;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    announcementId = (args is String ? args : args?.toString() ?? '').trim();
    controller.loadAnnouncementDetails(announcementId);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Announcements details'),
      body: Obx(() {
        final announcement = controller.findAnnouncement(announcementId);
        final state = controller.detailState(announcementId);
        if (announcement == null || controller.isMissing(announcementId)) {
          if (controller.isMissing(announcementId)) {
            return const EmptyDataWidget(
              message: 'This announcement is no longer available.',
            );
          }
          if (state == LoadingState.error || state == LoadingState.offline) {
            return EmptyDataWidget(
              message: state == LoadingState.offline
                  ? 'You are offline. Connect to load this announcement.'
                  : 'Could not load this announcement.',
              onRefresh: () =>
                  controller.loadAnnouncementDetails(announcementId),
            );
          }
          return const Center(child: CustomLoader());
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnnouncementBannerCarousel(
                bannerUrls: announcement.allBannerUrls,
                height: 225.h,
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
              if (announcement.status == 'declined' &&
                  (announcement.declineReason?.trim().isNotEmpty ?? false)) ...[
                CustomText(
                  top: 16.h,
                  text: 'Decline reason',
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.start,
                ),
                CustomText(
                  top: 6.h,
                  text: announcement.declineReason!,
                  textAlign: TextAlign.start,
                ),
              ],
              SizedBox(height: 12.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(() {
            final announcement = controller.findAnnouncement(announcementId);
            if (announcement == null || controller.isMissing(announcementId)) {
              return const SizedBox.shrink();
            }
            final status = announcement.status ?? '';
            final isMe =
                announcement.createdBy?.sId ==
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
                              isLoading:
                                  controller.updateLoadingState.isLoading,
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
                          barrierDismissible: false,
                          builder: (context) => AnnouncementDeclineDialog(
                            announcementId: announcement.sId ?? '',
                            controller: controller,
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
                        onTapRightButton: () async {
                          await controller.deleteAnnouncement(announcementId);
                          // Deleted: leave the details page as well.
                          if (controller.isMissing(announcementId) &&
                              Get.currentRoute ==
                                  AppRoutes.announcementsDetailsScreen) {
                            Get.back();
                          }
                        },
                        description:
                            'Are you sure want to delete your Announcements?',
                      );
                    }),
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
