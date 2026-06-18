import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:masic_generation/features/bottom_nav_bar/presentation/widgets/nav_item_widget.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: MediaQuery.of(context).padding.bottom + 10.h),
      child: CustomContainer(
        radiusAll: 100.r,
        paddingVertical: 10.h,
        color: AppColors.primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            NavItemModel.userNavItems.length,
                (index) {
              final navItem = NavItemModel.userNavItems[index];
              return BottomNavItem(
                index: index,
                navItem: navItem,
              );
                } ,
          ),
        ),
      ),
    );
  }
}
