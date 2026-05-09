import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = ProfileController.to.isUserSelected(user.sId ?? '');

      return ListTile(
        selected: isSelected,
        selectedTileColor: AppColors.primaryColor.withValues(alpha: 0.1),
        leading: CustomNetworkImage(
          height: 48.r,
          width: 48.r,
          boxShape: BoxShape.circle,
          imageUrl: user.profileImage,
        ),
        title: CustomText(
          textAlign: TextAlign.start,
          text: user.name ?? '',
          fontSize: 16.sp,
        ),
        subtitle: CustomText(
          textAlign: TextAlign.start,
          text: 'Mother tree: ${user.motherTree ?? ''}',
          fontSize: 10.sp,
        ),
        trailing: CustomButton(
          width: 69.w,
          height: 30.h,
          backgroundColor: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : AppColors.primaryColor,
          foregroundColor: !isSelected ? Colors.white : AppColors.primaryColor,
          fontSize: 10.sp,
          label: isSelected ? 'Selected' : 'Select',
          onPressed: () =>
              ProfileController.to.toggleUserSelection(user.sId ?? ''),
        ),
        onTap: () => ProfileController.to.toggleUserSelection(user.sId ?? ''),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.colorE6E6E6),
          borderRadius: BorderRadius.circular(100.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 0),
      );
    });
  }
}
