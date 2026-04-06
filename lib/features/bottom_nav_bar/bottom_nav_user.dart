import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/features/home/home_screen.dart';
import 'package:flutter_task/features/profile/profile_screen.dart';
import 'package:get/get.dart';

class CustomBottomNavUserBar extends StatelessWidget {
  const CustomBottomNavUserBar({super.key});

  static final List<Widget> _screens = [
    HomeScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  static final List<Map<String, dynamic>> _navItems = [
    {"icon": Assets.icons.tree.path, "label": "Home"},
    {"icon": Assets.icons.home.path, "label": "Home"},
    {"icon": Assets.icons.profileHome.path, "label": "Profile"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: GetBuilder<BottomNavBarController>(
        builder: (controller) => _screens[controller.selectedIndex],
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 20.h,
        ),
        child: CustomContainer(
          radiusAll: 100.r,
          paddingVertical: 10.h,
          color: AppColors.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
                  (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    return GetBuilder<BottomNavBarController>(
      builder: (controller) {
        final bool isSelected = controller.selectedIndex == index;

        return GestureDetector(
          onTap: () => controller.onChange(index),
          child: CustomContainer(
            color: isSelected ? Colors.black26 : Colors.transparent,
            paddingAll: 9.r,
            shape: BoxShape.circle,
            child: SvgPicture.asset(
              _navItems[index]["icon"],
              width: 24.w,
              height: 24.h,
            ),
          ),
        );
      },
    );
  }
}