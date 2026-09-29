import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/helpers/url_launch_helper.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';

class LinkedInOpenButton extends StatelessWidget {
  const LinkedInOpenButton({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(100.r),
        child: InkWell(
          onTap: () => UrlLaunchHelper.open(url),
          borderRadius: BorderRadius.circular(100.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14.r,
                  color: Colors.white,
                ),
                SizedBox(width: 6.w),
                CustomText(
                  text: 'Open LinkedIn',
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
