import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_task/features/home/presentation/widgets/home_announcement_card.dart';
import 'package:flutter_task/features/home/presentation/widgets/poll_card_widget.dart';
import 'package:flutter_task/features/poll/presentation/widgets/request_card_widget.dart';
import 'package:get/get.dart';


class HomeContent extends StatelessWidget {
  const HomeContent({super.key});


  @override
  Widget build(BuildContext context) {
    final  controller = HomeController.to;
    return Obx(() => RefreshIndicator(
      onRefresh: ()async {
        controller.retry();
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
                child:  DotsIndicator(
                  position: controller.currentAnnouncementPage.toDouble(),
                  dotsCount: controller.announcements.length,
                  decorator: DotsDecorator(
                    activeSize: Size(24.0.w, 8.0.h),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    size: Size.square(8.0.r),
                    spacing: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    activeColor: AppColors.primaryColor,
                  ),
                )

              ),
            ),
          ],

          // Request section
          SliverToBoxAdapter(
            child: CustomText(
              top: 8.h, left: 20.w, right: 20.w, bottom: 10.h,
              textAlign: TextAlign.start,
              color: AppColors.primaryColor,
              text: 'Request',
              fontSize: 16.sp,
            ),
          ),
          SliverToBoxAdapter(
            child: RequestCardWidget(
              onTap: () => Get.toNamed(AppRoutes.requestScreen),
            ),
          ),

          if(controller.polls.isNotEmpty)...[
            SliverToBoxAdapter(
              child: CustomText(
                top: 12.h, left: 20.w, right: 20.w, bottom: 10.h,
                textAlign: TextAlign.start,
                color: AppColors.primaryColor,
                text: 'Poll',
                fontSize: 16.sp,
              ),
            ),
            SliverToBoxAdapter(
              child: CarouselSlider(
                items: List.generate(controller.polls.length, (index) => PollCardWidget(poll: controller.polls[index])),
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
                child: Obx(() => DotsIndicator(
                  position: controller.currentPollPage.toDouble(),
                  dotsCount: controller.polls.length,
                  decorator: DotsDecorator(
                    activeSize: Size(24.0.w, 8.0.h),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    size: Size.square(8.0.r),
                    spacing: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    activeColor: AppColors.primaryColor,
                  ),
                )),
              ),
            ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
        ],
      ),
    )
    );
  }
}