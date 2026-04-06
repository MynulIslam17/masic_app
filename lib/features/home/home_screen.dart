import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/home/widgets/home_announcement_card.dart';
import 'package:flutter_task/features/home/widgets/poll_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}




class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  int _currentPagePoll = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              actions: [
                IconButton(onPressed: (){}, icon:   Assets.icons.noti.svg(

                ),)
              ],
              expandedHeight: 110.h,
              floating: false,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Builder(
                builder: (context) {
                  final settings = context
                      .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                  final isCollapsed = settings?.isScrolledUnder ?? false;
                  return Row(
                    children: [
                      CustomNetworkImage(
                        boxShape: BoxShape.circle,
                        height: 42.r,
                        width: 42.r,
                        imageUrl: '',
                        fallbackAsset: Assets.images.profile.path,
                        colorFilter: ColorFilter.mode(isCollapsed ? AppColors.primaryColor : Colors.white, BlendMode.srcIn),
                        
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              fontSize: 14.sp,
                              color: isCollapsed ? AppColors.primaryColor : Colors.white,
                              textAlign: TextAlign.start,
                              text: 'Refan',
                            ),
                            CustomText(
                              color: isCollapsed ? AppColors.primaryColor : Colors.white,
                              textAlign: TextAlign.start,
                              text: 'welcome to MASIC generation',
                              fontSize: 10.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),              backgroundColor: AppColors.bgColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 16.w,bottom: 60.h),
                background: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomNetworkImage(
                        height: 110.h,
                        width: double.infinity,
                        imageUrl: '',
                        fallbackAsset: Assets.images.homeBanner.path,
                      ),
                    ),
                    Positioned(
                      right: -40.w,
                        bottom: -24.h,
                        child: Assets.images.bannerDesign.image(
                          fit: BoxFit.cover,
                          width: 405.w,
                          height: 251.h
                        )),

                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child:  CustomContainer(
                          topLeftRadius: 33.r,
                          topRightRadius: 33.r,
                          height: 36.h,
                          linearColors: List.generate(
                            31,
                                (i) => AppColors.bgColor.withOpacity((70 + i) / 100),
                          ),

                          child:     CustomText(
                            top: 12.h,
                            left:20.w,
                            right: 20.w,
                            textAlign: TextAlign.start,
                            color: AppColors.primaryColor,
                            text: 'Announcement',
                            fontSize: 16.sp,
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(
              height: 210.h,
              child: PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => HomeAnnouncementCard(), itemCount: 5,),
            ),
            Center(
              child: DotsIndicator(
                position: _currentPage.toDouble(),
                dotsCount: 5,
                decorator: DotsDecorator(
                  activeSize:  Size(24.0.w, 8.0.h),
                  activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  size: Size.square(8.0.r),
                  spacing: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  activeColor: AppColors.primaryColor,
                ),
              ),
            ),


            CustomText(
              top: 8.h,
              left:20.w,
              right: 20.w,
              bottom: 10.h,
              textAlign: TextAlign.start,
              color: AppColors.primaryColor,
              text: 'Request',
              fontSize: 16.sp,
            ),



            CustomContainer(
              horizontalMargin: 16.w,
              bordersColor: AppColors.color8A8A8A,
              radiusAll: 20.r,
              height: 158.h,
              width: double.infinity,
              paddingHorizontal: 44.r,
              paddingVertical: 20.r,
              child: Column(
                children: [
                  CustomText(
                    maxline: 1,
                    text: 'Request for opportunities',
                    fontSize: 16.sp,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 12.h),
                  CustomText(
                    maxline: 2,
                    text:
                    'Submit requests for jobs, volunteering opportunities, workshops',
                    fontSize: 10.sp,
                  ),
                  SizedBox(height: 14.h),

                  CustomButton(
                    height: 38.h,
                    fontSize: 12.sp,
                    onPressed: () {},
                    label: 'Request',
                  ),
                ],
              ),
            ),

            CustomText(
              top: 12.h,
              left:20.w,
              right: 20.w,
              bottom: 10.h,
              textAlign: TextAlign.start,
              color: AppColors.primaryColor,
              text: 'Poll',
              fontSize: 16.sp,
            ),

            CarouselSlider(
              items: List.generate(5, (index) {
                return PollCardWidget();
              }), options: CarouselOptions(
                height: 158.h,
                viewportFraction: 0.8,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPagePoll = index;
                });
              },
              )),


            SizedBox(height: 10.h),
            Center(
              child: DotsIndicator(
                position: _currentPagePoll.toDouble(),
                dotsCount: 5,
                decorator: DotsDecorator(
                  activeSize:  Size(24.0.w, 8.0.h),
                  activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  size: Size.square(8.0.r),
                  spacing: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  activeColor: AppColors.primaryColor,
                ),
              ),
            ),

          ],),
      ),
    );
  }
}
