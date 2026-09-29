import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/localized_name_helper.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/custom_button.dart';
import 'package:masic_generation/core/widgets/custom_container.dart';
import 'package:masic_generation/core/widgets/custom_text.dart';
import 'package:masic_generation/features/tree/data/models/tree_model.dart';
import 'package:masic_generation/features/tree/presentation/controllers/tree_controller.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree/constants.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:get/get.dart';

class NodeCard extends StatelessWidget {
  final Meta meta;
  final VoidCallback? onToggle;
  final bool isExpanded;

  const NodeCard({
    super.key,
    required this.meta,
    this.onToggle,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.bgColor,
      radiusAll: 8.r,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              debugPrint('CLICKED => ${meta.id}');
              Get.toNamed(AppRoutes.treeDetailsScreen, arguments: meta.id);
            },
            child: CustomContainer(
              color: !meta.isRoot ? Colors.transparent : Colors.white,
              radiusAll: 8.r,
              bordersColor: !meta.isRoot
                  ? Colors.transparent
                  : AppColors.primaryColor.withValues(alpha: 0.4),
              paddingAll: !meta.isRoot ? 0.r : 4.r,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: math.min(
                          FamilyTreeMetrics.maxNameWidth,
                          MediaQuery.sizeOf(context).width * 0.42,
                        ),
                      ),
                      child: _TreeMemberName(
                        meta: meta,
                        fontSize: 13.sp,
                        fontWeight: meta.isRoot
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    // ── Edit button ─────────────────────────────────────────
                    if (meta.onDelete != null) ...[
                      SizedBox(width: 8.w),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _showEditDialog(context),
                        child: Container(
                          width: 26.r,
                          height: 26.r,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16.sp,
                            color: AppColors.primaryColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // ── Expand/collapse arrow ──────────────────────────────────────────
          if (meta.hasChildren) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpanded ? Icons.arrow_back : Icons.arrow_forward,
                  size: 16.sp,
                  color: AppColors.primaryColor.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: CustomText(
          text: 'Edit',
          fontSize: 20.sp,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: 'Please select the perfect option which you want to do?',
              fontSize: 12.sp,
              color: AppColors.appGreyColor,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.primaryColor,
              bordersColor: AppColors.primaryColor,
              onPressed: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.motherSelectScreen,
                  arguments: meta.memberId,
                );
              } ,
              label: 'Add new user',
            ),
            SizedBox(height: 16.h),
            Obx(
              () => CustomButton(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.primaryColor,
                bordersColor: AppColors.primaryColor,
                onPressed: meta.onDelete,
                isLoading: TreeController.to.deleteState.isLoading,
                label: 'Remove this user',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tree-only name: Arabic locale uses [Meta.arabicName] as-is.
/// If that field is empty, the English name is translated.
class _TreeMemberName extends StatelessWidget {
  const _TreeMemberName({
    required this.meta,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
  });

  final Meta meta;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      TranslationController.to.currentLanguage.value;
      final isArabic = LocalizedNameHelper.isArabicLocale;
      final arabic = meta.arabicName?.trim();
      final english = (meta.name?.trim().isNotEmpty == true)
          ? meta.name!.trim()
          : meta.label.trim();

      if (isArabic && arabic != null && arabic.isNotEmpty) {
        return CustomText(
          text: arabic,
          enableAutoTranslate: false,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          maxline: 2,
          textOverflow: TextOverflow.ellipsis,
        );
      }

      return CustomText(
        text: english,
        enableAutoTranslate: isArabic && english.isNotEmpty,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        maxline: 2,
        textOverflow: TextOverflow.ellipsis,
      );
    });
  }
}
