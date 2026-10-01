import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/image_preview_viewer.dart';
import 'package:masic_generation/core/widgets/widgets.dart';

class AnnouncementBannerCarousel extends StatefulWidget {
  const AnnouncementBannerCarousel({
    super.key,
    required this.bannerUrls,
    this.height,
    this.showDots = true,
  });

  final List<String> bannerUrls;
  final double? height;
  final bool showDots;

  @override
  State<AnnouncementBannerCarousel> createState() =>
      _AnnouncementBannerCarouselState();
}

class _AnnouncementBannerCarouselState
    extends State<AnnouncementBannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.bannerUrls;
    if (urls.isEmpty) return const SizedBox.shrink();

    final carouselHeight = widget.height ?? 225.h;

    if (urls.length == 1) {
      return GestureDetector(
        onTap: () => ImagePreviewViewer.open(
          context,
          imageUrl: urls.first,
        ),
        child: CustomNetworkImage(
          borderRadius: 12.r,
          height: carouselHeight,
          width: double.infinity,
          imageUrl: urls.first,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            CarouselSlider.builder(
              itemCount: urls.length,
              itemBuilder: (context, index, realIndex) {
                final url = urls[index];
                return GestureDetector(
                  onTap: () => ImagePreviewViewer.openGallery(
                    context,
                    imageUrls: urls,
                    initialIndex: index,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CustomNetworkImage(
                      borderRadius: 12.r,
                      height: carouselHeight,
                      width: double.infinity,
                      imageUrl: url,
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: carouselHeight,
                viewportFraction: 1.0,
                enableInfiniteScroll: urls.length > 1,
                autoPlay: urls.length > 1,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, reason) {
                  if (mounted) {
                    setState(() {
                      _currentIndex = index;
                    });
                  }
                },
              ),
            ),
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    CustomText(
                      text: '${_currentIndex + 1}/${urls.length}',
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (widget.showDots) ...[
          SizedBox(height: 8.h),
          DotsIndicator(
            dotsCount: urls.length,
            position: _currentIndex.toDouble(),
            decorator: DotsDecorator(
              color: AppColors.borderColor,
              activeColor: AppColors.primaryColor,
              size: Size.square(6.0.r),
              activeSize: Size(16.0.w, 6.0.h),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0.r),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
