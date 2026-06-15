import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AddContactScreen extends StatelessWidget {
  const AddContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: "Contact"),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),

            // ── Fields ─────────────────────────────────────────────────────
            CustomTextField(
              labelText: 'Phone no',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.numberController,
              keyboardType: TextInputType.phone,
              hintText: "Write here...",
            ),

            CustomTextField(
              labelText: 'Linkedin link',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.linkedinController,
              hintText: "Write here...",
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.r),
        child: Obx(() {
          return CustomButton(
            label: "Save",
            isLoading: controller.updateLoadingState.isLoading,
            onPressed: () {
              controller.updateUserProfile();
            },
          );
        }),
      ),
    );
  }
}
