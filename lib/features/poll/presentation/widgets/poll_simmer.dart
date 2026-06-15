import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/widgets/app_simmer.dart';

class PollShimmer extends StatelessWidget {
  const PollShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer.wrap(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            // ── 1. Poll title ───────────────────────────────────────
            AppShimmer.line(height: 16, width: double.infinity),
            SizedBox(height: 6.h),

            // ── 2. Tagline ──────────────────────────────────────────
            AppShimmer.line(height: 12, width: 200.w),
            SizedBox(height: 8.h),

            // ── 3. "Already answered" badge ─────────────────────────
            _BadgeShimmer(),
            SizedBox(height: 10.h),

            // ── 4. Divider ──────────────────────────────────────────
            AppShimmer.box(width: double.infinity, height: 1, radius: 1),
            SizedBox(height: 22.h),

            // ── 5. Option tiles ─────────────────────────────────────
            ...List.generate(4, (i) => _OptionTileShimmer(index: i)),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _BadgeShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppShimmer.circle(size: 14.r),
          SizedBox(width: 4.w),
          AppShimmer.line(width: 90.w, height: 11),
        ],
      ),
    );
  }
}

// ─── Option Tile ──────────────────────────────────────────────────────────────
// Mirrors OptionTile widget: radio button + label + optional vote-bar

class _OptionTileShimmer extends StatelessWidget {
  const _OptionTileShimmer({required this.index});

  final int index;

  /// Vary bar widths so it looks like real vote data
  static const _barFractions = [0.72, 0.45, 0.88, 0.30];

  @override
  Widget build(BuildContext context) {
    final barFraction = _barFractions[index % _barFractions.length];

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio + option label row
            Row(
              children: [
                AppShimmer.circle(size: 20.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: AppShimmer.line(height: 14),
                ),
                SizedBox(width: 10.w),
                // Vote percentage chip
                AppShimmer.box(width: 36.w, height: 20.h, radius: 6),
              ],
            ),
            SizedBox(height: 10.h),

            // Vote progress bar — track
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Stack(
                children: [
                  AppShimmer.box(
                    width: double.infinity,
                    height: 6.h,
                    radius: 6,
                  ),
                  // Filled portion
                  LayoutBuilder(
                    builder: (_, constraints) => AppShimmer.box(
                      width: constraints.maxWidth * barFraction,
                      height: 6.h,
                      radius: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}