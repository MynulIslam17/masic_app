import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter_task/features/privacy/presentation/controllers/privacy_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_task/core/widgets/widgets.dart';

class PrivacyPolicyAllScreen extends StatefulWidget {
  const PrivacyPolicyAllScreen({super.key});

  @override
  State<PrivacyPolicyAllScreen> createState() => _PrivacyPolicyAllScreenState();
}

class _PrivacyPolicyAllScreenState extends State<PrivacyPolicyAllScreen> {
  late final String title;
  late final String key;
  final controller = PrivacyController.to;
  final RxBool _isEditing = false.obs;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    title = args?['title'] ?? 'Terms and Conditions';
    key = args?['key'] ?? 'terms';
    controller.setActiveKey(key);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthController.to.isAdmin();

    return Scaffold(
      backgroundColor: const Color(0xffF6F5F1),
      appBar: CustomAppBar(title: title),
      body: Obx(() {
        switch (controller.loadingState) {
          case LoadingState.initial:
          case LoadingState.loading:
            return const Center(child: CustomLoader());

          case LoadingState.offline:
          case LoadingState.error:
            return EmptyDataWidget(
              message: 'Failed to load data. Please try again.',
              onRefresh: () async => await controller.refresh(),
            );

          case LoadingState.loaded:
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Content ──────────────────────────────────────────────
                  if(_isEditing.value == false)
                  CustomText(text: controller.description),

                  // ── TextField (editing mode only) ─────────────────────────
                  if (isAdmin)
                    Obx(
                          () => _isEditing.value
                          ? CustomTextField(
                            showShadow: false,
                            controller: controller.desController,
                            minLines: 20,
                            maxLines: 20,
                            hintText: 'Enter content...',
                          )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            );
        }
      }),

      // ── Bottom nav buttons (admin only) ───────────────────────────────────
      bottomNavigationBar: isAdmin
          ? Obx(
            () => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          child: _isEditing.value
              ? Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _isEditing.value = false;
                    controller.desController.clear();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const CustomText(text: 'Cancel'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(
                      () => CustomButton(
                    isLoading:
                    controller.updateLoadingState.isLoading,
                    onPressed: () async {
                      await controller.updatePrivacy(key);
                      _isEditing.value = false;
                    },
                    label: 'Save',
                  ),
                ),
              ),
            ],
          )
              : CustomButton(
            onPressed: () {
              controller.desController.text =
                  controller.description;
              _isEditing.value = true;
            },
            label: 'Update',
          ),
        ),
      )
          : null,
    );
  }
}