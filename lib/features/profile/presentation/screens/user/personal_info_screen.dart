import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/features/profile/presentation/widgets/Item_card.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? requestType = Get.arguments as String?;
    final controller = ProfileController.to;
    return CustomScaffold(
      paddingSide: 24.w,
      appBar: CustomAppBar(title: 'Personal information'),
      body: SingleChildScrollView(
        child: Obx(() {
          final user = controller.userData;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Short Bio ──────────────────────────────────────────────────
              CustomText(text: 'Short Bio', bottom: 10.h, top: 10.h),
              if (user?.bio != null && user!.bio!.isNotEmpty)
                ItemCard(
                  subtitle: user.bio!,
                  onUpdate: () => Get.toNamed(AppRoutes.addBioScreen),
                )
              else
                _addOutlineButton(
                  label: 'Add bio',
                  onPressed: () => Get.toNamed(AppRoutes.addBioScreen),
                ),

              if(requestType != null)...[
                CustomText(text: 'Job specification', bottom: 10.h, top: 10.h),
                if (RequestController.to.jobSpecTEController.text.isNotEmpty)
                  ItemCard(
                    subtitle: RequestController.to.jobSpecTEController.text,
                    onUpdate: () => Get.toNamed(AppRoutes.jobSpecificationScreen),
                  )
                else
                  _addOutlineButton(
                    label: 'Job specification',
                    onPressed: () => Get.toNamed(AppRoutes.jobSpecificationScreen),
                  ),
              ],


              // ── Contact Information ────────────────────────────────────────
              CustomText(text: 'Contact information', bottom: 10.h, top: 10.h),
              if (user?.contact != null)
                ItemCard(
                  title: user?.contact?.phone ?? '',
                  subtitle: user?.contact?.linkedin ?? '',
                  onUpdate: () => Get.toNamed(AppRoutes.addContactScreen),
                )
              else
                _addOutlineButton(
                  label: 'Add contact information',
                  onPressed: () => Get.toNamed(AppRoutes.addContactScreen),
                ),

              // ── Education ──────────────────────────────────────────────────
              CustomText(text: 'Education', bottom: 10.h, top: 10.h),
              if (user?.educationHistory != null &&
                  user!.educationHistory!.isNotEmpty)
                ...user.educationHistory!.asMap().entries.map(
                  (e) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: ItemCard(
                      title: e.value.degree ?? '',
                      subtitle: e.value.school ?? '',
                      onUpdate: () {
                        controller.prepareEducationForEdit(e.value, e.key);
                        Get.toNamed(
                          AppRoutes.addEducationScreen,
                          arguments: e.value,
                        );
                      },
                    ),
                  ),
                ),
              _addOutlineButton(
                label: 'Add education',
                onPressed: () {
                  controller.clearEducationControllers();
                  Get.toNamed(AppRoutes.addEducationScreen);
                },
              ),

              // ── Job Experience ─────────────────────────────────────────────
              CustomText(text: 'Job experience', bottom: 10.h, top: 10.h),
              if (user?.experience != null && user!.experience!.isNotEmpty)
                ...user.experience!.asMap().entries.map(
                  (e) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: ItemCard(
                      title: e.value.position ?? '',
                      subtitle: e.value.company ?? '',
                      onUpdate: () {
                        controller.prepareJobForEdit(e.value, e.key);
                        Get.toNamed(AppRoutes.addJobScreen, arguments: e.value);
                      },
                    ),
                  ),
                ),
              _addOutlineButton(
                label: 'Add job experience',
                onPressed: () {
                  controller.clearJobControllers();
                  Get.toNamed(AppRoutes.addJobScreen);
                },
              ),

              // ── CV ─────────────────────────────────────────────────────────
              CustomText(text: 'CV', bottom: 10.h, top: 10.h),
              if (user?.cvUrl != null)
                ItemCard(
                  subtitle: user!.cvUrl!.split('/').last,
                  onUpdate: () => Get.toNamed(AppRoutes.addCvScreen),
                )
              else
                _addOutlineButton(
                  label: 'Upload CV',
                  onPressed: () => Get.toNamed(AppRoutes.addCvScreen),
                ),

              SizedBox(height: 40.h),
            ],
          );
        }),
      ),

      bottomNavigationBar: requestType == null
          ? SizedBox.shrink()
          : Obx(() {
              final controller = RequestController.to;
              return Padding(
                padding: EdgeInsets.all(16.r),
                child: SafeArea(
                  child: CustomButton(
                    isLoading: controller.createState.isLoading,
                    label: 'Submit',
                    onPressed: () {
                      //Get.toNamed(AppRoutes.personalInfoScreen);
                      controller.createRequest(type: requestType);
                    },
                  ),
                ),
              );
            }),
    );
  }

  Widget _addOutlineButton({
    required String label,
    required VoidCallback onPressed,
  }) => CustomButton(
    onPressed: onPressed,
    label: label,
    bordersColor: AppColors.primaryColor,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.primaryColor,
    suffixIcon: Icon(
      Icons.add_rounded,
      color: AppColors.primaryColor,
      size: 20.r,
    ),
  );
}
