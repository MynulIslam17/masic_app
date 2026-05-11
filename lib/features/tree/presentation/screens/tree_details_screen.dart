import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/helpers/time_format.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
import 'package:flutter_task/features/tree/presentation/widgets/user_details_simmer.dart';
import 'package:get/get.dart';

class TreeDetailsScreen extends StatefulWidget {
  const TreeDetailsScreen({super.key});

  @override
  State<TreeDetailsScreen> createState() => _TreeDetailsScreenState();
}

class _TreeDetailsScreenState extends State<TreeDetailsScreen> {
  final String userId = Get.arguments as String;

  final controller = TreeController.to;

  @override
  void initState() {
    super.initState();
    controller.fetchUserDetails(userId);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Profile Information'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Obx(() {
          final user = controller.userDetails;
          switch (controller.detailsLoadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return UserDetailsShimmer();

            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Failed to load data. Please try again.',
                onRefresh: () async =>
                    await controller.fetchUserDetails(userId),
              );

            case LoadingState.loaded:
              return Column(
                children: [
                  SizedBox(height: 8.h),
                  CustomNetworkImage(
                    boxShape: BoxShape.circle,
                    height: 80.r,
                    width: 80.r,
                    fallbackAsset: Assets.images.profile.image(),
                    imageUrl: user?.profileImage,
                  ),
                  SizedBox(height: 24.h),
                  CustomContainer(
                    paddingAll: 16.r,
                    color: AppColors.bgColor,
                    bordersColor: AppColors.borderColor,
                    radiusAll: 12.r,
                    child: Column(
                      spacing: 16.h,
                      children: [
                        _buildInfoRow(
                          label: 'Name',
                          value: user?.name ?? 'N/A',
                        ),
                        _buildInfoRow(
                          label: 'Email',
                          value: user?.email ?? 'N/A',
                        ),
                        _buildInfoRow(
                          label: 'Phone no',
                          value: user?.spousePhone ?? 'N/A',
                        ),
                        _buildInfoRow(
                          label: 'Date of birth',
                          value: TimeFormatHelper.formatDateTime(
                            user?.dateOfBirth ?? '',
                          ),
                        ),
                        _buildInfoRow(
                          label: 'Gender',
                          value: user?.gender ?? 'N/A',
                        ),
                        _buildInfoRow(
                          label: 'Employment status',
                          value: user?.employmentStatus ?? 'N/A',
                        ),
                        _buildInfoRow(
                          label: 'Education',
                          value: user?.education ?? 'N/A',
                        ),
                        _buildInfoRow(
                          label: 'University name',
                          value: user?.universityName ?? 'N/A',
                        ),
                        _buildInfoRow(
                          label: 'Field of work',
                          value: user?.fieldOfWork ?? 'N/A',
                        ),
                        _buildInfoRow(
                          label: 'Spouse name',
                          value: user?.spouseName ?? 'N/A',
                        ),
                        //_buildInfoRow(label: 'Spouse number',     value: user?.spousePhone     ?? 'N/A'),
                        _buildInfoRow(
                          label: 'Linkedin link',
                          value: user?.linkedinLink ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              );
          }
        }),
      ),
    );
  }

  // ── Row Helpers ────────────────────────────────────────────────────────────
  Widget _buildInfoRow({
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100.w,
          child: CustomText(
            text: label,
            fontSize: 12.sp,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(width: 24.w),
        CustomText(text: ':', fontSize: 12.sp),
        SizedBox(width: 32.w),
        Expanded(
          child:
              valueWidget ??
              CustomText(
                enableAutoTranslate: false,
                text: value ?? '',
                fontSize: 12.sp,
                textAlign: TextAlign.start,
              ),
        ),
      ],
    );
  }
}
