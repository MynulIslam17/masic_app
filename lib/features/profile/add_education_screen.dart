import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/time_format.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AddEducationScreen extends StatefulWidget {
  const AddEducationScreen({super.key});

  @override
  State<AddEducationScreen> createState() => _AddEducationScreenState();
}

class _AddEducationScreenState extends State<AddEducationScreen> {
  final controller = ProfileController.to;

  @override
  void initState() {
    super.initState();
    final EducationHistory? education = Get.arguments;

    if (education != null) {
      controller.prepareEducationForEdit(education);
    } else {
      controller.clearEducationControllers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: "Education"),
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),

            // ── Fields ─────────────────────────────────────────────────────
            CustomTextField(
              labelText: 'School or university name',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.schoolController,
              hintText: "Write here...",
            ),

            CustomTextField(
              labelText: 'Degree type',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.degreeController,
              hintText: "Write here...",
            ),

            CustomTextField(
              labelText: 'Major',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: controller.majorController,
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
                    controller: controller.fromDateController,
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
                        controller.fromDateController.text =
                            TimeFormatHelper.formatDate(picked);
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.r),
                Obx(() {
                  return Expanded(
                    child: CustomTextField(
                      labelText: 'To',
                      labelColor: controller.isEducationOngoings
                          ? AppColors.colorE6E6E6
                          : null,
                      showShadow: false,
                      borderColor: AppColors.colorE6E6E6,
                      filColor: AppColors.bgColor,
                      controller: controller.toDateController,
                      hintText: "00/00/0000",
                      readOnly: true,
                      onTap: () async {
                        if (controller.isEducationOngoings) {
                          controller.toDateController.text = '';
                          return;
                        }
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          controller.toDateController.text =
                              TimeFormatHelper.formatDate(picked);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),

            Row(
              children: [
                Obx(() {
                  return Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      activeColor: AppColors.primaryColor,
                      checkColor: AppColors.white,
                      value: controller.isEducationOngoings,
                      onChanged: (value) =>
                          controller.onChangedEducation(value),
                    ),
                  );
                }),
                CustomText(
                  textAlign: TextAlign.start,
                  text: 'Current Education',
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
