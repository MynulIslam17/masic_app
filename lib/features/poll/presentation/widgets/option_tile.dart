import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/poll/data/models/poll_details_model.dart';
import 'package:masic_generation/features/poll/presentation/controllers/poll_controller.dart';
import 'package:get/get.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({super.key, required this.options, required this.isReadOnly});

  final PollOption options;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = PollController.to;
      final isSelected = controller.selectedOptionId == (options.id ?? '');
      final hasVoted = controller.selectedOptionId.isNotEmpty || isReadOnly;

      return Stack(
        children: [
          // ── Percentage fill bar ───────────────────────────────────────
          if (hasVoted)
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (options.percentage ?? 0) / 100.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.12)
                        : AppColors.primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

          // ── Option row ────────────────────────────────────────────────
          CustomContainer(
            // Disable tap if already answered (read-only mode)
            onTap: isReadOnly
                ? null
                : () => controller.selectOption(options.id ?? ''),
            marginBottom: 10.h,
            paddingHorizontal: 16.w,
            paddingVertical: 12.h,
            radiusAll: 12.r,
            bordersColor: isSelected
                ? AppColors.primaryColor
                : AppColors.colorB0B0B0,
            child: Row(
              children: [
                // ── Radio circle ────────────────────────────────────────
                Container(
                  width: 28.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.colorB0B0B0,
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 14.w : 0,
                      height: isSelected ? 14.h : 0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),

                // ── Option text ─────────────────────────────────────────
                Expanded(
                  child: CustomText(
                    textAlign: TextAlign.start,
                    text: options.text ?? '',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // ── Percentage label ────────────────────────────────────
                if (hasVoted)
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: CustomText(
                      text: '${options.percentage}%',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : null,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
