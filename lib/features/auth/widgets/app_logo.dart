import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    // this.title,
    // this.subtitle,  this.icon,
  });

  // final String? title, subtitle;
  // final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Assets.icons.logo.svg(height: 105.h,width: 131.w),
        //?icon,
        SizedBox(height: 20.h),
        // if (title != null) ...[
        //   CustomText(
        //     text: title ?? '',
        //     fontSize: 24.sp,
        //     fontWeight: FontWeight.w400,
        //     color: AppColors.primaryColor,
        //   ),
        //   SizedBox(height: 6.h),
        // ],
        //
        // if (subtitle != null)
        //   CustomText(
        //     text: subtitle ?? '',
        //     fontSize: 16.sp,
        //    color: Color(0xff444444),
        //   ),
      ],
    );
  }
}
