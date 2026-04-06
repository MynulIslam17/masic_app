import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';


class AnnouncementsDetailsScreen extends StatefulWidget {
  const AnnouncementsDetailsScreen({super.key});

  @override
  State<AnnouncementsDetailsScreen> createState() =>
      _AnnouncementsDetailsScreenState();
}

class _AnnouncementsDetailsScreenState
    extends State<AnnouncementsDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Announcements details'),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomNetworkImage(
                  borderRadius: 12.r,
                  height: 152.h,
                  width: double.infinity,
                  imageUrl:
                      'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg' ??
                      '',
                ),

                CustomText(
                  top: 10.h,
                  textAlign: TextAlign.start,
                  text: 'Event title here. . .' ?? 'N/A',
                  fontSize: 16.sp,
                ),

                CustomText(
                  top: 12.h,
                  textAlign: TextAlign.start,
                  text:
                      'Post your announcement here for your users for'
                          ' communication about users. Post your announcement '
                          'here for your users for better communication about '
                          'users. Post your announcement here for your users for '
                          'better communication about users. Post your '
                          'announcement here for your users for better '
                          'communication about users. Post your announcement here'
                          ' for your users for better communication about users. '
                          'Post your announcement here for your users for better '
                          'communication about users.' ??
                      'N/A',
                  fontSize: 10.sp,
                ),

                SizedBox(height: 12.h),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(onPressed: () {}, label: 'Edit'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  bordersColor: AppColors.errorColor,
                  foregroundColor: AppColors.errorColor,
                  backgroundColor: AppColors.bgColor,
                  fontWeight: FontWeight.w400,
                  label: 'Delete',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CustomDialog(
                        title: "Delete Announcements",
                        rightButtonLabel: 'Yes, Delete',
                        onTapLeftButton: () {
                          Get.back();
                        },
                        onTapRightButton: () {
                        },
                        description:
                            'Are you sure want to delete your Announcements?',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
