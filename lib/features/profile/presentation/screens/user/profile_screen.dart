
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/core/widgets/profile_list_tile.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomScaffold(
      //appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 44.h),
            Obx(
              () {
                return CustomNetworkImage(
                    boxShape: BoxShape.circle,
                    height: 80.r, width: 80.r ,imageUrl: controller.userData?.profileImage);
              }
            ),
            Obx(() {
                return CustomText(
                  text: controller.userData?.name ?? '',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  top: 6.h,
                );
              }
            ),
        
            SizedBox(height: 20.h),
            // List of Options
            ProfileListTile(
              icon: Assets.icons.profile.path,
              title: "Profile Information",
              onTap: () {
                Get.toNamed(AppRoutes.profileInformationScreen);
              },
            ),
            ProfileListTile(
              icon: Assets.icons.requested.path,
              title: "Requests",
              onTap: () {
                Get.toNamed(AppRoutes.requestedScreen);
              },
            ),ProfileListTile(
              icon: Assets.icons.personal.path,
              title: "Personal Information",
              onTap: () {
                Get.toNamed(AppRoutes.personalInfoScreen);
              },
            ), ProfileListTile(
              icon: Assets.icons.language.path,
              title: "Language",
              onTap: () {
                Get.toNamed(AppRoutes.languageScreen);
              },
            ),ProfileListTile(
              icon: Assets.icons.announcement.path,
              title: "Announcement request",
              onTap: () {
                Get.toNamed(AppRoutes.announcementsScreen);
              },
            ),ProfileListTile(
              icon: Assets.icons.admin.path,
              title: "Admin Support",
              onTap: () {
                Get.toNamed(AppRoutes.supportScreen);
              },
            ),
            ProfileListTile(
              icon: Assets.icons.setting.path,
              title: "Settings",
              onTap: () {
              Get.toNamed(AppRoutes.settingScreen);
              },
            ),
        
            // Log Out Button
            ProfileListTile(
              icon: Assets.icons.logout.path,
              title: "log out",
              trailing: SizedBox.shrink(),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                    title: "Log Out",
                    description: 'Are you sure you want to sure Logout?',
                    onTapLeftButton: () {
                      Get.back();
                    },
                    onTapRightButton: AuthController.to.logout,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
