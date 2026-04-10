import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';

class ProfileListTile extends StatelessWidget {
  const ProfileListTile({
    super.key,
    this.color,
    this.textColor,
    this.trailing,
    required this.title,
    required this.onTap,
    required this.icon,
  });

  final Color? color;
  final Color? textColor;
  final Widget? trailing;
  final String title;
  final VoidCallback onTap;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomContainer(
          onTap: onTap,
          verticalMargin: 10.h,
          paddingHorizontal: 16.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                height: 24.r,
                width: 24.r,
                colorFilter: ColorFilter.mode(
                  AppColors.color8A8A8A,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomText(
                  text: title,
                  textAlign: TextAlign.start,
                  color: textColor ?? AppColors.appBarTitleColor,
                ),
              ),
              if (trailing == null)
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: AppColors.appBarTitleColor,
                  size: 16.r,
                )
              else
                trailing!,
            ],
          ),
        ),
        Divider(color: AppColors.grayShade100, thickness: 0.5.h),
      ],
    );
  }
}
