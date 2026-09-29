import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;

    return AlertDialog(
      backgroundColor: AppColors.bgColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      title: CustomText(
        text: 'Filter',
        color: AppColors.primaryColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            _buildSection(
              'Gender',
              ['Male', 'Female'],
              getter: () => controller.genderFilter,
              setter: (val) => controller.setGenderFilter(val),
            ),
            SizedBox(height: 14.h),
            _buildSection(
              'Age Range',
              ['01-20', '21-40', '41-60', '61-80', '81-100'],
              getter: () => controller.ageFilter,
              setter: (val) => controller.setAgeFilter(val),
            ),
            SizedBox(height: 14.h),
            _buildSection(
              'Employment Status',
              ['Employed', 'Unemployed', 'Self-employed'],
              getter: () => controller.employmentFilter,
              setter: (val) => controller.setEmploymentFilter(val),
            ),
            SizedBox(height: 14.h),
            _buildSection(
              'Education Level',
              ['College', 'School', 'University', 'Postgraduate'],
              getter: () => controller.educationFilter,
              setter: (val) => controller.setEducationFilter(val),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                backgroundColor: Colors.transparent,
                bordersColor: AppColors.primaryColor,
                foregroundColor: AppColors.primaryColor,
                label: 'Apply',
                onPressed: () {
                  controller.refresh();
                  Get.back();
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomButton(
                backgroundColor: Colors.transparent,
                bordersColor: AppColors.errorColor,
                foregroundColor: AppColors.errorColor,
                label: 'Clear',
                onPressed: () {
                  controller.clearAllFilters();
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
      String label,
      List<String> items, {
        required String Function() getter,
        required void Function(String) setter,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, fontSize: 16.sp, color: AppColors.primaryColor),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: items.map((item) {
            return Obx(() {
              final isSelected = getter() == item;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setter(isSelected ? '' : item),
                child: CustomContainer(
                  radiusAll: 100.r,
                  bordersColor: isSelected
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  paddingVertical: 12.h,
                  paddingHorizontal: 20.w,
                  child: CustomText(
                    text: item,
                    fontSize: 10.sp,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.grayShade100,
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ],
    );
  }
}