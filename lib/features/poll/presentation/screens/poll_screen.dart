import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/poll/data/models/poll_details_model.dart';
import 'package:flutter_task/features/poll/presentation/controllers/poll_controller.dart';
import 'package:get/get.dart';

class PollScreen extends StatelessWidget {
  const PollScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final pollId = Get.arguments as String;
    final controller = PollController.to;
    controller.fetchPollDetails(pollId);
    return CustomScaffold(
      appBar: CustomAppBar(title: "Polls Answers"),
      body: Obx(
        () {
          final pollData = controller.pollDetails;

          switch (controller.detailsLoadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return Center(child: CustomLoader());

            case LoadingState.offline:
            case LoadingState.error:
              return CustomText(text: '');
            case LoadingState.loaded:
                return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  CustomText(text: pollData?.title ?? '',fontSize: 16.sp,bottom: 6.h,fontWeight: FontWeight.w500,),
                  CustomText(
                    textAlign: TextAlign.start,
                    color: AppColors.primaryColor,
                    fontSize: 12.sp,
                    text:  pollData?.tagline ?? ''),
                  Divider(height: 44.h,),
                  if(pollData?.options != null && pollData?.options!.isNotEmpty == true)
                    ...pollData!.options!.asMap().entries.map((e) => _buildOption(e.key, e.value)),
                ],
              );
          }

        }
      ),
    );
  }

  Widget _buildOption(int index, Options opt) {
    final isSelected = true;
    final selected = true;
    return Stack(
      children: [
        if (selected)
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: opt.percentage?.toDouble() ?? 0,
              child: CustomContainer(
                marginBottom: 10.h,
                color: AppColors.primaryColor.withOpacity(0.1),
                radiusAll: 12.r,
              ),
            ),
          ),
        CustomContainer(
          onTap: (){
            // if(selected) return;
            // setState(() {
            //   _selected = index;
            // });

          },
          marginBottom: 10.h,
          paddingHorizontal: 16.w,
          paddingVertical: 12.h,
          radiusAll: 12.r,
          bordersColor: isSelected ? AppColors.primaryColor : AppColors.colorB0B0B0,
          child: Row(
            children: [
              CustomContainer(
                shape: BoxShape.circle,
                bordersColor: isSelected ? AppColors.primaryColor : AppColors.colorB0B0B0,
                child: CustomContainer(
                  marginAll: 4.r,
                  shape: BoxShape.circle,
                  width: 20.w,
                  height: 20.h,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: Offset(0, 1),
                    ),

                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w,),
              Expanded(child: CustomText(
                textAlign: TextAlign.start,
                text: opt.text ?? '',fontSize: 14.sp,fontWeight: FontWeight.w500,)),
              if(selected)
              CustomText(text: '${opt.percentage.toString()}%',fontSize: 14.sp,fontWeight: FontWeight.w500,),
              ]),
        ),
      ],
    );
  }
}