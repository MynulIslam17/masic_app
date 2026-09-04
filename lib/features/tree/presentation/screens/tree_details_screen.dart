import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/tree/presentation/controllers/tree_controller.dart';
import 'package:masic_generation/features/tree/presentation/widgets/user_details_simmer.dart';
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
                        if (user?.name != null && user!.name!.isNotEmpty)
                          _buildInfoRow(label: 'Name', value: user.name, translateValue: false),
                        // if (user?.arabicName != null && user!.arabicName!.isNotEmpty)
                        //   _buildInfoRow(label: 'Arabic Name', value: user.arabicName, translateValue: false),
                        if (user?.email != null && user!.email!.isNotEmpty)
                          _buildInfoRow(label: 'Email', value: user.email, translateValue: false),
                        if (user?.phone != null && user!.phone!.isNotEmpty)
                          _buildInfoRow(label: 'Phone no', value: user.phone, translateValue: true),
                        if (user?.gender != null && user!.gender!.isNotEmpty)
                          _buildInfoRow(label: 'Gender', value: user.gender, translateValue: true),
                        if (user?.employmentStatus != null &&
                            user!.employmentStatus!.isNotEmpty)
                          _buildInfoRow(
                            label: 'Employment status',
                            value: user!.employmentStatus,
                            translateValue: true,
                          ),
                        if (user?.education != null &&
                            user!.education!.isNotEmpty)
                          _buildInfoRow(
                            label: 'Education',
                            value: user!.education,
                            translateValue: true,
                          ),
                        if (user?.universityName != null &&
                            user!.universityName!.isNotEmpty)
                          _buildInfoRow(
                            label: 'University name',
                            value: user!.universityName,
                            translateValue: false,
                          ),
                        if (user?.fieldOfWork != null &&
                            user!.fieldOfWork!.isNotEmpty)
                          _buildInfoRow(
                            label: 'Field of work',
                            value: user!.fieldOfWork,
                            translateValue: true,
                          ),
                        if (user?.spouseName != null &&
                            user!.spouseName!.isNotEmpty)
                          _buildInfoRow(
                            label: 'Spouse name',
                            value: user!.spouseName,
                            translateValue: false,
                          ),
                        if (user?.contact?.linkedin != null &&
                            user!.contact!.linkedin!.isNotEmpty)
                          _buildInfoRow(
                            label: 'Linkedin link',
                            value: user!.contact!.linkedin,
                            translateValue: false,
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
    bool translateValue = false,
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
                enableAutoTranslate: translateValue,
                text: value ?? '',
                fontSize: 12.sp,
                textAlign: TextAlign.start,
              ),
        ),
      ],
    );
  }
}
