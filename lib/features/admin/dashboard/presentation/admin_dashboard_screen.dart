import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/admin_app_bar.dart';
import 'package:flutter_task/core/widgets/custom_scaffold.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/features/admin/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:flutter_task/features/admin/dashboard/presentation/widgets/custom_bar_chart.dart';
import 'package:flutter_task/features/admin/dashboard/presentation/widgets/custom_pie_chart.dart';
import 'package:flutter_task/features/home/presentation/widgets/home_simmer.dart';
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
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.adminProfileScreen);
            },
            icon: Icon(Icons.menu, color: AppColors.color8A8A8A),
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
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    // ── Age Range Bar Chart ──────────────────────────
                    CustomBarChart(
                      label: 'Age Range',
                      chartData: dashboard?.ageRangeChartData ?? [],
                    ),

                    // ── Male & Female Pie Chart ──────────────────────
                    CustomPieChart(
                      pieChartData: dashboard?.genderChartData ?? [],
                      label: 'Male and Female user',
                    ),

                    // ── Common name Bar Chart ──────────────────────────
                    CustomBarChart(
                      label: 'Common name',
                      chartData: dashboard?.commonNamesChartData ?? [],
                    ),

                    // ── Employment status Pie Chart ──────────────────────
                    CustomPieChart(
                      pieChartData: dashboard?.employmentStatusChartData ?? [],
                      label: 'Employment status',
                    ),

                    // ── Field of work Bar Chart ──────────────────────────
                    CustomBarChart(
                      label: 'Field of work',
                      chartData: dashboard?.fieldOfWorkChartData ?? [],
                    ),

                    // ── School or University student Pie Chart ──────────────────────
                    CustomPieChart(
                      pieChartData: dashboard?.educationLevelChartData ?? [],
                      label: 'School or University student',
                    ),

                    // ── Location Bar Chart ──────────────────────────
                    CustomBarChart(
                      label: 'Location',
                      chartData: dashboard?.locationChartData ?? [],
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
