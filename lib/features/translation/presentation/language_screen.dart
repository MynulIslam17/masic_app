import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/constants/language_constants.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:get/get.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TranslationController.to;

    return CustomScaffold(
      appBar: CustomAppBar(title: 'language'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          Obx(() => Column(
            children: AppLanguages.all.map((lang) {
              final bool isSelected = controller.currentCode == lang.code;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isSelected ? 10.h : 0,
                    horizontal: 16.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  tileColor: AppColors.primaryColor100,
                  title: CustomText(
                    enableAutoTranslate: false,
                    textAlign: TextAlign.start,
                    color: AppColors.appGreyColor,
                    text: '${lang.flag}  ${lang.name}',
                  ),
                  trailing: isSelected
                      ? Assets.icons.selected.svg()
                      : const SizedBox.shrink(),
                  onTap: () async {
                    await controller.changeLanguage(
                      lang,
                      onChange: Get.back,
                    );
                  },
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}