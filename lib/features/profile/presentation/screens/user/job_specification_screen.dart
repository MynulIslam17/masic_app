import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';


class JobSpecificationScreen extends StatelessWidget {
  const JobSpecificationScreen({super.key});

  String get _appBarTitle {
    switch ((Get.arguments as String?)?.toLowerCase()) {
      case 'volunteering':
        return 'Volunteering';
      case 'other':
        return 'Other';
      case 'job':
      default:
        return 'Job';
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestType = Get.arguments as String?;
    final controller = RequestController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: '$_appBarTitle Specification'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child:
               CustomButton(
                label: "Save",
                onPressed: () {
                  if (!controller.formKey.currentState!.validate()) return;
                  Get.toNamed(AppRoutes.personalInfoScreen, arguments: requestType);
                },
              ),
        
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),


            // ── Fields ─────────────────────────────────────────────────────
            Form(
              key: controller.formKey,
              child: CustomTextField(
                labelText: 'Add your $_appBarTitle specification.',
                showShadow: false,
                borderColor: AppColors.colorE6E6E6,
                filColor: AppColors.bgColor,
                controller: controller.jobSpecTEController,
                maxLines: 20,
                minLines: 20,
                hintText: "Write here...",
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
