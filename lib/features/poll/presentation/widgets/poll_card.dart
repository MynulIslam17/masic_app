import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/helpers/time_format.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/poll/data/models/poll_model.dart';
import 'package:get/get.dart';

class PollCard extends StatelessWidget {
  const PollCard({super.key, required this.poll});

  final PollModel poll;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginBottom: 10.h,
      paddingAll: 16.r,
      radiusAll: 10.r,
      color: Colors.transparent,
      bordersColor: AppColors.colorE6E6E6,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            maxline: 1,
            textAlign: TextAlign.start,
            text: poll.title ?? 'N/A',
            fontSize: 16.sp,
          ),

          CustomText(
            top: 12.h,
            textAlign: TextAlign.start,
            maxline: 3,
            text: poll.tagline ?? 'N/A',
            fontSize: 12.sp,
          ),

          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                textAlign: TextAlign.start,
                text:
                'Create date : ${TimeFormatHelper.getDate(poll.createdAt ?? DateTime.now().toString())}',
                fontSize: 12.sp,
              ),
              CustomText(
                textAlign: TextAlign.end,
                text:
                'at ${TimeFormatHelper.timeWithAMPM(DateTime.parse(poll.createdAt ?? DateTime.now().toString()))}',
                fontSize: 12.sp,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          CustomButton(
            onPressed: () {
              Get.toNamed(AppRoutes.pollResultScreen,arguments: poll.sId);
            },
            bordersColor: AppColors.primaryColor,
            foregroundColor: AppColors.primaryColor,
            backgroundColor: Colors.white,
            fontSize: 12.sp,
            height: 38.h,
            fontWeight: FontWeight.w400,
            label: 'View Answers (${poll.totalResponses ?? 0} responses)',
          ),
        ],
      ),
    );
  }
}
