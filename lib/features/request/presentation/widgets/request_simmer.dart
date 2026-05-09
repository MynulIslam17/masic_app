import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/widgets/widgets.dart';

class RequestShimmer extends StatelessWidget {
  const RequestShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => AppShimmer.wrap(
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
      ),
      itemCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }
}
