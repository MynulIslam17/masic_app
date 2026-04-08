import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/helpers/helper_data.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final TextEditingController _announcementTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Announcements'),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          children: [
            CustomTextField(
              validator: (_) => null,
              prefixIcon: Assets.icons.search.svg(),
              borderRadio: 100.r,
              borderColor: AppColors.colorE6E6E6,
              showShadow: false,
              controller: _announcementTEController,
              hintText: 'Search here . . .',
            ),

            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    textAlign: TextAlign.start,
                    fontSize: 12.sp,
                    text: 'Total events : ${HelperData.announcements.length}',
                  ),
                ),
                CustomButton(
                  height: 38.h,
                  elevation: true,
                  borderWidth: 3,
                  bordersColor: Color(0xffB0B0B0),
                  foregroundColor: AppColors.primaryColor,
                  backgroundColor: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  width: 174.w,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CustomDialog(
                        title: "Select announcement type",
                        rightButtonLabel: 'For all',
                        leftButtonLabel: 'Group',
                        leftButtonBgColor: AppColors.primaryColor,
                        leftButtonLabelColor: Colors.white,
                        rightButtonLabelColor: AppColors.primaryColor,
                        titleColor: AppColors.primaryColor,
                        onTapLeftButton: () {
                          Get.back();
                          Get.toNamed(AppRoutes.memberSelectScreen);
                        },
                        onTapRightButton: () {
                          Get.back();
                         Get.toNamed(AppRoutes.createAnnouncementsScreen);
                        },
                        description:
                        'Please select one which type of announcement you want to upload',
                      ),
                    );
                  },
                  label: 'Create announcements',
                ),
              ],
            ),

            /// ============ > Events List < ============
            SizedBox(height: 24.h),
            ListView.builder(
              itemCount: HelperData.announcements.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = HelperData.announcements[index];
                return _buildAnnouncementCard(
                  imageUrl: item['imageUrl'],
                  title: item['title'],
                  description: item['description'],
                  status: item['status'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard({
    String? imageUrl,
    String? title,
    String? description,
    String? status,
  }) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                textAlign: TextAlign.start,
                text: status ??  'N/A',
                fontSize: 12.sp,
                color: AppColors.primaryColor,
              ),
            ],
          ),

          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            SizedBox(height: 12.h),
            CustomNetworkImage(
              borderRadius: 12.r,
              height: 152.h,
              width: double.infinity,
              imageUrl: imageUrl ?? '',
            ),
          ],

          CustomText(
            top: 10.h,
            textAlign: TextAlign.start,
            text: title ?? 'N/A',
            fontSize: 16.sp,
          ),

          CustomText(
            top: 12.h,
            textAlign: TextAlign.start,
            maxline: 3,
            text:
                description ??
                'N/A',
            fontSize: 10.sp,
          ),

          SizedBox(height: 12.h),
          CustomButton(
            onPressed: () {
             Get.toNamed(AppRoutes.announcementsDetailsScreen);
            },
            bordersColor: AppColors.primaryColor,
            foregroundColor: AppColors.primaryColor,
            backgroundColor: Colors.white,
            fontSize: 12.sp,
            height: 38.h,
            fontWeight: FontWeight.w400,
            label: 'View details',
          ),
        ],
      ),
    );
  }
}
