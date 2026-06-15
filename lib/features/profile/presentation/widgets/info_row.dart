import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/widgets/widgets.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, this.value, this.valueWidget});


  final String label;
 final String? value;
    final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
     return Padding(
       padding:  EdgeInsets.symmetric(vertical: 4.h),
       child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: CustomText(
              text: label,
              fontSize: 12.sp,
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(width: 24.w),
          CustomText(text: ':', fontSize: 12.sp),
          SizedBox(width: 32.w),
          Expanded(
            child:
            valueWidget ??
                CustomText(
                  enableAutoTranslate: false,
                  text: value ?? '',
                  fontSize: 12.sp,
                  textAlign: TextAlign.start,
                ),
          ),
        ],
           ),
     );
  }
}
