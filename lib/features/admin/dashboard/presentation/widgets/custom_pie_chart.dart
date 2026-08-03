import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/custom_container.dart';
import 'package:masic_generation/core/widgets/custom_text.dart';
import 'package:masic_generation/features/admin/dashboard/data/models/dashboard_model.dart';

class CustomPieChart extends StatefulWidget {
  const CustomPieChart({
    super.key,
    required this.pieChartData,
    required this.label,
    this.onSectionTap,
  });

  final List<BarChartModel> pieChartData;
  final String label;
  final ValueChanged<String>? onSectionTap;

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  int touchedIndex = -1;
  int? _pressedIndex;

  static const List<Color> _defaultColors = [
    Color(0xFF6A89BD),
    Color(0xFF98AED2),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
  ];

  void _handleTap(String label) {
    widget.onSectionTap?.call(label);
  }

  @override
  Widget build(BuildContext context) {
    final pieChartData = widget.pieChartData;
    final total = pieChartData.fold<num>(0, (sum, item) => sum + item.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          textAlign: TextAlign.start,
          text: widget.label,
          fontSize: 16.sp,
          bottom: 16.h,
        ),
        Row(
          children: [
            SizedBox(
              height: 173.r,
              width: 173.r,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    enabled: widget.onSectionTap != null,
                    touchCallback: (event, response) {
                      final index =
                          response?.touchedSection?.touchedSectionIndex;

                      // Keep pressed section from down/press events.
                      if (event is FlTapDownEvent ||
                          event is FlLongPressStart ||
                          event is FlPanDownEvent) {
                        if (index != null &&
                            index >= 0 &&
                            index < pieChartData.length) {
                          _pressedIndex = index;
                          setState(() => touchedIndex = index);
                        }
                      }

                      // On mobile FlTapUpEvent is NOT "interested for interactions",
                      // so handle navigation before that early-out.
                      if (event is FlTapUpEvent) {
                        final tapIndex =
                            (index != null &&
                                index >= 0 &&
                                index < pieChartData.length)
                            ? index
                            : _pressedIndex;
                        if (tapIndex != null &&
                            tapIndex >= 0 &&
                            tapIndex < pieChartData.length) {
                          _handleTap(pieChartData[tapIndex].label);
                        }
                        _pressedIndex = null;
                        setState(() => touchedIndex = -1);
                        return;
                      }

                      if (!event.isInterestedForInteractions ||
                          response?.touchedSection == null) {
                        setState(() => touchedIndex = -1);
                        return;
                      }

                      if (index != null && index >= 0) {
                        setState(() => touchedIndex = index);
                      }
                    },
                  ),
                  sections: List.generate(pieChartData.length, (index) {
                    final item = pieChartData[index];
                    final pct = total == 0
                        ? 0
                        : (item.value / total * 100).round();
                    final color = _defaultColors[index % _defaultColors.length];
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
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pieChartData.length, (index) {
                  final item = pieChartData[index];
                  final color = _defaultColors[index % _defaultColors.length];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < pieChartData.length - 1 ? 12 : 0,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onSectionTap == null
                            ? null
                            : () => _handleTap(item.label),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: _buildLegendItem(
                            color: color,
                            label: item.label,
                            count: item.value.toInt(),
                          ),
                        ),
                      ),
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
