import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/photo_picker_helper.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:get/get.dart';

class CreateAnnouncementsScreen extends StatelessWidget {
  const CreateAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AnnouncementController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Request announcements'),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              SizedBox(height: 16.h),
              CustomTextField(
                borderColor: AppColors.colorE6E6E6,
                showShadow: false,
                filColor: AppColors.bgColor,
                controller: controller.titleTEController,
                hintText: 'Announcements title',
              ),

              SizedBox(height: 8.h),
              Obx(
                 () {
                  return CustomButton(
                    prefixIcon: controller.selectedImage == null ? Icons.cloud_upload_outlined : Icons.image,
                    bordersColor: AppColors.colorE6E6E6,
                    backgroundColor: AppColors.bgColor,
                    foregroundColor: controller.selectedImage == null ? AppColors.colorB0B0B0 : AppColors.primaryColor,
                    fontSize: 14.sp,
                    height: 58.h,
                    fontWeight: FontWeight.w400,
                    radius: 16.r,
                    onPressed: () {
                      PhotoPickerHelper.showPhotoPicker(
                        context: context,
                        onImagePicked: (file) => controller.selectImage(file),
                        maxWidth: 1920,
                        maxHeight: 1080,
                        imageQuality: 85,
                      );
                    },
                    label: controller.selectedImage == null ? 'Upload banner' : 'Change banner',
                  );
                }
              ),

              SizedBox(height: 16.h),

              CustomTextField(
                filColor: AppColors.bgColor,
                maxLines: 20,
                minLines: 20,
                borderColor: AppColors.colorE6E6E6,
                showShadow: false,
                controller: controller.decTEController,
                hintText: 'Write a description here . . .',
              ),
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
                  onPressed: controller.createAnnouncement, label: 'Submit');
            }
          ),
        ),
      ),
    );
  }
}
