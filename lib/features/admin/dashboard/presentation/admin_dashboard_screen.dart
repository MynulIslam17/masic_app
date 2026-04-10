import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/admin_app_bar.dart';
import 'package:flutter_task/core/widgets/custom_scaffold.dart';
import 'package:flutter_task/features/admin/dashboard/data/models/bar_chart_model.dart';
import 'package:flutter_task/features/admin/dashboard/presentation/widgets/custom_bar_chart.dart';
import 'package:flutter_task/features/admin/dashboard/presentation/widgets/custom_pie_chart.dart';
import 'package:get/get.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            // ── Age Range Bar Chart ──────────────────────────
            CustomBarChart(
              label: 'Age Range',
              chartData: BarChartModel.ageData,
            ),

            // ── Male & Female Pie Chart ──────────────────────
            CustomPieChart(
              pieChartData: BarChartModel.gender,
              label: 'Male and Female user',
            ),

            // ── Common name Bar Chart ──────────────────────────
            CustomBarChart(
              label: 'Common name',
              chartData: BarChartModel.nameData,
            ),

            // ── Employment status Pie Chart ──────────────────────
            CustomPieChart(
              pieChartData: BarChartModel.employmentStatusData,
              label: 'Employment status',
            ),

            // ── Field of work Bar Chart ──────────────────────────
            CustomBarChart(
              label: 'Field of work',
              chartData: BarChartModel.workData,
            ),

            // ── School or University student Pie Chart ──────────────────────
            CustomPieChart(
              pieChartData: BarChartModel.studentData,
              label: 'School or University student',
            ),

            // ── Location Bar Chart ──────────────────────────
            CustomBarChart(
              label: 'Location',
              chartData: BarChartModel.locationData,
            ),
          ],
        ),
      ),
    );
  }
}
