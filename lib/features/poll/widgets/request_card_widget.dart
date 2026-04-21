import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';

class RequestCardWidget extends StatelessWidget {
  const RequestCardWidget({super.key,  this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return             CustomContainer(
      horizontalMargin: 16.w,
      bordersColor: AppColors.color8A8A8A,
      radiusAll: 20.r,
      height: 158.h,
      width: double.infinity,
      paddingHorizontal: 44.r,
      paddingVertical: 20.r,
      child: Column(
        children: [
          CustomText(
            maxline: 1,
            text: 'Request for opportunities',
            fontSize: 16.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 12.h),
          CustomText(
            maxline: 2,
            text:
            'Submit requests for jobs, volunteering opportunities, workshops',
            fontSize: 10.sp,
          ),
          SizedBox(height: 14.h),

          CustomButton(
            height: 38.h,
            fontSize: 12.sp,
            onPressed: onTap,
            label: 'Request',
          ),
        ],
      ),
    );

  }
}
