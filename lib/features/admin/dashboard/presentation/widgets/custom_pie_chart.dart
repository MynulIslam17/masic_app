import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/custom_container.dart';
import 'package:flutter_task/core/widgets/custom_text.dart';
import 'package:flutter_task/features/admin/dashboard/data/models/dashboard_model.dart';

class CustomPieChart extends StatelessWidget {
  const CustomPieChart({
    super.key,
    required this.pieChartData,
    required this.label,
  });

  final List<BarChartModel> pieChartData;
  final String label;

  @override
  Widget build(BuildContext context) {
    int touchedIndex = -1;

    // Default colors — add more if needed
    final List<Color> defaultColors = [
      Color(0xFF6A89BD),
      Color(0xFF98AED2),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
    ];
    final total = pieChartData.fold<num>(0, (sum, item) => sum + item.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          textAlign: TextAlign.start,
          text: label,
          fontSize: 16.sp,
          bottom: 16.h,
        ),
        Row(
          children: [
            // Pie Chart
            SizedBox(
              height: 173.r,
              width: 173.r,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  startDegreeOffset: -90,
                  sections: List.generate(pieChartData.length, (index) {
                    final item = pieChartData[index];
                    final pct = total == 0
                        ? 0
                        : (item.value / total * 100).round();
                    final color = defaultColors[index % defaultColors.length];
                    final isTouched = index == touchedIndex;

                    return PieChartSectionData(
                      value: item.value.toDouble(),
                      color: color,
                      radius: isTouched ? 95 : 88,
                      title: '${item.label}\n$pct%',
                      titleStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),

            SizedBox(width: 44.w),

            // Legend
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pieChartData.length, (index) {
                  final item = pieChartData[index];
                  final color = defaultColors[index % defaultColors.length];
              
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < pieChartData.length - 1 ? 12 : 0,
                    ),
                    child: _buildLegendItem(
                      color: color,
                      label: item.label,
                      count: item.value.toInt(),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),

        SizedBox(height: 18.h),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      children: [
        CustomContainer(
          width: 8.r,
          height: 8.r,
          color: color,
          shape: BoxShape.circle,
        ),
        Flexible(
          child: CustomText(
            textAlign: TextAlign.start,
            left: 8.w,
            text: '$label  :  $count',
            fontSize: 12.sp,
            color: AppColors.appGreyColor,
          ),
        ),
      ],
    );
  }
}
