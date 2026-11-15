import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/features/profile/presentation/widgets/info_row.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
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
          TranslationController.to.currentLanguage.value;
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
                      children: [
                        if (user != null &&
                            ((user.name?.isNotEmpty ?? false) ||
                                (user.arabicName?.isNotEmpty ?? false)))
                          InfoRow.personName(
                            label: 'Name',
                            name: user.name,
                            arabicName: user.arabicName,
                          ),
                        if (user?.email != null &&
                            user!.email!.isNotEmpty &&
                            !user.hideEmailOnProfile)
                          InfoRow(
                            label: 'Email',
                            value: user.email,
                            copyable: true,
                          ),
                        if (user?.phone != null && user!.phone!.isNotEmpty)
                          InfoRow(
                            label: 'Phone no',
                            value: user.phone,
                            copyable: true,
                          ),
                        if (user?.gender != null && user!.gender!.isNotEmpty)
                          InfoRow(
                            label: 'Gender',
                            value: user.gender,
                            translateValue: true,
                          ),
                        if (user?.employmentStatus != null &&
                            user!.employmentStatus!.isNotEmpty)
                          InfoRow(
                            label: 'Employment status',
                            value: user.employmentStatus,
                            translateValue: true,
                          ),
                        if (user?.education != null &&
                            user!.education!.isNotEmpty)
                          InfoRow(
                            label: 'Education',
                            value: user.education,
                            translateValue: true,
                          ),
                        if (user?.universityName != null &&
                            user!.universityName!.isNotEmpty)
                          InfoRow(
                            label: 'University name',
                            value: user.universityName,
                          ),
                        if (user?.fieldOfWork != null &&
                            user!.fieldOfWork!.isNotEmpty)
                          InfoRow(
                            label: 'Field of work',
                            value: user.fieldOfWork,
                            translateValue: true,
                          ),
                        if (user?.spouseName != null &&
                            user!.spouseName!.isNotEmpty)
                          InfoRow(
                            label: 'Spouse name',
                            value: user.spouseName,
                          ),
                        if (user?.spousePhone != null &&
                            user!.spousePhone!.isNotEmpty)
                          InfoRow(
                            label: 'Spouse number',
                            value: user.spousePhone,
                            copyable: true,
                          ),
                        if ((user?.resolvedLinkedIn?.isNotEmpty ?? false) ||
                            (user?.linkedinLink?.isNotEmpty ?? false))
                          InfoRow.linkedIn(
                            url: (user?.resolvedLinkedIn?.isNotEmpty ?? false)
                                ? user!.resolvedLinkedIn!
                                : user!.linkedinLink!,
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
}
