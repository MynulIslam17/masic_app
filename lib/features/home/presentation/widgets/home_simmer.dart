import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/widgets/app_simmer.dart';
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer.wrap(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Announcement card ────────────────────────────────
            _AnnouncementCardShimmer(),
            SizedBox(height: 10.h),

            // ── 2. Dots indicator ───────────────────────────────────
            _DotsRowShimmer(),
            SizedBox(height: 8.h),

            // ── 3. "Request" label ──────────────────────────────────
            _SectionLabelShimmer(top: 8.h, left: 20.w, right: 20.w, bottom: 10.h),

            // ── 4. Request card ─────────────────────────────────────
            _RequestCardShimmer(),
            SizedBox(height: 12.h),

            // ── 5. "Poll" label ─────────────────────────────────────
            _SectionLabelShimmer(top: 12.h, left: 20.w, right: 20.w, bottom: 10.h),

            // ── 6. Poll carousel card ───────────────────────────────
            _PollCardShimmer(),
            SizedBox(height: 10.h),

            // ── 7. Poll dots indicator ──────────────────────────────
            _DotsRowShimmer(),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

// ─── Announcement Card ────────────────────────────────────────────────────────

class _AnnouncementCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 210.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: small icon box + title line
            Row(
              children: [
                AppShimmer.box(width: 40.w, height: 40.h, radius: 8),
                SizedBox(width: 12.w),
                Expanded(child: AppShimmer.line(height: 16)),
              ],
            ),
            SizedBox(height: 12.h),

            // Body lines
            AppShimmer.lines(count: 3, lastLineWidth: 160.w),
            const Spacer(),

            // Bottom tag + date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer.box(width: 70.w, height: 24.h, radius: 6),
                AppShimmer.box(width: 80.w, height: 14.h, radius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dots Row ─────────────────────────────────────────────────────────────────

class _DotsRowShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final isActive = i == 0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: AppShimmer.box(
              width: isActive ? 24.w : 8.w,
              height: 8.h,
              radius: 5,
            ),
          );
        }),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabelShimmer extends StatelessWidget {
  const _SectionLabelShimmer({
    required this.top,
    required this.left,
    required this.right,
    required this.bottom,
  });

  final double top, left, right, bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
      child: AppShimmer.box(width: 80.w, height: 16.h, radius: 6),
    );
  }
}

// ─── Request Card ─────────────────────────────────────────────────────────────

class _RequestCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + title
            Row(
              children: [
                AppShimmer.circle(size: 36.r),
                SizedBox(width: 10.w),
                Expanded(child: AppShimmer.line(width: 140.w, height: 15)),
                AppShimmer.box(width: 28.w, height: 28.h, radius: 8),
              ],
            ),
            SizedBox(height: 14.h),
            // Two info rows
            _InfoRowShimmer(),
            SizedBox(height: 10.h),
            _InfoRowShimmer(labelWidth: 100.w),
            SizedBox(height: 14.h),
            // Action button
            AppShimmer.button(height: 44),
          ],
        ),
      ),
    );
  }
}

class _InfoRowShimmer extends StatelessWidget {
  const _InfoRowShimmer({this.labelWidth});
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppShimmer.box(width: labelWidth ?? 80.w, height: 12.h, radius: 4),
        const Spacer(),
        AppShimmer.box(width: 60.w, height: 12.h, radius: 4),
      ],
    );
  }
}

// ─── Poll Card ────────────────────────────────────────────────────────────────

class _PollCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mirror CarouselSlider with viewportFraction: 0.8 → slight peek on right
    return SizedBox(
      height: 158.h,
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Expanded(
            flex: 8,
            child: _PollCardContent(),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: AppShimmer.box(height: 158.h, radius: 16),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }
}

class _PollCardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 158.h,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question lines
          AppShimmer.line(height: 15),
          SizedBox(height: 6.h),
          AppShimmer.line(width: 200.w, height: 15),
          SizedBox(height: 14.h),

          // 2 option rows
          _OptionRowShimmer(width: 0.65),
          SizedBox(height: 8.h),
          _OptionRowShimmer(width: 0.45),
          const Spacer(),

          // Footer: vote count + button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmer.box(width: 80.w, height: 12.h, radius: 4),
              AppShimmer.box(width: 60.w, height: 30.h, radius: 8),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionRowShimmer extends StatelessWidget {
  const _OptionRowShimmer({required this.width});
  final double width; // 0..1 fraction of available space

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth * width;
        return Stack(
          children: [
            // Background track
            AppShimmer.box(
              width: double.infinity,
              height: 22.h,
              radius: 6,
            ),
            // Filled portion — slightly darker white, same shimmer
            AppShimmer.box(
              width: barWidth,
              height: 22.h,
              radius: 6,
            ),
          ],
        );
      },
    );
  }
}