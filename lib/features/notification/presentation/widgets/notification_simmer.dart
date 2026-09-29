import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/widgets/app_simmer.dart';

class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

  static const int _placeholderCount = 6;

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
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppShimmer.circle(size: 44.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppShimmer.line(width: 140.w, height: 14),
                      ),
                      SizedBox(width: 8.w),
                      AppShimmer.line(width: 48.w, height: 12),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  AppShimmer.lines(count: 2, spacing: 6, lastLineWidth: 180.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
