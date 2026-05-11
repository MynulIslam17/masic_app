import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_task/features/home/presentation/widgets/home_content.dart';
import 'package:flutter_task/features/home/presentation/widgets/home_simmer.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final HomeController controller = HomeController.to;
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              actions: [
                IconButton(onPressed: () {}, icon: Assets.icons.noti.svg()),
              ],
              expandedHeight: 110.h,
              floating: false,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Builder(
                builder: (context) {
                  final settings = context
                      .dependOnInheritedWidgetOfExactType<
                        FlexibleSpaceBarSettings
                      >();
                  final isCollapsed = settings?.isScrolledUnder ?? false;
                  return Obx(() {
                    final userData = ProfileController.to.userData;
                    return GestureDetector(
                      onTap: () {
                        BottomNavBarController.to.onChange(2);
                      },
                      child: Row(
                        children: [
                          CustomNetworkImage(
                            boxShape: BoxShape.circle,
                            height: 42.r,
                            width: 42.r,
                            imageUrl: userData?.profileImage,
                            fallbackAsset: Assets.images.profile.image(),
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  enableAutoTranslate: false,
                                  fontSize: 14.sp,
                                  color: isCollapsed
                                      ? AppColors.primaryColor
                                      : Colors.white,
                                  textAlign: TextAlign.start,
                                  text: userData?.name ?? '',
                                ),
                                CustomText(
                                  color: isCollapsed
                                      ? AppColors.primaryColor
                                      : Colors.white,
                                  textAlign: TextAlign.start,
                                  text: 'welcome to MASIC generation',
                                  fontSize: 10.sp,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                },
              ),
              backgroundColor: AppColors.bgColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 16.w, bottom: 60.h),
                background: Stack(
                  children: [
                    Positioned.fill(
                      child: Obx(
                         () {
                          return CustomNetworkImage(
                            height: 110.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            imageUrl: controller.bannerUrl,
                            fallbackAsset: Assets.images.homeBanner.image(
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      ),
                    ),
                    Positioned(
                      right: -40.w,
                      bottom: -24.h,
                      child: Assets.images.bannerDesign.image(
                        fit: BoxFit.cover,
                        width: 405.w,
                        height: 251.h,
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CustomContainer(
                        topLeftRadius: 33.r,
                        topRightRadius: 33.r,
                        height: 36.h,
                        linearColors: List.generate(
                          31,
                          (i) => AppColors.bgColor.withOpacity((70 + i) / 100),
                        ),

                        child: Obx(
                           () {
                             if(controller.announcements.isEmpty) return SizedBox();
                            return CustomText(
                              top: 12.h,
                              left: 20.w,
                              right: 20.w,
                              textAlign: TextAlign.start,
                              color: AppColors.primaryColor,
                              text: 'Announcement',
                              fontSize: 16.sp,
                            );
                          }
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Obx(() {
          switch (controller.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return HomeShimmer();

            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Failed to load data. Please try again.',
                onRefresh: () async => await controller.refresh(),
              );

            case LoadingState.loaded:
              return HomeContent();
          }
        }),
      ),
    );
  }
}
