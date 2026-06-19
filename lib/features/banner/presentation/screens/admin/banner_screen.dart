import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/photo_picker_helper.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/announcement/presentation/widgets/announcement_simmer.dart';
import 'package:masic_generation/features/banner/presentation/controllers/banner_controller.dart';
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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => CustomText(
                        textAlign: TextAlign.start,
                        fontSize: 12.sp,
                        text: 'Total events : ${controller.banners.length}',
                      ),
                    ),
                  ),
                  CustomButton(
                    height: 38.h,
                    elevation: true,
                    borderWidth: 3,
                    bordersColor: const Color(0xffB0B0B0),
                    foregroundColor: AppColors.primaryColor,
                    backgroundColor: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    width: 120.w,
                    onPressed: () {
                      PhotoPickerHelper.showPhotoPicker(
                        context: context,
                        onImagePicked: (image) async =>
                            await controller.selectImage(image),
                      );
                    },
                    label: 'Upload',
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            Obx(() {
              switch (controller.loadingState) {
                case LoadingState.initial:
                case LoadingState.loading:
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AnnouncementShimmer(),
                  );

                case LoadingState.offline:
                case LoadingState.error:
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyDataWidget(
                      message: 'Failed to load data',
                      onRefresh: () async => await controller.refresh(),
                    ),
                  );

                case LoadingState.loaded:
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final banner = controller.banners[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < controller.banners.length - 1
                                ? 16.h
                                : 0,
                          ),
                          child: Stack(
                            children: [
                              CustomNetworkImage(
                                borderRadius: 32.r,
                                imageUrl: banner.imageUrl,
                                height: 225.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: CustomContainer(
                                  radiusAll: 32.r,
                                  height: 112.h,
                                  width: double.infinity,
                                  linearColors: [
                                    AppColors.white.withValues(alpha: 0.0),
                                    AppColors.white,
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 10.h,
                                left: 16.w,
                                child: Row(
                                  children: [
                                    CustomContainer(
                                      shape: BoxShape.circle,
                                      paddingAll: 14.r,
                                      color: AppColors.colorD9D9D9,
                                      child: CustomText(
                                        textAlign: TextAlign.start,
                                        color: AppColors.primaryColor,
                                        fontSize: 16.sp,
                                        text: '${index + 1}',
                                      ),
                                    ),
                                    CustomText(
                                      left: 10.w,
                                      textAlign: TextAlign.start,
                                      color: AppColors.primaryColor,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                      text:
                                          'Upload at ${TimeFormatHelper.formatDate(DateTime.parse(banner.createdAt ?? ''))}',
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 4.h,
                                right: 6.w,
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Obx(
                                        () => CustomDialog(
                                          title: 'Delete Banner',
                                          rightButtonLabel: 'Yes, Delete',
                                          isLoading:
                                              controller
                                                  .deleteLoadingState
                                                  .isLoading,
                                          onTapLeftButton: () => Get.back(),
                                          onTapRightButton: () =>
                                              controller.deleteBanner(
                                                banner.sId ?? '',
                                              ),
                                          description:
                                              'Are you sure want to delete your Banner?',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Assets.icons.delete.svg(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: controller.banners.length,
                    ),
                  );
              }
            }),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}
