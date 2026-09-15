import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/widgets/localized_name_text.dart';
import 'package:masic_generation/core/widgets/widgets.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.translateValue = false,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  /// Whether to auto-translate the value text.
  /// Set true for structured/enum values (gender, employment, education, etc.)
  /// Leave false (default) for personal identifiers (name, email, phone, urls).
  final bool translateValue;

  /// Single "Name" row: English [name] only; Arabic [arabicName] or translated [name].
  factory InfoRow.personName({
    Key? key,
    required String label,
    String? name,
    String? arabicName,
  }) {
    return InfoRow(
      key: key,
      label: label,
      valueWidget: LocalizedNameText(
        name: name,
        arabicName: arabicName,
        fontSize: 12.sp,
        textAlign: TextAlign.start,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
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
            child: valueWidget ??
                CustomText(
                  enableAutoTranslate: translateValue,
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
