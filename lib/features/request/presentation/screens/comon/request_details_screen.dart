import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter_task/features/profile/presentation/widgets/info_row.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requestId = Get.arguments as String;
    final controller = RequestController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: "Details"),
      body: Obx(() {
        final request = controller.requests.firstWhereOrNull(
          (e) => e.sId == requestId,
        );
        if (request == null) {
          return const Center(child: Text('Request not found'));
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              CustomNetworkImage(
                border: Border.all(color: AppColors.primaryColor, width: 4.w),
                boxShape: BoxShape.circle,
                height: 80.r,
                width: 80.r,
                imageUrl: request.user?.profileImage,
              ),

              SizedBox(height: 12.h),
              _buildCard(
                label: 'Contact Information',
                children: [
                  InfoRow(label: 'Phone no', value: request.contact?.phone ?? 'N/A'),
                  InfoRow(label: 'Email', value: request.contact?.email ?? 'N/A'),
                ]
              ),


              if(request.bio != null)
              _buildCard(
                label: 'Applicants short Bio :',
                children: [
                  CustomText(
                      fontSize: 12.sp,
                      textAlign: TextAlign.start,
                      text: request.bio ?? 'N/A'),
                ]
              ),

              if(request.jobSpec != null)
              _buildCard(
                label: 'Job specialization :',
                children: [
                  CustomText(
                      fontSize: 12.sp,
                      textAlign: TextAlign.start,
                      text: request.jobSpec ?? 'N/A'),
                ]
              ),


              if(request.contact != null)
              _buildCard(
                label: 'Contact Info :',
                children: [
                  InfoRow(label: 'Phone no', value: request.contact?.phone ?? 'N/A'),
                  InfoRow(label: 'Email', value: request.contact?.email ?? 'N/A'),
                  InfoRow(label: 'Linkedin', value: request.contact?.linkedin ?? 'N/A'),
                ]
              ),
            ],
          ),
        );
      }),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(() {
            final request = controller.requests.firstWhereOrNull(
              (e) => e.sId == requestId,
            );
            if (request == null) return const SizedBox.shrink();
            final status = request.status ?? '';
            final isAdmin = AuthController.to.isAdmin();
            if (isAdmin && status == 'pending') {
              return Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Obx(() {
                            return CustomDialog(
                              title: "Approve Announcements",
                              titleColor: AppColors.primaryColor,
                              rightButtonLabel: 'Yes, Approve',
                              rightButtonBgColor: AppColors.primaryColor,
                              rightButtonLabelColor: Colors.white,
                              onTapLeftButton: () => Get.back(),
                              onTapRightButton: () {},
                              description:
                                  'Are you sure want to approve your Announcements?',
                            );
                          }),
                        );
                      },
                      label: 'Approved',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      bordersColor: AppColors.errorColor,
                      foregroundColor: AppColors.errorColor,
                      backgroundColor: AppColors.bgColor,
                      label: 'Rejected',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => CustomDialog(
                            title: "Reject Announcements",
                            rightButtonLabel: 'Yes, Reject',
                            onTapLeftButton: () => Get.back(),
                            onTapRightButton: () {},
                            description:
                                'Are you sure want to reject your Announcements?',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ),
      ),
    );
  }


  Widget _buildCard({required String label, required List<Widget>? children}) {
    return CustomContainer(
      width: double.infinity,
      marginBottom: 16.h,
      paddingVertical: 10.h,
      paddingHorizontal: 16.w,
      color: AppColors.bgColor,
      bordersColor: AppColors.borderColor,
      radiusAll: 12.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textAlign: TextAlign.start,
            text: label,
          ),
          SizedBox(height: 12.h),
          ...children ?? []
        ],
      )
    );
  }
}
