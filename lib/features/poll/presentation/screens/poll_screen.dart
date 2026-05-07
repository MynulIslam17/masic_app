import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/poll/presentation/controllers/poll_controller.dart';
import 'package:flutter_task/features/poll/presentation/widgets/option_tile.dart';
import 'package:flutter_task/features/poll/presentation/widgets/poll_simmer.dart';
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
      body: Obx(() {
        final pollData = controller.pollDetails;

        switch (controller.detailsLoadingState) {
          case LoadingState.initial:
          case LoadingState.loading:
            return PollShimmer();

          case LoadingState.offline:
          case LoadingState.error:
            return EmptyDataWidget(
              message: 'Failed to load poll details. Please try again.',
              onRefresh: () async => await controller.fetchPollDetails(pollId),
            );

          case LoadingState.loaded:
            if (pollData?.answerType == 'selector' &&
                pollData?.answered == true &&
                pollData?.myAnswer?.optionId != null) {
              controller.initSelectedOption(pollData!.myAnswer!.optionId!);
            }

            if (pollData?.answerType == 'write-in' &&
                pollData?.answered == true &&
                pollData?.answer != null) {
              controller.initWriteInAnswer(pollData!.answer!);
            }

            final bool alreadyAnswered = pollData?.answered ?? false;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // ── Poll title ──────────────────────────────────────────
                  CustomText(
                    text: pollData?.title ?? '',
                    fontSize: 16.sp,
                    bottom: 6.h,
                    fontWeight: FontWeight.w500,
                  ),

                  // ── Tagline ─────────────────────────────────────────────
                  CustomText(
                    textAlign: TextAlign.start,
                    color: AppColors.primaryColor,
                    fontSize: 12.sp,
                    text: pollData?.tagline ?? '',
                  ),

                  // ── "Already answered" badge ────────────────────────────
                  if (alreadyAnswered) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14.sp,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: 4.w),
                          CustomText(
                            text: 'Already answered',
                            fontSize: 11.sp,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],

                  Divider(height: 44.h),

                  if (pollData?.answerType == 'selector' &&
                      pollData?.options != null &&
                      pollData!.options!.isNotEmpty)
                    ...pollData.options!.asMap().entries.map(
                      (e) => OptionTile(
                        isReadOnly: alreadyAnswered,
                        options: e.value,
                      ),
                    ),

                  if (pollData?.answerType == 'write-in') ...[
                    CustomTextField(
                      validator: (_) => null,
                      showShadow: !alreadyAnswered,
                      controller: controller.answerController,
                      hintText: 'Write your answer here',
                      minLines: 5,
                      enabled: !alreadyAnswered,
                    ),
                    SizedBox(height: 24.h),

                    if (!alreadyAnswered)
                      CustomButton(
                        isLoading: controller.writeInLoadingState.isLoading,
                        onPressed: () {
                          controller.pollAnswer();
                        },
                        label: 'Submit',
                      ),

                    if (alreadyAnswered)
                      CustomText(
                        text: 'You have already submitted your answer.',
                        fontSize: 12.sp,
                        color: AppColors.primaryColor,
                        textAlign: TextAlign.center,
                      ),
                  ],

                  SizedBox(height: 32.h),
                ],
              ),
            );
        }
      }),
    );
  }
}
