import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/custom_scaffold.dart';
import 'package:masic_generation/core/widgets/custom_text.dart';

class AiAgentScreen extends StatelessWidget {
  const AiAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Assets.icons.aiEmpty.svg(width: 100.r, height: 100.r),
            SizedBox(height: 32.h),
            CustomText(
              text: 'AI Agent Under Maintenance',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
            CustomText(
              left: 24.w,
              right: 24.w,
              top: 10.h,
              text:
                  "This feature is currently under development. We'll launch it soon, InshaAllah.",
              fontSize: 12.sp,
            ),
          ],
        ),
      ),
    );
  }
}
