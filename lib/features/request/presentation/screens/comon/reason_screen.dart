import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';

class ReasonScreen extends StatelessWidget {
  const ReasonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requestId = Get.arguments as String;
    final controller = RequestController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: "Reason"),
      body: Column(
        children: [
          Form(
            key: controller.formKey,
            child: CustomTextField(
              hintText: 'Write details here . . .',
              showShadow: false,
              maxLines: 5,
              minLines: 5,
              controller: controller.declineReasonTEController,
            ),
          ),

          SizedBox(height: 44.h),
          Obx(() {
              return CustomButton(
                onPressed: () => controller.updateStatus(
                  requestId: requestId,
                  status: 'declined',
                  declineReason: controller.declineReasonTEController.text.trim(),
                ),
                label: 'Submit',
                isLoading: controller.updateState.isLoading,
              );
            }
          ),
        ],
      ),
    );
  }
}
