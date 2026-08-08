import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/core/widgets/profile_list_tile.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AdminAppBar(
        showLeading: false,
        actions: [

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            // List of Options
            ProfileListTile(
              icon: Assets.icons.dashboard.path,
              title: "Dashboard",
              onTap: () {
                Get.toNamed(AppRoutes.adminDashboardScreen);
              },
            ),
            ProfileListTile(
              icon: Assets.icons.allAdmin.path,
              title: "All admins",
              onTap: () {
                ProfileController.to.setRoleFilter('admin');
                  Get.toNamed(AppRoutes.allAdminScreen);
              },
            ),
            ProfileListTile(
              icon: Assets.icons.allUser.path,
              title: "All users",
              onTap: () {
                 Get.toNamed(AppRoutes.allUserScreen);
              },
            ),

            ProfileListTile(
              icon: Assets.icons.poll.path,
              title: "Poll",
              onTap: () {
                Get.toNamed(AppRoutes.pollScreen);
              },
            ),
            ProfileListTile(
              icon: Assets.icons.announcement.path,
              title: "Announcement",
              onTap: () {
                Get.toNamed(AppRoutes.announcementsScreen);
              },
            ),
            ProfileListTile(
              icon: Assets.icons.requested.path,
              title: "Requests",
              onTap: () {
                Get.toNamed(AppRoutes.requestedScreen);
              },
            ),
            ProfileListTile(
              icon: Assets.icons.banner.path,
              title: "Banner images",
              onTap: () {
                 Get.toNamed(AppRoutes.bannerScreen);
              },
            ),
        
            ProfileListTile(
              icon: Assets.icons.language.path,
              title: "Language",
              onTap: () {
                Get.toNamed(AppRoutes.languageScreen);
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
                    onTapRightButton: () async {
                      await AuthController.to.logout();
                      Get.offAllNamed(AppRoutes.loginScreen);
                    },
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
