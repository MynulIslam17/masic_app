import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class TabItem extends StatelessWidget {
  final String label;
  final int index;
  final RxInt selectedTab;
  final void Function(int) onTap;

  const TabItem({super.key,
    required this.label,
    required this.index,
    required this.selectedTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = selectedTab.value == index;
      return Expanded(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 16.w),
          child: GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive
                        ? AppColors.primaryColor
                        : AppColors.colorE6E6E6,
                    width: isActive ? 1 : 0.5,
                  ),
                ),
              ),
              child: Center(
                child: CustomText(
                  fontSize: 12.sp,
                  text: label,),
              ),
            ),
          ),
        ),
      );
    });
  }
}