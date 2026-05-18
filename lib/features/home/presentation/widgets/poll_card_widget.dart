import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/poll/data/models/poll_model.dart';
import 'package:get/get.dart';


class PollCardWidget extends StatelessWidget {
  const PollCardWidget({super.key, required this.poll});

  final PollModel poll;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      horizontalMargin: 6.w,
      bordersColor: AppColors.color8A8A8A,
      radiusAll: 20.r,
      height: 158.h,
      width: 298.w,
      paddingAll: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            top: 10.h,
            maxline: 1,
            textAlign: TextAlign.start,
            text: poll.title ?? '',
            fontSize: 16.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 12.h),
          CustomText(
            maxline: 2,
            textAlign: TextAlign.start,
            text: poll.tagline ?? '',
            fontSize: 10.sp,
          ),
          SizedBox(height: 14.h),

          CustomButton(
            bordersColor: AppColors.primaryColor,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.primaryColor,
            height: 38.h,
            fontSize: 12.sp,
            onPressed: () {
              Get.toNamed(AppRoutes.pollDetailsScreen, arguments: poll.sId);
            },
            label: 'Answer poll',
          ),
        ],
      ),
    );
  }
}
