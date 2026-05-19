import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/request/data/models/request_local_model.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';

class RequestWidget extends StatelessWidget {
  const RequestWidget({super.key, required this.request});

  final RequestLocalModel request;

  @override
  Widget build(BuildContext context) {
    final controller = RequestController.to;
    return CustomContainer(
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
            text: request.title ?? 'Request for opportunities',
            fontSize: 16.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 12.h),
          CustomText(
            maxline: 2,
            text:
                request.description ??
                'Submit requests for jobs, volunteering opportunities, workshops',
            fontSize: 10.sp,
          ),
          SizedBox(height: 14.h),

          CustomButton(
            height: 38.h,
            fontSize: 12.sp,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Obx(() {
                  return Stack(
                    children: [
                      AlertDialog(
                        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
                        title: CustomText(
                          fontWeight: FontWeight.w600,
                          text: 'Select request',
                          fontSize: 20.sp,
                          color: AppColors.primaryColor,
                        ),
                        content: CustomText(
                          text:
                              'Before request you need to select your which data you are used.',
                        ),

                        actions: [
                          CustomButton(
                            label: 'Request by profile data',
                            onPressed: () {
                              Get.back();
                              Get.toNamed(AppRoutes.jobSpecificationScreen,arguments: request.type);
                            },
                          ),
                          SizedBox(height: 10.h),

                          CustomButton(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.primaryColor,
                            bordersColor: AppColors.primaryColor,
                            label: 'Request manually',
                            onPressed: () {
                              Get.back();
                              Get.toNamed(AppRoutes.jobSpecificationScreen);
                            },
                          ),
                        ],
                      ),

                      if (controller.createState.isLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              );
            },
            label: 'Request',
          ),
        ],
      ),
    );
  }
}
