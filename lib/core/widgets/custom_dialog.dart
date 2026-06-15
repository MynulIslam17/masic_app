import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';

class CustomDialog extends StatelessWidget {
  final String title, description;
  final String? leftButtonLabel;
  final String? rightButtonLabel;
  final Color? rightButtonBgColor, rightButtonLabelColor;
  final Color? leftButtonBgColor, leftButtonLabelColor;
  final Color? titleColor;
  final VoidCallback onTapLeftButton;
  final VoidCallback onTapRightButton;
  final bool isLoading;

  const CustomDialog({
    super.key,
    required this.title,
    this.leftButtonLabel = "Cancel",
    this.rightButtonLabel = "Log Out",
    required this.onTapLeftButton,
    required this.onTapRightButton,
    this.rightButtonBgColor = Colors.transparent,
    this.rightButtonLabelColor = AppColors.errorColor,
    this.leftButtonBgColor = Colors.transparent,
    this.leftButtonLabelColor = AppColors.primaryColor,
    required this.description,
    this.titleColor = AppColors.errorColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Text
                CustomText(text: title, fontSize: 16.sp, color: titleColor),
                SizedBox(height: 20.h),

                Divider(color: AppColors.appBarTitleColor, thickness: 0.5.h),

                SizedBox(height: 20.h),

                // Description Text
                CustomText(
                  left: 10.w,
                  right: 10.w,
                  text: description,
                  fontSize: 16.sp,
                  color: Color(0xff545454),
                  maxline: 2,
                ),
                SizedBox(height: 24.h),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    Expanded(
                      child: CustomButton(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        bordersColor: leftButtonLabelColor,
                        backgroundColor: leftButtonBgColor,
                        foregroundColor: leftButtonLabelColor,
                        onPressed: isLoading ? null : onTapLeftButton,
                        label: leftButtonLabel!,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // Confirm Button
                    Expanded(
                      child: CustomButton(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        bordersColor: rightButtonLabelColor,
                        backgroundColor: rightButtonBgColor,
                        foregroundColor: rightButtonLabelColor,
                        onPressed: isLoading ? null : onTapRightButton,
                        label: rightButtonLabel!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}