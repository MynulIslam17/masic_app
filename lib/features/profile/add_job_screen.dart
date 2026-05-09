import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/time_format.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';


class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {

  final controller = ProfileController.to;


  @override
  void initState() {
    final Experience? job = Get.arguments;
    if (job != null) {
      controller.prepareJobForEdit(job);
    } else {
      controller.clearJobControllers();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: "Job"),
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
          }
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),

            // ── Fields ─────────────────────────────────────────────────────
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
                   () {
                    return Expanded(
                      child:
                           CustomTextField(
                            labelText: 'To',
                            labelColor: controller.isJobOngoings ? AppColors.colorE6E6E6 : null,
                            showShadow: false,
                            borderColor: AppColors.colorE6E6E6,
                            filColor: AppColors.bgColor,
                            controller: controller.toJobDateController,
                            hintText: "00/00/0000",
                            readOnly: true,
                            onTap: () async {
                              if (controller.isJobOngoings){
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
                    );
                  }
                ),
                ]
            ),
           // SizedBox(height: 12.h),
            Row(
              children: [
                Obx(() {
                    return Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        activeColor: AppColors.primaryColor,
                        checkColor: AppColors.white,
                        value: controller.isJobOngoings,
                        onChanged: (value) => controller.onChangedJob(value),
                      ),
                    );
                  }
                ),
                CustomText(
                  textAlign: TextAlign.start,
                    text: 'Current job', fontSize: 13.sp),
              ]
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
