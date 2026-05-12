import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/helpers/time_format.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/request/data/models/request_model.dart';
import 'package:get/get.dart';

class RequestCardWidget extends StatelessWidget {
  const RequestCardWidget({super.key, required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: () {
        Get.toNamed(AppRoutes.requestDetailsScreen,arguments: request.sId);
      },
      horizontalMargin: 16.w,
      bordersColor: AppColors.primaryColor,
      radiusAll: 20.r,
      height: 158.h,
      width: double.infinity,
      paddingHorizontal: 16.r,
      paddingVertical: 16.r,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomText(
                  textAlign: TextAlign.start,
                  maxline: 1,
                  text: request.jobSpec ?? 'N/A',
                  fontSize: 16.sp,
                  color: AppColors.primaryColor,
                ),
              ),
              CustomContainer(
                horizontalMargin: 0,
                bordersColor: getColor(request.status ?? 'N/A'),
                radiusAll: 100.r,
                paddingVertical: 4.h,
                paddingHorizontal: 16.w,
                child: CustomText(
                  text: request.status ?? 'N/A',
                  fontSize: 10.sp,
                  color: getColor(request.status ?? 'N/A'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          CustomText(
            textAlign: TextAlign.start,
            maxline: 3,
            text: request.bio ?? 'N/A',
            fontSize: 12.sp,
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                textAlign: TextAlign.start,
                text:
                    'Date : ${TimeFormatHelper.getDate(request.createdAt ?? DateTime.now().toString())}',
                fontSize: 10.sp,
              ),
              CustomText(
                textAlign: TextAlign.end,
                text:
                    'at ${TimeFormatHelper.timeWithAMPM(DateTime.parse(request.createdAt ?? DateTime.now().toString()))}',
                fontSize: 10.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color getColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'approved':
        return AppColors.primaryColor;
      default:
        return AppColors.red;
    }
  }
}
