import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';


class JobSpecificationScreen extends StatelessWidget {
  const JobSpecificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requestType = Get.arguments as String?;
    final controller = RequestController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: "Job specification"),
      bottomNavigationBar: Padding(
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),


            // ── Fields ─────────────────────────────────────────────────────
            Form(
              key: controller.formKey,
              child: CustomTextField(
                labelText: 'Add your Job specification.',
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
