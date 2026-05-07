import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/widgets/app_simmer.dart';

class AnnouncementShimmer extends StatelessWidget {
  const AnnouncementShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) => AppShimmer.wrap(
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge (top right)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppShimmer.line(width: 60.w, height: 14),
              ],
            ),

            SizedBox(height: 12.h),

            // Banner image placeholder
            AppShimmer.image(
              width: double.infinity,
              height: 152.h,
              radius: 12,
            ),

            SizedBox(height: 10.h),

            // Title
            AppShimmer.line(width: 200.w, height: 16),

            SizedBox(height: 12.h),

            // Description (3 lines)
            AppShimmer.lines(count: 3, spacing: 6, lastLineWidth: 140.w),

            SizedBox(height: 12.h),

            // View details button
            AppShimmer.button(height: 38),
          ],
        ),
      ),
    ));
  }
}