import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/menu_show_helper.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomContainer(
      paddingVertical: 10.h,
      paddingHorizontal: 10.w,
      radiusAll: 24.r,
      bordersColor: AppColors.borderColor,
      child: Column(
        children: [
          Row(
            children: [
              CustomNetworkImage(
                height: 40.h,
                width: 40.w,
                boxShape: BoxShape.circle,
                imageUrl: user.profileImage,
              ),
              Expanded(
                child: CustomText(
                  textAlign: TextAlign.start,
                  left: 10.w,
                  fontSize: 16.sp,
                  text: user.name ?? '',
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) async {
                  final selectedMenu = await MenuShowHelper.showCustomMenu(
                    context: context,
                    details: details,
                    options: [
                      'View Details',
                      'Block',
                      if (ProfileController.to.userData?.role == 'superAdmin')...[
                        if(user.role == 'admin')
                        'Decline admin access',
                        if(user.role == 'user')
                        'Give admin access',
                      ],
                    ],
                  );

                  if (selectedMenu == null) return;

                  if (selectedMenu == 'View Details') {
                    Get.toNamed(
                      AppRoutes.profileDetailsScreen,
                      arguments: user,
                    );
                  } else if (selectedMenu == 'Decline admin access') {
                    showDialog(
                      context: context,
                      builder: (context) => Obx(
                        () => CustomDialog(
                          title: 'Decline admin access?',
                          leftButtonLabel: 'Cancel',
                          rightButtonLabel: 'Decline',
                          isLoading: controller.updateRoleState.isLoading,
                          onTapLeftButton: () => Get.back(),
                          onTapRightButton: () =>
                              controller.updateRole(user.sId!, 'user'),
                          description:
                              'Are you sure you want to decline this admin access request?',
                        ),
                      ),
                    );
                  } else if (selectedMenu == 'Give admin access') {
                    showDialog(
                      context: context,
                      builder: (context) => Obx(
                        () => CustomDialog(
                          title: 'Give admin access?',
                          leftButtonLabel: 'Cancel',
                          rightButtonLabel: 'Give',
                          isLoading: controller.updateRoleState.isLoading,
                          onTapLeftButton: () => Get.back(),
                          onTapRightButton: () =>
                              controller.updateRole(user.sId!, 'admin'),
                          description:
                              'Are you sure you want to give this admin access request?',
                        ),
                      ),
                    );
                  }
                },
                child: Icon(Icons.more_vert, size: 20.h),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildMenu(
            icon: Assets.icons.colorEmail.svg(),
            label: user.email ?? 'N/A',
          ),
          _buildMenu(
            icon: Assets.icons.work.svg(),
            label: user.employmentStatus ?? 'N/A',
          ),
          _buildMenu(
            icon: Assets.icons.phone.svg(),
            label: user.phone ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildMenu({required Widget icon, required String label}) {
    return CustomContainer(
      marginBottom: 10.h,
      paddingVertical: 10.h,
      paddingHorizontal: 10.w,
      radiusAll: 24.r,
      bordersColor: AppColors.borderColor,
      child: Row(
        children: [
          icon,
          Expanded(
            child: CustomText(
              textAlign: TextAlign.start,
              left: 10.w,
              fontSize: 10.sp,
              text: label,
            ),
          ),
        ],
      ),
    );
  }
}
