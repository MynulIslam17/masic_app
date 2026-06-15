import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AddJobScreen extends StatelessWidget {
  const AddJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: "Job"),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.r),
        child: Obx(
          () => CustomButton(
            label: "Save",
            isLoading: controller.updateLoadingState.isLoading,
            onPressed: () => controller.updateUserProfile(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),

            CustomTextField(
              labelText: 'Company name',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.jobnameController,
              hintText: "Write here...",
            ),

            CustomTextField(
              labelText: 'Position title',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.positionController,
              hintText: "Write here...",
            ),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'From',
                    showShadow: false,
                    borderColor: AppColors.colorE6E6E6,
                    filColor: AppColors.bgColor,
                    controller: controller.fromJobDateController,
                    hintText: "00/00/0000",
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        controller.fromJobDateController.text =
                            TimeFormatHelper.formatDate(picked);
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.r),
                Obx(
                  () => Expanded(
                    child: CustomTextField(
                      labelText: 'To',
                      labelColor: controller.isJobOngoings
                          ? AppColors.colorE6E6E6
                          : null,
                      showShadow: false,
                      borderColor: AppColors.colorE6E6E6,
                      filColor: AppColors.bgColor,
                      controller: controller.toJobDateController,
                      hintText: "00/00/0000",
                      readOnly: true,
                      onTap: () async {
                        if (controller.isJobOngoings) {
                          controller.toJobDateController.text = '';
                          return;
                        }
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          controller.toJobDateController.text =
                              TimeFormatHelper.formatDate(picked);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Obx(
                  () => Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      activeColor: AppColors.primaryColor,
                      checkColor: AppColors.white,
                      value: controller.isJobOngoings,
                      onChanged: controller.onChangedJob,
                    ),
                  ),
                ),
                CustomText(
                  textAlign: TextAlign.start,
                  text: 'Current job',
                  fontSize: 13.sp,
                ),
              ],
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
