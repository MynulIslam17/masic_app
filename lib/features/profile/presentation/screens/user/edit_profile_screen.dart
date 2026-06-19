import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/menu_show_helper.dart';
import 'package:masic_generation/core/helpers/photo_picker_helper.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: "Edit Profile"),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(
                () {
              return CustomButton(
                label: "Update Profile",
                isLoading: controller.updateLoadingState.isLoading,
                onPressed: controller.updateUserProfile,
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),

            // ── Avatar Picker ──────────────────────────────────────────────
            Obx(() {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  PhotoPickerHelper.showPhotoPicker(
                    context: context,
                    onImagePicked: (image) => controller.selectImage(image),
                  );
                },
                child: Stack(
                  children: [
                    CustomNetworkImage(
                      boxShape: BoxShape.circle,
                      height: 80.r,
                      width: 80.r,

                      fallbackAsset: Assets.images.profile.image(),
                      imageFile: controller.selectedImage,
                      imageUrl: controller.userData?.profileImage,
                    ),
                    Positioned(
                      bottom: 7.h,
                      left: 0,
                      right: 0,
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 24.h),

            // ── Fields ─────────────────────────────────────────────────────
            CustomTextField(
              prefixIcon: Assets.icons.person.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.nameController,
              hintText: "Full name",
            ),

            CustomTextField(
              prefixIcon: Assets.icons.email.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.emailController,
              hintText: "Email address",
              keyboardType: TextInputType.emailAddress,
            ),

            CustomTextField(
              prefixIcon: Assets.icons.number.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.phoneController,
              hintText: "Phone number",
              keyboardType: TextInputType.phone,
            ),

            CustomTextField(
              prefixIcon: Assets.icons.date.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.dateOfBirthController,
              hintText: "Date of birth",
              readOnly: true,
              suffixIcon: Icon(
                Icons.arrow_drop_down_outlined,
                color: AppColors.colorB0B0B0,
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  controller.setSelectedDate(picked);
                }
              },
            ),

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final value = MenuShowHelper.showCustomMenu(
                  context: context,
                  details: details,
                  options: ["Male", "Female"],
                );
                value.then((value) {
                  if (value != null) controller.genderController.text = value;
                });
              },
              child: CustomTextField(
                readOnly: true,
                suffixIcon: Icon(
                  Icons.arrow_drop_down_outlined,
                  color: AppColors.colorB0B0B0,
                ),
                prefixIcon: Assets.icons.gender.svg(),
                showShadow: false,
                borderColor: AppColors.colorE6E6E6,
                filColor: AppColors.bgColor,
                controller: controller.genderController,
                hintText: "Gender",
              ),
            ),

            // FIX #4 (employment): null-safe menu result
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final value = MenuShowHelper.showCustomMenu(
                  context: context,
                  details: details,
                  options: ["employed", "unemployed"],
                );
                value.then((value) {
                  if (value != null) {
                    controller.employmentController.text = value;
                  }
                });
              },
              child: CustomTextField(
                readOnly: true,
                suffixIcon: Icon(
                  Icons.arrow_drop_down_outlined,
                  color: AppColors.colorB0B0B0,
                ),
                prefixIcon: Assets.icons.employment.svg(),
                showShadow: false,
                borderColor: AppColors.colorE6E6E6,
                filColor: AppColors.bgColor,
                controller: controller.employmentController,
                hintText: "Employment status",
              ),
            ),

            // FIX #4 (education): null-safe menu result
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final value = MenuShowHelper.showCustomMenu(
                  context: context,
                  details: details,
                  options: [
                    "High School",
                    "Bachelor's Degree",
                    "Master's Degree",
                    "PhD",
                  ],
                );
                value.then((value) {
                  if (value != null) {
                    controller.educationController.text = value;
                  }
                });
              },
              child: CustomTextField(
                readOnly: true,
                suffixIcon: Icon(
                  Icons.arrow_drop_down_outlined,
                  color: AppColors.colorB0B0B0,
                ),
                prefixIcon: Assets.icons.education.svg(),
                showShadow: false,
                borderColor: AppColors.colorE6E6E6,
                filColor: AppColors.bgColor,
                controller: controller.educationController,
                hintText: "Education",
              ),
            ),

            CustomTextField(
              prefixIcon: Assets.icons.university.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.universityController,
              hintText: "University name",
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}