import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/announcement/data/models/announcement_model.dart';
import 'package:get/get.dart';


class AnnouncementsDetailsScreen extends StatelessWidget {
  const AnnouncementsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final announcement = Get.arguments as AnnouncementModel;
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
                  height: 225.h,
                  width: double.infinity,
                  imageUrl: announcement.bannerUrl,
                ),

                CustomText(
                  top: 10.h,
                  textAlign: TextAlign.start,
                  text: announcement.title ?? 'N/A',
                  maxline: 2,
                  textOverflow: TextOverflow.ellipsis,
                  fontSize: 16.sp,
                ),

                CustomText(
                  top: 12.h,
                  textAlign: TextAlign.start,
                  text: announcement.description ?? 'N/A',
                  fontSize: 10.sp,
                ),

                SizedBox(height: 12.h),
              ],
            ),
          ],
        ),
      ),
      // bottomNavigationBar: SafeArea(
      //   child: Padding(
      //     padding: EdgeInsets.all(16.r),
      //     child: Row(
      //       children: [
      //         Expanded(
      //           child: CustomButton(onPressed: () {}, label: 'Edit'),
      //         ),
      //         SizedBox(width: 12.w),
      //         Expanded(
      //           child: CustomButton(
      //             bordersColor: AppColors.errorColor,
      //             foregroundColor: AppColors.errorColor,
      //             backgroundColor: AppColors.bgColor,
      //             fontWeight: FontWeight.w400,
      //             label: 'Delete',
      //             onPressed: () {
      //               showDialog(
      //                 context: context,
      //                 builder: (context) => CustomDialog(
      //                   title: "Delete Announcements",
      //                   rightButtonLabel: 'Yes, Delete',
      //                   onTapLeftButton: () {
      //                     Get.back();
      //                   },
      //                   onTapRightButton: () {
      //                   },
      //                   description:
      //                       'Are you sure want to delete your Announcements?',
      //                 ),
      //               );
      //             },
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
