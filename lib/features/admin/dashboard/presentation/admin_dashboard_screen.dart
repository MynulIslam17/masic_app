import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/admin_app_bar.dart';
import 'package:masic_generation/core/widgets/custom_scaffold.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/features/admin/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:masic_generation/features/admin/dashboard/presentation/widgets/custom_bar_chart.dart';
import 'package:masic_generation/features/admin/dashboard/presentation/widgets/custom_pie_chart.dart';
import 'package:masic_generation/features/home/presentation/widgets/home_simmer.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = DashboardController.to;
    return CustomScaffold(
      paddingSide: 0,
      appBar: AdminAppBar(
        showLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Assets.icons.clean.svg(height: 24.r, width: 24.r),
          ),
        ],
      ),
      body: Obx(() {
        final dashboard = controller.dashboard;
        switch (controller.loadingState) {
          case LoadingState.initial:
          case LoadingState.loading:
            return HomeShimmer();

          case LoadingState.offline:
          case LoadingState.error:
            return Center(
              child: EmptyDataWidget(
                message: 'Failed to load data. Please try again.',
                onRefresh: () async => await controller.refresh(),
              ),
            );

          case LoadingState.loaded:
            return RefreshIndicator(
              onRefresh: () async => await controller.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                          ProfileController.to.openUsersFilteredByGender(gender);
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
                  ],
                ),
              ),
            );
        }
      }),
    );
  }
}
