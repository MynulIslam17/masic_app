import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Profile Information'),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.r),
        child: SafeArea(
          child: CustomButton(
            label: 'Edit profile',
            onPressed: () {
             // Get.toNamed(AppRoutes.editProfileScreen);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            CustomNetworkImage(
              height: 54.r,
              width: 54.r,
              imageUrl: '' ?? '',
            ),
            SizedBox(height: 24.h),
            CustomContainer(
              paddingAll: 16.r,
              color: AppColors.bgColor,
              bordersColor: AppColors.borderColor,
              radiusAll: 12.r,
              child: Column(
                spacing: 16.h,
                children: [
                  _buildInfoRow(label: 'Name',              value: 'user?.fullName'          ?? 'N/A'),
                  _buildInfoRow(label: 'Email',             value: 'user?.email'             ?? 'N/A'),
                  _buildInfoRow(label: 'Phone no',          value: 'user?.phone'             ?? 'N/A'),
                  _buildInfoRow(label: 'Date of birth',     value: 'user?.dateOfBirth'       ?? 'N/A'),
                  _buildInfoRow(label: 'Gender',            value: 'user?.gender'            ?? 'N/A'),
                  _buildInfoRow(label: 'Employment status', value: 'user?.employmentStatus'  ?? 'N/A'),
                  _buildInfoRow(label: 'Education',         value: 'user?.education'         ?? 'N/A'),
                  _buildInfoRow(label: 'University name',   value: 'user?.universityName'    ?? 'N/A'),
                  // _buildInfoRow(label: 'Field of work',     value: 'user?.fieldOfWork'       ?? 'N/A'),
                  // _buildInfoRow(label: 'Spouse name',       value: 'user?.spouseName'        ?? 'N/A'),
                  // _buildInfoRow(label: 'Spouse number',     value: 'user?.spouseNumber'      ?? 'N/A'),
                  // _buildInfoRow(label: 'Linkedin link',     value: 'user?.linkedinLink'      ?? 'N/A'),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // ── Row Helpers ────────────────────────────────────────────────────────────
  Widget _buildInfoRow({
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100.w,
          child: CustomText(
            text: label,
            fontSize: 12.sp,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(width: 24.w),
        CustomText(text: ':', fontSize: 12.sp),
        SizedBox(width: 32.w),
        Expanded(
          child:
          valueWidget ??
              CustomText(
                enableAutoTranslate: false,
                text: value ?? '',
                fontSize: 12.sp,
                textAlign: TextAlign.start,
              ),
        ),
      ],
    );
  }
}