import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/widgets/widgets.dart';

class RequestShimmer extends StatelessWidget {
  const RequestShimmer({super.key});

  static const int _placeholderCount = 3;

  @override
  Widget build(BuildContext context) {
    // A Column rather than a shrink-wrapped ListView: the list never scrolls,
    // and a viewport cannot report the intrinsic height that
    // SliverFillRemaining asks for.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_placeholderCount, (_) => _item()),
    );
  }

  Widget _item() {
    return AppShimmer.wrap(
      child: CustomContainer(
        horizontalMargin: 16.w,
        bordersColor: Colors.grey.shade300,
        radiusAll: 20.r,
        height: 158.h,
        width: double.infinity,
        paddingHorizontal: 16.r,
        paddingVertical: 16.r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: title + status badge ──────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer.line(width: 160.w, height: 16),
                AppShimmer.box(width: 70.w, height: 24.h, radius: 100.r),
              ],
            ),
            SizedBox(height: 16.h),

            // ── Bio lines ─────────────────────────────────────
            AppShimmer.lines(count: 3, lastLineWidth: 180.w),

            const Spacer(),

            // ── Footer: date + time ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer.line(width: 110.w, height: 10),
                AppShimmer.line(width: 90.w, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
