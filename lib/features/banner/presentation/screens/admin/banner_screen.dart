import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/photo_picker_helper.dart';
import 'package:flutter_task/core/helpers/time_format.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/announcement/presentation/widgets/announcement_simmer.dart';
import 'package:flutter_task/features/banner/presentation/controllers/banner_controller.dart';
import 'package:get/get.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BannerController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Banner'),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () {
                        return CustomText(
                          textAlign: TextAlign.start,
                          fontSize: 12.sp,
                          text: 'Total events : ${controller.banners.length}',
                        );
                      }
                    ),
                  ),
                  CustomButton(
                    height: 38.h,
                    elevation: true,
                    borderWidth: 3,
                    bordersColor: Color(0xffB0B0B0),
                    foregroundColor: AppColors.primaryColor,
                    backgroundColor: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    width: 120.w,
                    onPressed: () {
                      PhotoPickerHelper.showPhotoPicker(context: context, onImagePicked: (image) async => await controller.selectImage(image));
                    },
                    label: 'Upload',
                  ),
                ],
              ),

              /// ============ > Events List < ============
              SizedBox(height: 24.h),
              Obx(() {
                switch (controller.loadingState) {
                  case LoadingState.initial:
                  case LoadingState.loading:
                    return AnnouncementShimmer();

                  case LoadingState.offline:
                  case LoadingState.error:
                       return EmptyDataWidget(
                      message: 'Failed to load data',
                      onRefresh: () async => await controller.refresh(),
                    );

                  case LoadingState.loaded:
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.banners.length,
                      itemBuilder: (context, index) {
                        final banner = controller.banners[index];
                        return Stack(

                          children: [
                            CustomNetworkImage(
                              borderRadius: 32.r,
                              imageUrl: banner.imageUrl,
                              height: 225.h,
                              width: double.infinity,
                              fit: BoxFit.cover,),
                            Positioned(
                              bottom: 16.h,
                              left: 16.w,
                              child: CustomText(
                                  textAlign: TextAlign.start,
                                  color: AppColors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  text: TimeFormatHelper.formatDate(DateTime.parse(banner.createdAt ?? '')))
                            ) ,


                            Positioned(
                              top: 4.h,
                              right: 6.w,
                              child: IconButton(onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Obx(() {
                                    return CustomDialog(
                                      title: "Delete Banner",
                                      rightButtonLabel: 'Yes, Delete',
                                      isLoading: controller.deleteLoadingState.isLoading,
                                      onTapLeftButton: () => Get.back(),
                                      onTapRightButton: () => controller.deleteBanner(banner.sId ?? ''),
                                      description:
                                      'Are you sure want to delete your Banner?',
                                    );
                                  }
                                  ),
                                );
                              }, icon: Assets.icons.delete.svg())
                            )
                          ],
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(height: 16.h),
                    );
                }
              }),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
