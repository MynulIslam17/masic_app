import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/clipboard_helper.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/localized_name_text.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/presentation/widgets/linkedin_open_button.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.translateValue = false,
    this.copyable = false,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  /// Whether to auto-translate the value text.
  /// Set true for structured/enum values (gender, employment, education, etc.)
  /// Leave false (default) for personal identifiers (name, email, phone, urls).
  final bool translateValue;

  /// When true, tap copies [value] (email / phone).
  final bool copyable;

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

  factory InfoRow.linkedIn({
    Key? key,
    String label = 'LinkedIn',
    required String url,
  }) {
    return InfoRow(
      key: key,
      label: label,
      valueWidget: LinkedInOpenButton(url: url),
    );
  }

  bool get _canCopy {
    final text = value?.trim() ?? '';
    return copyable && text.isNotEmpty && text.toUpperCase() != 'N/A';
  }

  Future<void> _copy() {
    return ClipboardHelper.copy(value ?? '', message: '$label copied');
  }

  @override
  Widget build(BuildContext context) {
    final textStyleSize = 12.sp;

    Widget content = valueWidget ??
        CustomText(
          enableAutoTranslate: translateValue,
          text: translateValue
              ? (value?.toTitleCaseOrNull ?? '')
              : (value ?? ''),
          fontSize: textStyleSize,
          textAlign: TextAlign.start,
        );

    if (_canCopy) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _copy,
        onLongPress: _copy,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            SizedBox(width: 4.w),
            Icon(
              Icons.copy_rounded,
              size: 12.sp,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: label,
            fontSize: textStyleSize,
            textAlign: TextAlign.start,
          ),
          CustomText(
            text: ' : ',
            fontSize: textStyleSize,
            textAlign: TextAlign.start,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
