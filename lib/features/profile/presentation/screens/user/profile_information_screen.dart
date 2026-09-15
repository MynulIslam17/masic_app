import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:masic_generation/features/profile/presentation/widgets/info_row.dart';
import 'package:get/get.dart';

class ProfileInformationScreen extends StatelessWidget {
  const ProfileInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Profile Information'),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.r),
        child: SafeArea(
          child: CustomButton(
            label: 'Edit profile',
            onPressed: () {
              Get.toNamed(AppRoutes.editProfileScreen);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Obx(() {
          TranslationController.to.currentLanguage.value;
          final user = controller.userData;
          final hasName = (user?.name?.isNotEmpty ?? false) ||
              (user?.arabicName?.isNotEmpty ?? false);
          return Column(
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
                    if (hasName)
                      InfoRow.personName(
                        label: 'Name',
                        name: user?.name,
                        arabicName: user?.arabicName,
                      ),
                    if (user?.email != null && user!.email!.isNotEmpty)
                      InfoRow(label: 'Email', value: user!.email),
                    if (user?.phone != null && user!.phone!.isNotEmpty)
                      InfoRow(label: 'Phone no', value: user!.phone),
                    if (user?.dateOfBirth != null &&
                        user!.dateOfBirth!.isNotEmpty)
                      InfoRow(
                        label: 'Date of birth',
                        value: TimeFormatHelper.formatDateTime(
                          user!.dateOfBirth,
                        ),
                      ),
                    if (user?.gender != null && user!.gender!.isNotEmpty)
                      InfoRow(label: 'Gender', value: user!.gender, translateValue: true),
                    if (user?.employmentStatus != null &&
                        user!.employmentStatus!.isNotEmpty)
                      InfoRow(
                        label: 'Employment status',
                        value: user!.employmentStatus,
                        translateValue: true,
                      ),
                    if (user?.education != null &&
                        user!.education!.isNotEmpty)
                      InfoRow(
                        label: 'Education',
                        value: user!.education,
                        translateValue: true,
                      ),
                    if (user?.universityName != null &&
                        user!.universityName!.isNotEmpty)
                      InfoRow(
                        label: 'University name',
                        value: user!.universityName,
                      ),
                    if (user?.fieldOfWork != null &&
                        user!.fieldOfWork!.isNotEmpty)
                      InfoRow(
                        label: 'Field of work',
                        value: user!.fieldOfWork,
                        translateValue: true,
                      ),
                    if (user?.spouseName != null &&
                        user!.spouseName!.isNotEmpty)
                      InfoRow(
                        label: 'Spouse name',
                        value: user!.spouseName,
                      ),
                    if (user?.spousePhone != null &&
                        user!.spousePhone!.isNotEmpty)
                      InfoRow(
                        label: 'Spouse number',
                        value: user!.spousePhone,
                      ),
                    if (user?.contact?.linkedin != null &&
                        user!.contact!.linkedin!.isNotEmpty)
                      InfoRow(
                        label: 'Linkedin link',
                        value: user!.contact!.linkedin,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
            ],
          );
        }),
      ),
    );
  }
}
