import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.announcement});

  final AnnouncementModel announcement;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginBottom: 10.h,
      paddingAll: 16.r,
      radiusAll: 10.r,
      color: Colors.transparent,
      bordersColor: AppColors.colorE6E6E6,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                textAlign: TextAlign.start,
                text: announcement.status ?? 'N/A',
                fontSize: 12.sp,
                color: AppColors.primaryColor,
              ),
            ],
          ),

          if (announcement.bannerUrl != null &&
              announcement.bannerUrl!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            CustomNetworkImage(
              borderRadius: 12.r,
              height: 152.h,
              width: double.infinity,
              imageUrl: announcement.bannerUrl,
            ),
          ],

          CustomText(
            top: 10.h,
            textAlign: TextAlign.start,
            text: announcement.title ?? 'N/A',
            fontSize: 16.sp,
          ),

          CustomText(
            top: 12.h,
            textAlign: TextAlign.start,
            maxline: 3,
            text: announcement.description ?? 'N/A',
            fontSize: 10.sp,
          ),

          SizedBox(height: 12.h),
          CustomButton(
            onPressed: () {
              Get.toNamed(AppRoutes.announcementsDetailsScreen,arguments: announcement.sId);
            },
            bordersColor: AppColors.primaryColor,
            foregroundColor: AppColors.primaryColor,
            backgroundColor: Colors.white,
            fontSize: 12.sp,
            height: 38.h,
            fontWeight: FontWeight.w400,
            label: 'View details',
          ),
        ],
      ),
    );
  }
}
