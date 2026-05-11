import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/custom_text.dart';
import 'package:flutter_task/features/admin/dashboard/data/models/dashboard_model.dart';

class CustomBarChart extends StatelessWidget {
  const CustomBarChart({
    super.key,
    required this.chartData,
    required this.label,
  });

  final List<BarChartModel> chartData;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          textAlign: TextAlign.start,
            text: label, fontSize: 16.sp, bottom: 16.h),
        SizedBox(
          height: 229.h,
          child: BarChart(
            BarChartData(
              maxY: 100,
              barTouchData: BarTouchData(
                enabled: false,
                handleBuiltInTouches: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.white,
                  tooltipBorder: const BorderSide(
                    color: Color(0xFFBAC8E1),
                    width: 1,
                  ),
                  tooltipBorderRadius: BorderRadius.circular(100.r),
                  tooltipPadding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  tooltipMargin: -8.h,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} %',
                      TextStyle(color: AppColors.primaryColor, fontSize: 10.sp),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 24.w,
                    getTitlesWidget: (value, meta) => CustomText(
                      text: value.toInt().toString(),
                      fontSize: 10.sp,
                      color: Colors.black.withOpacity(0.70),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44.h,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= chartData.length) {
                        return const SizedBox.shrink();
                      }
                      return CustomText(
                        top: 6.h,
                        text: chartData[index].label,
                        fontSize: 10.sp,
                        color: Colors.black.withOpacity(0.70),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: Color(0xffBAC8E1),
                  strokeWidth: 0.4,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(chartData.length, (i) {
                final value = chartData[i].value;
                return BarChartGroupData(
                  x: i,
                  showingTooltipIndicators: [0],
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: const Color(0xFFBAC8E1),
                      width: 33.w,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(0),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),

        SizedBox(height: 18.h),

      ],
    );
  }
}
