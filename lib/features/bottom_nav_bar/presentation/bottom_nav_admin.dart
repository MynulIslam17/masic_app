import 'package:flutter/material.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:masic_generation/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:masic_generation/features/bottom_nav_bar/presentation/widgets/admin_bottom_nav_bar.dart';
import 'package:get/get.dart';

class BottomNavAdminBar extends StatelessWidget {
  const BottomNavAdminBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.bgColor,
      body: GetBuilder<BottomNavBarController>(
        builder: (controller) =>
        IndexedStack(
        index: controller.selectedIndex,
        children:  NavItemModel.adminNavItems.map((e) => e.screen).toList(),
      ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(),
    );
  }
}