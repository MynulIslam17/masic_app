import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/fonts.gen.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/privacy/presentation/controllers/privacy_controller.dart';

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

    return CustomScaffold(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HTML content (view mode) ───────────────────────────────
                  Obx(
                    () => _isEditing.value
                        ? const SizedBox.shrink()
                        : _PrivacyHtmlContent(
                            html: controller.description,
                          ),
                  ),

                  // ── HTML editor (admin editing mode) ───────────────────────
                  if (isAdmin)
                    Obx(
                      () => _isEditing.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Edit HTML content',
                                  textAlign: TextAlign.start,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  enableAutoTranslate: false,
                                ),
                                SizedBox(height: 8.h),
                                CustomTextField(
                                  showShadow: false,
                                  controller: controller.desController,
                                  minLines: 20,
                                  maxLines: 20,
                                  hintText: '<p>Enter HTML content...</p>',
                                ),
                              ],
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
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, MediaQuery.of(context).padding.bottom + 10.h),
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
              controller.desController.text = controller.description;
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

class _PrivacyHtmlContent extends StatelessWidget {
  const _PrivacyHtmlContent({required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    if (html.trim().isEmpty) {
      return const EmptyDataWidget(message: 'No content available.');
    }

    return HtmlWidget(
      html,
      textStyle: TextStyle(
        fontSize: 14.sp,
        fontFamily: FontFamily.poppins,
        color: AppColors.darkColor,
        height: 1.6,
      ),
    );
  }
}