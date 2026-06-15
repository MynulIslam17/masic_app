import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/request/data/models/request_model.dart';
import 'package:get/get.dart';

class RequestedCardWidget extends StatelessWidget {
  const RequestedCardWidget({super.key, required this.request});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomText(
                  textOverflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  maxline: 1,
                  text: request.jobSpec ?? 'N/A',
                  fontSize: 16.sp,
                  color: AppColors.primaryColor,
                ),
              ),
              if(AuthController.to.isAdmin())
                CustomButton(onPressed: (){
                  Get.toNamed(AppRoutes.requestDetailsScreen,arguments: request.sId);
                },
                label: 'View details',
                  fontSize: 12.sp,
                  width: 100.w,
                  height: 32.h,
                )else
              CustomContainer(
                horizontalMargin: 0,
                bordersColor: getColor(request.status ?? 'N/A'),
                radiusAll: 100.r,
                color: request.status == 'approved' ? AppColors.primaryColor : null,
                paddingVertical: 8.h,
                paddingHorizontal: 24.w,
                child: CustomText(
                  text: request.status ?? 'N/A',
                  fontSize: 10.sp,
                  color: request.status == 'approved' ? AppColors.white  : getColor(request.status ?? 'N/A'),
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
      case 'approved':
        return AppColors.primaryColor;
      default:
        return AppColors.red;
    }
  }
}
