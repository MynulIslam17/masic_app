import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/helpers/time_format.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/presentation/widgets/info_row.dart';
import 'package:get/get.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.arguments as UserModel?;
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Profile Details'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            CustomNetworkImage(
              boxShape: BoxShape.circle,
              height: 80.r,
              width: 80.r,
              fallbackAsset: Assets.images.profile.image(),
              imageUrl: user?.profileImage,
            ),
            SizedBox(height: 24.h),
            CustomContainer(
              paddingAll: 16.r,
              color: AppColors.bgColor,
              bordersColor: AppColors.borderColor,
              radiusAll: 12.r,
              child: Column(
                // spacing: 16.h,
                children: [
                  InfoRow(label: 'Name', value: user?.name ?? 'N/A'),
                  InfoRow(label: 'Email', value: user?.email ?? 'N/A'),
                  InfoRow(label: 'Phone no', value: user?.phone ?? 'N/A'),
                  InfoRow(
                    label: 'Date of birth',
                    value: TimeFormatHelper.formatDateTime(
                      user?.dateOfBirth ?? '',
                    ),
                  ),
                  InfoRow(label: 'Gender', value: user?.gender ?? 'N/A'),
                  InfoRow(
                    label: 'Employment status',
                    value: user?.employmentStatus ?? 'N/A',
                  ),
                  InfoRow(
                    label: 'Education',
                    value: user?.education ?? 'N/A',
                  ),
                  InfoRow(
                    label: 'University name',
                    value: user?.universityName ?? 'N/A',
                  ),
                  InfoRow(
                    label: 'Field of work',
                    value: user?.fieldOfWork ?? 'N/A',
                  ),
                  InfoRow(
                    label: 'Spouse name',
                    value: user?.spouseName ?? 'N/A',
                  ),
                  InfoRow(
                    label: 'Spouse number',
                    value: user?.spousePhone ?? 'N/A',
                  ),
                  InfoRow(
                    label: 'Linkedin link',
                    value: user?.linkedinLink ?? 'N/A',
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
