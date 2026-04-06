import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/helpers/menu_show_helper.dart';
import 'package:flutter_task/core/helpers/photo_picker_helper.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _employmentController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    _employmentController.dispose();
    _educationController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: "Edit Profile"),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.r),
        child: CustomButton(
          label: "Update Profile",
          onPressed: () {
            // TODO: call update API
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),

            // ── Avatar Picker ──────────────────────────────────────────────
            GestureDetector(
              onTap: () {
                PhotoPickerHelper.showPicker(
                  context: context,
                  onImagePicked: (image) {},
                );
              },
              child: Stack(
                children: [
                  CustomNetworkImage(height: 54.r, width: 54.r, imageUrl: ''),

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
            ),

            SizedBox(height: 24.h),

            // ── Fields ─────────────────────────────────────────────────────
            CustomTextField(
              prefixIcon: Assets.icons.person.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _nameController,
              hintText: "Full name",
            ),

            CustomTextField(
              prefixIcon: Assets.icons.email.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _emailController,
              hintText: "Email address",
              keyboardType: TextInputType.emailAddress,
            ),

            CustomTextField(
              prefixIcon: Assets.icons.number.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _phoneController,
              hintText: "Phone number",
              keyboardType: TextInputType.phone,
            ),

            CustomTextField(
              prefixIcon: Assets.icons.date.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _dateOfBirthController,
              hintText: "Date of birth",
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  _dateOfBirthController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                }
              },
            ),

            GestureDetector(
              onTapDown: (details) {
                final value = MenuShowHelper.showCustomMenu(
                  context: context,
                  details: details,
                  options: ["Male", "Female"],
                );
                value.then((value) {
                  _genderController.text = value!;
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
                controller: _genderController,
                hintText: "Gender",
              ),
            ),

            GestureDetector(
              onTapDown: (details) {
                final value = MenuShowHelper.showCustomMenu(
                  context: context,
                  details: details,
                  options: ["Employed", "Self-employed", "Unemployed"],
                );

                value.then((value) {
                  _employmentController.text = value!;
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
                controller: _employmentController,
                hintText: "Employment status",
              ),
            ),

            GestureDetector(
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
                  _educationController.text = value!;
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
                controller: _educationController,
                hintText: "Education",
              ),
            ),

            CustomTextField(
              prefixIcon: Assets.icons.university.svg(),
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _universityController,
              hintText: "University name",
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
