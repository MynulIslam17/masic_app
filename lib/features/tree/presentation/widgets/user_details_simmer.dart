import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/widgets/widgets.dart';

class UserDetailsShimmer extends StatelessWidget {
  const UserDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer.wrap(
      child: Column(
        children: [
          SizedBox(height: 8.h),

          // ── Profile circle ──────────────────────────────────────────
          AppShimmer.circle(size: 80.r),

          SizedBox(height: 24.h),

          // ── Info card ───────────────────────────────────────────────
          AppShimmer.card(
            radius: 12.r,
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: List.generate(11, (index) {
                final isLast = index == 10;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
                  child: _buildRowShimmer(),
                );
              }),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildRowShimmer() {
    return Row(
      children: [
        // label placeholder
        AppShimmer.line(width: 100.w, height: 12),
        SizedBox(width: 24.w),
        // colon placeholder
        AppShimmer.line(width: 6.w, height: 12),
        SizedBox(width: 32.w),
        // value placeholder — expanded, random-ish width via flex
        Expanded(child: AppShimmer.line(height: 12)),
      ],
    );
  }
}