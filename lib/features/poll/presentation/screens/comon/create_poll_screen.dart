import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/poll/presentation/controllers/poll_controller.dart';
import 'package:get/get.dart';

class CreatePollScreen extends StatelessWidget {
  const CreatePollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String answerType = Get.arguments as String;
    final controller = PollController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Create poll'),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              CustomTextField(
                borderColor: AppColors.colorE6E6E6,
                showShadow: false,
                filColor: AppColors.bgColor,
                controller: controller.titleTEController,
                hintText: 'Title here',
              ),
              SizedBox(height: 16.h),

              CustomTextField(
                filColor: AppColors.bgColor,
                maxLines: 2,
                minLines: 2,
                borderColor: AppColors.colorE6E6E6,
                showShadow: false,
                controller: controller.decTEController,
                hintText: 'short tagline',
              ),
              if (answerType == "selector") ...[
                CustomText(text: 'Answer type', top: 10.h, bottom: 8.h),

                Obx(() => Column(
                  children: [
                    ...List.generate(controller.optionControllers.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CustomTextField(
                                borderColor: AppColors.colorE6E6E6,
                                showShadow: false,
                                filColor: AppColors.bgColor,
                                hintText: 'Option ${index + 1}',
                                controller: controller.optionControllers[index],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            CustomContainer(
                              onTap: () => controller.removeOptionField(index),
                              color: AppColors.colorE6E6E6,
                              paddingAll: 14.r,
                              radiusAll: 16.r,
                              child: Icon(Icons.remove, color: AppColors.grey400, size: 20.r),
                            ),
                          ],
                        ),
                      );
                    }),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            validator: (_) => null,
                            borderColor: AppColors.colorE6E6E6,
                            showShadow: false,
                            readOnly: true,
                            onTap: () => controller.addOptionField(),
                            filColor: AppColors.bgColor,
                            hintText: 'Write an answer here',
                            controller: TextEditingController(),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        CustomContainer(
                          onTap: () => controller.addOptionField(),
                          color: AppColors.colorE6E6E6,
                          paddingAll: 14.r,
                          radiusAll: 16.r,
                          child: Icon(Icons.add, color: AppColors.grey400, size: 20.r),
                        ),
                      ],
                    ),
                  ],
                )),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(
             () {
              return CustomButton(
                isLoading: controller.createLoadingState.isLoading,
                  onPressed: () => controller.createPoll(answerType), label: 'Submit');
            }
          ),
        ),
      ),
    );
  }
}
