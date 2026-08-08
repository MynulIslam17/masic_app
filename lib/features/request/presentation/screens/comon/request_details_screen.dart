import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/presentation/widgets/info_row.dart';
import 'package:masic_generation/features/request/presentation/controllers/request_controller.dart';
import 'package:masic_generation/features/request/presentation/widgets/details_bottom_nav.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requestId = Get.arguments as String;
    final controller = RequestController.to;
    return CustomScaffold(
      appBar: CustomAppBar(
        title: "Details",
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(
                AppRoutes.requestPdfPreviewScreen,
                arguments: requestId,
              );
            },
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: Obx(() {
        final request = controller.requests.firstWhereOrNull(
          (e) => e.sId == requestId,
        );
        if (request == null) {
          return const Center(child: Text('Request not found'));
        }
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CustomNetworkImage(
                  border: Border.all(color: AppColors.primaryColor, width: 4.w),
                  boxShape: BoxShape.circle,
                  height: 100.r,
                  width: 100.r,
                  imageUrl: request.user?.profileImage,
                ),
              ),

              if (request.declineReason != null)
                CustomContainer(
                  marginTop: 24.h,
                  radiusAll: 10.r,
                  paddingHorizontal: 16.w,
                  paddingVertical: 10.h,
                  color: AppColors.errorColor.withValues(alpha: 0.1),
                  width: double.infinity,
                  border: Border(
                    left: BorderSide(color: AppColors.errorColor, width: 5.w),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.errorColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'DECLINE REASON',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.errorColor,
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              text: request.declineReason!,
                              fontSize: 13.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 24.h),
              _buildCard(
                children: [
                  InfoRow(label: 'Name', value: request.user?.name ?? 'N/A'),
                  if (request.user?.arabicName != null && request.user!.arabicName!.isNotEmpty)
                    InfoRow(label: 'Arabic Name', value: request.user!.arabicName),
                  InfoRow(
                    label: 'Email',
                    value: request.contact?.email ?? 'N/A',
                  ),
                  InfoRow(
                    label: 'Phone no',
                    value: request.contact?.phone ?? 'N/A',
                  ),
                  InfoRow(
                    label: 'Address',
                    value: request.contact?.address ?? 'N/A',
                  ),
                ],
              ),

              if (request.bio != null)
                _buildCard(
                  label: 'Applicants short Bio :',
                  children: [
                    CustomText(
                      fontSize: 12.sp,
                      textAlign: TextAlign.start,
                      text: request.bio ?? 'N/A',
                    ),
                  ],
                ),

              if (request.jobSpec != null)
                _buildCard(
                  label: 'Job specialization :',
                  children: [
                    CustomText(
                      fontSize: 12.sp,
                      textAlign: TextAlign.start,
                      text: request.jobSpec ?? 'N/A',
                    ),
                  ],
                ),

              if (request.contact != null)
                _buildCard(
                  label: 'Contact Info :',
                  children: [
                    InfoRow(
                      label: 'Phone no',
                      value: request.contact?.phone ?? 'N/A',
                    ),
                    InfoRow(
                      label: 'Email',
                      value: request.contact?.email ?? 'N/A',
                    ),
                    if (request.contact?.linkedin != null)
                      InfoRow(
                        label: 'Linkedin',
                        valueWidget: CustomButton(
                          height: 24.h,
                          onPressed: () async {
                            final Uri url = Uri.parse(
                              request.contact?.linkedin ?? '',
                            );

                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          fontSize: 12.sp,
                          label:
                              request.contact?.linkedin?.split('/').last ?? '',
                        ),
                      ),
                  ],
                ),

              if (request.education != null) ...[
                CustomText(
                  text: 'Education :',
                  textAlign: TextAlign.start,
                  bottom: 10.h,
                ),
                ...request.education!.map(
                  (e) => _buildCard(
                    children: [
                      InfoRow(label: 'University', value: e.school ?? 'N/A'),
                      InfoRow(label: 'Degree type', value: e.degree ?? 'N/A'),
                      InfoRow(label: 'Major', value: e.major ?? 'N/A'),
                      InfoRow(
                        label: 'From',
                        value: TimeFormatHelper.formatDateTime(e.from ?? 'N/A'),
                      ),
                      InfoRow(
                        label: 'To',
                        value: e.isCurrent == true
                            ? 'Ongoing'
                            : TimeFormatHelper.formatDateTime(e.to ?? 'N/A'),
                      ),
                    ],
                  ),
                ),
              ],

              if (request.experience != null) ...[
                CustomText(
                  text: 'Experience :',
                  textAlign: TextAlign.start,
                  bottom: 10.h,
                ),
                ...request.experience!.map(
                  (e) => _buildCard(
                    children: [
                      InfoRow(label: 'Company name', value: e.company ?? 'N/A'),
                      InfoRow(
                        label: 'Position title',
                        value: e.position ?? 'N/A',
                      ),
                      InfoRow(
                        label: 'From',
                        value: TimeFormatHelper.formatDateTime(e.from ?? 'N/A'),
                      ),
                      InfoRow(
                        label: 'To',
                        value: e.isCurrent == true
                            ? 'Ongoing'
                            : TimeFormatHelper.formatDateTime(e.to ?? 'N/A'),
                      ),
                    ],
                  ),
                ),
              ],

              if (request.cvUrl != null && request.certificateUrl != null)
                _buildCard(
                  label: 'Documents :',
                  children: [
                    if (request.cvUrl != null)
                      InfoRow(
                        label: 'CV',
                        valueWidget: CustomButton(
                          height: 24.h,
                          onPressed: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return CustomContainer(
                                  paddingAll: 16.r,
                                  child: CustomNetworkImage(
                                    borderRadius: 10.r,
                                    imageUrl: request.cvUrl,
                                    height: 500.h,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            );
                          },

                          fontSize: 12.sp,
                          label: request.cvUrl?.split('/').last ?? '',
                        ),
                      ),
                    if (request.certificateUrl != null)
                      InfoRow(
                        label: 'certificate',
                        valueWidget: CustomButton(
                          height: 24.h,
                          onPressed: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return CustomContainer(
                                  paddingAll: 16.r,
                                  child: CustomNetworkImage(
                                    borderRadius: 10.r,
                                    imageUrl: request.certificateUrl,
                                    height: 500.h,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            );
                          },
                          fontSize: 12.sp,
                          label: request.certificateUrl?.split('/').last ?? '',
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      }),

      bottomNavigationBar: DetailsBottomNav(requestId: requestId),
    );
  }

  Widget _buildCard({String? label, required List<Widget>? children}) {
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
          if (label != null) ...[
            CustomText(textAlign: TextAlign.start, text: label),
            SizedBox(height: 12.h),
          ],

          ...children ?? [],
        ],
      ),
    );
  }
}

