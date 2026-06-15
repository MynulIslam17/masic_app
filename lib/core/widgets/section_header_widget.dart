import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
class SectionHeaderWidget extends StatelessWidget {
  const SectionHeaderWidget({super.key, this.onTap, required this.title,  this.fontWeight = FontWeight.w400});

  final VoidCallback? onTap;
  final String title;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            fontSize: 16.sp,
            text: title,
            color: AppColors.colorB0B0B0,
            fontWeight: fontWeight,
          ),
          if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: CustomText(
              fontSize: 14.sp,
              text: 'See All',
              color: AppColors.color6F6F70,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
