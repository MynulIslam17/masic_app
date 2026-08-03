import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/custom_text.dart';
import 'package:masic_generation/features/admin/dashboard/data/models/dashboard_model.dart';

class CustomBarChart extends StatefulWidget {
  const CustomBarChart({
    super.key,
    required this.chartData,
    required this.label,
    this.onBarTap,
  });

  final List<BarChartModel> chartData;
  final String label;
  final ValueChanged<String>? onBarTap;

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  int? _pressedIndex;

  void _handleTap(String label) {
    widget.onBarTap?.call(label);
  }

  @override
  Widget build(BuildContext context) {
    final chartData = widget.chartData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          textAlign: TextAlign.start,
          text: widget.label,
          fontSize: 16.sp,
          bottom: 16.h,
        ),
        SizedBox(
          height: 229.h,
          child: BarChart(
            BarChartData(
              maxY: 100,
              barTouchData: BarTouchData(
                enabled: true,
                handleBuiltInTouches: widget.onBarTap == null,
                touchCallback: (event, response) {
                  if (widget.onBarTap == null) return;

                  final index = response?.spot?.touchedBarGroupIndex;

                  if (event is FlTapDownEvent ||
                      event is FlLongPressStart ||
                      event is FlPanDownEvent) {
                    if (index != null &&
                        index >= 0 &&
                        index < chartData.length) {
                      _pressedIndex = index;
                    }
                  }

                  if (event is FlTapUpEvent) {
                    final tapIndex =
                        (index != null &&
                            index >= 0 &&
                            index < chartData.length)
                        ? index
                        : _pressedIndex;
                    if (tapIndex != null &&
                        tapIndex >= 0 &&
                        tapIndex < chartData.length) {
                      _handleTap(chartData[tapIndex].label);
                    }
                    _pressedIndex = null;
                  }
                },
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
                      final item = chartData[index];
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onBarTap == null
                            ? null
                            : () => _handleTap(item.label),
                        child: CustomText(
                          top: 6.h,
                          text: item.label,
                          fontSize: 10.sp,
                          color: Colors.black.withOpacity(0.70),
                        ),
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
