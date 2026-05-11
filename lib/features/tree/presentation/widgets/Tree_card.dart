import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/custom_text.dart';
import 'package:get/get.dart';

class TreeCard extends StatelessWidget {
  final String label;
  final String id;
  final bool isRoot;
  final bool hasChildren;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const TreeCard({
    super.key,
    required this.label,
    required this.isRoot,
    required this.hasChildren,
    required this.isExpanded,
    this.onToggle, required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.treeDetailsScreen, arguments: id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isRoot
                ? AppColors.primaryColor
                : AppColors.primaryColor.withOpacity(0.4),
            width: isRoot ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: label,
              fontSize: 13.sp,
              fontWeight: isRoot ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.primaryColor,
            ),
            if (hasChildren) ...[
              SizedBox(width: 8.w),
              GestureDetector(
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
      ),
    );
  }
}