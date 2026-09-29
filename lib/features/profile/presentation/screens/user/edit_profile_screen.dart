import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/menu_show_helper.dart';
import 'package:masic_generation/core/helpers/photo_picker_helper.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool get _isOnboarding => ProfileController.to.isOnboarding;

  @override
  void initState() {
    super.initState();
    if (_isOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ProfileController.to.prepareOnboardingProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomScaffold(
    appBar: CustomAppBar(
      title: _isOnboarding ? 'Complete Your Profile' : 'Edit Profile',
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Obx(
              () {
            return CustomButton(
              label: _isOnboarding ? 'Continue' : 'Update Profile',
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
          if (_isOnboarding) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomText(
                text:
                    'Please complete your profile before selecting your mother tree.',
                fontSize: 14.sp,
                textAlign: TextAlign.center,
                color: AppColors.colorB0B0B0,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          SizedBox(height: _isOnboarding ? 8.h : 24.h),

          // ── Avatar Picker ──────────────────────────────────────────────
          Obx(() {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                PhotoPickerHelper.showPhotoPicker(
                  context: context,
                  onImagePicked: (image) => controller.selectImage(image),
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
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
            readOnly: _isOnboarding,
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

          _dropdownField(
            options: const ['Male', 'Female'],
            controller: controller.genderController,
            hintText: 'Gender',
            prefixIcon: Assets.icons.gender.svg(),
          ),
          _dropdownField(
            options: const ['Employed', 'Unemployed', 'Student'],
            controller: controller.employmentController,
            hintText: 'Employment status',
            prefixIcon: Assets.icons.employment.svg(),
          ),
          _dropdownField(
            options: const [
              'High School',
              "Bachelor's Degree",
              "Master's Degree",
              'PhD',
            ],
            controller: controller.educationController,
            hintText: 'Education',
            prefixIcon: Assets.icons.education.svg(),
          ),

          CustomTextField(
            prefixIcon: Assets.icons.university.svg(),
            showShadow: false,
            borderColor: AppColors.colorE6E6E6,
            filColor: AppColors.bgColor,
            controller: controller.universityController,
            hintText: "University name",
          ),

          CustomTextField(
            prefixIcon: Assets.icons.work.svg(color: AppColors.colorB0B0B0),
            showShadow: false,
            borderColor: AppColors.colorE6E6E6,
            filColor: AppColors.bgColor,
            controller: controller.fieldOfWorkController,
            hintText: "Field of work",
          ),

          CustomTextField(
            prefixIcon: Assets.icons.person.svg(),
            showShadow: false,
            borderColor: AppColors.colorE6E6E6,
            filColor: AppColors.bgColor,
            controller: controller.spouseNameController,
            hintText: "Spouse name",
          ),

          CustomTextField(
            prefixIcon: Assets.icons.number.svg(),
            showShadow: false,
            borderColor: AppColors.colorE6E6E6,
            filColor: AppColors.bgColor,
            controller: controller.spousePhoneController,
            hintText: "Spouse phone number",
            keyboardType: TextInputType.phone,
          ),

          SizedBox(height: 32.h),
        ],
      ),
    ),
        );
  }

  Widget _dropdownField({
    required List<String> options,
    required TextEditingController controller,
    required String hintText,
    required Widget prefixIcon,
  }) {
    return Builder(
      builder: (fieldContext) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final value = await MenuShowHelper.showBelow(
              context: fieldContext,
              options: options,
            );
            if (value != null) controller.text = value;
          },
          child: AbsorbPointer(
            child: CustomTextField(
              readOnly: true,
              suffixIcon: Icon(
                Icons.arrow_drop_down_outlined,
                color: AppColors.colorB0B0B0,
              ),
              prefixIcon: prefixIcon,
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller,
              hintText: hintText,
            ),
          ),
        );
      },
    );
  }
}