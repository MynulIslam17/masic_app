
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';

class EmptyScreenHelper {
  EmptyScreenHelper._();

  static EmptyScreenHelper get instance => EmptyScreenHelper._();


  Widget emptyData ({required RefreshCallback onRefresh,String? title}){
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.lotties.emptyData.lottie(height: 200.h),
          CustomText(
            text: title ?? 'No Data Found',
            color: AppColors.color6F6F70,
            fontSize: 16.sp,
          ),
          SizedBox(height: 16.h),

          /// 🔄 Refresh Button
          CustomButton(
            label: 'Refresh',
            onPressed: onRefresh,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            fontSize: 14.sp,
            height: 34.h,
            width: 100.w,
          ),
        ],
      ),
    );

  }

}