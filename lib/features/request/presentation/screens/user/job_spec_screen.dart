import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';

class JobSpecScreen extends StatelessWidget {
  const JobSpecScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RequestController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Job Specification'),
      body: Column(
        children: [
          Form(
            key: controller.createFormKey,
            child: CustomTextField(
              hintText: 'Write details here . . .',
              showShadow: false,
              maxLines: 5,
              minLines: 5,
              controller: controller.jobSpecTEController,
            ),
          ),

          SizedBox(height: 44.h),
          Obx(() {
              return CustomButton(
                onPressed: () => controller.createRequest(),
                label: 'Submit',
                isLoading: controller.createState.isLoading,
              );
            }
          ),
        ],
      ),
    );
  }
}
