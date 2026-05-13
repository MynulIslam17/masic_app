import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter_task/features/poll/presentation/controllers/poll_controller.dart';
import 'package:flutter_task/features/poll/presentation/widgets/option_tile.dart';
import 'package:flutter_task/features/poll/presentation/widgets/poll_simmer.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class PollResultScreen extends StatelessWidget {
  const PollResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pollId = Get.arguments as String;
    final controller = PollController.to;
    controller.fetchPollResult(pollId);
    return CustomScaffold(
      appBar: CustomAppBar(title: "Polls Answers"),
      body: Obx(() {
        final pollData = controller.pollResult;

        switch (controller.resultLoadingState) {
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
                  Divider(height: 44.h),

                  CustomText(
                    top: 6.h,
                    bottom: 20.h,
                    text: '${pollData?.totalResponses ?? 0} Responses.',
                    textAlign: TextAlign.start,
                    fontSize: 20.sp,
                    color: AppColors.primaryColor,
                  ),

                  if (pollData?.answerType == 'selector' &&
                      pollData?.options != null &&
                      pollData!.options!.isNotEmpty)
                    ...pollData.options!.asMap().entries.map(
                      (e) => OptionTile(options: e.value, isReadOnly: true,)
                    ),
                  if (pollData?.answerType == 'write-in' &&
                      pollData?.answers != null &&
                      pollData!.answers!.isNotEmpty) ...[
                    ...pollData.answers!.map(
                      (e) => CustomContainer(
                        marginBottom: 10.h,
                        paddingHorizontal: 10.w,
                        paddingVertical: 8.h,
                        radiusAll: 12.r,
                        bordersColor: AppColors.borderColor,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomNetworkImage(
                              imageUrl: e.user?.profileImage,
                              width: 40.w,
                              height: 40.h,
                              boxShape: BoxShape.circle,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(text: e.user?.name ?? ''),
                                  CustomText(text: e.answer ?? '',fontSize: 10.sp,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 32.h),
                ],
              ),
            );
        }
      }),

      bottomNavigationBar: SafeArea(child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 10.h),
            child: CustomButton(
              bordersColor: AppColors.errorColor,
              foregroundColor: AppColors.errorColor,
              backgroundColor: Colors.transparent,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Obx(() {
                      return CustomDialog(
                        title: "Delete Poll",
                        rightButtonLabel: 'Yes, Delete',
                        isLoading: controller.deleteLoadingState.isLoading,
                        onTapLeftButton: () => Get.back(),
                        onTapRightButton: () => controller.deletePoll(pollId),
                        description:
                        'Are you sure want to delete your Poll?',
                      );
                    }
                  ),
                );

              },label: 'Delete',),
          ))

    );
  }
}
