import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/core/widgets/localized_name_text.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:get/get.dart';

class AdminAppBar extends  StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({
    super.key, required this.actions,  this.showLeading = true,
  });

  final List<Widget> actions;
  final bool showLeading;


  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomAppBar(
      showLeading: showLeading,
      titleWidget: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(() {
            TranslationController.to.currentLanguage.value;
            final userData = controller.userData;
            final authUser = AuthController.to.cachedUser;
            final name = userData?.name ?? authUser?.name;
            final arabicName = userData?.arabicName ?? authUser?.arabicName;
            final hasName = (name?.trim().isNotEmpty ?? false) ||
                (arabicName?.trim().isNotEmpty ?? false);
            final roleLabel = UserModel.roleLabelOf(
              userData?.role ?? authUser?.role,
            );
            return Row(
              children: [
                CustomNetworkImage(
                  boxShape: BoxShape.circle,
                  height: 42.r,
                  width: 42.r,
                  imageUrl: userData?.profileImage,
                  fallbackAsset: Assets.images.profile.image(),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasName)
                        LocalizedNameText(
                          name: name,
                          arabicName: arabicName,
                          fontSize: 14.sp,
                          textAlign: TextAlign.start,
                        )
                      else if (roleLabel != null)
                        CustomText(
                          text: roleLabel,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.start,
                        ),
                      CustomText(
                        textAlign: TextAlign.start,
                        text: hasName && roleLabel != null
                            ? roleLabel
                            : 'Welcome to MASIC Generation',
                        fontSize: 10.sp,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),


      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
