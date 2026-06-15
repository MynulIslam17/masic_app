import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:get/get.dart';


class HomeAnnouncementCard extends StatelessWidget {
  const HomeAnnouncementCard({super.key, required this.announcement});

  final AnnouncementModel announcement;

  @override
  Widget build(BuildContext context) {
    return     Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            CustomContainer(
                marginLeft: 34.w,
                width: 112.w,
                child: Divider(color: AppColors.color8A8A8A,)),
            CustomContainer(
              horizontalMargin: 16.w,
              bordersColor: AppColors.primaryColor,
              radiusAll: 20.r,
              height: 164.h,
              width: double.infinity,
              paddingAll: 20.r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  CustomText(
                    textAlign: TextAlign.start,
                    text: announcement.title ?? '',
                    fontSize: 16.sp,
                  ),
                  SizedBox(height: 12.h),
                  CustomText(
                    maxline: 2,
                    textAlign: TextAlign.start,
                    text: announcement.description ?? '',
                    fontSize: 10.sp,
                  ),
                  SizedBox(height: 12.h),

                  CustomButton(
                    width: 100.w,
                    height: 32.h,
                    fontSize: 12.sp,
                    onPressed: (){
                      Get.toNamed(AppRoutes.announcementsDetailsScreen,arguments: announcement.sId);
                    },label: 'View details',)
                ],
              ),
            ),

            CustomContainer(
                marginLeft: 100.w,
                width: 197.w,
                child: Divider(color: AppColors.color8A8A8A,)),
          ],
        ),

        Positioned(
            top: 0,
            right: 44.w,
            child: CustomContainer(
                width: 80.w,
                color: AppColors.bgColor,
                child: Assets.icons.logo.svg(width: 57.w,height: 45.h))),
      ],
    );
  }
}
