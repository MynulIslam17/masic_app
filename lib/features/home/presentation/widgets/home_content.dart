import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_task/features/home/presentation/widgets/home_announcement_card.dart';
import 'package:flutter_task/features/home/presentation/widgets/poll_card_widget.dart';
import 'package:get/get.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeController.to;
    return Obx(
      () => RefreshIndicator(
        onRefresh: () async {
          controller.refresh();
        },
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Announcements
            if (controller.announcements.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 210.h,
                  child: PageView.builder(
                    onPageChanged: (value) {
                      controller.currentAnnouncementPage = value;
                    },
                    itemCount: controller.announcements.length,
                    itemBuilder: (context, index) => HomeAnnouncementCard(
                      announcement: controller.announcements[index],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: DotsIndicator(
                    position: controller.currentAnnouncementPage.toDouble(),
                    dotsCount: controller.announcements.length,
                    decorator: DotsDecorator(
                      activeSize: Size(24.0.w, 8.0.h),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      size: Size.square(8.0.r),
                      spacing: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 2.h,
                      ),
                      activeColor: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],

            // Request section
            SliverToBoxAdapter(
              child: CustomText(
                top: 8.h,
                left: 20.w,
                right: 20.w,
                bottom: 10.h,
                textAlign: TextAlign.start,
                color: AppColors.primaryColor,
                text: 'Request',
                fontSize: 16.sp,
              ),
            ),
            SliverToBoxAdapter(
              child: CustomContainer(
                horizontalMargin: 16.w,
                bordersColor: AppColors.color8A8A8A,
                radiusAll: 20.r,
                height: 158.h,
                width: double.infinity,
                paddingHorizontal: 44.r,
                paddingVertical: 20.r,
                child: Column(
                  children: [
                    CustomText(
                      maxline: 1,
                      text: 'Request for opportunities',
                      fontSize: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      maxline: 2,
                      text:
                          'Submit requests for jobs, volunteering opportunities, workshops',
                      fontSize: 10.sp,
                    ),
                    SizedBox(height: 14.h),

                    CustomButton(
                      height: 38.h,
                      fontSize: 12.sp,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
                            title: CustomText(
                              fontWeight: FontWeight.w600,
                              text: 'Select request',
                              fontSize: 20.sp,
                              color: AppColors.primaryColor,
                            ),
                            content: CustomText(text: 'Before request you need to select your which data you are used.'),
                            actions: [
                              CustomButton(
                                label: 'Request by profile data',
                                onPressed: () => Get.back(),
                              ),
                              SizedBox(height: 10.h),
                              CustomButton(
                                backgroundColor: Colors.transparent,
                                bordersColor: AppColors.primaryColor,
                                foregroundColor: AppColors.primaryColor,
                                label: 'Request manually',
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        );
                      },
                      label: 'Request',
                    ),
                  ],
                ),
              ),
            ),

            if (controller.polls.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: CustomText(
                  top: 12.h,
                  left: 20.w,
                  right: 20.w,
                  bottom: 10.h,
                  textAlign: TextAlign.start,
                  color: AppColors.primaryColor,
                  text: 'Poll',
                  fontSize: 16.sp,
                ),
              ),
              SliverToBoxAdapter(
                child: CarouselSlider(
                  items: List.generate(
                    controller.polls.length,
                    (index) => PollCardWidget(poll: controller.polls[index]),
                  ),
                  options: CarouselOptions(
                    height: 158.h,
                    viewportFraction: 0.8,
                    onPageChanged: (index, reason) {
                      controller.currentPollPage = index;
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10.h)),
              SliverToBoxAdapter(
                child: Center(
                  child: Obx(
                    () => DotsIndicator(
                      position: controller.currentPollPage.toDouble(),
                      dotsCount: controller.polls.length,
                      decorator: DotsDecorator(
                        activeSize: Size(24.0.w, 8.0.h),
                        activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        size: Size.square(8.0.r),
                        spacing: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 2.h,
                        ),
                        activeColor: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(child: SizedBox(height: 10.h)),
          ],
        ),
      ),
    );
  }
}
