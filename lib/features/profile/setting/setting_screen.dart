import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/core/widgets/profile_list_tile.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: Column(
        children: [
          SizedBox(height: 20.h),

          if (AuthController.to.isAdmin())
            ProfileListTile(
              icon: Assets.icons.profile.path,
              title: "Profile Information",
              onTap: () {
                Get.toNamed(AppRoutes.profileInformationScreen);
              },
            )
          else
            ProfileListTile(
              icon: Assets.icons.password.path,
              title: "Change Password",
              onTap: () {
                Get.toNamed(AppRoutes.settingChangePassword);
              },
            ),

          // Terms & Condition
          ProfileListTile(
            icon: Assets.icons.terms.path,
            title: "Terms & Condition",
            onTap: () {
              Get.toNamed(AppRoutes.privacyPolicyAllScreen,
                arguments: {'title': 'Terms & Condition', 'key': 'terms'},
              );
            },
          ),

          // Privacy Policy
          ProfileListTile(
            icon: Assets.icons.policy.path,
            title: "Privacy Policy",
            onTap: () {
              Get.toNamed(AppRoutes.privacyPolicyAllScreen,
                arguments: {'title': 'Privacy Policy', 'key': 'privacy'},
              );
            },
          ),

          // About Us
          // ProfileListTile(
          //   icon: Assets.icons.about.path,
          //   title: "About Us",
          //   onTap: () {
          //     Get.toNamed(AppRoutes.privacyPolicyAllScreen,
          //       arguments: {'title': 'About Us', 'key': 'about'},
          //     );
          //   },
          // ),

          Spacer(),
          CustomButton(
            bordersColor: AppColors.errorColor,
            prefixIcon: Icons.delete_forever_outlined,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.errorColor,
            label: 'Delete Account',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Obx(
                  () => CustomDialog(
                    title: "Delete Account",
                    rightButtonLabel: 'Yes, Delete',
                    rightButtonBgColor: AppColors.errorColor,
                    isLoading: ProfileController.to.deleteAccountState.isLoading,
                    onTapLeftButton: () {
                      Get.back();
                    },
                    onTapRightButton: () {
                      ProfileController.to.deleteAccount();
                    },
                    description: 'Are you sure want to delete your Account? This action cannot be undone.',
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
