import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/core/widgets/localized_name_text.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({
    super.key,
    required this.user,
    this.isMotherTree = false,
    this.isTree = false,
  });

  final UserModel user;
  final bool isMotherTree;
  final bool isTree;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      TranslationController.to.currentLanguage.value;
      final isBlock = user.isDeleted ?? false;
      final controller = ProfileController.to;
      final isSelected = isMotherTree
          ? controller.selectedUserId == (user.linkedMember ?? '')
          : isTree
          ? controller.selectedUserId == (user.sId ?? '')
          : controller.isUserSelected(user.sId ?? '');
      return ListTile(
        selected: isSelected,
        selectedTileColor: AppColors.primaryColor.withValues(alpha: 0.05),
        leading: CustomNetworkImage(
          height: 48.r,
          width: 48.r,
          boxShape: BoxShape.circle,
          imageUrl: user.profileImage,
        ),
        title: LocalizedNameText(
          name: user.name,
          arabicName: user.arabicName,
          textAlign: TextAlign.start,
          fontSize: 16.sp,
        ),
        subtitle: CustomText(
          textAlign: TextAlign.start,
          text: 'Mother tree: ${user.motherTree ?? ''}',
          fontSize: 10.sp,
        ),
        trailing: (user.treeJoinStatus == 'placed' && isTree)
            ? CustomButton(
                width: 69.w,
                height: 30.h,
                backgroundColor: AppColors.colorE8E8E8,
                foregroundColor: AppColors.appGreyColor,
                fontSize: 10.sp,
                label: 'Disable',
                onPressed: () {},
              )
            : (isBlock && AuthController.to.isAdmin())
            ? CustomButton(
                width: 69.w,
                height: 30.h,
                bordersColor: AppColors.primaryColor,
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
                fontSize: 10.sp,
                label: 'Unblock',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Obx(
                      () => CustomDialog(
                        title: 'Unblock user?',
                        leftButtonLabel: 'Cancel',
                        rightButtonLabel: 'Unblock',
                        isLoading: controller.blockUserState.isLoading,
                        onTapLeftButton: () => Get.back(),
                        onTapRightButton: () =>
                            controller.blockUser(user.sId!, type: 'unblock'),
                        description:
                            'Are you sure you want to unblock this user?',
                      ),
                    ),
                  );
                },
              )
            : CustomButton(
                width: 69.w,
                height: 30.h,
                bordersColor: AppColors.primaryColor,
                backgroundColor: isSelected
                    ? AppColors.primaryColor
                    : Colors.transparent,
                foregroundColor: !isSelected
                    ? AppColors.primaryColor
                    : AppColors.white,
                fontSize: 10.sp,
                label: isSelected ? 'Deselect' : 'Select',
          onPressed: () {
            if (isMotherTree || isTree) {
              final id = isTree ? user.sId ?? '' : user.linkedMember ?? '';
              debugPrint('Current selected: ${controller.selectedUserId}');
              debugPrint('This user id: $id');
              debugPrint('isSelected: $isSelected');
              if (isSelected) {
                controller.selectSingleUser('');
              } else {
                controller.selectSingleUser(id);
              }
            }
          },
              ),
        onTap: () {
          if (isBlock || user.treeJoinStatus == 'placed') return;
          if (isMotherTree || isTree) {
            final id = isTree ? user.sId ?? '' : user.linkedMember ?? '';
            if (isSelected) {
              controller.selectSingleUser('');
            } else {
              controller.selectSingleUser(id);
            }
          } else {
            controller.toggleUserSelection(user.sId ?? '');
          }
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.colorE6E6E6),
          borderRadius: BorderRadius.circular(100.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 0),
      );
    });
  }
}
