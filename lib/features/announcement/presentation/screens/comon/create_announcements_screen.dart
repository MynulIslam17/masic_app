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
              Obx(() {
                final images = controller.selectedImages;
                if (images.isEmpty) {
                  return CustomButton(
                    prefixIcon: Icons.cloud_upload_outlined,
                    bordersColor: AppColors.colorE6E6E6,
                    backgroundColor: AppColors.bgColor,
                    foregroundColor: AppColors.colorB0B0B0,
                    fontSize: 14.sp,
                    height: 58.h,
                    fontWeight: FontWeight.w400,
                    radius: 16.r,
                    onPressed: () {
                      PhotoPickerHelper.showMultiPhotoPicker(
                        context: context,
                        maxImages: 10,
                        onImagesPicked: (files) => controller.addImages(files),
                        maxWidth: 1920,
                        maxHeight: 1080,
                        imageQuality: 85,
                      );
                    },
                    label: 'Upload banner images (up to 10)',
                  );
                }

                return CustomContainer(
                  paddingAll: 12.r,
                  color: AppColors.bgColor,
                  bordersColor: AppColors.colorE6E6E6,
                  radiusAll: 16.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Banner Images (${images.length}/10)',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                          if (images.length < 10)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                PhotoPickerHelper.showMultiPhotoPicker(
                                  context: context,
                                  maxImages: 10 - images.length,
                                  onImagesPicked: (files) =>
                                      controller.addImages(files),
                                  maxWidth: 1920,
                                  maxHeight: 1080,
                                  imageQuality: 85,
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 16.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  CustomText(
                                    text: 'Add more',
                                    fontSize: 11.sp,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 80.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              images.length + (images.length < 10 ? 1 : 0),
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            if (index == images.length) {
                              return GestureDetector(
                                onTap: () {
                                  PhotoPickerHelper.showMultiPhotoPicker(
                                    context: context,
                                    maxImages: 10 - images.length,
                                    onImagesPicked: (files) =>
                                        controller.addImages(files),
                                    maxWidth: 1920,
                                    maxHeight: 1080,
                                    imageQuality: 85,
                                  );
                                },
                                child: Container(
                                  width: 80.h,
                                  height: 80.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        size: 24.sp,
                                        color: AppColors.primaryColor,
                                      ),
                                      CustomText(
                                        text: 'Add',
                                        fontSize: 10.sp,
                                        color: AppColors.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final file = images[index];
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.file(
                                    file,
                                    width: 80.h,
                                    height: 80.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4.r,
                                  right: 4.r,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        controller.removeImage(index),
                                    child: Container(
                                      padding: EdgeInsets.all(3.r),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 12.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),

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
