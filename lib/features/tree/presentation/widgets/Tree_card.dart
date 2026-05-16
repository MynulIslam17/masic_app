import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/custom_button.dart';
import 'package:flutter_task/core/widgets/custom_container.dart';
import 'package:flutter_task/core/widgets/custom_text.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
import 'package:get/get.dart';

class TreeCard extends StatelessWidget {
  final String label;
  final String id;
  final bool isRoot;
  final bool hasChildren;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final VoidCallback? onToggleEdit;

  const TreeCard({
    super.key,
    required this.label,
    required this.isRoot,
    required this.hasChildren,
    required this.isExpanded,
    this.onToggle, required this.id, this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.treeDetailsScreen, arguments: id);
          },
          child: CustomContainer(
            color: !isRoot ? Colors.transparent : Colors.white,
            radiusAll: 8.r,
            bordersColor: !isRoot ? Colors.transparent : AppColors.primaryColor.withValues(alpha: 0.4),
            paddingAll: !isRoot ? 0.r : 4.r,
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
                children: [
                  CustomText(
                    text: label,
                    fontSize: 13.sp,
                    fontWeight: isRoot ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.primaryColor,
                  ),
                  if (onToggleEdit != null) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
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
                                  text:
                                  'Please select the perfect option which you want to do ?',
                                  fontSize: 12.sp,
                                  color: AppColors.appGreyColor,
                                ),

                                SizedBox(height: 24.h),

                                CustomButton(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: AppColors.primaryColor,
                                  bordersColor: AppColors.primaryColor,
                                  onPressed: () {},
                                  label: 'Add new user',
                                ),

                                SizedBox(height: 16.h),

                                 Obx(() {
                                     return CustomButton(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: AppColors.primaryColor,
                                          bordersColor: AppColors.primaryColor,
                                          onPressed: onToggleEdit,
                                          isLoading: TreeController.to.deleteState.isLoading,
                                          label: 'Remove this user',
                                        );
                                   }
                                 ),
                              ],
                            ),

                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      height: 45.h,
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: AppColors.primaryColor,
                                      bordersColor: AppColors.primaryColor,
                                      onPressed: () {
                                      },
                                      label: 'Continue',
                                    ),
                                  ),

                                  SizedBox(width: 12.w),

                                  Expanded(
                                    child: CustomButton(
                                      height: 45.h,
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: AppColors.errorColor,
                                      bordersColor: AppColors.errorColor,
                                      onPressed: () {
                                        Get.back(canPop: true);
                                      },
                                      label: 'Cancel',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );                      },
                      child: Container(
                        width: 26.r,
                        height: 26.r,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit_outlined,
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
    );
  }
}