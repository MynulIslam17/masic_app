import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';

class AuthTitleWidgets extends StatelessWidget {
  const AuthTitleWidgets({
    super.key,
    this.title,
    this.subtitle,
    this.titleColor,
    this.subTitleColor,
    this.titleFontSize,
    this.subTitleFontSize,
    this.logo,
  });

  final Widget? logo;
  final String? title;
  final String? subtitle;
  final Color? titleColor;
  final Color? subTitleColor;
  final double? titleFontSize;
  final double? subTitleFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?logo,
        if (title != null)
          CustomText(
            top: 12.h,
            text: title ?? '',
            fontSize: titleFontSize ?? 14.sp,
            color: titleColor ?? AppColors.appGreyColor,
          ),
        if (subTitleColor != null)
          CustomText(
            top: 6.h,
            textAlign: TextAlign.start,
            text: subtitle ?? '',
            fontSize: subTitleFontSize ?? 15.sp,
            color: subTitleColor ?? AppColors.secondaryColor,
            textOverflow: TextOverflow.fade,
          ),
      ],
    );
  }
}
