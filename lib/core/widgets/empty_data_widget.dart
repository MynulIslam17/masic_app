import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';

class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({
    super.key,
    this.message, this.onRefresh,
  });

  final String? message;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.lotties.emptyData.lottie(height: 150.h),
          SizedBox(height: 16.h),
          CustomText(text: message ?? 'No data found'),
          SizedBox(height:44.h),
          if(onRefresh != null)
          CustomButton(
            height: 38.h,
              fontSize: 12.sp,
              width: 100.w,
              onPressed: onRefresh, label: 'Refresh'),
      ],
      ),
    );
  }
}
