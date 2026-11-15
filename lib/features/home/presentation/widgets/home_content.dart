import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/admin/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:masic_generation/features/admin/dashboard/presentation/widgets/custom_bar_chart.dart';
import 'package:masic_generation/features/admin/dashboard/presentation/widgets/custom_pie_chart.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/home/presentation/controllers/home_controller.dart';
import 'package:masic_generation/features/home/presentation/widgets/home_announcement_card.dart';
import 'package:masic_generation/features/home/presentation/widgets/poll_card_widget.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeController.to;
    final controllerD = DashboardController.to;

    return Obx(
      () => RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            controller.refresh(),
            if (AuthController.to.isAdmin()) controllerD.refresh(),
          ]);
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


            if(!AuthController.to.isAdmin())...[
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
                          Get.toNamed(AppRoutes.requestScreen);
                        },
                        label: 'Request',
                      ),
                    ],
                  ),
                ),
              ),

            ],

            if (controller.polls.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        //top: 12.h,
                        left: 20.w,
                        right: 20.w,
                        //bottom: 10.h,
                        textAlign: TextAlign.start,
                        color: AppColors.primaryColor,
                        text: 'Poll',
                        fontSize: 16.sp,
                      ),
                    ),
                    
                    TextButton(onPressed: (){
                      Get.toNamed(AppRoutes.pollScreen);
                    }, child: CustomText(text: 'See all', color: AppColors.primaryColor))
                  ],
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
            if(AuthController.to.isAdmin())
              SliverToBoxAdapter(
                child: Obx(() {
                  final dashboard = controllerD.dashboard;
                  final dashLoading =
                      controllerD.loadingState == LoadingState.loading ||
                      controllerD.loadingState == LoadingState.initial;
                  if (dashboard == null || !dashboard.hasAnyChartData) {
                    if (dashLoading) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: const Center(child: CustomLoader()),
                      );
                    }
                    return HomeEmptyStateCard(
                      key: const ValueKey('home_admin_empty_state'),
                      title: controller.announcements.isEmpty &&
                              controller.polls.isEmpty
                          ? 'Nothing to show yet'
                          : 'No dashboard statistics yet',
                      message: controllerD.loadingState == LoadingState.error
                          ? 'Could not load dashboard statistics. Pull down to retry.'
                          : 'Charts appear here once members fill in their profile details (age, gender, work, education, location).',
                      onRefresh: () async {
                        await Future.wait([
                          controller.refresh(),
                          controllerD.refresh(),
                        ]);
                      },
                    );
                  }
                 return Padding(
                   padding:  EdgeInsets.symmetric(horizontal: 16.w),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       SizedBox(height: 16.h),
                       // ── Age Range Bar Chart ──────────────────────────
                       if (dashboard?.ageRangeChartData != null &&
                           dashboard!.ageRangeChartData.isNotEmpty)
                         CustomBarChart(
                           label: 'Age Range',
                           chartData: dashboard.ageRangeChartData,
                           onBarTap: (age) {
                             ProfileController.to.openUsersFilteredByAge(age);
                           },
                         ),

                       // ── Male & Female Pie Chart ──────────────────────
                       if (dashboard?.genderChartData != null &&
                           dashboard!.genderChartData.isNotEmpty)
                         CustomPieChart(
                           pieChartData: dashboard.genderChartData,
                           label: 'Male and Female user',
                           onSectionTap: (gender) {
                             ProfileController.to
                                 .openUsersFilteredByGender(gender);
                           },
                         ),

                       // ── Common name Bar Chart ──────────────────────────
                       if (dashboard?.commonNamesChartData != null &&
                           dashboard!.commonNamesChartData.isNotEmpty)
                         CustomBarChart(
                           label: 'Common name',
                           chartData: dashboard.commonNamesChartData,
                           onBarTap: (name) {
                             ProfileController.to.openUsersFilteredByName(name);
                           },
                         ),

                       // ── Employment status Pie Chart ──────────────────────
                       if (dashboard?.employmentStatusChartData != null &&
                           dashboard!.employmentStatusChartData.isNotEmpty)
                         CustomPieChart(
                           pieChartData: dashboard.employmentStatusChartData,
                           label: 'Employment status',
                           onSectionTap: (status) {
                             ProfileController.to
                                 .openUsersFilteredByEmployment(status);
                           },
                         ),

                       // ── Field of work Bar Chart ──────────────────────────
                       if (dashboard?.fieldOfWorkChartData != null &&
                           dashboard!.fieldOfWorkChartData.isNotEmpty)
                         CustomBarChart(
                           label: 'Field of work',
                           chartData: dashboard.fieldOfWorkChartData,
                           onBarTap: (field) {
                             ProfileController.to
                                 .openUsersFilteredByFieldOfWork(field);
                           },
                         ),

                       // ── School or University student Pie Chart ──────────────────────
                       if (dashboard?.educationLevelChartData != null &&
                           dashboard!.educationLevelChartData.isNotEmpty)
                         CustomPieChart(
                           pieChartData: dashboard.educationLevelChartData,
                           label: 'School or University student',
                         ),

                       // ── Location Bar Chart ──────────────────────────
                       if (dashboard?.locationChartData != null &&
                           dashboard!.locationChartData.isNotEmpty)
                         CustomBarChart(
                           label: 'Location',
                           chartData: dashboard.locationChartData,
                         ),
                       SizedBox(height: MediaQuery.of(context).padding.bottom + 10.h),
                     ],
                   ),
                 );
                }),
              ),
            // Keep the last item clear of the floating bottom nav bar.
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).bottom + 24.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Placeholder shown on the home screen when there is nothing else to render,
/// so the area under the header is never a blank white void.
class HomeEmptyStateCard extends StatelessWidget {
  const HomeEmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    this.onRefresh,
  });

  final String title;
  final String message;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      horizontalMargin: 16.w,
      verticalMargin: 16.h,
      bordersColor: AppColors.color8A8A8A,
      radiusAll: 20.r,
      width: double.infinity,
      paddingHorizontal: 24.w,
      paddingVertical: 24.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 40.r,
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 12.h),
          CustomText(
            text: title,
            fontSize: 16.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 8.h),
          CustomText(text: message, fontSize: 12.sp, maxline: 4),
          if (onRefresh != null) ...[
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => onRefresh!(),
              child: CustomText(
                text: 'Refresh',
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
