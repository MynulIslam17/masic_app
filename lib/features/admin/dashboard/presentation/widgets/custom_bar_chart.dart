import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/services/translation_service.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/custom_text.dart';
import 'package:masic_generation/features/admin/dashboard/data/models/dashboard_model.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:get/get.dart';

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

  /// Translated bottom-axis labels (parallel to widget.chartData)
  List<String> _translatedLabels = [];
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _translatedLabels = widget.chartData.map((e) => e.label).toList();
    _translateAll();

    _worker = ever(TranslationController.to.retranslateTrigger, (_) {
      _translateAll();
    });
  }

  @override
  void didUpdateWidget(CustomBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartData != widget.chartData) {
      _translatedLabels = widget.chartData.map((e) => e.label).toList();
      _translateAll();
    }
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  Future<void> _translateAll() async {
    final targetCode = TranslationController.to.currentCode;
    final results = await Future.wait(
      widget.chartData.map(
        (item) =>
            TranslationService().translate(item.label, targetCode: targetCode),
      ),
    );
    if (mounted) {
      setState(() {
        _translatedLabels = results;
      });
    }
  }

  void _handleTap(String originalLabel) {
    widget.onBarTap?.call(originalLabel);
  }

  bool get _rotateLabels {
    final data = widget.chartData;
    if (data.length > 5) return true;
    return data.any((e) => e.label.trim().length > 6);
  }

  @override
  Widget build(BuildContext context) {
    final chartData = widget.chartData;
    final rotate = _rotateLabels;
    final count = math.max(chartData.length, 1);
    final availableWidth = math.max(
      MediaQuery.sizeOf(context).width - 72.w,
      200.0,
    );
    final slotWidth = 56.w;
    final needScroll = count * slotWidth > availableWidth;
    final chartWidth = needScroll ? count * slotWidth : availableWidth;
    final barWidth = (chartWidth / count * 0.42).clamp(14.0, 33.w);
    final reservedBottom = rotate ? 86.h : 40.h;
    final chartHeight = rotate ? 276.h : 229.h;

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
          height: chartHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: needScroll
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: chartWidth,
              height: chartHeight,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  alignment: BarChartAlignment.spaceAround,
                  groupsSpace: 16,
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
                          TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 10.sp,
                          ),
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
                          enableAutoTranslate: false,
                          text: value.toInt().toString(),
                          fontSize: 10.sp,
                          color: Colors.black.withOpacity(0.70),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: reservedBottom,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= chartData.length) {
                            return const SizedBox.shrink();
                          }
                          final originalLabel = chartData[index].label;
                          final displayLabel = index < _translatedLabels.length
                              ? _translatedLabels[index]
                              : originalLabel;
                          return SideTitleWidget(
                            meta: meta,
                            space: 16,
                            angle: rotate ? -0.85 : 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: widget.onBarTap == null
                                  ? null
                                  : () => _handleTap(originalLabel),
                              child: SizedBox(
                                width: rotate ? 72.w : slotWidth,
                                child: Text(
                                  displayLabel,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.black.withOpacity(0.70),
                                  ),
                                ),
                              ),
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
                          width: barWidth,
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
          ),
        ),
        SizedBox(height: 18.h),
      ],
    );
  }
}
