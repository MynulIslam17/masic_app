import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/photo_picker_helper.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AddCvScreen extends StatelessWidget {
  const AddCvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: "Upload documents"),
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

            Obx(() {
              final existingCvUrl = controller.userData?.cvUrl;
              final newCvFile = controller.selectedCV;

              final hasNewFile = newCvFile != null;
              final hasExistingCv = existingCvUrl != null && existingCvUrl.isNotEmpty;
              final hasAnyCv = hasNewFile || hasExistingCv;

              final cvFileName = hasNewFile
                  ? (newCvFile.path.split('/').last)
                  : hasExistingCv
                  ? existingCvUrl.split('/').last
                  : null;

              return CustomContainer(
                onTap: () {
                  PhotoPickerHelper.showFilePicker(
                    context: context,
                    onFilePicked: (file) => controller.onFilePicked(file),
                  );
                },
                radiusAll: 12.r,
                bordersColor: hasAnyCv
                    ? AppColors.primaryColor
                    : AppColors.colorE8E8E8,
                paddingAll: 44.r,
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(controller.userData?.cvUrl != null)
                      IconButton(onPressed: (){
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context, builder: (context) {

                          return CustomContainer(
                            paddingAll: 16.r,
                            child: CustomNetworkImage(
                              borderRadius: 10.r,
                              imageUrl: controller.userData!.cvUrl!,
                              height: 500.h,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          );
                        });
                      }, icon: CustomText(text: 'Viewing existing CV', color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
                    if (hasAnyCv)
                      Icon(
                        Icons.file_copy,
                        size: 48.sp,
                        color: AppColors.primaryColor,
                      )
                    else
                      Assets.icons.uploadImage.svg(),

                    SizedBox(height: 16.h),

                    CustomText(
                      text: hasAnyCv ? cvFileName! : "Upload CV",
                      top: 0,
                    ),
                    if (hasAnyCv)
                      CustomText(
                        text: "Tap to change",
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        top: 4.h,
                      ),
                  ],
                ),
              );
            }),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }


}


