import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/core/widgets/localized_name_text.dart';
import 'package:masic_generation/features/poll/data/models/poll_details_model.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:get/get.dart';

class PollResponseList extends StatelessWidget {
  final PollDetailsModel pollData;

  const PollResponseList({super.key, required this.pollData});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      TranslationController.to.currentLanguage.value;
      return _buildList(context);
    });
  }

  Widget _buildList(BuildContext context) {
    if (pollData.responses == null || pollData.responses!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 44.h),
        CustomText(
          text: 'User Responses',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          bottom: 16.h,
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pollData.responses!.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final response = pollData.responses![index];
            final user = response.user;
            
            String answerText = '';
            if (pollData.answerType == 'selector') {
              final option = pollData.options?.firstWhere(
                (opt) => opt.id == response.optionId,
                orElse: () => PollOption(text: 'Unknown option'),
              );
              answerText = option?.text ?? '';
            } else if (pollData.answerType == 'write-in') {
              answerText = response.answer ?? '';
            }

            return CustomContainer(
              color: AppColors.white,
              paddingAll: 12.r,
              radiusAll: 12.r,
              borderWidth: 1,
              bordersColor: AppColors.colorD9D9D9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomNetworkImage(
                    boxShape: BoxShape.circle,
                    height: 40.r,
                    width: 40.r,
                    imageUrl: user?.profileImage,
                    fallbackAsset: Assets.images.profile.image(),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: user != null
                                  ? LocalizedNameText(
                                      name: user.name,
                                      arabicName: user.arabicName,
                                      fallback: 'Anonymous User',
                                      textAlign: TextAlign.start,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    )
                                  : CustomText(
                                      textAlign: TextAlign.start,
                                      text: 'Anonymous User',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      enableAutoTranslate: false,
                                    ),
                            ),
                            if (response.answeredAt != null)
                              CustomText(
                                text: TimeFormatHelper.formatDate(
                                  DateTime.parse(response.answeredAt!),
                                ),
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          textAlign: TextAlign.start,
                          text: answerText,
                          fontSize: 12.sp,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
