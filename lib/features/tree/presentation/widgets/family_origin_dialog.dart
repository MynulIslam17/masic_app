import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:get/get.dart';

class FamilyOriginDialog extends StatelessWidget {
  const FamilyOriginDialog({super.key});

  static const String _originText = """The Subai' tribe is an ancient and distinguished Adnanite Arab tribe of Amiri lineage, historically centered in the town of Al-Khurmah. Its tribal presence extends to Ranyah, the lower regions of Wadi Turabah, and the surrounding valleys located east of Taif.
It is traditionally recognized that the Al-Subeaei family in Unaizah descends from Banu Thawr, one of the principal branches of the tribe, whose traditional sheikhs are the Al Shari’ family of Al-Hulaymah, the historic leaders of Banu Thawr.
The Subai' tribe comprises numerous branches and sub-clans, among the most notable are:
• Banu Amir
• Banu Umar
• Al Umair
• Al Qurayshat
• Banu Thawr
• Al Zukur
• Al Rubah
• Al Suwadah""";

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const FamilyOriginDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screen.height * 0.75,
          maxWidth: 400.w,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: 'Family origin',
                color: AppColors.primaryColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: SingleChildScrollView(
                  child: CustomText(
                    textAlign: TextAlign.start,
                    text: _originText,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                width: 140.w,
                height: 40.h,
                backgroundColor: AppColors.transparent,
                foregroundColor: AppColors.primaryColor,
                bordersColor: AppColors.primaryColor,
                onPressed: () => Get.back(canPop: true),
                label: 'Close',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
