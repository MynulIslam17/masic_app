import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/custom_text.dart';
import 'package:get/get.dart';

import '../../../../core/constants/language_constants.dart';
import '../controller/translation_controller.dart';

/// A ready-to-use language picker bottom sheet.
///
/// **Show it anywhere:**
/// ```dart
/// LanguagePicker.show(context);
/// ```
///
/// **With an onChange callback:**
/// ```dart
/// LanguagePicker.show(
///   context,
///   onChange: (lang) => print('Switched to ${lang.name}'),
/// );
/// ```
class LanguagePicker {
  LanguagePicker._();

  static void show(
      BuildContext context, {
        void Function(AppLanguage)? onChange,
      }) {
    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _LanguagePickerSheet(onChange: onChange),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({this.onChange});

  final void Function(AppLanguage)? onChange;

  @override
  Widget build(BuildContext context) {
    final controller = TranslationController.to;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
           SizedBox(height: 16.h),

          // Title
          CustomText(text:
            'Select Language',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
           SizedBox(height: 12.h),

          // Language list
          Obx(() {
            final current = controller.currentCode;
            return Column(
              children: AppLanguages.all.map((lang) {
                final isSelected = lang.code == current;
                return ListTile(
                  leading: Text(lang.flag,
                      style:  TextStyle(fontSize: 28.sp)),
                  title: CustomText(
                    textAlign: TextAlign.start,
                      text : lang.name,color: AppColors.primaryColor),
                  subtitle: CustomText(
                    textAlign: TextAlign.start,
                      text: lang.code.toUpperCase(),
                      color: theme.hintColor),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                      color: AppColors.primaryColor)
                      : null,
                  selected: isSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.changeLanguage(
                      lang,
                      onChange: onChange != null ? () => onChange!(lang) : null,
                    );
                  },
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

/// A compact flag + code button that opens [LanguagePicker] on tap.
///
/// ```dart
/// LanguageButton()  // place in AppBar actions or settings screen
/// ```
// class LanguageButton extends StatelessWidget {
//   const LanguageButton({
//     super.key,
//     this.onChange,
//   });
//
//   final void Function(AppLanguage)? onChange;
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final controller = TranslationController.to;
//       return InkWell(
//         onTap: () => LanguagePicker.show(context, onChange: onChange),
//         borderRadius: BorderRadius.circular(8),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 controller.currentFlag,
//                 style: const TextStyle(fontSize: 20),
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 controller.currentCode.toUpperCase(),
//                 style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }